


-- (A) roll metrices
-- (B) driver and customer experience


--------------------------------------------------  (A) roll metrices   --------------------------------------------------


-- (1) How many rolls were ordered?

SELECT
    COUNT(*) AS number_of_all_rolls_orders
FROM
    customer_orders;


-- (2a) How many unique customer orders were made?

SELECT
    COUNT(DISTINCT customer_id) AS distinct_customers
FROM
    customer_orders;


-- (2b) How many orders did each unique customer place?

SELECT
    customer_id,
    COUNT(customer_id) AS count_of_orders_from_customers
FROM
    customer_orders
GROUP BY
    customer_id
ORDER BY
    customer_id


-- (3) How many successful orders were delivered by each driver?

SELECT
    driver_id,
    COUNT(DISTINCT order_id) AS no_of_successful_order_delivery_by_each_driver
FROM
    driver_order
WHERE
    cancellation NOT IN ('Cancellation', 'Customer Cancellation')
GROUP BY
    driver_id;


-- (4) How many of each type of roll was delivered?

-- SELECT
--     order_id,
--     driver_id,
--     pickup_time,
--     distance,
--     duration,
--     cancellation
-- FROM
--     driver_order
-- WHERE
--     cancellation NOT IN ('Customer Cancellation', 'Cancellation');

-- above query will not give the correct result since it will ommit the null values 

SELECT
    roll_id,
    COUNT(roll_id) AS numer_of_times_this_roll_was_ordered
FROM
    customer_orders
WHERE
    order_id IN (
        SELECT
            order_id
        FROM
            (
                SELECT
                    *,
                    CASE
                        WHEN cancellation IN ('Cancellation', 'Customer Cancellation') THEN 'c'
                        ELSE 'nc'
                    END AS order_cancel_details
                FROM
                    driver_order
            )
        WHERE
            order_cancel_details = 'nc'
    )
GROUP BY
    roll_id;


-- (5) How many veg and non-veg rolls were ordered by each customer?

SELECT
    a.*,
    b.roll_name
FROM
    (
        SELECT
            customer_id,
            roll_id,
            COUNT(roll_id) cnt
        FROM
            customer_orders
        GROUP BY
            customer_id,
            roll_id
    ) a
    INNER JOIN rolls b ON a.roll_id = b.roll_id;


-- (6) What was the maximum number of rolls delivered in a single order?

SELECT
    *
FROM
    (
        SELECT
            *,
            RANK() OVER (
                ORDER BY
                    cnt desc
            ) rnk
        FROM
            (
                SELECT
                    order_id,
                    COUNT(roll_id) cnt
                FROM
                    (
                        SELECT
                            *
                        FROM
                            customer_orders
                        WHERE
                            order_id IN (
                                SELECT
                                    order_id
                                FROM
                                    (
                                        SELECT
                                            *,
                                            CASE
                                                WHEN cancellation IN ('Cancellation', 'Customer Cancellation') THEN 'c'
                                                ELSE 'nc'
                                            END AS order_cancel_details
                                        FROM
                                            driver_order
                                    )
                                WHERE
                                    order_cancel_details IN ('nc')
                            )
                    )
                GROUP BY
                    order_id
            ) c
    ) d
WHERE
    rnk = 1


-- (7) For each customer, how many delivered rolls had at least one change, and how many had no changes?

WITH temp_customer_orders (
    order_id,
    customer_id,
    roll_id,
    not_include_items,
    extra_items_included,
    order_date
) AS (
    SELECT
        order_id,
        customer_id,
        roll_id,
        CASE
            WHEN not_include_items IS NULL
            OR not_include_items = '' THEN '0'
            ELSE not_include_items
        END AS new_not_include_items,
        CASE
            WHEN extra_items_included IS NULL
            OR extra_items_included = ''
            OR extra_items_included = 'NaN' THEN '0'
            ELSE extra_items_included
        END AS new_extra_items_included,
        order_date
    FROM
        customer_orders
),
temp_driver_order (
    order_id,
    driver_id,
    pickup_time,
    distance,
    duration,
    new_cancellation
) AS (
    SELECT
        order_id,
        driver_id,
        pickup_time,
        distance,
        duration,
        CASE
            WHEN cancellation IN ('Cancellation', 'Customer Cancellation') THEN 0
            ELSE 1
        END AS new_cancellation
    FROM
        driver_order
)
SELECT
    customer_id,
    chg_no_chg,
    COUNT(order_id) AS atleast_one_change
