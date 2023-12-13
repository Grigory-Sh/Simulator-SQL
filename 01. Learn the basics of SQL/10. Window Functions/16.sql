/*
На основе информации в таблицах orders и products рассчитайте стоимость каждого заказа,
ежедневную выручку сервиса и долю стоимости каждого заказа в ежедневной выручке,
выраженную в процентах. В результат включите следующие колонки: id заказа, время
создания заказа, стоимость заказа, выручку за день, в который был совершён заказ,
а также долю стоимости заказа в выручке за день, выраженную в процентах.
При расчёте долей округляйте их до трёх знаков после запятой.
Результат отсортируйте сначала по убыванию даты совершения заказа (именно даты, а не времени),
потом по убыванию доли заказа в выручке за день, затем по возрастанию id заказа.
При проведении расчётов отменённые заказы не учитывайте.
Поля в результирующей таблице:
order_id, creation_time, order_price, daily_revenue, percentage_of_daily_revenue
*/

WITH t1 AS (
  SELECT
    order_id,
    creation_time,
    UNNEST(product_ids) AS product_id
  FROM
    orders
  WHERE
    order_id NOT IN (
      SELECT
        order_id
      FROM
        user_actions
      WHERE
        action = 'cancel_order'
    )
),
t2 AS (
  SELECT
    order_id,
    creation_time,
    price
  FROM
    t1
    LEFT JOIN products USING (product_id)
),
t3 AS (
  SELECT
    order_id,
    creation_time,
    SUM(price) AS order_price
  FROM
    t2
  GROUP BY
    order_id,
    creation_time
),
t4 AS (
  SELECT
    order_id,
    creation_time,
    order_price,
    SUM(order_price) OVER (PARTITION BY creation_time :: DATE) daily_revenue
  FROM
    t3
)

SELECT
  order_id,
  creation_time,
  order_price,
  daily_revenue,
  ROUND(
    order_price :: DECIMAL / daily_revenue :: DECIMAL * 100,
    3
  ) AS percentage_of_daily_revenue
FROM
  t4
ORDER BY
  creation_time :: DATE DESC,
  percentage_of_daily_revenue DESC,
  order_id ASC

-- OR

SELECT order_id,
       creation_time,
       order_price,
       sum(order_price) OVER(PARTITION BY date(creation_time)) as daily_revenue,
       round(100 * order_price::decimal / sum(order_price) OVER(PARTITION BY date(creation_time)),
             3) as percentage_of_daily_revenue
FROM   (SELECT order_id,
               creation_time,
               sum(price) as order_price
        FROM   (SELECT order_id,
                       creation_time,
                       product_ids,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t3
            LEFT JOIN products using(product_id)
        GROUP BY order_id, creation_time) t
ORDER BY date(creation_time) desc, percentage_of_daily_revenue desc, order_id