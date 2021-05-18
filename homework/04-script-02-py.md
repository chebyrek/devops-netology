**1. Есть скрипт:**  
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```
**Какое значение будет присвоено переменной `c`?**   
Будет ошибка, т.к. python не хочет складывать строку и число  

**Как получить для переменной `c` значение 12?**  
Привести `a` к строке
```python
a = 1
b = '2'
c = str(a) + b
```
**Как получить для переменной `c` значение 3?**  
Привести `b` к типу int
```python
a = 1
b = '2'
c = a + int(b)
```
**2. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?**  
```python
#!/usr/bin/env python3

import os

git_dir = "~/netology/sysadm-homeworks"
bash_command = ["cd " + git_dir, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(f"{git_dir}/{prepare_result}")
```

**3. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.**  
```python
#!/usr/bin/env python3
import os
import sys
import argparse

parser = argparse.ArgumentParser(description='Repository info')
parser.add_argument('-path', type=str, help='Path to repository', default=os.getcwd())
args = parser.parse_args()

git_dir = args.path

if not os.path.exists(f'{git_dir}/.git'):
  sys.exit('This folder is not a local git repository')

bash_command = [f"cd {git_dir}", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(f"{git_dir}/{prepare_result}")
```
**4. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.**  