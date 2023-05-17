/*
Для каждого дня в таблицах orders и user_actions рассчитайте следующие показатели:
1. Выручку, полученную в этот день.
2. Выручку с заказов новых пользователей, полученную в этот день.
3. Долю выручки с заказов новых пользователей в общей выручке, полученной за этот день.
4. Долю выручки с заказов остальных пользователей в общей выручке, полученной за этот день.
Колонки с показателями назовите соответственно revenue, new_users_revenue, new_users_revenue_share, old_users_revenue_share.
Колонку с датами назовите date. Все показатели долей необходимо выразить в процентах.
При их расчёте округляйте значения до двух знаков после запятой. Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, revenue, new_users_revenue, new_users_revenue_share, old_users_revenue_share
*/

SELECT date, revenue, new_users_revenue,
       ROUND(new_users_revenue / revenue * 100, 2) AS new_users_revenue_share,
       ROUND((revenue - new_users_revenue) / revenue * 100, 2) AS old_users_revenue_share
FROM (SELECT date, SUM(price) AS revenue
      FROM (SELECT order_id, creation_time::DATE AS date, UNNEST(product_ids) AS product_id
            FROM orders
            WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
      LEFT JOIN products USING (product_id)
      GROUP BY date) AS t1
FULL JOIN
     (SELECT date, SUM(orders_cost) AS new_users_revenue
      FROM (SELECT MIN(time)::DATE AS date, user_id
            FROM user_actions
            GROUP BY user_id) AS t2
      LEFT JOIN
           (SELECT date, user_id, SUM(order_cost) AS orders_cost
            FROM (SELECT date, order_id, SUM(price) AS order_cost
                  FROM (SELECT order_id, creation_time::DATE AS date, UNNEST(product_ids) AS product_id
                        FROM orders
                        WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t3
                  LEFT JOIN products USING (product_id)
                  GROUP BY date, order_id) AS t4
            FULL JOIN 
                 (SELECT time::DATE AS date, user_id, order_id
                  FROM user_actions
                  WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t5
            USING (date, order_id)
            GROUP BY date, user_id) AS t6
      USING (date, user_id)
      GROUP BY date) AS t7
USING (date)
ORDER BY date

-- OR

SELECT date,
       revenue,
       new_users_revenue,
       round(new_users_revenue / revenue * 100, 2) as new_users_revenue_share,
       100 - round(new_users_revenue / revenue * 100, 2) as old_users_revenue_share
FROM   (SELECT creation_time::date as date,
               sum(price) as revenue
        FROM   (SELECT order_id,
                       creation_time,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t3
            LEFT JOIN products using (product_id)
        GROUP BY date) t1
    LEFT JOIN (SELECT start_date as date,
                      sum(revenue) as new_users_revenue
               FROM   (SELECT t5.user_id,
                              t5.start_date,
                              coalesce(t6.revenue, 0) as revenue
                       FROM   (SELECT user_id,
                                      min(time::date) as start_date
                               FROM   user_actions
                               GROUP BY user_id) t5
                           LEFT JOIN (SELECT user_id,
                                             date,
                                             sum(order_price) as revenue
                                      FROM   (SELECT user_id,
                                                     time::date as date,
                                                     order_id
                                              FROM   user_actions
                                              WHERE  order_id not in (SELECT order_id
                                                                      FROM   user_actions
                                                                      WHERE  action = 'cancel_order')) t7
                                          LEFT JOIN (SELECT order_id,
                                                            sum(price) as order_price
                                                     FROM   (SELECT order_id,
                                                                    unnest(product_ids) as product_id
                                                             FROM   orders
                                                             WHERE  order_id not in (SELECT order_id
                                                                                     FROM   user_actions
                                                                                     WHERE  action = 'cancel_order')) t9
                                                         LEFT JOIN products using (product_id)
                                                     GROUP BY order_id) t8 using (order_id)
                                      GROUP BY user_id, date) t6
                               ON t5.user_id = t6.user_id and
                                  t5.start_date = t6.date) t4
               GROUP BY start_date) t2 using (date)