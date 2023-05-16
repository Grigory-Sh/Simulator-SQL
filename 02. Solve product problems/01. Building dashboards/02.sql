/*
Дополните запрос из предыдущего задания и теперь для каждого дня, представленного
в таблицах user_actions и courier_actions, дополнительно рассчитайте следующие показатели:
1. Прирост числа новых пользователей.
2. Прирост числа новых курьеров.
3. Прирост общего числа пользователей.
4. Прирост общего числа курьеров.
Показатели, рассчитанные на предыдущем шаге, также включите в результирующую таблицу.
Колонки с новыми показателями назовите соответственно new_users_change, new_couriers_change,
total_users_growth, total_couriers_growth. Колонку с датами назовите date.
Все показатели прироста считайте в процентах относительно значений в предыдущий день.
При расчёте показателей округляйте значения до двух знаков после запятой.
Результирующая таблица должна быть отсортирована по возрастанию даты.
Поля в результирующей таблице: date, new_users, new_couriers, total_users, total_couriers, 
new_users_change, new_couriers_change, total_users_growth, total_couriers_growth
*/

SELECT date, new_users, new_couriers, total_users, total_couriers,
       ROUND((new_users - LAG(new_users, 1) OVER ())::DECIMAL / LAG(new_users, 1) OVER ()::DECIMAL * 100, 2) AS new_users_change,
       ROUND((new_couriers - LAG(new_couriers, 1) OVER ())::DECIMAL / LAG(new_couriers, 1) OVER ()::DECIMAL * 100, 2) AS new_couriers_change,
       ROUND((total_users - LAG(total_users, 1) OVER ())::DECIMAL / LAG(total_users, 1) OVER ()::DECIMAL * 100, 2) AS total_users_growth,
       ROUND((total_couriers - LAG(total_couriers, 1) OVER ())::DECIMAL / LAG(total_couriers, 1) OVER ()::DECIMAL * 100, 2) AS total_couriers_growth
FROM (SELECT date, new_users, new_couriers,
             SUM(new_users) OVER (ORDER BY date)::INTEGER AS total_users,
             SUM(new_couriers) OVER (ORDER BY date)::INTEGER AS total_couriers
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
      USING (date)) AS t5

-- OR

SELECT date,
       new_users,
       new_couriers,
       total_users,
       total_couriers,
       round(100 * (new_users - lag(new_users, 1) OVER (ORDER BY date)) / lag(new_users, 1) OVER (ORDER BY date)::decimal,
             2) as new_users_change,
       round(100 * (new_couriers - lag(new_couriers, 1) OVER (ORDER BY date)) / lag(new_couriers, 1) OVER (ORDER BY date)::decimal,
             2) as new_couriers_change,
       round(100 * new_users::decimal / lag(total_users, 1) OVER (ORDER BY date),
             2) as total_users_growth,
       round(100 * new_couriers::decimal / lag(total_couriers, 1) OVER (ORDER BY date),
             2) as total_couriers_growth
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