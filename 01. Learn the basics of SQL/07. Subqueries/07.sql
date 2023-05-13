/*
Из таблицы user_actions с помощью подзапроса или табличного выражения отберите все заказы,
которые не были отменены пользователями. Выведите колонку с id этих заказов.
Результат запроса отсортируйте по возрастанию id заказа.
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
Поле в результирующей таблице: order_id
*/

WITH canceled_orders AS (
  SELECT
    order_id
  FROM
    user_actions
  WHERE
    action = 'cancel_order'
)

SELECT
  order_id
FROM
  user_actions
WHERE
  order_id NOT IN (
    SELECT
      *
    FROM
      canceled_orders
  )
ORDER BY
  order_id ASC
LIMIT
  1000