FROM
    (
        SELECT
            *,
            CASE
                WHEN not_include_items = '0'
                AND extra_items_included = '0' THEN 'no change'
                ELSE 'change'
            END AS chg_no_chg
        FROM
            temp_customer_orders
        WHERE
            order_id IN (
                SELECT
                    order_id
                FROM
                    temp_driver_order
                WHERE
                    new_cancellation <> 0
            )
    ) a
GROUP BY
    customer_id,
    chg_no_chg;


-- (8) How many rolls were delivered that had both exclusions and extras?

WITH temp_customer_orders (
    order_id,
    customer_id,
    roll_id,
    not_include_items,
    extra_items_included,
    order_date
) AS (
    SELECT
        order_id,
        customer_id,
        roll_id,
        CASE
            WHEN not_include_items = ''
            OR not_include_items IS NULL THEN '0'
            ELSE not_include_items
        END AS new_not_include_items,
        CASE
            WHEN extra_items_included = ''
            OR extra_items_included = 'NaN'
            OR extra_items_included IS NULL THEN '0'
            ELSE extra_items_included
        END AS new_extra_items_included,
        order_date
    FROM
        customer_orders
),
temp_driver_order (
    order_id,
    driver_id,
    pickup_time,
    distance,
    duration,
    new_cancellation
) AS (
    SELECT
        order_id,
        driver_id,
        pickup_time,
        distance,
        duration,
        CASE
            WHEN cancellation IN ('Cancellation', 'Customer Cancellation') THEN 0
            ELSE 1
        END AS new_cancellation
    FROM
        driver_order
)
SELECT
    chg_no_chg,
    COUNT(chg_no_chg)
FROM
    (
        SELECT
            *,
            CASE
                WHEN not_include_items <> '0'
                AND extra_items_included <> '0' THEN 'both inc exc'
                ELSE 'either 1 inc or exc'
            END chg_no_chg
        FROM
            temp_customer_orders
        WHERE
            order_id IN (
                SELECT
                    order_id
                FROM
                    temp_driver_order
                WHERE
                    new_cancellation <> '0'
            )
    ) a
GROUP BY
    chg_no_chg;


-- (9) What was the total number of rolls ordered for each hour of the day?

SELECT
    hours_bucket,
    COUNT(hours_bucket)
FROM
    (
        SELECT
            *,
            concat(
                EXTRACT(
                    HOUR
                    FROM
                        order_date
                ):: VARCHAR,
                '-',
                (
                    EXTRACT(
                        HOUR
                        FROM
                            order_date
                    ) + 1
                ):: VARCHAR
            ) hours_bucket
        FROM
            customer_orders
    )
GROUP BY
    hours_bucket
ORDER BY
    hours_bucket


-- (10) What was the number of orders for each day of the week?

SELECT
    dow,
    COUNT(DISTINCT order_id)
FROM
    (
        SELECT
            *,
            TO_CHAR(order_date, 'Day') AS dow
        FROM
            customer_orders
    )
GROUP BY
    dow;

    
--------------------------------------------------  (B) driver and customer experience  --------------------------------------------------


-- (1) What was the average time, in minutes, it took for each driver to arrive at the Fasoos HQ to pick up the order?

SELECT
    driver_id,
    SUM(diff) / COUNT(order_id) avg_mins_to_reach_fasoos_hq
FROM
    (
        SELECT
            *
        FROM
            (
                SELECT
                    *,
                    ROW_NUMBER() OVER(
                        PARTITION BY order_id
                        ORDER BY
                            diff
                    ) rnk
                FROM
                    (
                        SELECT
                            a.order_id,
                            a.customer_id,
                            a.roll_id,
                            a.not_include_items,
                            a.extra_items_included,
                            a.order_date,
                            b.driver_id,
                            b.pickup_time,
                            b.distance,
                            b.duration,
                            b.cancellation,
                            EXTRACT(
                                epoch
                                FROM
                                    (b.pickup_time - a.order_date)
                            ) / 60 AS diff
                        FROM
                            customer_orders a
                            INNER JOIN driver_order b ON a.order_id = b.order_id
                        WHERE
                            b.pickup_time IS NOT NULL
                    ) a
            ) b
        WHERE
            rnk = 1
    ) c
