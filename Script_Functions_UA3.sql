
-- Fonction de calcul de l'amende total d'un un membre entré en paramètre
CREATE OR ALTER FUNCTION fn_CalculerAmendesMembre(@membreID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @totalAmende DECIMAL(10, 2);

    SELECT @totalAmende = SUM(Montant) FROM Amende a
    JOIN Emprunt e ON a.EmpruntID = e.Id_emprunt
    WHERE e.MemberID = @membreID AND a.Statut_A = 'Impayée';

    RETURN ISNULL(@totalAmende, 0); -- Retour de l'amende
END;

GO

-- Fonction de vérification de l'éligibilité d'un membre lors de l'emprunt
CREATE OR ALTER FUNCTION fn_VerifierEligibiliteEmprunt(@membreID INT)
RETURNS INT
AS
BEGIN
    DECLARE @eligible INT;
    DECLARE @amendesImpayees INT;
    DECLARE @statut VARCHAR(20);
    DECLARE @limite INT;

    -- Nombre d'amendes impayées rattachées aux emprunts du membre
    SELECT @amendesImpayees = COUNT(*)
    FROM Amende a
    JOIN Emprunt e ON a.EmpruntID = e.Id_emprunt
    WHERE e.MemberID = @membreID AND a.Statut_A = 'Impayée';

    -- Statut et limite d'emprunt du membre
    SELECT @statut = Statut_M, @limite = Limite_emprunt
    FROM Membre
    WHERE Id_membre = @membreID;

    -- Éligible si aucune amende impayée, statut actif et limite d'emprunt disponible
    IF (@amendesImpayees = 0 AND @statut = 'Actif' AND ISNULL(@limite, 0) > 0)
        SET @eligible = 1;
    ELSE
        SET @eligible = 0;

    RETURN @eligible;
END;
