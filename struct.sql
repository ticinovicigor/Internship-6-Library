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
	name VARCHAR NOT NULL UNIQUE
);

CREATE TABLE Books(
	bookId SERIAL PRIMARY KEY,
	name VARCHAR NOT NULL UNIQUE,
	booktype VARCHAR NOT NULL
);




CREATE TABLE Countries(
	countryId SERIAL PRIMARY KEY,
	name VARCHAR NOT NULL UNIQUE,
	population INT,
	avgPay INT
);

CREATE TABLE Authors(
	authorId SERIAL PRIMARY KEY,
	name VARCHAR NOT NULL UNIQUE,
	dateOfBirth TIMESTAMP,
	countryId INT REFERENCES Countries(countryId),
	gender INT
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