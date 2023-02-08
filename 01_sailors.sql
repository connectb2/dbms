create database sailors;
USE sailors;

create table sailor(
    sid INT PRIMARY  KEY,
    sname VARCHAR(50) NOT NULL,
    rating FLOAT NOT NULL,
    age INT NOT NULL
);

CREATE TABLE boat(
    bid INT PRIMARY KEY,
    bname VARCHAR(15) NOT NULL,
    color VARCHAR(15) NOT NULL
);

CREATE TABLE reservers(
    sid INT,
    bid INT, 
    date DATE NOT NULL,
    FOREIGN KEY (sid) REFERENCES sailor(sid) ON DELETE CASCADE,
    FOREIGN KEY (bid) REFERENCES boat(bid) ON DELETE CASCADE,
    PRIMARY KEY(sid, bid)
);

INSERT INTO sailor VALUES
(1, "sailor1", 8,45),
(2, "sailor2", 8.7, 32),
(3, "Jack storm", 6, 22),
(4, "Albert", 7.5, 50),
(5, "Astorm Gupta", 4, 20),
(6, "storm Shield", 2, 35);

INSERT INTO boat VALUES
(1, "boat1", "green"),
(2, "boat2", "yellow"),
(103, "boat103", "brown");

INSERT INTO reservers VALUES
(1, 103, '2022-10-21'),
(2, 1, '2023-01-21'),
(4, 103, "2023-02-02"),
(4, 2, '2022-11-30'),
(5, 103, '2019-07-16'), 
(4, 1, "2016-10-25");

-- Find the colours of boats reserved by Albert
select boat.color
from boat
join reservers on boat.bid = reservers.bid
join sailor on sailor.sid = reservers.sid
where sailor.sname = "Albert";


-- Find all sailor id’s of sailors who have a rating of at least 8 or reserved boat 103 
SELECT sid 
FROM sailor
WHERE rating >= 8
UNION 
SELECT sid 
FROM reservers
WHERE bid = 103;


-- Find the names of sailors who have not reserved a boat whose name contains the string “storm”. Order the names in ascending order.
SELECT sname
FROM sailor 
WHERE sname LIKE "%storm%" AND 
sid NOT IN (SELECT DISTINCT reservers.sid FROM reservers)
ORDER BY sname ASC;

-- Find the names of sailors who have reserved all boats
SELECT sname 
FROM sailor
WHERE sid IN (
    SELECT sid
    FROM reservers
    GROUP BY sid
    HAVING COUNT(bid) = (SELECT COUNT(bid) FROM boat)
);

-- Find the name and age of the oldest sailor.
SELECT sname, age 
FROM sailor
WHERE age IN 
(SELECT MAX(age) FROM sailor);

-- For each boat which was reserved by at least 5 sailors with age >= 40, find the boat id and the average age of such sailors.
SELECT bid, AVG(age) AS avg_age
FROM sailor
JOIN reservers ON sailor.sid = reservers.sid
WHERE age >= 40
GROUP BY reservers.bid



-- VIEWS AND TRIGGERS

-- A view that shows names and ratings of all sailors sorted by rating in descending order
CREATE VIEW view1 AS
SELECT sname, rating 
FROM sailor 
ORDER BY rating DESC;

SELECT * FROM view1;

-- Create a view that shows the names of the sailors who have reserved a boat on a given date.
CREATE VIEW view2 AS
SELECT sname 
FROM sailor
JOIN reservers ON sailor.sid = reservers.sid
WHERE date = "2023-02-02";

SELECT * FROM view 2;


-- Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.
CREATE  VIEW view3 AS
SELECT bname, color
FROM boat 
JOIN reservers ON boat.bid = reservers.bid
WHERE reservers.sid IN (SELECT sid FROM sailor WHERE rating >= 8);

SELECT * FROM view3;

-- TRIGGERS

-- A trigger that prevents boats from being deleted If they have active reservations.
DELIMITER $$
CREATE TRIGGER trigger1
BEFORE DELETE ON boat
FOR EACH ROW
BEGIN 
    IF(OLD.bid IN (SELECT bid FROM reservers)) THEN 
        SIGNAL SQLSTATE '45000' SET message_text = 'This boat has active reservations => Cannot delete the boat';
    END IF;
END;$$
DELIMITER ;

DELETE FROM boat WHERE bid = 103;
DROP TRIGGER trigger1;

-- A trigger that prevents sailors with rating less than 3 from reserving a boat.
DELIMITER $$
CREATE TRIGGER trigger2
BEFORE INSERT ON reservers
FOR EACH ROW
BEGIN 
    IF((SELECT rating FROM sailor WHERE sid = NEW.sid) < 3) THEN
        SIGNAL SQLSTATE '45000' SET message_text = "Rating of sailor less than 3, cannot reserve boat";
    END IF;
END;$$
DELIMITER ;

INSERT INTO reservers VALUES
(6, 1, "2023-01-05");


-- A trigger that deletes all expired reservations, (ASSUMPTION - Reservation expires in 2 years)
DELIMITER $$
CREATE TRIGGER trigger3
BEFORE INSERT ON reservers
FOR EACH ROW
BEGIN 
    DELETE FROM reservers 
    WHERE DATEDIFF(curdate(), date) > 2;
END;$$
DELIMITER ;

