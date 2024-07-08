--triger
--1. Kitabxanada olmayan kitabları , kitabxanadan götürmək olmaz.
CREATE TRIGGER PreventBook_S_Cards
ON S_Cards 
FOR INSERT 
AS
BEGIN 
         DECLARE @book_id INT;
		 SELECT @book_id=Id_Book
		 FROM inserted

		 DECLARE @quantity_book INT;
		 SELECT @quantity_book=Quantity
		 FROM Books
		 WHERE Id=@book_id

		 IF(@quantity_book=0 OR @book_id IS NULL)
		 BEGIN 
		   ROLLBACK
		 END
		 ELSE
		 BEGIN
		 UPDATE Books
		 SET Quantity=@quantity_book-1
		 WHERE Books.Id=@book_id
		 END
		 

END

CREATE TRIGGER PreventBook_T_Cards
ON T_Cards 
FOR INSERT 
AS
BEGIN 
         DECLARE @book_id INT;
		 SELECT @book_id=Id_Book
		 FROM inserted

		 DECLARE @quantity_book INT;
		 SELECT @quantity_book=Quantity
		 FROM Books
		 WHERE Id=@book_id

		 IF(@quantity_book=0 OR @book_id IS NULL)
		 BEGIN 
		   ROLLBACK
		 END
		 ELSE
		 BEGIN
		 UPDATE Books
		 SET Quantity=@quantity_book-1
		 WHERE Books.Id=@book_id
		 END
		 

END




--2. Müəyyən kitabı qaytardıqda, onun Quantity-si (sayı) artmalıdır.

CREATE TRIGGER IncreaseBookToLib_S_Cards
ON S_CARDS
FOR UPDATE
AS
BEGIN
DECLARE @idBook int;
DECLARE @QuantityBook int;

SELECT @idBook=Id_Book
FROM inserted

SELECT @QuantityBook=Quantity
FROM BOOKS
WHERE Id=@idBook

IF(@idBook IS NULL)
BEGIN
    ROLLBACK
END
ELSE
 UPDATE Books
 SET Quantity=@QuantityBook+1
 WHERE Books.Id=@idBook


END

CREATE TRIGGER IncreaseBookToLib_T_Cards
ON T_CARDS
FOR UPDATE
AS
BEGIN
DECLARE @idBook int;
DECLARE @QuantityBook int;

SELECT @idBook=Id_Book
FROM inserted

SELECT @QuantityBook=Quantity
FROM BOOKS
WHERE Id=@idBook

IF(@idBook IS NULL)
BEGIN
    ROLLBACK
END
ELSE
 UPDATE Books
 SET Quantity=@QuantityBook+1
 WHERE Books.Id=@idBook


END


--3. Kitab kitabxanadan verildikdə onun sayı azalmalıdır.



--BU TASKI EYNEN TASK 1 KIMI YAZARDIM :)


--4. Bir tələbə artıq 3 itab götütürübsə ona yeni kitab vermək olmaz.
CREATE TRIGGER TakeBookForStudents 
ON S_Cards
AFTER INSERT
AS
BEGIN
    DECLARE @students_Id int ;
	DECLARE @quantity_Book int;

	SELECT @students_Id =Id_Student
	FROM inserted

	SELECT @quantity_Book=Count(Id_Student)
	FROM S_Cards
	WHERE Id_Student=@students_Id
	GROUP BY Id_Student

	if(@students_Id IS NULL OR @quantity_Book>3 )
	BEGIN
	
	  ROLLBACK;
	END
	
END


--5. Əgər tələbə bir kitabı 2aydan çoxdur oxuyursa, bu halda tələbəyə yeni kitab vermək olmaz.
CREATE TRIGGER TakeBookForStudentsPart1
ON S_CARDS
AFTER INSERT
AS
BEGIN

  DECLARE @studentID INT;
  DECLARE @isBookLimitExceeded BIT;

  SELECT @studentID=Id_Student
  FROM inserted

   IF (@studentID IS NULL)
    BEGIN
        PRINT 'Error: Student ID is null.';
    END

  SELECT @isBookLimitExceeded=1
  FROM S_Cards
  WHERE Id_Student=@studentID AND DATEDIFF(MONTH,DateOut,GETDATE())>2

    IF @isBookLimitExceeded = 1
    BEGIN
        PRINT 'Error: Student cannot take a new book if they have been reading a book for more than 2 months.';
        ROLLBACK;
   END



END
--6. Kitabı bazadan sildikdə, onun haqqında data LibDeleted cədvəlinə köçürülməlidir.

-----