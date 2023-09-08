# Домашняя работа 1
*находится в ветке homework1*  
### Необходимо:  
реализовать терраформ для разворачивания одной виртуалки в yandex-cloud  
запровиженить nginx с помощью ansible  
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

# Домашняя работа 1
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