/*
Для каждого дня, представленного в таблицах user_actions и courier_actions, рассчитайте следующие показатели:
1. Число новых пользователей.
2. Число новых курьеров.
3. Общее число пользователей на текущий день.
4. Общее число курьеров на текущий день.
Колонки с показателями назовите соответственно new_users, new_couriers, total_users, total_couriers.
Колонку с датами назовите date. Проследите за тем, чтобы показатели были выражены целыми числами.
Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, new_users, new_couriers, total_users, total_couriers
*/

SELECT date, new_users, new_couriers, SUM(new_users) OVER (ORDER BY date)::INTEGER AS total_users, SUM(new_couriers) OVER (ORDER BY date)::INTEGER AS total_couriers
FROM (SELECT date, COUNT(user_id) AS new_users
      FROM (SELECT user_id, MIN(time)::DATE AS date
            FROM user_actions
            GROUP BY user_id) AS t1
      GROUP BY date) AS t2
FULL JOIN
     (SELECT date, COUNT(courier_id) AS new_couriers
      FROM (SELECT courier_id, MIN(time)::DATE AS date
            FROM courier_actions
            GROUP BY courier_id) AS t3
      GROUP BY date) AS t4
USING (date)

-- OR

SELECT start_date as date,
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
               GROUP BY start_date) t4 using (start_date)