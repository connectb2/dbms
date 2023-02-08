-- drop database courseEnrollment;
CREATE DATABASE courseEnrollment;
USE courseEnrollment;

CREATE TABLE student(
    regno VARCHAR(15) PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    major VARCHAR(15) NOT NULL,
    bdate DATE NOT NULL
);

CREATE TABLE course(
    course_id INT PRIMARY KEY,
    cname VARCHAR(15) NOT NULL,
    dept VARCHAR(50) NOT NULL
);

CREATE TABLE textbook(
    isbn INT PRIMARY KEY,
    book_title VARCHAR(50) NOT NULL,
    publisher VARCHAR(50) NOT NULL,
    author VARCHAR(30) NOT NULL
);

CREATE TABLE enroll(
    regno VARCHAR(15),
    course_id INT,
    sem INT NOT NULL,
    marks INT NOT NULL,
    FOREIGN KEY (regno) REFERENCES student(regno) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
    PRIMARY KEY(regno, course_id)
);

CREATE TABLE bookAdoption(
    course_id INT,
    isbn INT,
    sem INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (isbn) REFERENCES textbook(isbn) ON DELETE CASCADE,
    PRIMARY KEY (course_id, isbn)
);

INSERT INTO student VALUES
("01JST20CS151", "Shiva", "DBMS", "2002-10-21"),
("01JST20CS120", "Prasad", "Finance", "2001-11-26"),
("01JST21CS101", "Sanjay", "Business", "2003-02-06"),
("01JST20CS141", "Samrudh", "Electronics", "2003-02-06"),
("01JST18CS101", "Prajwal", "Construction", "2002-12-06");

INSERT INTO course VALUES
(1, "DBMS", "CSE"),
(2, "Finance", "Finology"),
(3, "Business", "Business Administration"),
(4, "Electronics", "ECE"),
(5, "Construction", "Civil");

INSERT INTO textbook VALUES
(1234, "DBMS", "JSS", "Navikant"),
(2134, "Trading vs Long term", "IIM", "Robert"),
(4567, "Zero To Hundred", "Nike", "Phil Heath"),
(8520, "Semiconductors", "IEEE", "Gaury Roy"),
(7894, "Smart Materials", "Anderson Publication", "Mark Mansin"),
(8624, "OS", "Galvin Publ.", "Galvin");

INSERT INTO enroll VALUES
("01JST20CS151", 1, 5, 95),
("01JST20CS120", 2, 3, 80),
("01JST21CS101", 3, 6, 71),
("01JST20CS141", 4, 7, 92),
("01JST18CS101", 5, 3, 43),
("01JST20CS151", 3, 5, 21),
("01JST20CS120", 1, 3, 35),
("01JST21CS101", 2, 6, 72),
("01JST20CS141", 5, 7, 96),
("01JST18CS101", 4, 3, 40);

INSERT INTO bookadoption VALUES
(1, 1234, 5),
(2, 2134, 3),
(3, 4567, 6),
(4, 8520, 7),
(5, 7894, 3),
(1, 8624, 4);

-- Demonstrate how you add a new text book to the database and make this book be adopted by some department.
INSERT INTO textbook VALUES
(7410, "Sensors", "IEEE", "Arnold");

INSERT INTO bookadoption VALUES
(4, 7410, 2);

-- Produce a list of text books (include Course #, Book-ISBN, Book-title) in the alphabetical order for courses offered by the ‘CS’ department that use more than two books.
SELECT b.course_id, b.isbn, t.book_title
FROM bookAdoption b
JOIN textbook t ON b.isbn = t.isbn
JOIN course c ON b.course_id = c.course_id
WHERE c.dept = "CSE"  AND(
    SELECT COUNT(isbn)
    FROM bookAdoption b1
    WHERE b1.course_id = c.course_id
) >= 2
ORDER BY t.book_title;

-- List any department that has all its adopted books published by a specific publisher
SELECT DISTINCT c.dept
FROM course c
JOIN bookAdoption b ON c.course_id = b.course_id
JOIN textbook t ON t.isbn = b.isbn
GROUP BY c.dept
HAVING COUNT(t.publisher) = SUM(t.publisher = "IEEE");

-- List the students who have scored maximum marks in ‘DBMS’ course.
SELECT s.name , e.marks 
FROM student s
JOIN enroll e ON s.regno = e.regno
JOIN course c ON c.course_id = e.course_id
WHERE c.cname = "DBMS"
ORDER BY e.marks DESC;

-- Create a view to display all the courses opted by a student along with marks obtained.
CREATE VIEW view1 AS
SELECT s.name, c.cname, e.marks
FROM student s
JOIN enroll e ON s.regno = e.regno
JOIN course c ON c.course_id = e.course_id
WHERE s.regno = "01JST20CS151";

SELECT * FROM view1;

-- Create a view to show the enrolled details of a student.
CREATE VIEW view2 AS 
SELECT s.name, c.cname AS EnrolledCourse
FROM student s
JOIN enroll e ON s.regno = e.regno
JOIN course c ON c.course_id = e.course_id
WHERE s.regno = "01JST20CS151";

SELECT * FROM view2;

-- Create a view to display course related books from course_adoption and text book table using book_ISBN
SELECT c.cname, t.isbn, t.book_title
FROM course c
JOIN bookAdoption b ON b.course_id = c.course_id
JOIN textbook t ON t.isbn = b.isbn;

-- Create a trigger such that it Deletes all records from enroll table when course is deleted
DELIMITER $$
CREATE TRIGGER trigger1
AFTER DELETE ON course
FOR EACH ROW
BEGIN 
    DELETE FROM enroll
    WHERE OLD.course_id = enroll.course_id;
END;$$
DELIMITER ;

DELETE FROM course
WHERE course_id = 1;

-- Create a trigger that prevents a student from enrolling in a course if the marks pre_requisit is less than the given threshold
DELIMITER $$
CREATE TRIGGER trigger2
BEFORE INSERT ON enroll
FOR EACH ROW
BEGIN 
    IF((SELECT AVG(marks) FROM enroll WHERE regno = NEW.regno) < 40) THEN 
        SIGNAL SQLSTATE '45000' SET message_text = "Cannot enroll in this course";
    END IF;
END;$$
DELIMITER ;

INSERT INTO enroll VALUES
("01JST21CS101", 5, 7, 0);

