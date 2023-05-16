/*
Для каждого дня, представленного в таблице user_actions, рассчитайте следующие показатели:
1. Общее число заказов.
2. Число первых заказов (заказов, сделанных пользователями впервые).
3. Число заказов новых пользователей (заказов, сделанных пользователями в тот же день, когда они впервые воспользовались сервисом).
4. Долю первых заказов в общем числе заказов (долю п.2 в п.1).
5. Долю заказов новых пользователей в общем числе заказов (долю п.3 в п.1).
Колонки с показателями назовите соответственно orders, first_orders, new_users_orders, first_orders_share, new_users_orders_share.
Колонку с датами назовите date. Проследите за тем, чтобы во всех случаях количество заказов было выражено целым числом.
Все показатели с долями необходимо выразить в процентах. При расчёте долей округляйте значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, orders, first_orders, new_users_orders, first_orders_share, new_users_orders_share
*/

SELECT date, orders, first_orders, new_users_orders,
       ROUND(first_orders::DECIMAL / orders::DECIMAL * 100, 2) AS first_orders_share,
       ROUND(new_users_orders::DECIMAL / orders::DECIMAL * 100, 2) AS new_users_orders_share
FROM (SELECT time::DATE AS date, COUNT(order_id) AS orders
      FROM user_actions
      WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
      GROUP BY time::DATE
      ORDER BY date) AS t1
FULL JOIN
     (SELECT time::DATE as date, COUNT(user_id) AS first_orders
      FROM (SELECT user_id, MIN(time) AS time
            FROM user_actions
            WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
            GROUP BY user_id) AS t2
      GROUP BY time::DATE
      ORDER BY date) AS t3
USING (date)
FULL JOIN
     (SELECT date, SUM(orders) FILTER (WHERE orders != 0)::INTEGER AS new_users_orders
      FROM (SELECT date, user_id, COALESCE(orders, 0) AS orders
            FROM (SELECT user_id, MIN(time)::DATE AS date
                  FROM user_actions
                  GROUP BY user_id
                  ORDER BY date) AS t4
            LEFT JOIN
                 (SELECT time::DATE AS date, user_id, COUNT(order_id) AS orders
                 FROM user_actions
                 WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
                 GROUP BY time, user_id
                 ORDER BY time, user_id) AS t5
            USING (date, user_id)) AS t6
      GROUP BY date) AS t7
USING (date)
ORDER BY date

-- OR

SELECT date,
       orders,
       first_orders,
       new_users_orders::int,
       round(100 * first_orders::decimal / orders, 2) as first_orders_share,
       round(100 * new_users_orders::decimal / orders, 2) as new_users_orders_share
FROM   (SELECT creation_time::date as date,
               count(distinct order_id) as orders
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
           and order_id in (SELECT order_id
                         FROM   courier_actions
                         WHERE  action = 'deliver_order')
        GROUP BY date) t5
    LEFT JOIN (SELECT first_order_date as date,
                      count(user_id) as first_orders
               FROM   (SELECT user_id,
                              min(time::date) as first_order_date
                       FROM   user_actions
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')
                       GROUP BY user_id) t4
               GROUP BY first_order_date) t7 using (date)
    LEFT JOIN (SELECT start_date as date,
                      sum(orders) as new_users_orders
               FROM   (SELECT t1.user_id,
                              t1.start_date,
                              coalesce(t2.orders, 0) as orders
                       FROM   (SELECT user_id,
                                      min(time::date) as start_date
                               FROM   user_actions
                               GROUP BY user_id) t1
                           LEFT JOIN (SELECT user_id,
                                             time::date as date,
                                             count(distinct order_id) as orders
                                      FROM   user_actions
                                      WHERE  order_id not in (SELECT order_id
                                                              FROM   user_actions
                                                              WHERE  action = 'cancel_order')
                                      GROUP BY user_id, date) t2
                               ON t1.user_id = t2.user_id and
                                  t1.start_date = t2.date) t3
               GROUP BY start_date) t6 using (date)
ORDER BY date