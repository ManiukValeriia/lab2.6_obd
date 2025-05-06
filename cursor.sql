BEGIN TRAN;

-- Оновлення віку для певної тварини
UPDATE Animal SET Age = Age + 1 WHERE Nickname = 'Bella';

-- Умова, яка призведе до ROLLBACK (наприклад, якщо тварин із Purpose = 'donation' немає)
IF (SELECT COUNT(*) FROM Animal WHERE Purpose = 'donation') = 0
    ROLLBACK;
ELSE
    COMMIT;



BEGIN TRAN;

-- Оновлення Gender некоректним значенням викличе помилку через CHECK
UPDATE Animal SET Gender = 'unknown' WHERE Nickname = 'Bella';

IF @@ERROR <> 0
    ROLLBACK;
ELSE
    COMMIT;



BEGIN TRAN;
BEGIN TRY
    -- Це порушить CHECK (лише 'male' або 'female' дозволено)
    UPDATE Animal SET Gender = 'other' WHERE Nickname = 'Bella';
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Помилка: ' + ERROR_MESSAGE();
END CATCH;

CREATE TABLE LargeAnimal (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Nickname NVARCHAR(50),
    Age INT,
    Gender VARCHAR(10),
    Purpose NVARCHAR(100)
);

BEGIN TRAN;

DECLARE @i INT = 1;
WHILE @i <= 100000
BEGIN
    INSERT INTO LargeAnimal (Nickname, Age, Gender, Purpose)
    VALUES (
        CONCAT('Animal_', @i),
        FLOOR(RAND()*15)+1,
        CASE WHEN @i % 2 = 0 THEN 'male' ELSE 'female' END,
        'testing'
    );
    SET @i = @i + 1;
END;

COMMIT;

SELECT COUNT(*) FROM LargeAnimal;


CREATE OR ALTER PROCEDURE GetAnimalsByGender
    @Gender VARCHAR(10)
AS
BEGIN
    PRINT 'Start Time: ' + CAST(GETDATE() AS VARCHAR);
    
    SELECT * FROM Animal
    WHERE Gender = @Gender;

    PRINT 'End Time: ' + CAST(GETDATE() AS VARCHAR);
END;

SELECT a.Nickname, a.Age, s.Name AS StaffName
FROM Animal a
JOIN Room_Staff rs ON rs.ID_staff = a.ID_staff
JOIN Staff s ON s.ID_staff = rs.ID_staff
WHERE a.Gender = 'female'
ORDER BY a.Age DESC;
