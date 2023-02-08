-- DROP DATABASE orderProcessing;
CREATE DATABASE orderProcessing;
USE orderProcessing;


CREATE TABLE customer(
    cust_id INT PRIMARY KEY,
    cname VARCHAR(30) NOT NULL,
    city VARCHAR(15) NOT NULL
);

CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    odate DATE NOT NULL,
    cust_id INT,
    order_amt INT,
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id) ON DELETE CASCADE 
);

CREATE TABLE item(
    item_id INT PRIMARY KEY,
    unit_price INT NOT NULL
);

CREATE TABLE warehouse(
    w_id INT PRIMARY KEY,
    city VARCHAR(15) NOT NULL
);

CREATE TABLE order_item(
    order_id INT,
    item_id INT,
    qty INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE CASCADE,
    PRIMARY KEY(order_id)
);

CREATE TABLE shipment(
    order_id INT,
    w_id INT,
    ship_date DATE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (w_id) REFERENCES warehouse(w_id) ON DELETE CASCADE,
    PRIMARY KEY(order_id)
);

INSERT INTO customer VALUES
(1, "customer1", "Banglore"),
(2, "customer2", "Mysore"),
(3, "Kumar", "Delhi"),
(4, "customer4", "Chennai"),
(5, "customer5", "Hydrabad");

INSERT INTO orders VALUES
(1, "2020-10-21", 1, 2000),
(2, "2021-02-25", 2, 500),
(3, "2022-11-10", 3, 2500),
(4, "2023-01-30", 3, 1000),
(5, "2023-01-01", 4, 1200),
(6, "2018-04-05", 5, 6000);

INSERT INTO item VALUES
(1, 400),
(2, 200),
(3, 1000),
(4, 100),
(5, 500);

INSERT INTO warehouse VALUES
(1, "Banglore"),
(2, "Chennai"),
(3, "Delhi"),
(4, "Mumbai");

INSERT INTO order_item VALUES
(1, 2, 5),
(2, 1, 1),
(3, 4, 5),
(4, 3, 1),
(5, 5, 12),
(6, 3, 6);

INSERT INTO shipment VALUES
(1, 1, "2020-10-24"),
(2, 2, "2021-03-01"),
(3, 3, "2022-11-17"),
(4, 2, "2023-02-03"),
(5, 3, "2023-01-10"),
(6, 4, "2018-04-15");


-- List the Order# and Ship_date for all orders shipped from Warehouse# "W2".
SELECT order_id, ship_date
FROM shipment
WHERE w_id = 2;

-- List the Warehouse information from which the Customer named "Kumar" was supplied his orders. Produce a listing of Order#, Warehouse#.
SELECT shipment.order_id, shipment.w_id
FROM shipment
JOIN orders ON shipment.order_id = orders.order_id
JOIN customer ON customer.cust_id = orders.cust_id
WHERE customer.cname = "Kumar";

-- Produce a listing: Cname, #ofOrders, Avg_Order_Amt  for that customer.
SELECT customer.cname, COUNT(orders.order_id) AS OrderCount, AVG(orders.order_amt) AS AvgOrderAmt
FROM orders
JOIN customer ON customer.cust_id = orders.cust_id
GROUP BY (orders.cust_id);


-- Delete all orders for customer named "Kumar".
DELETE FROM orders
WHERE cust_id IN (
    SELECT cust_id
    FROM customer
    WHERE  cname = "Kumar"
);

-- Find the item with the maximum unit price.
SELECT item_id
FROM item 
WHERE unit_price = (
    SELECT MAX(unit_price)
    FROM item
);


-- VIEWS AND TRIGGERS

-- Create a view to display orderID and shipment date of all orders shipped from a warehouse 2.
CREATE VIEW view1 AS
SELECT order_id, ship_date
FROM shipment
WHERE w_id = 2;

SELECT * FROM view1;

-- A view that shows the warehouse name from where the kumar’s order is been shipped
SELECT warehouse.w_id, warehouse.city 
FROM warehouse
JOIN shipment ON warehouse.w_id = shipment.w_id
JOIN orders ON shipment.order_id = orders.order_id
WHERE orders.cust_id = (
    SELECT cust_id 
    FROM customer 
    WHERE cname LIKE "%Kumar"
);

-- A tigger that updates order_amount based on quantity and unit price of order_item
DELIMITER $$
CREATE TRIGGER trigger1
AFTER INSERT ON order_item
FOR EACH ROW
BEGIN
    UPDATE orders 
    SET orders.order_amt = orders.order_amt + NEW.qty * (SELECT unit_price FROM item WHERE item_id = NEW.item_id)
    WHERE orders.order_id = NEW.order_id;
END; $$
DELIMITER ;

