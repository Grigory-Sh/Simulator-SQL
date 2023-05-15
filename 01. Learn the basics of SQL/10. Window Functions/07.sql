/*
На основе запроса из предыдущего задания для каждого пользователя рассчитайте,
сколько в среднем времени проходит между его заказами. Не считайте этот показатель
для тех пользователей, которые за всё время оформили лишь один заказ. Полученное
среднее значение (интервал) переведите в часы, а затем округлите до целого числа.
Колонку со средним значением часов назовите hours_between_orders.
Результат отсортируйте по возрастанию id пользователя.
Добавьте LIMIT 1000.
Поля в результирующей таблице: user_id, hours_between_orders
*/

WITH t2 AS (
  SELECT
    user_id,
    order_id,
    AGE(
      time,
      LAG(time, 1) OVER (
        PARTITION BY user_id
        ORDER BY
          time
      )
    ) AS time_diff
  FROM
    (
      SELECT
        user_id,
        order_id,
        time
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
),
t3 AS (
  SELECT
    *
  FROM
    t2
  WHERE
    time_diff IS NOT NULL
)

SELECT
  user_id,
  ROUND(
    EXTRACT(
      EPOCH
      FROM
        AVG(time_diff)
    ) / 3600
  ) AS hours_between_orders
FROM
  t3
GROUP BY
  user_id
ORDER BY
  user_id ASC
LIMIT
  1000

-- OR

SELECT user_id,
       round(extract(epoch
FROM   avg(time_diff))/3600) as hours_between_orders
FROM   (SELECT user_id,
               order_id,
               time,
               time - lag(time, 1) OVER (PARTITION BY user_id
                                         ORDER BY time) as time_diff
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) t
WHERE  time_diff is not null
GROUP BY user_id
ORDER BY user_id limit 1000