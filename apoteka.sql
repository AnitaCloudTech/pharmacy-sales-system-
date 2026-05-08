

-- 1. Kreiranje baze
CREATE DATABASE IF NOT EXISTS Apoteka;
USE Apoteka;

-- 2. Kreiranje tabela

-- Tabela Lekovi
CREATE TABLE Lekovi (
    LekID INT PRIMARY KEY AUTO_INCREMENT,
    Naziv VARCHAR(100) NOT NULL,
    Proizvodjac VARCHAR(100),
    Cena DECIMAL(10,2) NOT NULL,
    KolicinaNaStanju INT NOT NULL
);

-- Tabela Kupci
CREATE TABLE Kupci (
    KupacID INT PRIMARY KEY AUTO_INCREMENT,
    Ime VARCHAR(50) NOT NULL,
    Prezime VARCHAR(50) NOT NULL,
    Telefon VARCHAR(20)
);

-- Tabela Prodaja
CREATE TABLE Prodaja (
    ProdajaID INT PRIMARY KEY AUTO_INCREMENT,
    LekID INT NOT NULL,
    KupacID INT,
    Kolicina INT NOT NULL,
    DatumProdaje DATE NOT NULL,
    FOREIGN KEY (LekID) REFERENCES Lekovi(LekID),
    FOREIGN KEY (KupacID) REFERENCES Kupci(KupacID)
);

-- Lekovi
INSERT INTO Lekovi (Naziv, Proizvodjac, Cena, KolicinaNaStanju)
VALUES 
('Paracetamol', 'Galenika', 120.00, 50),
('Ibuprofen', 'Hemofarm', 150.00, 30),
('Aspirin', 'Bayer', 200.00, 20),
('Amoksicilin', 'Lek', 350.00, 15);

-- Kupci
INSERT INTO Kupci (Ime, Prezime, Telefon)
VALUES 
('Marko', 'Markovic', '0601234567'),
('Jovana', 'Jovanovic', '0612345678'),
('Petar', 'Petrovic', '0623456789');

-- Prodaja
INSERT INTO Prodaja (LekID, KupacID, Kolicina, DatumProdaje)
VALUES
(1, 1, 2, '2025-11-19'),
(2, 2, 1, '2025-11-19'),
(3, 3, 3, '2025-11-18');

-- Prikaz svih lekova sa stanjem
SELECT * FROM Lekovi;

-- Prikaz svih kupaca
SELECT * FROM Kupci;

-- Prikaz prodaje sa detaljima lekova i kupaca
SELECT p.ProdajaID, l.Naziv AS Lek, k.Ime AS KupacIme, k.Prezime AS KupacPrezime, 
       p.Kolicina, p.DatumProdaje
FROM Prodaja p
JOIN Lekovi l ON p.LekID = l.LekID
LEFT JOIN Kupci k ON p.KupacID = k.KupacID
ORDER BY p.DatumProdaje DESC;

-- Ukupna zarada po lekovima
SELECT l.Naziv AS Lek, SUM(p.Kolicina * l.Cena) AS UkupnaZarada
FROM Prodaja p
JOIN Lekovi l ON p.LekID = l.LekID
GROUP BY l.Naziv;

UPDATE Lekovi l
JOIN (
    SELECT LekID, SUM(Kolicina) AS UkupnaKolicina
    FROM Prodaja
    WHERE DatumProdaje = '2025-11-19'
    GROUP BY LekID
) p_sum ON l.LekID = p_sum.LekID
SET l.KolicinaNaStanju = l.KolicinaNaStanju - p_sum.UkupnaKolicina;

-- Prikaz lekova sa stanjem nakon prodaje
SELECT * FROM Lekovi;

-- Pretraga lekova po nazivu
SELECT * FROM Lekovi
WHERE Naziv LIKE '%Ibuprofen%';

-- Prikaz prodaje za određenog kupca
SELECT p.ProdajaID, l.Naziv, p.Kolicina, p.DatumProdaje
FROM Prodaja p
JOIN Lekovi l ON p.LekID = l.LekID
WHERE p.KupacID = 2;

-- Ukupna zarada po kupcima
SELECT k.Ime, k.Prezime, SUM(p.Kolicina * l.Cena) AS UkupnaZarada
FROM Prodaja p
JOIN Kupci k ON p.KupacID = k.KupacID
JOIN Lekovi l ON p.LekID = l.LekID
GROUP BY k.KupacID;

-- Izveštaj prodaje po datumima
SELECT DatumProdaje, SUM(p.Kolicina * l.Cena) AS ZaradaPoDanu
FROM Prodaja p
JOIN Lekovi l ON p.LekID = l.LekID
GROUP BY DatumProdaje
ORDER BY DatumProdaje DESC;
-- Test unosa prodaje (automatsko smanjenje stanja lekova)

INSERT INTO Prodaja (LekID, KupacID, Kolicina, DatumProdaje)
VALUES (1, 1, 5, '2025-11-19');  -- ovo će automatski smanjiti Paracetamol za 5

-- Trigger za automatsko smanjenje stanja lekova nakon prodaje

DELIMITER $$

CREATE TRIGGER trg_AfterInsertProdaja
AFTER INSERT ON Prodaja
FOR EACH ROW
BEGIN
    UPDATE Lekovi
    SET KolicinaNaStanju = KolicinaNaStanju - NEW.Kolicina
    WHERE LekID = NEW.LekID;
END$$

DELIMITER ;
























