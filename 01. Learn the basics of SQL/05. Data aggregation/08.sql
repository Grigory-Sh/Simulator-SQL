/*
Представьте, что один из пользователей сервиса сделал заказ, в который вошли одна пачка сухариков, одна пачка чипсов и один энергетический напиток.
Посчитайте стоимость такого заказа.
Колонку с рассчитанной стоимостью заказа назовите order_price.
Для расчётов используйте таблицу products.
Поле в результирующей таблице: order_price
*/

SELECT
  SUM(price) AS order_price
FROM
  products
WHERE
  name IN ('сухарики', 'чипсы', 'энергетический напиток')