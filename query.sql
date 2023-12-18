---ime, prezime, spol (ispisati ‘MUŠKI’, ‘ŽENSKI’, ‘NEPOZNATO’, ‘OSTALO’;), ime države i 
---prosječna plaća u toj državi svakom autoru
SELECT a.name, a.gender, c.name, c.avgPay FROM Authors a
JOIN Countries c ON c.countryId = a.countryId

---naziv i datum objave svake znanstvene knjige zajedno s imenima glavnih autora koji su na njoj radili, 
---pri čemu imena autora moraju biti u jednoj ćeliji i u obliku Prezime, I.; 
---npr. Puljak, I.; Godinović, N.; Bilušić, A.
SELECT name, dateOfPublishing, 
(STRING_AGG(CONCAT(a.lastName, ',', SUBSTRING(a.firstName, 1, 1), '.'), ';')) AS MainAuthors FROM Books b
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


