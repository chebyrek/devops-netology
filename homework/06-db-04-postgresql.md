# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД  
`\l[+]   [PATTERN]`
- подключения к БД  
`\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}`
- вывода списка таблиц  
`\dt[S+] [PATTERN]`
- вывода описания содержимого таблиц  
`\d[S+]  NAME`
- выхода из psql  
`\q`

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.
```sql
select attname 
from pg_stats 
where tablename='orders' 
      and avg_width in (
                      select MAX(avg_width) 
                      from pg_stats 
                      where tablename='orders'
                      );

 attname 
---------
 title
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.
```sql
begin;

CREATE TABLE public.new_orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
);

create table orders_1 (
    check (price > 499)
) inherits (new_orders);

create table orders_2 (
    check (price <= 499)
) inherits (new_orders);

INSERT INTO orders_1 (id,title,price)
SELECT id,title,price
from orders
where price > 499;

INSERT INTO orders_2 (id,title,price)
SELECT id,title,price
from orders
where price <= 499;

ALTER TABLE orders RENAME TO orders_bk;
ALTER TABLE new_orders RENAME TO orders;

create rule orders_insert_to_1 
as on insert to orders 
where (price > 499) 
do instead 
      insert into orders_1 values(new.*);
      
create rule orders_insert_to_2 
as on insert to orders 
where (price <= 499) 
do instead 
      insert into orders_2 values(new.*);
      
drop table orders_bk;

commit;
```
Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?  

Можно, нужно использовать условие `PARTITION BY` при создании основной таблицы, после создать дополнительные таблицы, используя `PARTITION OF`

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

Добавить к параметрам столбца `UNIQUE`
```sql
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL UNIQUE,
    price integer DEFAULT 0
);
```
---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
