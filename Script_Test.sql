
USE Bibliotheque_Universitaire;

-- Insertion des membres dans la table Membre
INSERT INTO Membre(Nom,Prenom,Email,Type_M)
VALUES ('Sung','Jinwho','MonarchShadow@exemple.com','Personnel');

INSERT INTO Membre(Nom,Prenom,Email,Type_M)
VALUES ('Diego','Conwell','DonConwell17@exemple.com','Etudiant');

INSERT INTO Membre(Nom,Prenom,Email,Type_M)
VALUES ('Lucho','Vampar','ElVampar09@exemple.com','Etudiant');

INSERT INTO Membre(Nom,Prenom,Email,Type_M)
VALUES ('Jinpachi','Ego','EgoJinpey@exemple.com','Professeur');

INSERT INTO Membre(Nom,Prenom,Email,Type_M)
VALUES ('Foster','Xavier','XFrost10@exemple.com','Professeur');

INSERT INTO Membre(Nom,Prenom,Email,Type_M)
VALUES ('Shawn','Frost','BlizardEternel@exemple.com','Personnel');

SELECT * FROM Membre;

-- Insertion des livres dans la table Livre
INSERT INTO Livre(ISBN,Titre,Auteur,Qte_dispo)
VALUES (97820704,'Rédemption','Aoi Ashito',10);

INSERT INTO Livre(ISBN,Titre,Auteur,Qte_dispo)
VALUES (99903064,'Arise','Yoichi Isagi',22);

INSERT INTO Livre(ISBN,Titre,Auteur,Qte_dispo)
VALUES (27431614,'Kingdom','Maì Pencilgon',17);

INSERT INTO Livre(ISBN,Titre,Auteur,Qte_dispo)
VALUES (23724225,'Amaterasu','Horochi',20);

INSERT INTO Livre(ISBN,Titre,Auteur,Qte_dispo)
VALUES (22242005,'Les Mémoires de Vanitas','Thedma',11);

SELECT * FROM Livre;

DELETE FROM Membre WHERE Nom = 'Shawn'; -- Suppression d'un membre pour tester le trigger

-- Test de la fonction d'éligibilité du membre dont id = 4
DECLARE @var INT;
SET @var = dbo.fn_VerifierEligibiliteEmprunt(4);
PRINT @var;

-- Affichage de l'historique d'audit
SELECT * FROM HistoriqueModifications;

-- Test de la procédures du rapport d'emprunt en retard
EXEC dbo.sp_RapportEmpruntsRetard;

-- Test de la procédure de la mise à jour du statut d'un membre
EXEC dbo.sp_MettreAJourStatutsMembres;

-- Test de la procédure l'enregistrement d'un emprunt
EXEC dbo.sp_EnregistrerEmprunt @membreid=4,@livreid=2,@datempr='2024/06/16',@dateret='2024/11/30';
EXEC dbo.sp_EnregistrerEmprunt @membreid=1,@livreid=4,@datempr='2025/04/11',@dateret='2025/06/24';
EXEC dbo.sp_EnregistrerEmprunt @membreid=4,@livreid=2,@datempr='2025/02/18',@dateret='2025/04/14';

-- Test de la procédure du retour d'un livre emprunté
EXEC dbo.sp_RetournerLivre @empruntID=2,@membreid=1,@livreid=4;
EXEC dbo.sp_RetournerLivre @empruntID=3,@membreid=4,@livreid=2;
EXEC dbo.sp_RetournerLivre @empruntID=1,@membreid=4,@livreid=2;

SELECT * FROM Emprunt;
SELECT * FROM Amende;