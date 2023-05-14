/*
Используя запрос из предыдущего задания, рассчитайте суммарную стоимость каждого заказа.
Выведите колонки с id заказов и их стоимостью. Колонку со стоимостью заказа назовите order_price.
Результат отсортируйте по возрастанию id заказа.
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
Поля в результирующей таблице: order_id, order_price
*/

SELECT
  order_id,
  SUM(price) AS order_price
FROM
  (
    SELECT
      order_id,
      product_id,
      price
    FROM
      (
        SELECT
          order_id,
          UNNEST(product_ids) AS product_id
        FROM
          orders
      ) AS t1
      LEFT JOIN products USING (product_id)
  ) AS t2
GROUP BY
  order_id
ORDER BY
  order_id
LIMIT
  1000