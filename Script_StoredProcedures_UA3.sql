
-- Enregistrer un emprunt de livre en vérifiant la quantité disponible et l'éligibilité
CREATE OR ALTER PROCEDURE sp_EnregistrerEmprunt
@membreid INT, -- Argument représentant l'id d'un membre
@livreid INT, -- Argument représentant l'id d'un livre
@datempr DATE, -- Argument représentant la date d'emprunt d'un livre
@dateret DATE -- Argument représentant la date fixée pour le retour du livre emprunter
AS
BEGIN
	-- Récupération de la quantité du livre disponible dans une variable
	DECLARE @qte INT; 
	SELECT @qte = Qte_dispo FROM Livre WHERE Id_livre = @livreid;

	-- Récupération du statut du membre dans une variable
	DECLARE @membrestatut VARCHAR(15);
	SELECT @membrestatut = Statut_M FROM Membre WHERE Id_membre = @membreid;

	-- Récupération de la limite d'emprunt d'un membre dans une variable
	DECLARE @limitemprunt INT, @typemembre VARCHAR(20);
	SELECT @limitemprunt = Limite_emprunt, @typemembre = Type_M FROM Membre WHERE Id_membre = @membreid;

	IF (@qte=0 OR @membrestatut!='Actif' OR @limitemprunt=0) -- Check s'il la quantité est suffisante pour un emprunt
		Begin
			PRINT 'Désolé, Impossible d effectué un emprunt!!!'; -- Message en cas d'emprunt impossible
		End;
	ELSE -- Cas où l'emprunt est possible
		Begin
			-- Enregistrement de l'emprunt dans la table
			INSERT INTO Emprunt(MemberID,LivreID,Date_emprunt,Date_retour)
				VALUES (@membreid,@livreid,@datempr,@dateret);

			-- Mise à jour de la limite d'emprunt du membre
			UPDATE Membre
				SET Limite_emprunt = Limite_emprunt - 1
			WHERE Id_membre = @membreid;

			-- Mise à jour de la quantité disponible du livre
			UPDATE Livre
				SET Qte_dispo = Qte_dispo - 1
			WHERE Id_livre = @livreid;

			-- Message de validation de l'opération
			PRINT 'Enregistrement de l emprunt du livre éffectué avec succès pour un '+@typemembre;
			PRINT 'La limite d emprunt pour le membre '+CAST(@membreid AS VARCHAR)+' a été mise à jour.';
			PRINT 'La quantitée d exemplaire du livre '+CAST(@livreid AS VARCHAR)+' a été mise à jour';
		End;
END;

go

-- Retourner un livre et calculer automatiquement l'amende s'il y'a un retard
CREATE OR ALTER PROCEDURE sp_RetournerLivre
    @empruntID INT, -- Argument représentant l'id de l'emprunt effectué
	@membreid INT, -- Argument représentant l'id d'un membre
	@livreid INT -- Argument représentant l'id d'un livre
AS
BEGIN
    DECLARE @montant DECIMAL(10, 2); -- Variable pour stocker le montant de l'amende
     -- Check si les id du membre et du livre existe dans la base de donnée
	IF @livreid IN (SELECT Id_livre FROM Livre) AND @membreid IN (SELECT Id_membre FROM Membre)
	begin -- Existence confirmée
		-- Mise à jour du statut de l'emprunt et calcul de l'amende
		UPDATE Emprunt
		SET @montant = DATEDIFF(DAY, Date_retour, GETDATE()) * 0.50,
			Statut_E = CASE 
						WHEN DATEDIFF(DAY, Date_retour, GETDATE()) > 0 THEN 'En retard'
						ELSE 'Rendu à temps'
					 END
		WHERE Id_emprunt = @empruntID;

		-- Mise à jour de la quantité disponible du livre
		UPDATE Livre
			SET Qte_dispo = Qte_dispo + 1
		WHERE Id_livre = @livreid;

		-- Mise à jour de la limite d'emprunt du membre
		UPDATE Membre
			SET Limite_emprunt = Limite_emprunt + 1
		WHERE Id_membre = @membreid;

		IF @montant > 0 -- Si le retour est en retard, calcul et affichage de l'amende
		Begin
			-- Enregistrement de l'amende dans la table Amende
			INSERT INTO Amende (EmpruntID, Montant, Statut_A)
				VALUES (@empruntID, @montant, 'Impayée');
			PRINT 'Ce livre a été rendu en retard et la pénalité est de: ' + CAST(@montant AS VARCHAR) + '$';
		End;
		ELSE -- Affichage classique si aucun retard
			PRINT 'Retour du livre enregistré avec succès, Aucune pénalité';

		PRINT 'La limite d emprunt pour le membre '+CAST(@membreid AS VARCHAR)+' a été mise à jour.';
		PRINT 'La quantitée d exemplaire du livre '+CAST(@livreid AS VARCHAR)+' a été mise à jour';
	End;
	ELSE -- Existence non confirmée
		Begin
			PRINT 'Identifiant(s) incorrect(s)!!!!';
		End;
END;

go

-- Rapport des emprunts non rendus à temps
CREATE OR ALTER PROCEDURE sp_RapportEmpruntsRetard
AS
BEGIN
	-- Récupération des informations des emprunts uniquement en retard
	SELECT e.Id_emprunt, CONCAT(m.Nom , ' ' , m.Prenom) AS Membres, l.Titre AS Livre,
		e.Date_emprunt, e.Date_retour, DATEDIFF(DAY, e.Date_retour, GETDATE()) AS JoursRetards
		FROM Emprunt e
		JOIN Membre m ON e.MemberID = m.Id_membre
		JOIN Livre l ON l.Id_livre = e.LivreID
		WHERE e.Statut_E = 'En retard';
END;


GO


-- Mettre à jour le statut d'un membre
CREATE OR ALTER PROCEDURE sp_MettreAJourStatutsMembres
AS
BEGIN
    DECLARE @membreID INT;

	-- Conception du curseur
    DECLARE membrecurseur CURSOR FOR
    SELECT Id_membre FROM Membre;

    OPEN membrecurseur;
    FETCH NEXT FROM membrecurseur INTO @membreID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
		-- Mise à jour pour suspendre un membre s'il a une amende impayée
        UPDATE Membre
		-- Compter le nombre d'amende par membre pour chaque emprunt qu'il a effectuer et dont il a écopé d'une amende
        SET Statut_M = CASE 
                        WHEN (SELECT COUNT(*) FROM Amende WHERE EmpruntID IN
						(SELECT Id_emprunt FROM Emprunt WHERE MemberID = @membreID) AND Statut_A = 'Impayée') > 0 THEN 'Suspendu'
                        ELSE 'Actif'
                     END
        WHERE Id_membre = @membreID;

        FETCH NEXT FROM membrecurseur INTO @membreID;
    END

    CLOSE membrecurseur;
    DEALLOCATE membrecurseur;
END;