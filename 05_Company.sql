-- DROP DATABASE company;
CREATE DATABASE company;
USE company;

CREATE TABLE employee(
    ssn VARCHAR(10) PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    address VARCHAR(100) NOT NULL,
    sex VARCHAR(1) NOT NULL,
    salary INT NOT NULL,
    super_ssn VARCHAR(10),
    dno INT 
);

ALTER TABLE employee
ADD FOREIGN KEY(super_ssn) REFERENCES employee(ssn) ON DELETE SET NULL;

CREATE TABLE department(      
    dno INT PRIMARY KEY,
    dname VARCHAR(30) NOT NULL,
    mgr_ssn VARCHAR(10),
    mgr_stdt DATE,
    FOREIGN KEY (mgr_ssn) REFERENCES employee(ssn) ON DELETE SET NULL
);

CREATE TABLE dlocation(
    dno INT,
    dloc VARCHAR(30),
    FOREIGN KEY (dno) REFERENCES department(dno) ON DELETE CASCADE,
    PRIMARY KEY(dno, dloc)
);

CREATE TABLE project(
    pno INT PRIMARY KEY,
    pname VARCHAR(50) NOT NULL,
    plocation VARCHAR(30) NOT NULL,
    dno INT,
    FOREIGN KEY (dno) REFERENCES department(dno) ON DELETE CASCADE
);

CREATE TABLE works_on(
    ssn VARCHAR(10),
    pno INT,
    hours INT,
    FOREIGN KEY (ssn) REFERENCES employee(ssn) ON DELETE CASCADE,
    FOREIGN KEY (pno) REFERENCES project(pno) ON DELETE CASCADE,
    PRIMARY KEY (ssn, pno)
);  

INSERT INTO employee VALUES
("11225", "Shiv Shambo", "Rajajinagar, Banglore", "M", 1500000, NULL, NULL),
("85462", "Brenden Scott", "Kuvempnagar, Mysore", "M", 100000, NULL, NULL),
("79135", "Kriti Shetti", "Borivali, Mumbai", "F", 2000000, NULL, NULL),
("71826", "Anushka Sengi", "Gurgaon, Delhi", "F", 500000, NULL, NULL),
("93824", "Mark Mansion", "Ahemdabad, Gujarat", "M", 400000, NULL, NULL),
("92824", "Mary Kom", "Haryana, UP", "F", 800000, NULL, NULL),
("82465", "Mark Henry", "Ahemdabad, Gujarat", "M", 600000, NULL, NULL);

UPDATE employee SET super_ssn = "11225" WHERE ssn = "79135";
UPDATE employee SET super_ssn = "93824" WHERE ssn = "71826";
UPDATE employee SET super_ssn =  "82465" WHERE ssn = "92824";

INSERT INTO department VALUES
(1, "Accounts", "11225", "2022-10-21"),
(2, "R&D", "85462", "2020-01-11"),
(3, "Quality Assesment", "82465", "2022-11-11"),
(4, "Production", "93824", "2022-11-11");

UPDATE employee SET dno = 4 WHERE ssn = "11225";
UPDATE employee SET dno = 2 WHERE ssn = "85462";
UPDATE employee SET dno = 1 WHERE ssn = "79135";
UPDATE employee SET dno = 3 WHERE ssn = "71826";
UPDATE employee SET dno = 2 WHERE ssn = "93824";
UPDATE employee SET dno = 3 WHERE ssn = "92824";
UPDATE employee SET dno = 1 WHERE ssn = "82465";

INSERT INTO dlocation VALUES
(1, "Jaynagar, Bengaluru"),
(2, "Vijaynagar, Mysuru"),
(3, "Chennai, Tamil Nadu"),
(4, "Kuvempunagar, Mysuru");

INSERT INTO Project VALUES
(1, "System Testing", "Mumbai, Maharashtra", 4),
(2, "IOT", "JP Nagar, Bengaluru", 1),
(3, "Product Optimization", "Hyderabad, Telangana", 3),
(4, "Yeild Increase", "Kuvempunagar, Mysuru", 1),
(5, "Product Refinement", "Saraswatipuram, Mysuru", 2);

INSERT INTO works_on VALUES
("11225", 1, 18),
("85462", 2, 26),
("79135", 4, 48),
("71826", 3, 12),
("93824", 1, 6),
("92824", 4, 16),
("82465", 2, 36);

-- Make a list of all project numbers for projects that involve an employee whose last name is ‘Scott’, either as a worker or as a manager of the department that controls the project.
SELECT p.pno
FROM project p
JOIN works_on w ON p.pno = w.pno
JOIN employee e ON e.ssn = w.ssn
WHERE e.name LIKE "%Scott"
UNION
SELECT p.pno
FROM project p
JOIN works_on w ON p.pno = w.pno
JOIN employee e ON e.ssn = w.ssn
JOIN department d ON e.ssn = d.mgr_ssn
WHERE e.name LIKE "%Scott";


-- Show the resulting salaries if every employee working on the ‘IoT’ project is given a 10 percent raise
SELECT e.name, e.salary AS OldSalary, e.salary * 1.1 AS NewSalary
FROM employee e
JOIN works_on w ON e.ssn = w.ssn
JOIN project p ON w.pno = p.pno
WHERE p.pno IN(
    SELECT pno
    FROM project 
    WHERE pname="IOT"
);

-- Find the sum of the salaries of all employees of the ‘Accounts’ department, as well as the maximum salary, the minimum salary, and the average salary in this department
SELECT SUM(e.salary), MAX(e.salary), MIN(e.salary)
FROM employee e
JOIN department d ON d.dno = e.dno
WHERE d.dname = "Accounts";

-- Retrieve the name of each employee who works on all the projects controlled by department number 1 (use NOT EXISTS operator).
SELECT name
FROM employee
WHERE NOT EXISTS (
    SELECT *
    FROM project
    WHERE project.dno = 1
    AND project.pno NOT IN (
        SELECT pno
        FROM works_on
        WHERE works_on.ssn = employee.ssn
    )
);

-- For each department that has more than five employees, retrieve the department number and the number of its employees who are making more than Rs. 6,00,000.
SELECT dno, COUNT(ssn)
FROM employee
WHERE salary > 600000
GROUP BY(dno)
HAVING COUNT(ssn) > 5;


-- Create a view that shows name, dept name and location of all employees.
CREATE VIEW view1 AS
SELECT  e.name, d.dname, dl.dloc
FROM employee e 
JOIN department d ON e.dno = d.dno
JOIN dlocation dl ON d.dno = dl.dno;

SELECT * FROM view1;

-- Create a trigger that prevents a project from being deleted if it is currently being worked by any employee
DELIMITER $$
CREATE TRIGGER trigger1
BEFORE DELETE ON project
FOR EACH ROW
    BEGIN 
        IF (EXISTS(SELECT * FROM works_on WHERE pno = OLD.pno)) THEN
            SIGNAL SQLSTATE '45000' SET message_text = "Project being worked, it cannot be deleted";
        END IF;
    END; $$
DELIMITER ;

