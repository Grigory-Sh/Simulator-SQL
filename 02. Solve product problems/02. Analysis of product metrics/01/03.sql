/*

*/

SELECT date,
       ROUND(running_revenue / running_active_users, 2) AS running_arpu,
       ROUND(running_revenue / running_paying_users, 2) AS running_arppu ,
       ROUND(running_revenue / running_orders, 2) AS running_aov
FROM (SELECT date, SUM(SUM(price)) OVER (ORDER BY date) AS running_revenue
      FROM (SELECT creation_time::DATE AS date, order_id, UNNEST(product_ids) AS product_id
            FROM orders
            WHERE order_id NOT  IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
      LEFT JOIN products USING (product_id)
      GROUP BY date) AS t2
FULL JOIN
     (SELECT date, SUM(COUNT(user_id)) OVER (ORDER BY date) AS running_active_users
      FROM (SELECT user_id, MIN(time)::DATE AS date
            FROM user_actions
            GROUP BY user_id) AS t3
      GROUP BY date) AS t4
USING (date)
FULL JOIN
     (SELECT date, SUM(COUNT(user_id)) OVER (ORDER BY date) AS running_paying_users
      FROM (SELECT user_id, MIN(time)::DATE AS date
            FROM user_actions
            WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
            GROUP BY user_id) AS t5
      GROUP BY date) AS t6
USING (date)
FULL JOIN
     (SELECT date, SUM(COUNT(DISTINCT order_id)) OVER (ORDER BY date) AS running_orders
      FROM (SELECT MIN(time)::DATE AS date, order_id
            FROM user_actions
            WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
            GROUP BY order_id) AS t7
      GROUP BY date) AS t8
USING (date)
ORDER BY date

-- OR

SELECT date,
       round(sum(revenue) OVER (ORDER BY date)::decimal / sum(new_users) OVER (ORDER BY date),
             2) as running_arpu,
       round(sum(revenue) OVER (ORDER BY date)::decimal / sum(new_paying_users) OVER (ORDER BY date),
             2) as running_arppu,
       round(sum(revenue) OVER (ORDER BY date)::decimal / sum(orders) OVER (ORDER BY date),
             2) as running_aov
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
    LEFT JOIN (SELECT date,
                      count(user_id) as new_users
               FROM   (SELECT user_id,
                              min(time::date) as date
                       FROM   user_actions
                       GROUP BY user_id) t5
               GROUP BY date) t6 using (date)
    LEFT JOIN (SELECT date,
                      count(user_id) as new_paying_users
               FROM   (SELECT user_id,
                              min(time::date) as date
                       FROM   user_actions
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')
                       GROUP BY user_id) t7
               GROUP BY date) t8 using (date)