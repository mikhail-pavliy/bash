# 1. Парметры конфигурации скрипта
```ruby
IFS=$' '                               # разделитель записей в лог файле
PIDFILE=/var/run/mytestpidfile.pid     # укажем pid файл
LOGDIR=logs                            # укажем директорию с логами
LOGFILE=/var/log/mytestlogfile.log     # укажем лог файл скрипта
recipient="vagrant@localhost"          # укажем адрес, куда посылать письма
XCOUNT=15                              # укажем количество записей, которые будут включены в письмо
YCOUNT=15

# date setup                  # установим дату, начиная от текущей, за которую нам нужны сведения 
                                  
hourago="1 hours ago"
dlog="`date +"%d/%b/%Y %H:%M:%S"`"
datt="`date +"%d/%b/%Y:%H"`"
dacc="`date --date="$hourago" +"%d/%b/%Y:%H"`"
derr="`date --date="$hourago" +"%Y/%m/%d-%H"`"
errd="`echo $derr | sed 's/-/\ /'`"
```
# 2. IP адреса с наибольшим количеством запросов (15)
```ruby
awk -F" " '{print $1}' access-4560-644067.log | sort | uniq -c | sort -nr | head -15
```
# 3. Запрашиваемые url с наибольшим количеством запросов (15)
```ruby
awk -F" " '{print $7}' access-4560-644067.log | sort | uniq -c | sort -nr | head -15
```
# 4. Все ошибки
```ruby
cat error.log | grep "$errd"
```
# 5. Http коды возврата и их количество (15)
```ruby
awk -F" " '{print $9}' access-4560-644067.log | sort | uniq -c | sort -nr
```
Добавляем к этим запросам фильтрацию по дате ($dacc) и указание откуда брать файлы логов ($LOGDIR), параметр количества записеей ($COUNT):
```ruby
cat $LOGDIR/access.log | grep "$dacc" | awk '{print $1}' | sort | uniq -c | sort -nr | head -$COUNT
```
Вычисляем дату, нужно что бы было 1 час назад:
```ruby
hourago="1 hour ago"
dacc="`date --date="$hourago" +"%d/%b/%Y:%H"`
```
Добавим скрипт в cron с условием запуска раз в час:
```ruby
* */1 * * *  root /bin/sh /script.sh >/var/log/wlen.log 2>&1
```
