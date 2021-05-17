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
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(f"{git_dir}/{prepare_result}")
```
