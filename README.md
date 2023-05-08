# Simulator SQL

Схема базы данных:
![logo](Database_Schema.jpg)

## Типы данных

В таблицах могут храниться разные типы данных: целые и дробные числа, текст, даты, массивы из чисел. В наших данных вы встретитесь со следующими типами:
| Тип данных | Описание | Пример |
--- | --- | ---
INT | Целое число | id пользователя: 132
NUMERIC / DECIMAL | Вещественное число | Стоимость товара: 120.55
VARCHAR | Текст | Действие с заказом: «create_order»
DATE | Дата с точностью до дня | Дата рождения пользователя: 25/03/91
TIMESTAMP | Дата с точностью до секунды | Время регистрации в приложении: 24/08/22 01:52:24
[] | Массив | Список id товаров в заказе: [1, 13, 22]

## Структура и наполнение таблиц

### user_actions действия пользователей с заказами.
| Столбец | Тип данных | Описание |
--- | --- | ---
user_id | INT | id пользователя
order_id | INT | id заказа
action | VARCHAR(50) | действие пользователя с заказом; 'create_order' — создание заказа, 'cancel_order' — отмена заказа
time | TIMESTAMP | время совершения действия

### courier_actions — действия курьеров с заказами.
| Столбец | Тип данных | Описание |
--- | --- | ---
courier_id | INT | id курьера
order_id | INT | id заказа
action | VARCHAR(50) | действие курьера с заказом; 'accept_order' — принятие заказа, 'deliver_order' — доставка заказа
time | TIMESTAMP | время совершения действия

### orders — информация о заказах.
| Столбец | Тип данных | Описание |
--- | --- | ---
order_id | INT | id заказа 
creation_time | TIMESTAMP | время создания заказа
product_ids | integer[] | список id товаров в заказе

### users — информация о пользователях.
| Столбец | Тип данных | Описание |
--- | --- | ---
user_id | INT | id пользователя
birth_date | DATE | дата рождения
sex | VARCHAR(50) | пол

### couriers — информация о курьерах.
| Столбец | Тип | данных | Описание |
--- | --- | ---
courier_id | INT | id курьера
birth_date | DATE | дата рождения
sex | VARCHAR(50) | пол

### products — информация о товарах, которые доставляет сервис.
| Столбец | Тип данных | Описание |
--- | --- | ---
product_id | INT | id продукта
name | VARCHAR(50) | название товара
price | FLOAT(4) | цена товара

##### Примечание:
В скобках у типа данных __VARCHAR__ указано максимально допустимое количество символов в тексте. У типа данных __NUMERIC__ в скобках указано общее число знаков.