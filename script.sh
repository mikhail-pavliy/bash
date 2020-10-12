#!/bin/bash

# Парметры конфигурации скрипта
IFS=$' '
PIDFILE=/var/run/mytestpidfile.pid
LOGDIR=logs
LOGFILE=/var/log/mytestlogfile.log
recipient="vagrant@localhost"
XCOUNT=15
YCOUNT=15

# установим дату
hourago="1 hours ago"
dlog="`date +"%d/%b/%Y %H:%M:%S"`"
datt="`date +"%d/%b/%Y:%H"`"
dacc="`date --date="$hourago" +"%d/%b/%Y:%H"`"
derr="`date --date="$hourago" +"%Y/%m/%d-%H"`"
errd="`echo $derr | sed 's/-/\ /'`"

send_email()
{
        (
cat - <<END
Subject: hourly web server report
From: no-reply@localhost
To: $recipient
Content-Type: text/plain
From the last hour there is some stats from web server
Report from $dacc to $datt.
We have some ip addresses:
count ip-address
${IP_LIST[@]}
and we have some urls:
count url
${IP_ADDR[@]}
and we have some http codes:
count code
${HTTP_STATUS[@]}
We have some errors:
${ERRORS[@]}
END
) | /usr/sbin/sendmail $1
}

# Обработка лог файла

if [ -e $PIDFILE ]
then
    echo "$dlog --> Script is running!" >> $LOGFILE 2>&1
    exit 1
else
        echo "$$" > $PIDFILE
        trap 'rm -f $PIDFILE; exit $?' INT TERM EXIT
        IP_LIST+=(`cat $LOGDIR/access-4560-644067.log | grep "$dacc" | awk '{print $1}' | sort | uniq -c | sort -nr | head -$XCOUNT`)
        IP_ADDR+=(`cat $LOGDIR/access-4560-644067.log | grep "$dacc" | awk '{print $7}' | sort | uniq -c | sort -nr | head -$YCOUNT`)
        HTTP_STATUS+=(`cat $LOGDIR/access-4560-644067.log | grep "$dacc" | awk '{print $9}' | sort | uniq -c | sort -nr`)
        ERRORS+=(`cat $LOGDIR/error.log | grep "$errd"`)
        send_email $recipient
        rm -r $PIDFILE
        trap - INT TERM EXIT
        echo "$dlog --> Success" >> $LOGFILE 2>&1
fi
