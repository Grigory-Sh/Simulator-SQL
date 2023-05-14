/*
Снова объедините таблицы user_actions и orders, но теперь оставьте только уникальные
неотменённые заказы (мы делали похожий запрос на прошлом уроке).
Остальные условия задачи те же: вывести id пользователей и заказов, а также список товаров в заказе.
Отсортируйте таблицу по id пользователя по возрастанию, затем по id заказа — тоже по возрастанию.
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
Поля в результирующей таблице: user_id, order_id, product_ids
*/

SELECT
  user_id,
  order_id,
  product_ids
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
ORDER BY
  user_id,
  order_id
limit
  1000