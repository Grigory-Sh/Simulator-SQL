/*
Выведите id и содержимое 100 последних доставленных заказов из таблицы orders.
Содержимым заказов считаются списки с id входящих в заказ товаров.
Результат отсортируйте по возрастанию id заказа.
Поля в результирующей таблице: order_id, product_ids

Пояснение:
Обратите внимание, что содержимое заказов находится в таблице orders, а информация о действиях с заказами — в таблице courier_actions.
*/

SELECT
  order_id,
  product_ids
FROM
  orders
WHERE
  order_id IN (
    SELECT
      order_id
    FROM
      courier_actions
    WHERE
      action = 'deliver_order'
    ORDER BY
      time DESC
    LIMIT
      100
  )
ORDER BY
  order_id ASC