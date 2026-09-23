
-- Création des Triggers pour une insertion, une mise à jour et une suppression d'un membre ou d'un livre
CREATE OR ALTER TRIGGER tr_AuditNouveauMembre
ON Membre
AFTER INSERT
AS
BEGIN
	BEGIN TRY
		-- Journaliser l'insertion dans l'historique
		INSERT INTO HistoriqueModifications(TableModifiee, Operation, Details)
			VALUES ('Membre', 'INSERTION', 'Insertion d’un nouveau membre');
	END TRY

	BEGIN CATCH
		-- gestion de l'erreur
		PRINT 'Une ereur est survenue, l’opération a été annulée:';
		SELECT ERROR_MESSAGE();
	END CATCH;
END;

go

CREATE OR ALTER TRIGGER tr_AuditNouveauLivre
ON Livre
AFTER INSERT
AS
BEGIN
	BEGIN TRY
		-- Journaliser l'insertion dans l'historique
		INSERT INTO HistoriqueModifications(TableModifiee, Operation, Details)
			VALUES ('Livre', 'INSERTION', 'Insertion d’un nouveau livre');
	END TRY

	BEGIN CATCH
		-- gestion de l'erreur
		PRINT 'Une ereur est survenue, l’opération a été annulée:';
		SELECT ERROR_MESSAGE();
	END CATCH;
END;

go

CREATE OR ALTER TRIGGER tr_AuditModifMembre
ON Membre
AFTER UPDATE
AS
BEGIN
	BEGIN TRY
		-- Journaliser la mise à jour dans l'historique
		INSERT INTO HistoriqueModifications(TableModifiee, Operation, Details)
			VALUES ('Membre', 'MISE À JOUR', 'Modification des informations d’un membre');
	END TRY

	BEGIN CATCH
		-- gestion de l'erreur
		PRINT 'Une ereur est survenue, l’opération a été annulée:';
		SELECT ERROR_MESSAGE();
	END CATCH;
END;

go

CREATE OR ALTER TRIGGER tr_AuditModifLivre
ON Livre
AFTER UPDATE
AS
BEGIN
	BEGIN TRY
		-- Journaliser la mise à jour dans l'historique
		INSERT INTO HistoriqueModifications(TableModifiee, Operation, Details)
			VALUES ('Livre', 'MISE À JOUR', 'Modification des informations d’un livre');
	END TRY

	BEGIN CATCH
		-- gestion de l'erreur
		PRINT 'Une ereur est survenue, l’opération a été annulée:';
		SELECT ERROR_MESSAGE();
	END CATCH;
END;

go

CREATE OR ALTER TRIGGER tr_AuditDelMembre
ON Membre
AFTER DELETE
AS
BEGIN
	BEGIN TRY
		-- Mise à jour du statut du membre après suppression
		UPDATE Membre
		SET Statut_M = 'Expiré'
		WHERE Id_membre IN (SELECT d.Id_membre FROM deleted d);

		-- Journaliser l'insertion dans l'historique
		INSERT INTO HistoriqueModifications(TableModifiee, Operation, Details)
			VALUES ('Membre', 'SUPPRESSION', 'Suppression d’un membre');
	END TRY

	BEGIN CATCH
		-- gestion de l'erreur
		PRINT 'Une ereur est survenue, l’opération a été annulée:';
		SELECT ERROR_MESSAGE();
	END CATCH;
END;

go

CREATE OR ALTER TRIGGER tr_AuditDelLivre
ON Livre
AFTER DELETE
AS
BEGIN
	BEGIN TRY
		-- Journaliser la suppression dans l'historique
		INSERT INTO HistoriqueModifications(TableModifiee, Operation, Details)
			VALUES ('Livre', 'SUPPRESSION', 'Suppression d’un Livre');
	END TRY

	BEGIN CATCH
		-- gestion de l'erreur
		PRINT 'Une ereur est survenue, l’opération a été annulée:';
		SELECT ERROR_MESSAGE();
	END CATCH;
END;

go

CREATE OR ALTER TRIGGER tr_UpdateStatutEmprunt
ON Emprunt
AFTER INSERT
AS
BEGIN
	BEGIN TRY
		-- Mise à jour du statut de l'emprunt apres son retour en fonction des circonstances
		UPDATE Emprunt
		SET Statut_E = CASE 
						WHEN Date_retour < GETDATE() THEN 'En retard'
						ELSE 'À rendre'
					 END
		WHERE Id_emprunt IN (SELECT i.Id_emprunt FROM inserted i);

		-- Journaliser l'insertion dans l'historique
		INSERT INTO HistoriqueModifications(TableModifiee, Operation, Details)
				VALUES ('Emprunt', 'INSERTION', 'Modification du statut de l’emprunt d’un Livre lors de son insertion');
		END TRY
		BEGIN CATCH
			-- gestion de l'erreur
			PRINT 'Une ereur est survenue, l’opération a été annulée:';
			SELECT ERROR_MESSAGE();
		END CATCH;
	END;

GO

CREATE OR ALTER TRIGGER tr_AuditLimiteEmpruntMembre
ON Membre
AFTER INSERT
AS
BEGIN
	BEGIN TRY
	-- Mise à jour de la limite d'emprunt pour chaque membre inséré
		UPDATE Membre
		SET Limite_emprunt = CASE 
                                WHEN Type_M = 'Professeur' THEN 10 
                                ELSE 5
							END
		WHERE Id_Membre IN (SELECT i.Id_membre FROM inserted i);

		-- Journaliser la mise à jour dans l'historique
		INSERT INTO HistoriqueModifications(TableModifiee, Operation, Details)
			VALUES ('Membre', 'MISE À JOUR', 'Modification de la limite d’emprunt d’un nouveau membre');
	END TRY

	BEGIN CATCH
		-- gestion de l'erreur
		PRINT 'Une ereur est survenue, l’opération a été annulée:';
		SELECT ERROR_MESSAGE() AS ERREUR;
	END CATCH;
END;