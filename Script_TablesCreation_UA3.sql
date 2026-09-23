
-- Création de la base de donnée
CREATE DATABASE Bibliotheque_Universitaire;

use Bibliotheque_Universitaire;

-- Création des différentes tables dans la base de donnée

CREATE TABLE Membre(
   Id_membre INT IDENTITY(1,1),
   Nom VARCHAR(50) NOT NULL,
   Prenom VARCHAR(50),
   Email VARCHAR(100) UNIQUE,
   Statut_M VARCHAR(20) NOT NULL DEFAULT 'Actif',
   Type_M VARCHAR(15) NOT NULL,
   Limite_emprunt INT,
   PRIMARY KEY(Id_membre),
   CHECK (Statut_M = 'Actif' OR Statut_M = 'Suspendu')
);

CREATE TABLE Livre(
   Id_livre INT IDENTITY(1,1),
   ISBN INT NOT NULL UNIQUE,
   Titre VARCHAR(100),
   Auteur VARCHAR(50),
   Qte_dispo INT NOT NULL,
   PRIMARY KEY(Id_livre),
   CHECK (Qte_dispo >= 0)
);

CREATE TABLE Emprunt(
   Id_emprunt INT IDENTITY(1,1),
   MemberID INT NOT NULL,
   LivreID INT NOT NULL,
   Date_emprunt DATE NOT NULL,
   Date_retour DATE NOT NULL,
   Statut_E VARCHAR(20),
   PRIMARY KEY(Id_emprunt),
   FOREIGN KEY(LivreID) REFERENCES Livre(Id_livre),
   FOREIGN KEY(MemberID) REFERENCES Membre(Id_membre)
);

CREATE TABLE Amende(
   Id_amende INT IDENTITY(1,1),
   EmpruntID INT NOT NULL,
   Montant DECIMAL(10, 2),
   Statut_A VARCHAR(20) NOT NULL,
   PRIMARY KEY(Id_amende),
   FOREIGN KEY(EmpruntID) REFERENCES Emprunt(Id_emprunt)
);

CREATE TABLE HistoriqueModifications (
    Id_historique INT IDENTITY(1,1),
    TableModifiee VARCHAR(50),
    Operation VARCHAR(20),
    DateModification DATETIME DEFAULT GETDATE(),
    Details VARCHAR(250),
	PRIMARY KEY (Id_historique)
);