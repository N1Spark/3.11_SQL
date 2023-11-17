--1
CREATE TRIGGER update_library_on_return
ON S_Cards
AFTER UPDATE
AS
BEGIN
    IF UPDATE(date_in) AND NOT UPDATE(date_out)
    BEGIN
        UPDATE Book
        SET quantity = quantity + 1
        FROM Book
        INNER JOIN INSERTED ON Book.id = INSERTED.id_book;
    END
END;

--2
CREATE TRIGGER student_book_pickup
ON S_Cards
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF (SELECT COUNT(*) FROM S_Cards WHERE id_student IN (SELECT id_student FROM INSERTED) AND date_in IS NULL) >= 3
    BEGIN
        PRINT 'Нельзя брать больше 3 книг'
		ROLLBACK TRAN
    END
    ELSE
    BEGIN
        INSERT INTO S_Cards (id_student, id_book, date_out, id_librarian)
        SELECT id_student, id_book, date_out, id_librarian
        FROM INSERTED;
    END
END
