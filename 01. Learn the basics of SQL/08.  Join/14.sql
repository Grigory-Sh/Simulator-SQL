/*
Объедините запрос из предыдущего задания с частью запроса, который вы составили в задаче 11,
то есть объедините запрос со стоимостью заказов с запросом, в котором вы считали размер каждого заказа из таблицы user_actions.
На основе объединённой таблицы для каждого пользователя рассчитайте следующие показатели:
- общее число заказов — колонку назовите orders_count
- среднее количество товаров в заказе — avg_order_size
- суммарную стоимость всех покупок — sum_order_value
- среднюю стоимость заказа — avg_order_value
- минимальную стоимость заказа — min_order_value
- максимальную стоимость заказа — max_order_value
Полученный результат отсортируйте по возрастанию id пользователя.
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
Помните, что в расчётах мы по-прежнему учитываем только неотменённые заказы. При расчёте средних значений, округляйте их до двух знаков после запятой.
Поля в результирующей таблице: user_id, orders_count, avg_order_size, sum_order_value, avg_order_value, min_order_value, max_order_value
*/

WITH table1 AS (
  SELECT
    user_id,
    order_id,
    product_id,
    price
  FROM
    (
      SELECT
        *
      FROM
        user_actions
      WHERE
        order_id NOT IN (
          SELECT
            order_id
          FROM
            user_actions
          WHERE
            action = 'cancel_order'
        )
    ) AS t1
    LEFT JOIN (
      SELECT
        order_id,
        UNNEST(product_ids) as product_id
      FROM
        orders
    ) AS t2 USING (order_id)
    LEFT JOIN products USING (product_id)
),
table2 AS (
  SELECT
    order_id,
    SUM(price) AS order_value
  FROM
    table1
  GROUP BY
    order_id
),
table3 AS (
  SELECT
    *
  FROM
    table1 FULL
    JOIN table2 USING (order_id)
)

SELECT
  user_id,
  COUNT(DISTINCT order_id) AS orders_count,
  ROUND(
    COUNT(product_id) :: NUMERIC / COUNT(DISTINCT order_id) :: NUMERIC,
    2
  ) AS avg_order_size,
  SUM(price) AS sum_order_value,
  ROUND(
    SUM(price) :: NUMERIC / COUNT(DISTINCT order_id) :: NUMERIC,
    2
  ) AS avg_order_value,
  MIN(order_value) AS min_order_value,
  MAX(order_value) AS max_order_value
FROM
  table3
GROUP BY
  user_id
ORDER BY
  user_id
LIMIT
  1000

-- OR

SELECT user_id,
       count(order_price) as orders_count,
       round(avg(order_size), 2) as avg_order_size,
       sum(order_price) as sum_order_value,
       round(avg(order_price), 2) as avg_order_value,
       min(order_price) as min_order_value,
       max(order_price) as max_order_value
FROM   (SELECT user_id,
               order_id,
               array_length(product_ids, 1) as order_size
        FROM   (SELECT user_id,
                       order_id
                FROM   user_actions
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
            LEFT JOIN orders using(order_id)) t2
    LEFT JOIN (SELECT order_id,
                      sum(price) as order_price
               FROM   (SELECT order_id,
                              product_ids,
                              unnest(product_ids) as product_id
                       FROM   orders
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')) t3
                   LEFT JOIN products using(product_id)
               GROUP BY order_id) t4 using (order_id)
GROUP BY user_id
ORDER BY user_id limit 1000