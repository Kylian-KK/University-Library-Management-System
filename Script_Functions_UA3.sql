
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
	
	-- Éligible si pas d'amende ou amende payé, le statut du membre est actif et la limite d'emprunt est > 0
    IF(((SELECT COUNT(*) FROM Amende WHERE EmpruntID IN
	(SELECT Id_emprunt FROM Emprunt WHERE MemberID = @membreID) AND Statut_A = 'Payée') = 0
	OR (SELECT Statut_A FROM Amende WHERE EmpruntID IN
	(SELECT Id_emprunt FROM Emprunt WHERE MemberID = @membreID)) = 'Payée') AND
	(SELECT Statut_M FROM Membre WHERE Id_membre = @membreID) = 'Actif' AND
	(SELECT Limite_emprunt FROM Membre WHERE Id_membre = @membreID) > 0)
        SET @eligible = 1; -- Éligible
    ELSE
        SET @eligible = 0; -- Non éligible

    RETURN @eligible;
END;