/*
Произведите замену списков с id товаров из таблицы orders на списки с наименованиями товаров.
Наименования возьмите из таблицы products. Колонку с новыми списками наименований назовите product_names. 
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
Поля в результирующей таблице: order_id, product_names
*/

SELECT
  order_id,
  ARRAY_AGG(name) AS product_names
FROM
  (
    SELECT
      order_id,
      product_id,
      name
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
  order_id ASC
LIMIT
  1000

-- OR

SELECT order_id,
       array_agg(name) as product_names
FROM   (SELECT order_id,
               unnest(product_ids) as product_id
        FROM   orders) t join products using(product_id)
GROUP BY order_id limit 1000