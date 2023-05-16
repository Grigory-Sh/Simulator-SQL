/*
Для каждого дня, представленного в таблице user_actions, рассчитайте следующие показатели:
1. Долю пользователей, сделавших в этот день всего один заказ, в общем количестве платящих пользователей.
2. Долю пользователей, сделавших в этот день несколько заказов, в общем количестве платящих пользователей.
Колонки с показателями назовите соответственно single_order_users_share, several_orders_users_share.
Колонку с датами назовите date. Все показатели с долями необходимо выразить в процентах.
При расчёте долей округляйте значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, single_order_users_share, several_orders_users_share
*/

SELECT date,
       ROUND(single_order_users::DECIMAL / (single_order_users + several_orders_users)::DECIMAL * 100, 2) AS single_order_users_share,
       ROUND(several_orders_users::DECIMAL / (single_order_users + several_orders_users)::DECIMAL * 100, 2) AS several_orders_users_share
FROM (SELECT date, COUNT(user_id) FILTER (WHERE orders = 1) AS single_order_users, COUNT(user_id) FILTER (WHERE orders > 1) AS several_orders_users
      FROM (SELECT date, user_id, COUNT(order_id) AS orders
            FROM (SELECT user_id, order_id, time::DATE AS date
                  FROM user_actions
                  WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
            GROUP BY date, user_id) AS t2
      GROUP BY date) AS t3
ORDER BY date

-- OR

SELECT date,
       round(100 * single_order_users::decimal / paying_users,
             2) as single_order_users_share,
       100 - round(100 * single_order_users::decimal / paying_users,
                   2) as several_orders_users_share
FROM   (SELECT time::date as date,
               count(distinct user_id) as paying_users
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY date) t1
    LEFT JOIN (SELECT date,
                      count(user_id) as single_order_users
               FROM   (SELECT time::date as date,
                              user_id,
                              count(distinct order_id) as user_orders
                       FROM   user_actions
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')
                       GROUP BY date, user_id having count(distinct order_id) = 1) t2
               GROUP BY date) t3 using (date)
ORDER BY date