/*
С помощью оконной функции рассчитайте медианную стоимость всех заказов из таблицы orders, оформленных в нашем сервисе.
В качестве результата выведите одно число. Колонку с ним назовите median_price. Отменённые заказы не учитывайте.
Поле в результирующей таблице: median_price
*/

WITH t1 AS (
  SELECT
    order_id,
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
    price
  FROM
    t1
    LEFT JOIN products USING (product_id)
),
t3 AS (
  SELECT
    SUM(price) AS order_price,
    ROW_NUMBER() OVER (
      ORDER BY
        SUM(price)
    ) AS number
  FROM
    t2
  GROUP BY
    order_id
)

SELECT
  DISTINCT CASE
    WHEN (
      SELECT
        COUNT(order_price)
      FROM
        t3
    ) % 2 = 0 THEN (
      (
        SELECT
          order_price
        FROM
          t3
        WHERE
          number = (
            SELECT
              COUNT(order_price)
            FROM
              t3
          ) / 2
      ) + (
        SELECT
          order_price
        FROM
          t3
        WHERE
          number = (
            SELECT
              COUNT(order_price)
            FROM
              t3
          ) / 2 + 1
      )
    ) :: DECIMAL / 2
    ELSE (
      SELECT
        order_price
      FROM
        t3
      WHERE
        number = (
          SELECT
            COUNT(order_price)
          FROM
            t3
        ) / 2 + 1
    )
  END AS median_price
FROM
  t3