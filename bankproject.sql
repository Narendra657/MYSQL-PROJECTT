CREATE DATABASE BankDB;
USE BankDB;

-- customer table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    dob DATE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    address VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- account table
CREATE TABLE Accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    account_type ENUM('Savings','Current','Fixed Deposit'),
    balance DECIMAL(12,2) DEFAULT 0.00,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Transactions Table
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    type ENUM('Deposit','Withdrawal','Transfer'),
    amount DECIMAL(12,2),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Loans Table
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    loan_type ENUM('Home','Car','Personal','Education'),
    loan_amount DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);


-- Customers
INSERT INTO Customers (first_name, last_name, dob, email, phone, address)
VALUES 
('Ramesh', 'Kumar', '1990-05-14', 'ramesh@gmail.com', '9876543210', 'Hyderabad'),
('Sita', 'Reddy', '1995-08-20', 'sita@gmail.com', '9876501234', 'Bangalore');

-- Accounts
INSERT INTO Accounts (customer_id, account_type, balance)
VALUES 
(1, 'Savings', 25000.00),
(2, 'Current', 50000.00);

-- Transactions
INSERT INTO Transactions (account_id, type, amount)
VALUES
(1, 'Deposit', 10000.00),
(1, 'Withdrawal', 2000.00),
(2, 'Deposit', 15000.00);

-- Loans
INSERT INTO Loans (customer_id, loan_type, loan_amount, interest_rate, start_date, end_date)
VALUES
(1, 'Home', 500000.00, 7.5, '2023-01-01', '2033-01-01'),
(2, 'Car', 300000.00, 8.0, '2024-02-01', '2029-02-01');

-- Select all customers
SELECT * FROM Customers;

SELECT DISTINCT account_type FROM Accounts;

-- where clause
SELECT * FROM Accounts WHERE balance > 50000;

-- order by clauses 
SELECT * FROM Customers ORDER BY last_name ASC;

--  AND / OR / NOT
SELECT * FROM Loans 
WHERE loan_amount > 100000 AND loan_type = 'Home Loan';
 
SELECT * FROM Accounts 
WHERE account_type = 'Savings' OR balance > 100000;

SELECT * FROM Customers 
WHERE NOT address = 'Hyderabad';
 
-- insert into statement
INSERT INTO Customers (first_name, last_name, email, phone, city)
VALUES ('Ravi', 'Kumar', 'ravi@email.com', '9876543210', 'Chennai');

-- NULL VALUES
SELECT * FROM Customers WHERE email IS NULL;

-- UPDATE statement
UPDATE Accounts SET balance = balance + 5000 WHERE account_id = 2;

-- DELETE statement
DELETE FROM Customers WHERE customer_id = 5;

-- LIMIT 
SELECT * FROM Accounts ORDER BY balance DESC LIMIT 5;

-- AGGREGATE FUNCTIONS (MIN, MAX, COUNT, SUM, AVG)
SELECT MIN(balance) AS MinBalance, MAX(balance) AS MaxBalance FROM Accounts;

SELECT COUNT(*) AS TotalCustomers FROM Customers;

SELECT SUM(balance) AS TotalBankBalance FROM Accounts;

SELECT AVG(balance) AS AverageBalance FROM Accounts;

-- -- LIKE / WILDCARDS
SELECT * FROM Customers WHERE first_name LIKE 'R%';   -- starts 
SELECT * FROM Customers WHERE email LIKE '%.com';     -- ends 

-- N / BETWEEN
SELECT * FROM Accounts WHERE account_type IN ('Savings','Current');

SELECT * FROM Loans WHERE loan_amount BETWEEN 50000 AND 200000;

-- -- INNER JOIN
SELECT c.first_name, a.account_type, a.balance
FROM Customers c
INNER JOIN Accounts a ON c.customer_id = a.customer_id;

-- LEFT JOIN
SELECT c.first_name, a.account_type, a.balance
FROM Customers c
LEFT JOIN Accounts a ON c.customer_id = a.customer_id;

-- RIGHT JOIN
SELECT c.first_name, a.account_type, a.balance
FROM Customers c
RIGHT JOIN Accounts a ON c.customer_id = a.customer_id;


-- SELF JOIN

SELECT A.first_name AS Customer1, B.first_name AS Customer2, A.city
FROM Customers A, Customers B
WHERE A.city = B.city AND A.customer_id <> B.customer_id;

-- alter statement
ALTER TABLE Customers ADD dob DATE;
ALTER TABLE Customers DROP COLUMN dob;
ALTER TABLE Accounts MODIFY balance DECIMAL(15,2);

-- CASE CONDITIONS
SELECT account_id, balance,
CASE 
    WHEN balance < 10000 THEN 'Low Balance'
    WHEN balance BETWEEN 10000 AND 50000 THEN 'Medium Balance'
    ELSE 'High Balance'
END AS BalanceStatus
FROM Accounts;



-- 


-- TRIGGERRS APPLY AUTOMATIC UPDATE BALANCE AFTER TRANSACATION 
DELIMITER $$

CREATE TRIGGER update_balance_after_transaction
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    IF NEW.type = 'Deposit' THEN
        UPDATE Accounts 
        SET balance = balance + NEW.amount 
        WHERE account_id = NEW.account_id;
    ELSEIF NEW.type = 'Withdrawal' THEN
        UPDATE Accounts 
        SET balance = balance - NEW.amount 
        WHERE account_id = NEW.account_id;
    END IF;
END$$

DELIMITER ;


-- STORED PROCEDURES
DELIMITER $$

CREATE PROCEDURE TransferMoney(
    IN sender_id INT,
    IN receiver_id INT,
    IN amount DECIMAL(12,2)
)
BEGIN
    -- Deduct from sender
    INSERT INTO Transactions (account_id, type, amount)
    VALUES (sender_id, 'Withdrawal', amount);

    -- Add to receiver
    INSERT INTO Transactions (account_id, type, amount)
    VALUES (receiver_id, 'Deposit', amount);
END$$

DELIMITER ;






