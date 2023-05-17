/*
На основе данных в таблице orders для каждого часа в сутках рассчитайте следующие показатели:
1. Число успешных (доставленных) заказов.
2. Число отменённых заказов.
3. Долю отменённых заказов в общем числе заказов (cancel rate).
Колонки с показателями назовите соответственно successful_orders, canceled_orders, cancel_rate.
Колонку с часом оформления заказа назовите hour.
При расчёте доли отменённых заказов округляйте значения до трёх знаков после запятой.
Результирующая таблица должна быть отсортирована по возрастанию колонки с часом оформления заказа.
Поля в результирующей таблице: hour, successful_orders, canceled_orders, cancel_rate
*/

SELECT hour::INTEGER, successful_orders, canceled_orders,
       ROUND(canceled_orders::DECIMAL / (successful_orders + canceled_orders)::DECIMAL, 3) AS cancel_rate
FROM (SELECT DATE_PART('hour', creation_time) AS hour, COUNT(DISTINCT order_id) AS successful_orders
      FROM orders
      WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
      GROUP BY DATE_PART('hour', creation_time)) AS t1
FULL JOIN
     (SELECT DATE_PART('hour', creation_time) AS hour, COUNT(DISTINCT order_id) AS canceled_orders
      FROM orders
      WHERE order_id IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
      GROUP BY DATE_PART('hour', creation_time)) AS t2
USING (hour)
ORDER BY hour

-- OR

SELECT hour,
       successful_orders,
       canceled_orders,
       round(canceled_orders::decimal / (successful_orders + canceled_orders),
             3) as cancel_rate
FROM   (SELECT date_part('hour', creation_time)::int as hour,
               count(order_id) as successful_orders
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY hour) t1
    LEFT JOIN (SELECT date_part('hour', creation_time)::int as hour,
                      count(order_id) as canceled_orders
               FROM   orders
               WHERE  order_id in (SELECT order_id
                                   FROM   user_actions
                                   WHERE  action = 'cancel_order')
               GROUP BY hour) t2 using (hour)
ORDER BY hour