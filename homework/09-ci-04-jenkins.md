# Домашнее задание к занятию "09.04 Jenkins"

## Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.  
https://github.com/chebyrek/mnt-homeworks-ansible
```jenkins
pipeline {
    agent {
      label 'linux'
    }
    stages {
        stage('Install molecule'){
            steps {
                sh 'pip3 install -r test-requirements.txt'
            }
        }
        stage('Run molecule') {
            steps {
                sh 'molecule test'
            }
            
        }
    }
}
```
5. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.
6. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).
7. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
8. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`. Цель: получить собранный стек ELK в Ya.Cloud.  
https://github.com/chebyrek/08-ansible-02-playbook
```Jenkins
node("linux"){
    stage("Git checkout"){
        git credentialsId: 'cdae9af1-282c-41fc-94f7-a26c749ab4c7', url: 'git@github.com:chebyrek/08-ansible-02-playbook.git'
    }
    stage("Run playbook"){
        if (params.prod_run){
            sh 'ansible-playbook -i inventory/prod.yml site.yml'
        }
        else{
            sh 'ansible-playbook -i inventory/prod.yml --check --diff site.yml'
        }
        
    }
}
```
10. Отправить ссылку на репозиторий в ответе.


---
