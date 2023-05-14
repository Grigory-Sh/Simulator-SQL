/*
Используя запрос из предыдущего задания, посчитайте, сколько в среднем товаров заказывает каждый пользователь.
Выведите id пользователя и среднее количество товаров в заказе. Среднее значение округлите до двух знаков после запятой.
Колонку посчитанными значениями назовите avg_order_size. Результат выполнения запроса отсортируйте по возрастанию id пользователя. 
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
Поля в результирующей таблице: user_id, avg_order_size
*/

SELECT
  user_id,
  round(avg(array_length(product_ids, 1)), 2) as avg_order_size
FROM
  (
    SELECT
      user_id,
      order_id
    FROM
      user_actions
    WHERE
      order_id not in (
        SELECT
          order_id
        FROM
          user_actions
        WHERE
          action = 'cancel_order'
      )
  ) t1
  LEFT JOIN orders using(order_id)
GROUP BY
  user_id
ORDER BY
  user_id
limit
  1000