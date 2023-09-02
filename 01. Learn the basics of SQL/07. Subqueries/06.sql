/*
С помощью функции AGE() и агрегирующей функции снова рассчитайте возраст самого молодого курьера мужского пола в таблице couriers,
но в этот раз в качестве первой даты используйте последнюю дату из таблицы courier_actions.
Чтобы получилась именно дата, перед применением функции AGE() переведите посчитанную последнюю дату в формат DATE.
Возраст курьера измерьте количеством лет, месяцев и дней и переведите его в тип VARCHAR. Полученную колонку со значением возраста назовите min_age.
Поле в результирующей таблице: min_age

Пояснение:
В этой задаче результат подзапроса выступает в качестве аргумента функции. Чтобы весь запрос выглядел компактнее,
для приведения данных к другому типу можно использовать формат записи с двумя двоеточиями — ::.
Также обратите внимание, что для получения необходимого результата мы обращаемся к разным таблицам в рамках одного общего запроса.
*/

SELECT
  MIN(
    AGE(
      (
        SELECT
          MAX(time) :: DATE
        FROM
          courier_actions
      ),
      birth_date
    )
  ) :: VARCHAR AS min_age
FROM
  couriers
WHERE
  sex = 'male'