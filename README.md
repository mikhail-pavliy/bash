# 1. Парметры конфигурации скрипта
```ruby
IFS=$' '                      # разделитель записей в лог файле
PIDFILE=/var/run/wlen.pid     # укажем pid файл
LOGDIR=logs                   # укажем директорию с логами
LOGFILE=/var/log/wlen.log     # укажем лог файл скрипта
recipient="vagrant@localhost" # укажем адрес, куда посылать письма
XCOUNT=30                     # укажем количество записей, которые будут включены в письмо
YCOUNT=30

# date setup                  # установим дату, начиная от текущей, за которую нам нужны сведения 
                                  
hourago="1 hours ago"
dlog="`date +"%d/%b/%Y %H:%M:%S"`"
datt="`date +"%d/%b/%Y:%H"`"
dacc="`date --date="$hourago" +"%d/%b/%Y:%H"`"
derr="`date --date="$hourago" +"%Y/%m/%d-%H"`"
errd="`echo $derr | sed 's/-/\ /'`"
```
# 2. IP адреса с наибольшим количеством запросов (20)
```ruby
awk -F" " '{print $1}' access.log | sort | uniq -c | sort -nr | head -20
```
# 3. Запрашиваемые url с наибольшим количеством запросов (20)
```ruby
awk -F" " '{print $7}' access.log | sort | uniq -c | sort -nr | head -20
```
# 4. Все ошибки
```ruby
cat error.log | grep "$errd"
```
# 5. Http коды возврата и их количество (20)
```ruby
awk -F" " '{print $9}' access.log | sort | uniq -c | sort -nr
```
Добавляем к этим запросам фильтрацию по дате ($dacc) и указание откуда брать файлы логов ($LOGDIR), параметр количества записеей ($COUNT):
```ruby
cat $LOGDIR/access.log | grep "$dacc" | awk '{print $1}' | sort | uniq -c | sort -nr | head -$COUNT
```
Перед этим вычисляем дату, нужно что бы было 1 час назад:
```ruby
hourago="1 hour ago"
dacc="`date --date="$hourago" +"%d/%b/%Y:%H"`
```
Добавим скрипт в cron с условием запуска раз в час:
```ruby
* */1 * * *  root /bin/sh /web_log_email_notify.sh >/var/log/wlen.log 2>&1
```
с перенаправлением лога самого скрипта в файл.
```ruby
mail -u vagrant
 U 42 no-reply@localhost.l Fri Nov 9 12:10 34/789 "hourly web server report"
```
