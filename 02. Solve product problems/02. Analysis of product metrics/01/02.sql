/*
Для каждого дня в таблицах orders и user_actions рассчитайте следующие показатели:
1. Выручку на пользователя (ARPU) за текущий день.
2. Выручку на платящего пользователя (ARPPU) за текущий день.
3. Выручку с заказа, или средний чек (AOV) за текущий день.
Колонки с показателями назовите соответственно arpu, arppu, aov. Колонку с датами назовите date. 
При расчёте всех показателей округляйте значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию даты. 
Поля в результирующей таблице: date, arpu, arppu, aov
*/

SELECT date, ROUND(revenue / active_users, 2) AS arpu, ROUND(revenue / paying_users, 2) AS arppu, ROUND(revenue / orders, 2) AS aov
FROM (SELECT date, SUM(price) AS revenue
      FROM (SELECT order_id, creation_time::DATE AS date, UNNEST(product_ids) AS product_id
            FROM orders
            WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
      LEFT JOIN products USING (product_id)
      GROUP BY date) AS t2
FULL JOIN
     (SELECT time::DATE AS date,
             COUNT(DISTINCT user_id) AS active_users,
             COUNT(DISTINCT user_id) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS paying_users,
             COUNT(DISTINCT order_id) FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS orders
      FROM user_actions
      GROUP BY time::DATE) AS t3
USING (date)
ORDER BY date

-- OR

SELECT date,
       round(revenue::decimal / users, 2) as arpu,
       round(revenue::decimal / paying_users, 2) as arppu,
       round(revenue::decimal / orders, 2) as aov
FROM   (SELECT creation_time::date as date,
               count(distinct order_id) as orders,
               sum(price) as revenue
        FROM   (SELECT order_id,
                       creation_time,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
            LEFT JOIN products using(product_id)
        GROUP BY date) t2
    LEFT JOIN (SELECT time::date as date,
                      count(distinct user_id) as users
               FROM   user_actions
               GROUP BY date) t3 using (date)
    LEFT JOIN (SELECT time::date as date,
                      count(distinct user_id) as paying_users
               FROM   user_actions
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
               GROUP BY date) t4 using (date)
ORDER BY date