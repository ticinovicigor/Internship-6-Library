---ime, prezime, spol (ispisati ‘MUŠKI’, ‘ŽENSKI’, ‘NEPOZNATO’, ‘OSTALO’;), ime države i 
---prosječna plaća u toj državi svakom autoru
SELECT name, gender, c.name, c.avgPay FROM Authors a
JOIN Countries c ON c.countryId = a.countryId

---naziv i datum objave svake znanstvene knjige zajedno s imenima glavnih autora koji su na njoj radili, 
---pri čemu imena autora moraju biti u jednoj ćeliji i u obliku Prezime, I.; 
---npr. Puljak, I.; Godinović, N.; Bilušić, A.
SELECT name, dateOfPublishing, 
(STRING_AGG(CONCAT(a.lastName, ', ', SUBSTRING(a.firstName, 1, 1), '.'), ';')) AS MainAuthors FROM Books b
JOIN MainAuthorBooks mab ON mab.bookId = b.bookId
JOIN Authors a ON a.authorId = mab.authorId
WHERE b.bookType = 'znanstvena'
GROUP BY name, dateOfPublishing 

---sve kombinacije (naslova) knjiga i posudbi istih u prosincu 2023.; 
---u slučaju da neka nije ni jednom posuđena u tom periodu, prikaži je samo jednom 
---(a na mjestu posudbe neka piše null)
SELECT b.name, 
CASE WHEN DATE_PART('year', l.date) = 2023 AND DATE_PART('month', l.date) = 12
THEN CONCAT(l.bookId, ', ', userId,', ', isExtended,', ', date) 
ELSE NULL END AS bookid_userid_isextended_date
FROM Lends l
JOIN Books b ON b.bookId = l.bookId


---top 3 knjižnice s najviše primjeraka knjiga
SELECT * FROM Libraries l
ORDER BY(SELECT COUNT(*) FROM LibraryBooks lb WHERE l.libraryId = lb.LibraryId) DESC
LIMIT 3

---po svakoj knjizi broj ljudi koji su je pročitali (korisnika koji posudili bar jednom)
SELECT name, 
(SELECT COUNT(DISTINCT userId) FROM Users u WHERE l.userId = u.userId ) FROM Books b
JOIN Lends l ON l.bookId = b.bookId

---imena svih korisnika koji imaju trenutno posuđenu knjigu
SELECT name FROM Users u
JOIN Lends l ON l.userId = u.userId
WHERE NOT l.dateReturned < NOW()

---sve autore kojima je bar jedna od knjiga izašla između 2019. i 2022.
SELECT DISTINCT a.authorId, firstName, lastName, dateOfBirth, countryId, 
CASE WHEN gender = 0 THEN 'Not known'
WHEN gender = 1 THEN 'Male'
WHEN gender = 2 THEN 'Female'
ELSE 'Not applicable' END AS gender
FROM Authors a
JOIN MainAuthorBooks mab ON mab.authorId = a.authorId
JOIN SideAuthorBooks sab ON sab.authorId = a.authorId
JOIN Books b ON b.bookId = mab.bookId OR b.bookId = sab.bookId
WHERE DATE_PART('year', b.dateOfPublishing) BETWEEN 2019 AND 2022

---ime države i broj umjetničkih knjiga po svakoj 
---(ako su dva autora iz iste države, računa se kao jedna knjiga), 
---gdje su države sortirane po broju živih autora od najveće ka najmanjoj 
SELECT c.name, 
COUNT(*) FROM Books b
JOIN MainAuthorBooks mab ON mab.bookId = b.bookId
JOIN SideAuthorBooks sab ON sab.bookId = b.bookId
JOIN Authors a ON a.authorId = mab.authorId OR a.authorId = sab.authorId
JOIN Countries c ON c.countryId = a.countryId
WHERE b.bookType = 'umjetnička'
GROUP BY c.name, (SELECT COUNT(*) FROM Authors au WHERE au.countryId = c.countryId), c.population


