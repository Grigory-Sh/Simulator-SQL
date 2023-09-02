/*
Из таблицы orders выведите id и содержимое заказов,
которые включают хотя бы один из пяти самых дорогих товаров,
доступных в нашем сервисе.
Результат отсортируйте по возрастанию id заказа.
Поля в результирующей таблице: order_id, product_ids

Пояснение:
В этой задаче вам снова пригодится функция unnest.
Также для упрощения кода можно использовать табличные выражения.
*/

WITH table_1 AS (
  SELECT
    order_id,
    UNNEST(product_ids) AS product_id
  FROM
    orders
),
table_2 AS (
  SELECT
    DISTINCT order_id
  FROM
    table_1
  WHERE
    product_id IN (
      SELECT
        product_id
      FROM
        products
      ORDER BY
        price DESC
      LIMIT
        5
    )
)

SELECT
  order_id,
  product_ids
FROM
  orders
WHERE
  order_id IN (
    SELECT
      *
    FROM
      table_2
  )
ORDER BY
  order_id ASC

-- OR

with top_products as (SELECT product_id
                      FROM   products
                      ORDER BY price desc limit 5), unnest as (SELECT order_id,
                                                product_ids,
                                                unnest(product_ids) as product_id
                                         FROM   orders)
SELECT DISTINCT order_id,
                product_ids
FROM   unnest
WHERE  product_id in (SELECT product_id
                      FROM   top_products)
ORDER BY order_id