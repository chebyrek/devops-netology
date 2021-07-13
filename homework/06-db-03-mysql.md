# Домашнее задание к занятию "6.3. MySQL"


## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
```
Server version:         8.0.25 MySQL Community Server - GPL
```

Подключитесь к восстановленной БД и получите список таблиц из этой БД.
```mysql
mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```
**Приведите в ответе** количество записей с `price` > 300.
```sql
select count(*) from orders where price > 300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.
```sql
create user 'test'@'localhost' 
    identified with mysql_native_password by 'test-pass' 
    WITH MAX_QUERIES_PER_HOUR 100 
    PASSWORD EXPIRE INTERVAL 180 DAY 
    FAILED_LOGIN_ATTEMPTS 3 
    ATTRIBUTE '{"FirstName": "Pretty", "Name": "James"}'

select * from INFORMATION_SCHEMA.USER_ATTRIBUTES where user = 'test';
+------+-----------+------------------------------------------+
| USER | HOST      | ATTRIBUTE                                |
+------+-----------+------------------------------------------+
| test | localhost | {"Name": "James", "FirstName": "Pretty"} |
+------+-----------+------------------------------------------+
1 row in set (0.00 sec)
```
## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.  

`В таблице orders используется движок innoDB`    

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`
```sql
show profiles;
+----------+------------+----------------------------------+
| Query_ID | Duration   | Query                            |
+----------+------------+----------------------------------+
|        6 | 0.01912125 | alter table orders engine=myisam |
|        7 | 0.02104325 | alter table orders engine=innodb |
+----------+------------+----------------------------------+
7 rows in set, 1 warning (0.00 sec)
```
## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.
```
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

innodb_buffer_pool_size=615M
innodb_log_file_size=100M
innodb_log_buffer_size=1M 
innodb_flush_method=O_DSYNC 
innodb_flush_log_at_trx_commit=2 
innodb_file_per_table=1 

# Custom config should go here
!includedir /etc/mysql/conf.d/

```
---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
