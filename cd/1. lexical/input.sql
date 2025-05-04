SELECT name, age FROM users WHERE age > 21;

INSERT INTO customers VALUES ('John Doe', 35, 'john@example.com');
UPDATE products 
SET price = price * 0.9 
WHERE category = 'electronics';

DELETE FROM orders WHERE order_date < '2023-01-01';

CREATE TABLE employees (id INT PRIMARY KEY, name VARCHAR(100), department VARCHAR(50));
SELECT o.order_id, c.name, p.product_name
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
WHERE o.status = 'completed' AND p.category = 'books';