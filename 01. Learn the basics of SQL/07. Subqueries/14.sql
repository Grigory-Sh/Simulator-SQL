/*
Отберите из таблицы users пользователей мужского пола,
которые старше всех пользователей женского пола.
Выведите две колонки: id пользователя и дату рождения.
Результат отсортируйте по возрастанию id пользователя.
Поля в результирующей таблице: user_id, birth_date
*/

SELECT
  user_id,
  birth_date
FROM
  users
WHERE
  sex = 'male'
  and birth_date < (
    SELECT
      MIN(birth_date) AS birth_date
    FROM
      users
    WHERE
      sex = 'female'
  )
ORDER BY
  user_id