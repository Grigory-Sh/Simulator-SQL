/*
На основе данных в таблицах user_actions, courier_actions и orders для каждого дня рассчитайте следующие показатели:
1. Число платящих пользователей на одного активного курьера.
2. Число заказов на одного активного курьера.
3. Колонки с показателями назовите соответственно users_per_courier и orders_per_courier. Колонку с датами назовите date.
При расчёте показателей округляйте значения до двух знаков после запятой.
В расчётах учитывайте только неотменённые заказы. При расчёте числа курьеров учитывайте только тех,
которые в текущий день приняли хотя бы один заказ (который был в последствии доставлен) или доставили любой заказ.
При расчёте числа пользователей также учитывайте только тех, кто сделал хотя бы один заказ.
Результирующая таблица должна быть отсортирована по возрастанию даты.
Поля в результирующей таблице: date, users_per_courier, orders_per_courier
*/

SELECT date,
       ROUND(users_day::DECIMAL / courier_day::DECIMAL, 2) AS users_per_courier,
       ROUND(order_day::DECIMAL / courier_day::DECIMAL, 2) AS orders_per_courier
FROM (SELECT time::DATE AS date, COUNT(DISTINCT user_id) AS users_day, COUNT(DISTINCT order_id) AS order_day
      FROM user_actions
      WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
      GROUP BY time::DATE) AS t1
FULL JOIN
     (SELECT time::DATE AS date, COUNT(DISTINCT courier_id) AS courier_day
      FROM courier_actions
      WHERE order_id IN (SELECT order_id FROM courier_actions WHERE action = 'deliver_order')
      GROUP BY time::DATE) AS t2
USING (date)
ORDER BY date

-- OR

SELECT date,
       round(paying_users::decimal / couriers, 2) as users_per_courier,
       round(orders::decimal / couriers, 2) as orders_per_courier
FROM   (SELECT time::date as date,
               count(distinct courier_id) as couriers
        FROM   courier_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY date) t1 join (SELECT creation_time::date as date,
                               count(distinct order_id) as orders
                        FROM   orders
                        WHERE  order_id not in (SELECT order_id
                                                FROM   user_actions
                                                WHERE  action = 'cancel_order')
                        GROUP BY date) t2 using (date) join (SELECT time::date as date,
                                            count(distinct user_id) as paying_users
                                     FROM   user_actions
                                     WHERE  order_id not in (SELECT order_id
                                                             FROM   user_actions
                                                             WHERE  action = 'cancel_order')
                                     GROUP BY date) t3 using (date)
ORDER BY date