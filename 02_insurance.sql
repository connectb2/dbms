CREATE DATABASE insurance;
USE insurance;

CREATE TABLE person(
    driver_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    address VARCHAR(50) NOT NULL
);

CREATE TABLE car( 
    reg_no VARCHAR(20) PRIMARY KEY,
    model VARCHAR(20) NOT NULL,
    year_ INT NOT NULL
);

CREATE TABLE accident(
    report_no INT PRIMARY key,
    date DATE NOT NULL,
    location VARCHAR(100) NOT NULL
);

CREATE TABLE owns(
    driver_id VARCHAR(10),
    reg_no VARCHAR(20),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
    PRIMARY KEY(driver_id, reg_no)
);


CREATE TABLE participated(
    driver_id VARCHAR(10),
    reg_no VARCHAR(20),
    report_no INT,
    amt INT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
    FOREIGN KEY (report_no) REFERENCES accident(report_no) ON DELETE CASCADE,
    PRIMARY KEY(driver_id, reg_no, report_no)
);


INSERT INTO person VALUES
("D1", "Smith", "Kuvempunagar, Mysore"),
("D2", "Shivkaraman", "JP Nagar, Mysore"),
("D3", "Prajwal", "JSS Layout, Mysore"),
("D4", "Rishabh", "Vijaynagar, Mysore"),
("D5", "Naveen", "Paduvarahalli, Mysore");


INSERT INTO car VALUES
("KA-09-MA-1234", "Swift", 2019),
("KA-09-MM-5644", "Mazda", 2020),
("KA-10-XY-2569", "Tavera", 2021),
("KA-20-AB-2555", "Range Rover", 2022);

INSERT INTO accident VALUES
(12, "2019-10-15", "Vinayakanagar, Mysore"),
(22, "2020-12-25", "Bannimantap, Mysore"),
(28, "2022-10-15", "Gangotri, Mysore"),
(86, "2023-02-15", "Bandipur, Mysore"),
(150, "2023-01-15", "Mandimohalla, Mysore");

INSERT INTO owns VALUES
("D1", "KA-09-MM-5644"),
("D2", "KA-10-XY-2569"),
("D3", "KA-09-MA-1234"),
("D4", "KA-20-AB-2555");

INSERT INTO participated VALUES
("D1", "KA-09-MM-5644", 12, 25000),
("D2", "KA-10-XY-2569", 28, 65000),
("D3", "KA-09-MA-1234", 22, 10000),
("D4", "KA-20-AB-2555", 86, 82458),
("D1", "KA-09-MM-5644", 150, 15000);

-- Find the total number of people who owned cars that were involved in accidents in 2021
SELECT COUNT(DISTINCT driver_id) 
FROM participated 
JOIN accident ON participated.report_no = accident.report_no
WHERE YEAR(accident.date) = 2021;

-- Find the number of accidents in which the cars belonging to “Smith” were involved.
SELECT COUNT(driver_id)
FROM participated
WHERE driver_id = (SELECT driver_id FROM person WHERE name LIKE "%Smith%");

-- Add a new accident to the database; assume any values for required attributes.
insert into accident values
(455, "2023-04-05", "Mandya");

insert into participated values
("D2", "KA-10-XY-2569", 455, 70000);

-- Delete the Mazda belonging to “Smith”.
DELETE FROM car
WHERE model="Mazda" AND reg_no IN(
    SELECT owns.reg_no 
    FROM owns 
    JOIN person ON person.driver_id = owns.driver_id
    WHERE person.name LIKE "%Smith%"
);

-- Update the damage amount for the car with license number “KA09MA1234” in the accident with report.
UPDATE participated
SET amt=10000
WHERE reg_no = "KA-09-MA-1234";



-- VIEWS AND TRIGGERS

-- A view that shows models and year of cars that are involved in accident.
CREATE VIEW view1 AS
SELECT car.model, YEAR(accident.date)
FROM car
JOIN participated ON  car.reg_no = participated.reg_no
JOIN accident ON  accident.report_no = participated.report_no;

SELECT * FROM view1;

-- Create a view that shows the names of the drivers who participated in a accident in a specific place.
SELECT person.name
FROM person
JOIN participated ON  person.driver_id = participated.driver_id
JOIN accident ON  accident.report_no = participated.report_no
WHERE accident.location LIKE "%Mysore%";

-- A trigger that prevents driver with total damage amount >rs.50,000 from owning a car
DELIMITER $$
CREATE TRIGGER trigger1
BEFORE INSERT ON owns
FOR EACH ROW
BEGIN 
    IF((SELECT SUM(amt) FROM participated WHERE driver_id = NEW.driver_id) > 50000) THEN 
        SIGNAL SQLSTATE '45000' SET message_text = "Damage amount > 50000, You cannot own a new car";
    END IF;
END;$$
DELIMITER ;

-- A trigger that prevents a driver from participating in more than 3 accidents in a given year.4
insert into accident values
(905, "2023-01-06", "Mandya");

insert into participated values
("D1", "KA-09-MM-5644", 905, 70000);

DELIMITER $$
CREATE TRIGGER trigger2
BEFORE INSERT ON participated
FOR EACH ROW
BEGIN 
    IF((SELECT COUNT(*) FROM participated WHERE driver_id = NEW.driver_id) >= 3) THEN 
        DELETE FROM accident WHERE report_no = NEW.report_no;
        SIGNAL SQLSTATE '45000' SET message_text = "Driver is already involved in 3 accciddents";
    END IF;
END;$$
DELIMITER ;



