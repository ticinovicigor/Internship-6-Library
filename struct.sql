CREATE TABLE Libraries(
	libraryId SERIAL PRIMARY KEY,
	name VARCHAR NOT NULL UNIQUE,
	openingHour INT,
	closingHour INT
);

CREATE TABLE Librarians(
	librarianId SERIAL PRIMARY KEY,
	name VARCHAR NOT NULL UNIQUE,
	libraryId INT REFERENCES Libraries(libraryId)
);

CREATE TABLE Users(
	userId SERIAL PRIMARY KEY,
	name VARCHAR NOT NULL UNIQUE,
	libraryId INT REFERENCES Libraries(libraryId)
);

CREATE TABLE Books(
	bookId SERIAL PRIMARY KEY,
	name VARCHAR NOT NULL UNIQUE,
	booktype VARCHAR NOT NULL,
	dateOfPublishing TIMESTAMP
);




CREATE TABLE Countries(
	countryId SERIAL PRIMARY KEY,
	name VARCHAR NOT NULL UNIQUE,
	population INT,
	avgPay INT
);

CREATE TABLE Authors(
	authorId SERIAL PRIMARY KEY,
	firstName VARCHAR NOT NULL UNIQUE,
	lastName VARCHAR NOT NULL UNIQUE,
	dateOfBirth TIMESTAMP,
	countryId INT REFERENCES Countries(countryId),
	gender INT,
	field VARCHAR
);

CREATE TABLE MainAuthorBooks(
	authorId INT REFERENCES Authors(authorId),
	bookId INT REFERENCES Books(bookId),
	
	PRIMARY KEY(authorId, bookId)
);

CREATE TABLE SideAuthorBooks(
	authorId INT REFERENCES Authors(authorId),
	bookId INT REFERENCES Books(bookId),
	
	PRIMARY KEY(authorId, bookId)
);

CREATE TABLE LibraryBooks(
	libraryId INT REFERENCES Libraries(libraryId),
	bookId INT REFERENCES Books(bookId),
	
	PRIMARY KEY(libraryId, bookId)
);

CREATE TABLE Lends(
	bookId INT REFERENCES Books(bookId),
	userId INT REFERENCES Users(userId),
	date TIMESTAMP,
	dateReturned TIMESTAMP,
	isExtended INT,
	PRIMARY KEY(bookId, userId)
);

---CREATE TRIGGER isLibraryOpen
---    AFTER UPDATE ON Lends
---    FOR EACH ROW
---    WHEN ()
---    EXECUTE FUNCTION ;
	
---do 3 posudbe po osobi

CREATE PROCEDURE LendBook(book INT, client INT)
LANGUAGE SQL
AS $$
INSERT INTO Lends(bookId, userId, date, isExtended) values (book, client, NOW(), 0);
$$;

---CALL LendBook(1, 1);

CREATE PROCEDURE ExtendLend(book INT, client INT)
LANGUAGE SQL
AS $$
UPDATE Lends
SET isExtended = 40
WHERE bookId = book AND userId = client
$$;

---CALL ExtendLend(1, 1);