/*
Посчитайте возраст каждого пользователя в таблице users. Возраст измерьте числом полных лет, как мы делали в прошлых уроках.
Возраст считайте относительно последней даты в таблице user_actions. В результат включите колонки с id пользователя и возрастом.
Для тех пользователей, у которых в таблице users не указана дата рождения,
укажите среднее значение возраста всех остальных пользователей, округлённое до целого числа.
Колонку с возрастом назовите age. Результат отсортируйте по возрастанию id пользователя.
Поля в результирующей таблице: user_id, age
*/

WITH table_1 AS (
  SELECT
    MAX(time)
  FROM
    user_actions
)
SELECT
  user_id,
  CASE
    WHEN birth_date IS NOT NULL THEN DATE_PART(
      'year',
      AGE(
        (
          SELECT
            *
          FROM
            table_1
        ),
        birth_date
      )
    )
    ELSE (
      SELECT
        ROUND(
          AVG(
            DATE_PART(
              'year',
              AGE(
                (
                  SELECT
                    *
                  FROM
                    table_1
                ),
                birth_date
              )
            )
          )
        ) AS age
      FROM
        users
      WHERE
        birth_date IS NOT NULL
    )
  END AS age
FROM
  users
ORDER BY
  user_id

-- OR

with users_age as (
  SELECT
    user_id,
    date_part(
      'year',
      age(
        (
          SELECT
            max(time)
          FROM
            user_actions
        ),
        birth_date
      )
    ) as age
  FROM
    users
)

SELECT
  user_id,
  coalesce(
    age,
    (
      SELECT
        round(avg(age))
      FROM
        users_age
    )
  ) as age
FROM
  users_age
ORDER BY
  user_id