/*
На основе данных в таблице user_actions рассчитайте показатель дневного Retention для
всех пользователей, разбив их на когорты по дате первого взаимодействия с нашим приложением.
В результат включите четыре колонки: месяц первого взаимодействия, дату первого взаимодействия,
количество дней, прошедших с даты первого взаимодействия (порядковый номер дня начиная с 0),
и само значение Retention.
Колонки со значениями назовите соответственно start_month, start_date, day_number, retention.
Метрику необходимо выразить в виде доли, округлив полученные значения до двух знаков после запятой.
Месяц первого взаимодействия укажите в виде даты, округлённой до первого числа месяца.
Результат должен быть отсортирован сначала по возрастанию даты первого взаимодействия,
затем по возрастанию порядкового номера дня.
Поля в результирующей таблице: start_month, start_date, day_number, retention
*/

SELECT DATE_TRUNC('month', start_date)::DATE AS start_month,
       start_date,
       date - start_date AS day_number,
       ROUND(users::DECIMAL / MAX(users) OVER (PARTITION BY start_date), 2) AS retention
FROM (SELECT start_date, date, COUNT(DISTINCT user_id) AS users
      FROM (SELECT MIN(time::DATE) OVER (PARTITION BY user_id) AS start_date, time::DATE AS date, user_id
            FROM user_actions) AS t1
      GROUP BY start_date, date) AS t2
ORDER BY start_date, day_number

-- OR

SELECT date_trunc('month', start_date)::date as start_month,
       start_date,
       date - start_date as day_number,
       round(users::decimal / max(users) OVER (PARTITION BY start_date), 2) as retention
FROM   (SELECT start_date,
               time::date as date,
               count(distinct user_id) as users
        FROM   (SELECT user_id,
                       time::date,
                       min(time::date) OVER (PARTITION BY user_id) as start_date
                FROM   user_actions) t1
        GROUP BY start_date, time::date) t2