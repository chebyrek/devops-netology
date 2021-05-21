**1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:**  
```json
{ "info" : "Sample JSON output from our service\t",
    "elements" :[
        { "name" : "first",
        "type" : "server",
        "ip" : 7175 
        },
        { "name" : "second",
        "type" : "proxy",
        "ip : 71.78.22.43
        }
    ]
}
```
**Нужно найти и исправить все ошибки, которые допускает наш сервис**  
```json
{
   "info":"Sample JSON output from our service\t",
   "elements":[
      {
         "name":"first",
         "type":"server",
         "ip":7175
      },
      {
         "name":"second",
         "type":"proxy",
         "ip":"71.78.22.43"
      }
   ]
}
```
Неправильный IP это тоже ошибка или так и надо?  

**2.В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.**  
```python
import socket
import os
import yaml
import json

services = ('drive.google.com', 'mail.google.com', 'google.com')
log_name = "log"

def get_ip(service):
  try:  
    ip = socket.gethostbyname(service)
  except socket.gaierror:
    return 'is not available now'
  return ip

def write_to_json_and_yaml(file_name,data):
  with open(f'{file_name}.json', 'w') as json_file:
    json.dump(data, json_file)  
  with open(f'{file_name}.yaml', 'w') as yaml_file:
    yaml.dump(data, yaml_file)

result = {}
if not os.path.exists(f'{log_name}.json') or not os.path.exists(f'{log_name}.yaml'):
  for service in services:
    result.update({service : get_ip(service)})
    print(f'{service} - {get_ip(service)}')
    write_to_json_and_yaml(log_name, result)  
else:
  with open(f'{log_name}.yaml', 'r') as data_file:
    service_info = yaml.safe_load(data_file)
  for service in services:
    for service_name,service_ip in service_info.items():
      if service == service_name:
        ip_from_file = service_ip
        break 
    ip_from_check = get_ip(service)
    result.update({service : ip_from_check})
    if ip_from_check != ip_from_file:
      print(f'[ERROR] {service} IP mismatch: {ip_from_file} {ip_from_check}')
      continue
    print(f'{service} - {ip_from_check}')
  write_to_json_and_yaml(log_name, result)  

```
