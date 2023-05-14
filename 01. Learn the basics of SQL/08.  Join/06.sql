/*
Для начала сгруппируем две таблицы по колонке birth_date и посчитаем,
сколько пользователей/курьеров родились в каждый из дней.
Для этого можете выполнить в Redash следующие запросы: 

SELECT birth_date, COUNT(user_id) AS users_count
FROM users
WHERE birth_date IS NOT NULL
GROUP BY birth_date

SELECT birth_date, COUNT(courier_id) AS couriers_count
FROM couriers
WHERE birth_date IS NOT NULL
GROUP BY birth_date

В результате у вас получатся две таблицы с уникальными датами и количеством людей, родившихся в каждый из дней. Давайте их объединим.

С помощью FULL JOIN объедините по ключу birth_date таблицы, полученные в результате вышеуказанных запросов
(то есть объедините друг с другом два подзапроса). Не нужно изменять их, просто добавьте нужный join.
В результат включите две колонки с birth_date из обеих таблиц.
Эти две колонки назовите соответственно users_birth_date и couriers_birth_date.
Также включите в результат колонки с числом пользователей и курьеров — users_count и couriers_count.
Отсортируйте получившуюся таблицу сначала по колонке users_birth_date по возрастанию, затем по колонке couriers_birth_date — тоже по возрастанию.
Поля в результирующей таблице: users_birth_date, users_count,  couriers_birth_date, couriers_count
*/

SELECT
  t1.birth_date AS users_birth_date,
  users_count,
  t2.birth_date AS couriers_birth_date,
  couriers_count
FROM
  (
    SELECT
      birth_date,
      COUNT(user_id) AS users_count
    FROM
      users
    WHERE
      birth_date IS NOT NULL
    GROUP BY
      birth_date
  ) AS t1 FULL
  JOIN (
    SELECT
      birth_date,
      COUNT(courier_id) AS couriers_count
    FROM
      couriers
    WHERE
      birth_date IS NOT NULL
    GROUP BY
      birth_date
  ) AS t2 USING (birth_date)
ORDER BY
  users_birth_date ASC,
  couriers_birth_date ASC