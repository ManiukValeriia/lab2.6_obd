# lab2.6_obd
# ЛАБОРАТОРНА РОБОТА № 6
# Робота з індексами та курсорами в MSSQL

**Короткий опис:**

У результаті роботи було вивчено індекси в Microsoft SQL Server, їх вплив на продуктивність запитів та особливості використання. Отримано практичні навички 
створення, оптимізації, реорганізації та видалення індексів, а також аналізу їх ефективності в реальних запитах.

**Завдання 2**

BEGIN TRAN;
-- Оновлення віку для певної тварини
UPDATE Animal SET Age = Age + 1 WHERE Nickname = 'Bella';

-- Умова, яка призведе до ROLLBACK (наприклад, якщо тварин із Purpose = 'donation' немає)
IF (SELECT COUNT(*) FROM Animal WHERE Purpose = 'donation') = 0
    ROLLBACK;
ELSE
COMMIT;

**Завдання 3**

BEGIN TRAN;
-- Оновлення Gender некоректним значенням викличе помилку через CHECK
UPDATE Animal SET Gender = 'unknown' WHERE Nickname = 'Bella';

IF @@ERROR <> 0
    ROLLBACK;
ELSE
    COMMIT;
    
**Завдання 4**

BEGIN TRAN;
-- Оновлення Gender некоректним значенням викличе помилку через CHECK
UPDATE Animal SET Gender = 'unknown' WHERE Nickname = 'Bella';

IF @@ERROR <> 0
    ROLLBACK;
ELSE
    COMMIT;
    
**Завдання 5**

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

**Завдання 6**

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

**Завдання 7**

CREATE OR ALTER PROCEDURE GetAnimalsByGender
    @Gender VARCHAR(10)
AS
BEGIN
    PRINT 'Start Time: ' + CAST(GETDATE() AS VARCHAR);
    
    SELECT * FROM Animal
    WHERE Gender = @Gender;
    PRINT 'End Time: ' + CAST(GETDATE() AS VARCHAR);
END;

**Завдання 8**

<img width="551" alt="Снимок экрана 2025-05-06 в 19 18 04" src="https://github.com/user-attachments/assets/6bbafdc5-ca34-46aa-bd9d-b4986d88eac0" />

**Завдання 12**

У порівнянні запитів видно, що найшвидше виконується оптимізований запит із використанням індексів — його час становить лише 120 мс. Це значно швидше, 
ніж звичайний запит без індексів, який виконується за 950 мс. Це доводить, що правильне індексування може істотно покращити продуктивність.
Найповільніше працюють запити, реалізовані за допомогою курсорів. Перший курсор виконується понад 3 секунди (3200 мс), а інший, ще складніший курсор із JOIN, 
WHERE та ORDER BY, — понад 3,3 секунди. Повторне виконання другого курсора без його очищення (без DEALLOCATE) ще більше уповільнює систему, оскільки не вивільняються 
ресурси, які займає курсор.
Таким чином, щоб пришвидшити запити, варто:
- використовувати індекси на стовпцях, які часто застосовуються у фільтрах або сортуванні;
- уникати курсорів, особливо в роботі з великими таблицями;
- переглядати план виконання запиту для виявлення повільних місць;
- реорганізовувати або перебудовувати індекси, якщо база активно змінюється.
Курсори слід застосовувати лише у випадках, коли потрібна покрокова обробка рядків з урахуванням складної логіки, яку важко реалізувати звичайними SQL-запитами.