---autora i ime prve objavljene knjige istog
SELECT 
	a.authorId, 
	a.firstName, 
	a.lastName, 
	(SELECT name FROM Books b
		JOIN MainAuthorBooks mab ON mab.bookId = b.bookId
		JOIN SideAuthorBooks sab ON sab.bookId = b.bookId
		WHERE a.authorId = mab.authorId OR a.authorId = sab.authorId
	 ORDER BY b.dateOfPublishing ASC
	 LIMIT 1
	)
	FROM Authors a

---državu i ime druge objavljene knjige iste
SELECT
	c.name,
	(SELECT name FROM Books b
		JOIN MainAuthorBooks mab ON mab.bookId = b.bookId
		JOIN SideAuthorBooks sab ON sab.bookId = b.bookId
		JOIN Authors a ON a.authorId = mab.authorId OR a.authorId = sab.authorId
	 WHERE a.countryId = c.countryId AND b.dateOfPublishing > (SELECT MIN(b.dateOfPublishing) FROM Books b)
	 ORDER BY b.dateOfPublishing ASC
	 LIMIT 1
	)
FROM Countries c

---knjige i broj aktivnih posudbi, gdje se one s manje od 10 aktivnih ne prikazuju
SELECT
	b.name,
	(SELECT COUNT(*) FROM Lends l
	JOIN Books b ON l.bookId = b.bookId 
	WHERE NOW() BETWEEN l.date AND l.date + make_interval(days => 20 + l.isextended))
FROM Books b
GROUP BY b.name

---prosječan broj posudbi po primjerku knjige po svakoj državi
SELECT c.name, (SELECT AVG(cnt) FROM (SELECT COUNT (*) AS cnt FROM Lends l WHERE l.bookId = b.bookId)) FROM COUNTRIES c
JOIN Authors a on a.countryId = c.countryId
JOIN MainAuthorBooks mab ON mab.authorId = a.authorId
JOIN SideAuthorBooks sab ON sab.authorId = a.authorId
JOIN Books b ON b.bookId = sab.bookId OR b.bookId = mab.bookId

---broj autora (koji su objavili više od 5 knjiga) po struci, desetljeću rođenja i spolu; 
---u slučaju da je broj autora manji od 10, ne prikazuj kategoriju; poredaj prikaz po desetljeću rođenja
SELECT 
(SELECT COUNT(*) FROM Authors au 
 	WHERE au.field = a.field AND (SELECT COUNT(*) FROM Books b
								 	JOIN MainAuthorBooks mab ON mab.bookId = b.bookId
									JOIN SideAuthorBooks sab ON sab.bookId = b.bookId
								 	WHERE mab.authorId = au.authorId OR sab.authorId = au.authorId
								 )>5),
a.field,

(SELECT COUNT(*) FROM Authors au 
 	WHERE (SELECT EXTRACT(DECADE FROM au.dateOfBirth)) = (SELECT EXTRACT(DECADE FROM a.dateOfBirth)) AND (SELECT COUNT(*) FROM Books b
								 	JOIN MainAuthorBooks mab ON mab.bookId = b.bookId
									JOIN SideAuthorBooks sab ON sab.bookId = b.bookId
								 	WHERE mab.authorId = au.authorId OR sab.authorId = au.authorId
								 )>5),
								 
(SELECT EXTRACT(DECADE FROM a.dateOfBirth) AS Decade),

(SELECT COUNT(*) FROM Authors au 
 	WHERE au.gender = a.gender AND (SELECT COUNT(*) FROM Books b
								 	JOIN MainAuthorBooks mab ON mab.bookId = b.bookId
									JOIN SideAuthorBooks sab ON sab.bookId = b.bookId
								 	WHERE mab.authorId = au.authorId OR sab.authorId = au.authorId
								 )>5),

CASE WHEN gender = 0 THEN 'Not known'
WHEN gender = 1 THEN 'Male'
WHEN gender = 2 THEN 'Female'
ELSE 'Not applicable' END AS gender

FROM Authors a

---10 najbogatijih autora, ako po svakoj knjizi dobije ... €
---SELECT AuthorId, firstName, lastName,

---(SELECT )

---FROM Authors a