GROUP BY
    driver_id


-- (2) Is there any relationship between the number of rolls and the time it takes to prepare the order?

SELECT
    order_id,
    COUNT(roll_id),
    SUM(diff) / COUNT(roll_id) tym
FROM
    (
        SELECT
            a.order_id,
            a.customer_id,
            a.roll_id,
            a.not_include_items,
            a.extra_items_included,
            a.order_date,
            b.driver_id,
            b.pickup_time,
            b.distance,
            b.duration,
            b.cancellation,
            EXTRACT(
                epoch
                FROM
                    (b.pickup_time - a.order_date)
            ) / 60 AS diff
        FROM
            customer_orders a
            INNER JOIN driver_order b ON a.order_id = b.order_id
        WHERE
            b.pickup_time IS NOT NULL
    ) a
GROUP BY
    order_id


-- (3) What was the average distance traveled for each customer?

SELECT
    customer_id,
    SUM(distance) / COUNT(order_id) avg_distance
FROM
    (
        SELECT
            *
        FROM
            (
                SELECT
                    *,
                    ROW_NUMBER() OVER(
                        PARTITION BY order_id
                        ORDER BY
                            diff
                    ) rnk
                FROM
                    (
                        SELECT
                            a.order_id,
                            a.customer_id,
                            a.roll_id,
                            a.not_include_items,
                            a.extra_items_included,
                            a.order_date,
                            b.driver_id,
                            b.pickup_time,
                            TRIM(replace(LOWER(b.distance), 'km', '')):: NUMERIC distance,
                            b.duration,
                            b.cancellation,
                            EXTRACT(
                                epoch
                                FROM
                                    (b.pickup_time - a.order_date)
                            ) / 60 AS diff
                        FROM
                            customer_orders a
                            INNER JOIN driver_order b ON a.order_id = b.order_id
                        WHERE
                            b.pickup_time IS NOT NULL
                    ) a
            ) b
        WHERE
            rnk = 1
    ) c
GROUP BY
    customer_id;


-- (4) What are the longest and shortest delivery times for all orders?

-- select duration, position('m' in duration) from driver_order;

SELECT
    MAX(duration) max_durartion,
    MIN(duration) min_duration,
    MAX(duration) - MIN(duration) diff
FROM
    (
        SELECT
            (
                CASE
                    WHEN duration LIKE '%m%' THEN TRIM(LEFT(duration, POSITION('m' IN duration) -1))
                    ELSE duration
                END
            ):: INTEGER AS duration
        FROM
            driver_order
        WHERE
            duration IS NOT NULL
    ) a;


-- (5) What was the average speed for each driver for each delivery, and do you notice any trends in these values?

SELECT
    order_id,
    driver_id,
    distance_new,
    duration_new,
    distance_new / duration_new AS spped
FROM
    (
        SELECT
            order_id,
            driver_id,
            duration,
            distance,
            (
                CASE
                    WHEN duration LIKE '%m%' THEN TRIM(LEFT(duration, POSITION('m' IN duration) -1))
                    ELSE duration
                END
            ):: INTEGER AS duration_new,
            TRIM(replace(LOWER(distance), 'km', '')):: NUMERIC distance_new
        FROM
            driver_order
        WHERE
            distance IS NOT NULL
    ) a;


-- (6) What is the percentage of successful deliveries for each driver?

SELECT
    driver_id,
    (s * 1.0 / t) * 100 cancelled_per
FROM
    (
        SELECT
            driver_id,
            SUM(can_per) s,
            COUNT(driver_id) t
        FROM
            (
                SELECT
                    driver_id,
                    CASE
                        WHEN LOWER(cancellation) LIKE '%cancel%' THEN 0
                        ELSE 1
                    END AS can_per
                FROM
                    driver_order
            ) a
        GROUP BY
            driver_id
    ) b


