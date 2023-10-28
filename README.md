# Домашняя работа 2
*находится в ветке homework2*  
### Необходимо:  
- развернуть 4 виртуалки терраформом в яндекс облаке
- 1 виртуалка - Nginx - с публичным IP адресом
- 2 виртуалки - бэкенд на выбор студента ( любое приложение из гитхаба - uwsgi/unicorn/php-fpm/java) + nginx со статикой
- 1 виртуалкой с БД на выбор mysql/mongodb/postgres/redis.
- репозиторий в github: README, схема, манифесты терраформ и ансибл
- стенд должен разворачиваться с помощью terraform и ansible
- при отказате (выключение) виртуалки с бекендом система должна продолжать работать
### Предварительные условия:
- настроенный профиль yc
- установленные ansible и terraform
### Выполнение:  
*cloud-id и folder-id берутся из профиля yc, при необходимости переопределить*  
Команды для запуска:  
```sh
cd ./terraform
chmod +x env.sh
. env.sh
terraform apply
```

# Домашняя работа 2
**Для корректной работы необходимо залогиниться и настроить профиль yc**
также на хосте запуска должен присутствовать [terraform-inventory](https://github.com/adammck/terraform-inventory) по пути `/usr/local/bin/terraform-inventory`,  
либо команду для запуска плейбука неообходимо скорректировать в соответствии с расположением исполнительного файла `terraform-inventory`
```sh
cd ./terraform
chmod +x env.sh
. env.sh
terraform apply
cd ../ansible
ansible-playbook -u ubuntu --inventory-file=/usr/local/bin/terraform-inventory run.yml
```