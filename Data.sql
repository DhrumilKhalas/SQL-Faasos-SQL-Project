


DROP TABLE IF EXISTS driver;


CREATE TABLE driver(driver_id INTEGER, reg_date DATE);


INSERT INTO
    driver(driver_id, reg_date)
VALUES
    (1, TO_DATE('01-01-2021', 'MM-DD-YYYY')),
    (2, TO_DATE('01-03-2021', 'MM-DD-YYYY')),
    (3, TO_DATE('01-08-2021', 'MM-DD-YYYY')),
    (4, TO_DATE('01-15-2021', 'MM-DD-YYYY'));


DROP TABLE if EXISTS ingredients;


CREATE TABLE ingredients(
    ingredients_id INTEGER,
    ingredients_name VARCHAR(60)
);


INSERT INTO
    ingredients(ingredients_id, ingredients_name)
VALUES
    (1, 'BBQ Chicken'),
    (2, 'Chilli Sauce'),
    (3, 'Chicken'),
    (4, 'Cheese'),
    (5, 'Kebab'),
    (6, 'Mushrooms'),
    (7, 'Onions'),
    (8, 'Egg'),
    (9, 'Peppers'),
    (10, 'schezwan sauce'),
    (11, 'Tomatoes'),
    (12, 'Tomato Sauce');


DROP TABLE if EXISTS rolls;


CREATE TABLE rolls(roll_id INTEGER, roll_name VARCHAR(30));


INSERT INTO
    rolls(roll_id, roll_name)
VALUES
    (1, 'Non Veg Roll'),
    (2, 'Veg Roll');


DROP TABLE if EXISTS rolls_recipes;


CREATE TABLE rolls_recipes(roll_id INTEGER, ingredients VARCHAR(24));


INSERT INTO
    rolls_recipes(roll_id, ingredients)
VALUES
    (1, '1,2,3,4,5,6,8,10'),
    (2, '4,6,7,9,11,12');


DROP TABLE if EXISTS driver_order;


CREATE TABLE driver_order(
    order_id INTEGER,
    driver_id INTEGER,
    pickup_time TIMESTAMP,
    distance VARCHAR(7),
    duration VARCHAR(10),
    cancellation VARCHAR(23)
);


INSERT INTO
    driver_order(
        order_id,
        driver_id,
        pickup_time,
        distance,
        duration,
        cancellation
    )
VALUES
    (1, 1, '01-01-2021 18:15:34', '20km', '32 minutes', ''),
    (2, 1, '01-01-2021 19:10:54', '20km', '27 minutes', ''),
    (3, 1, '01-03-2021 00:12:37', '13.4km', '20 mins', 'NaN'),
    (4, 2, '01-04-2021 13:53:03', '23.4', '40', 'NaN'),
    (5, 3, '01-08-2021 21:10:57', '10', '15', 'NaN'),
    (6, 3, NULL, NULL, NULL, 'Cancellation'),
    (7, 2, '01-08-2020 21:30:45', '25km', '25mins', NULL),
    (8, 2, '01-10-2020 00:15:02', '23.4 km', '15 minute', NULL),
    (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
    (10, 1, '01-11-2020 18:50:20', '10km', '10minutes', NULL);


DROP TABLE if EXISTS customer_orders;


CREATE TABLE customer_orders(
    order_id INTEGER,
    customer_id INTEGER,
    roll_id INTEGER,
    not_include_items VARCHAR(4),
    extra_items_included VARCHAR(4),
    order_date TIMESTAMP
);


INSERT INTO
    customer_orders(
        order_id,
        customer_id,
        roll_id,
        not_include_items,
        extra_items_included,
        order_date
    )
VALUES
    (1, 101, 1, '', '', '01-01-2021  18:05:02'),
    (2, 101, 1, '', '', '01-01-2021 19:00:52'),
    (3, 102, 1, '', '', '01-02-2021 23:51:23'),
    (3, 102, 2, '', 'NaN', '01-02-2021 23:51:23'),
    (4, 103, 1, '4', '', '01-04-2021 13:23:46'),
    (4, 103, 1, '4', '', '01-04-2021 13:23:46'),
    (4, 103, 2, '4', '', '01-04-2021 13:23:46'),
    (5, 104, 1, NULL, '1', '01-08-2021 21:00:29'),
    (6, 101, 2, NULL, NULL, '01-08-2021 21:03:13'),
    (7, 105, 2, NULL, '1', '01-08-2021 21:20:29'),
    (8, 102, 1, NULL, NULL, '01-09-2021 23:54:33'),
    (9, 103, 1, '4', '1,5', '01-10-2021 11:22:59'),
    (10, 104, 1, NULL, NULL, '01-11-2021 18:34:49'),
    (10, 104, 1, '2,6', '1,4', '01-11-2021 18:34:49');


SELECT
    *
FROM
    customer_orders;


SELECT
    *
FROM
    driver_order;


SELECT
    *
FROM
    ingredients;


SELECT
    *
FROM
    driver;


SELECT
    *
FROM
    rolls;

    
SELECT
    *
FROM
    rolls_recipes;


