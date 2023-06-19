/*
Посчитайте количество товаров в каждом заказе, примените к этим значениям группировку и рассчитайте
количество заказов в каждой группе за неделю с 29 августа по 4 сентября 2022 года включительно.
Для расчётов используйте данные из таблицы orders.
Выведите две колонки: размер заказа и число заказов такого размера за указанный период.
Колонки назовите соответственно order_size и orders_count.
Результат отсортируйте по возрастанию размера заказа.
Поля в результирующей таблице: order_size, orders_count
*/

SELECT
  array_length(product_ids, 1) as order_size,
  count(order_id) as orders_count
FROM
  orders
WHERE
  creation_time >= DATE '2022-08-29'
  AND creation_time < DATE '2022-09-05'
GROUP BY
  order_size
ORDER BY
  order_size asc