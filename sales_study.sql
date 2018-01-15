mysql> CREATE TABLE salespersons
    -> (
    -> id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    -> name VARCHAR(20) NOT NULL,
    -> age INT NOT NULL,
    -> salary INT NOT NULL
    -> ) ENGINE=INNODB;
Query OK, 0 rows affected (0.43 sec)

mysql> INSERT INTO salespersons (name, age, salary)
    -> VALUES ('Abe', 61, 140000),
    -> ('Bob', 34, 44000),
    -> ('Chris', 34, 40000),
    -> ('Dan', 41, 52000),
    -> ('Ken', 57, 115000),
    -> ('Joe', 38, 38000)
    -> ;
Query OK, 6 rows affected (0.07 sec)
Records: 6  Duplicates: 0  Warnings: 0

mysql> CREATE TABLE customers
    -> (
    -> id INT PRIMARY KEY,
    -> name VARCHAR(20) NOT NULL,
    -> city VARCHAR(20) NOT NULL,
    -> industry_type CHAR NOT NULL
    -> ) ENGINE=INNODB;
Query OK, 0 rows affected (0.76 sec)

mysql>
mysql> INSERT INTO customers VALUES(1,'Samsonic','Pleasant','J'),(2,'Panasung','Oaktown','J'),(3,'Samony','Jackson','B'),(4,'Orange','Jackson','B');
Query OK, 4 rows affected (0.08 sec)
Records: 4  Duplicates: 0  Warnings: 0

mysql> CREATE TABLE orders(
    -> id INT PRIMARY KEY,
    -> order_date DATE NOT NULL,
    -> cust_id INT NOT NULL,
    -> salesperson_id INT NOT NULL,
    -> amount INT NOT NULL,
    -> FOREIGN KEY(cust_id) REFERENCES customers(id),
    -> FOREIGN KEY(salesperson_id) REFERENCES salespersons(id)
    -> )
    -> ENGINE=INNODB;
Query OK, 0 rows affected (0.53 sec)

mysql> INSERT INTO orders VALUES(1,'2013/1/8',1,2,540),(2,'2013/1/13',1,5,1800),(3,'2013/1/17',4,1,460),(4,'2013/2/2',3,2,2400),(5,'2013/2/3',2,4,600),(6,'2013/2/3',2,4,720),(7,'2013/3/5',4,4,150);
Query OK, 7 rows affected (0.07 sec)
Records: 7  Duplicates: 0  Warnings: 0


1)
mysql> SELECT distinct s.id, s.name, s.age, s.salary
    -> FROM salespersons AS s JOIN orders AS o
    -> ON s.id=o.salesperson_id
    -> JOIN customers AS c
    -> ON c.id=o.cust_id
    -> WHERE c.name='Samsonic';
+----+------+-----+--------+
| id | name | age | salary |
+----+------+-----+--------+
|  2 | Bob  |  34 |  44000 |
|  5 | Ken  |  57 | 115000 |
+----+------+-----+--------+
2 rows in set (0.01 sec)

2)
mysql> SELECT name
    -> FROM orders JOIN salespersons
    -> ON orders.salesperson_id=salespersons.id
    -> GROUP BY salesperson_id
    -> HAVING count(*)>1;
+------+
| name |
+------+
| Bob  |
| Dan  |
+------+
2 rows in set (0.00 sec)

3)
mysql> SELECT name, max(order_date) AS last_date
    -> FROM salespersons LEFT JOIN orders
    -> ON orders.salesperson_id=salespersons.id
    -> GROUP BY salesperson_id
    -> HAVING SUBDATE(CURDATE(), 15) > last_date;
+------+------------+
| name | last_date  |
+------+------------+
| Abe  | 2013-01-17 |
| Bob  | 2013-02-02 |
| Dan  | 2013-03-05 |
| Ken  | 2013-01-13 |
+------+------------+
4 rows in set (0.01 sec)

4)
mysql> SELECT o1.salesperson_id, o1.amount, name
    -> FROM orders AS o1 JOIN orders AS o2
    -> JOIN salespersons
    -> ON o1.salesperson_id=salespersons.id
    -> GROUP BY o1.amount, o2.amount
    -> HAVING COUNT(*) >= 1
    -> ORDER BY o1.amount DESC, o2.amount DESC
    -> LIMIT 1;
+----------------+--------+------+
| salesperson_id | amount | name |
+----------------+--------+------+
|              2 |   2400 | Bob  |
+----------------+--------+------+
1 row in set (0.00 sec)

5)
mysql> SELECT salespersons.name AS salesperson_name, GROUP_CONCAT(DISTINCT customers.industry_type) AS industry_types
    -> FROM salespersons JOIN orders
    -> ON orders.salesperson_id=salespersons.id
    -> JOIN customers
    -> ON orders.cust_id=customers.id
    -> GROUP BY salespersons.id;
+------------------+----------------+
| salesperson_name | industry_types |
+------------------+----------------+
| Abe              | B              |
| Bob              | J,B            |
| Dan              | B,J            |
| Ken              | J              |
+------------------+----------------+
4 rows in set (0.00 sec)

6)
mysql> SELECT salesperson_id, GROUP_CONCAT(distinct industry_type) AS industry_types, SUM(amount) AS total_amount
    -> FROM orders JOIN customers
    -> ON orders.cust_id=customers.id
    -> GROUP BY salesperson_id;
+----------------+----------------+--------------+
| salesperson_id | industry_types | total_amount |
+----------------+----------------+--------------+
|              1 | B              |          460 |
|              2 | J,B            |         2940 |
|              4 | B,J            |         1470 |
|              5 | J              |         1800 |
+----------------+----------------+--------------+
4 rows in set (0.00 sec)
