/*
Примените оконные функции к таблице products и с помощью ранжирующих
функций упорядочьте все товары по цене — от самых дорогих к самым дешёвым.
Добавьте в таблицу следующие колонки:
- Колонку product_number с порядковым номером товара (функция ROW_NUMBER).
- Колонку product_rank с рангом товара с пропусками рангов (функция RANK).
- Колонку product_dense_rank с рангом товара без пропусков рангов (функция DENSE_RANK).
Не забывайте указывать в окне сортировку записей — без неё ранжирующие функции могут
давать некорректный результат, если таблица заранее не отсортирована.
Деление на партиции внутри окна сейчас не требуется.
Сортировать записи в результирующей таблице тоже не нужно.
Поля в результирующей таблице: product_id, name, price, product_number, product_rank, product_dense_rank
*/

SELECT
  product_id,
  name,
  price,
  ROW_NUMBER() OVER (
    ORDER BY
      price DESC
  ) AS product_number,
  RANK() OVER (
    ORDER BY
      price DESC
  ) AS product_rank,
  DENSE_RANK() OVER (
    ORDER BY
      price DESC
  ) AS product_dense_rank
FROM
  products