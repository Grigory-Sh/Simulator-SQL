/*
Выясните, кто заказывал и доставлял самые большие заказы. Самыми большими считайте заказы с наибольшим числом товаров.
Выведите id заказа, id пользователя и id курьера. Также в отдельных колонках укажите возраст пользователя и возраст курьера.
Возраст измерьте числом полных лет, как мы делали в прошлых уроках.
Считайте его относительно последней даты в таблице user_actions — как для пользователей, так и для курьеров.
Колонки с возрастом назовите user_age и courier_age. Результат отсортируйте по возрастанию id заказа.
Поля в результирующей таблице: order_id, user_id, user_age, courier_id, courier_age
*/

WITH t1 AS (
  SELECT
    order_id
  FROM
    orders
  WHERE
    ARRAY_LENGTH(product_ids, 1) = (
      SELECT
        MAX(ARRAY_LENGTH(product_ids, 1))
      FROM
        orders
    )
),
t2 AS (
  SELECT
    DISTINCT order_id,
    user_id,
    courier_id
  FROM
    t1
    LEFT JOIN user_actions USING (order_id)
    LEFT JOIN courier_actions USING (order_id)
),
t3 AS (
  SELECT
    MAX(time)
  FROM
    user_actions
),
t4 AS (
  SELECT
    user_id,
    DATE_PART(
      'year',
      AGE(
        (
          SELECT
            *
          FROM
            t3
        ),
        birth_date
      )
    ) AS user_age
  FROM
    users
),
t5 AS (
  SELECT
    courier_id,
    DATE_PART(
      'year',
      AGE(
        (
          SELECT
            *
          FROM
            t3
        ),
        birth_date
      )
    ) AS courier_age
  FROM
    couriers
)
SELECT
  order_id,
  user_id,
  user_age,
  courier_id,
  courier_age
FROM
  t2
  LEFT JOIN t4 USING (user_id)
  LEFT JOIN t5 USING (courier_id)

  -- OR

  with order_id_large_size as (SELECT order_id
                             FROM   orders
                             WHERE  array_length(product_ids, 1) = (SELECT max(array_length(product_ids, 1))
                                                                    FROM   orders))
SELECT DISTINCT order_id,
                user_id,
                date_part('year', age((SELECT max(time)
                       FROM   user_actions), users.birth_date)) as user_age, courier_id, date_part('year', age((SELECT max(time)
                                                                                         FROM   user_actions), couriers.birth_date)) as courier_age
FROM   (SELECT order_id,
               user_id
        FROM   user_actions
        WHERE  order_id in (SELECT *
                            FROM   order_id_large_size)) t1
    LEFT JOIN (SELECT order_id,
                      courier_id
               FROM   courier_actions
               WHERE  order_id in (SELECT *
                                   FROM   order_id_large_size)) t2 using(order_id)
    LEFT JOIN users using(user_id)
    LEFT JOIN couriers using(courier_id)
ORDER BY order_id