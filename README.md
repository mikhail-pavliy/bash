Написать скрипт для крона
Скрипт должен присылать раз в час на заданную почту:

X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
Y запрашиваемых url (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
все ошибки c момента последнего запуска
список всех кодов возврата с указанием их кол-ва с момента последнего запуска В письме должно быть прописан обрабатываемый временной диапазон, должна быть реализована защита от мультизапуска.
0. Парметры конфигурации скрипта
IFS=$' '                      # разделитель записей в лог файле
PIDFILE=/var/run/wlen.pid     # укажем pid файл
LOGDIR=logs                   # укажем директорию с логами
LOGFILE=/var/log/wlen.log     # укажем лог файл скрипта
recipient="vagrant@localhost" # укажем адрес, куда посылать письма
XCOUNT=30                     # укажем количество записей, которые будут включены в письмо
YCOUNT=30

# date setup                  # установим дату, начиная от текущей, за которую нам нужны сведения 
                              # можно поставить "1 hour ago" - по условиям задания      
hourago="85 hours ago"
dlog="`date +"%d/%b/%Y %H:%M:%S"`"
datt="`date +"%d/%b/%Y:%H"`"
dacc="`date --date="$hourago" +"%d/%b/%Y:%H"`"
derr="`date --date="$hourago" +"%Y/%m/%d-%H"`"
errd="`echo $derr | sed 's/-/\ /'`"
1. IP адреса с наибольшим количеством запросов (20)
awk -F" " '{print $1}' access.log | sort | uniq -c | sort -nr | head -20
2. Запрашиваемые url с наибольшим количеством запросов (20)
awk -F" " '{print $7}' access.log | sort | uniq -c | sort -nr | head -20
3. Все ошибки
cat error.log | grep "$errd"
4. Http коды возврата и их количество (20)
awk -F" " '{print $9}' access.log | sort | uniq -c | sort -nr
Добавляем к этим запросам фильтрацию по дате ($dacc) и указание откуда брать файлы логов ($LOGDIR), параметр количества записеей ($COUNT):

cat $LOGDIR/access.log | grep "$dacc" | awk '{print $1}' | sort | uniq -c | sort -nr | head -$COUNT
Перед этим вычисляем дату, нужно что бы было 1 час назад:

hourago="1 hour ago"
dacc="`date --date="$hourago" +"%d/%b/%Y:%H"`
Полный листинг скрипта тут.

Добавим скрипт в cron с условием запуска раз в час:

* */1 * * *  root /bin/sh /web_log_email_notify.sh >/var/log/wlen.log 2>&1
с перенаправлением лога самого скрипта в файл.

mail -u vagrant
 > U 42 no-reply@localhost.l Fri Nov 9 12:10 34/789 "hourly web server report"
P.S.
Можно сделать так, что бы параметры запуска скрипта задавались из командой строки. Например:

web_log_email_notify.sh -l LOGDIR -c COUNT -e recipient
Следовательно, необходимо добавить в скрипт проверку в виде примерно такой конструкции:

while [ -n "$1" ]
do
case "$1" in
  -l) LOGDIR="$2"
    echo "-l value $LOGDIR"
    shift;;
  -c) COUNT="$2"
    echo "-c value $COUNT"
    shift;;
  -e) recipient="$2"
    echo "-e value $recipient";;
  --) shift
    break ;;
  *) echo "$1 is not a true value or option";;
esac
shift
done
