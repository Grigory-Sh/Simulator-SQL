/*
Для каждого дня, представленного в таблицах user_actions и courier_actions, рассчитайте следующие показатели:
1. Число платящих пользователей.
2. Число активных курьеров.
3. Долю платящих пользователей в общем числе пользователей на текущий день.
4. Долю активных курьеров в общем числе курьеров на текущий день.
Колонки с показателями назовите соответственно paying_users, active_couriers, paying_users_share,
active_couriers_share. Колонку с датами назовите date. Проследите за тем, чтобы абсолютные показатели были
выражены целыми числами. Все показатели долей необходимо выразить в процентах.
При их расчёте округляйте значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию даты. 
Поля в результирующей таблице: date, paying_users, active_couriers, paying_users_share, active_couriers_share
*/

SELECT date, paying_users,
       active_couriers,
       ROUND(paying_users::DECIMAL / total_users::DECIMAL * 100, 2) AS paying_users_share,
       ROUND(active_couriers::DECIMAL / total_couriers::DECIMAL * 100, 2) AS active_couriers_share
FROM (SELECT time::DATE AS date, COUNT(DISTINCT user_id) AS paying_users
      FROM (SELECT *
            FROM user_actions
            WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
      GROUP BY time::DATE) AS t2
FULL JOIN
     (SELECT time::DATE AS date, COUNT(DISTINCT courier_id) AS active_couriers
      FROM (SELECT *
            FROM courier_actions
            WHERE order_id IN (SELECT order_id FROM courier_actions WHERE action = 'deliver_order')) AS t3
      GROUP BY time::DATE) AS t4
USING (date)
FULL JOIN
     (SELECT date, SUM(COUNT(user_id)) OVER (ORDER BY date)::INTEGER AS total_users
      FROM (SELECT user_id, MIN(time)::DATE AS date
            FROM user_actions
            GROUP BY user_id) AS t5
      GROUP BY date) AS t6
USING (date)
FULL JOIN
     (SELECT date, SUM(COUNT(courier_id)) OVER (ORDER BY date)::INTEGER AS total_couriers
      FROM (SELECT courier_id, MIN(time)::DATE AS date
            FROM courier_actions
            GROUP BY courier_id) AS t7
      GROUP BY date) AS t8
USING (date)
ORDER by date

-- OR

SELECT date,
       paying_users,
       active_couriers,
       round(100 * paying_users::decimal / total_users, 2) as paying_users_share,
       round(100 * active_couriers::decimal / total_couriers, 2) as active_couriers_share
FROM   (SELECT start_date as date,
               new_users,
               new_couriers,
               (sum(new_users) OVER (ORDER BY start_date))::int as total_users,
               (sum(new_couriers) OVER (ORDER BY start_date))::int as total_couriers
        FROM   (SELECT start_date,
                       count(courier_id) as new_couriers
                FROM   (SELECT courier_id,
                               min(time::date) as start_date
                        FROM   courier_actions
                        GROUP BY courier_id) t1
                GROUP BY start_date) t2
            LEFT JOIN (SELECT start_date,
                              count(user_id) as new_users
                       FROM   (SELECT user_id,
                                      min(time::date) as start_date
                               FROM   user_actions
                               GROUP BY user_id) t3
                       GROUP BY start_date) t4 using (start_date)) t5
    LEFT JOIN (SELECT time::date as date,
                      count(distinct courier_id) as active_couriers
               FROM   courier_actions
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
               GROUP BY date) t6 using (date)
    LEFT JOIN (SELECT time::date as date,
                      count(distinct user_id) as paying_users
               FROM   user_actions
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
               GROUP BY date) t7 using (date)