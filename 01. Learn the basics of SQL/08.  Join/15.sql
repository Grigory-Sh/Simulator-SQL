/*
По таблицам courier_actions , orders и products определите 10 самых популярных товаров, доставленных в сентябре 2022 года.
Самыми популярными товарами будем считать те, которые встречались в заказах чаще всего.
Если товар встречается в одном заказе несколько раз (было куплено несколько единиц товара), то при подсчёте учитываем только одну единицу товара.
Выведите наименования товаров и сколько раз они встречались в заказах. Новую колонку с количеством покупок товара назовите times_purchased. 
Поля в результирующей таблице: name, times_purchased
*/

WITH table1 AS (
  SELECT
    order_id
  FROM
    courier_actions
  WHERE
    action = 'deliver_order'
    AND DATE_PART('year', time) = 2022
    AND DATE_PART('month', time) = 09
),
table2 AS (
  SELECT
    order_id,
    UNNEST(product_ids) AS product_id
  FROM
    orders
),
table3 AS (
  SELECT
    DISTINCT *
  FROM
    table2
  WHERE
    order_id IN (
      SELECT
        *
      FROM
        table1
    )
),
table4 AS (
  SELECT
    product_id,
    COUNT(order_id) AS times_purchased
  FROM
    table3
  GROUP BY
    product_id
  ORDER BY
    times_purchased DESC
  LIMIT
    10
)

SELECT
  name,
  times_purchased
FROM
  products
  RIGHT JOIN table4 USING (product_id)
ORDER BY
  times_purchased DESC

-- OR

SELECT
  name,
  count(product_id) AS times_purchased
FROM
  (
    SELECT
      DISTINCT order_id,
      unnest(product_ids) AS product_id
    FROM
      orders
  ) AS t
  LEFT JOIN products USING (product_id)
  RIGHT JOIN courier_actions USING (order_id)
WHERE
  action = 'deliver_order'
  AND date_part('month', time) = 9
  AND date_part('year', time) = 2022
GROUP BY
  name
ORDER BY
  times_purchased DESC
LIMIT
  10