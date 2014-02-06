#!/bin/bash
DNSSERVER1="dns.cloud.kbrwadventure.com"
DNSSERVER2="dns2.cloud.kbrwadventure.com"
LOGS=/tmp/resume_dns.txt
DATE=`date "+%d/%m/%Y %H:%M"`
MAIL="kevin@kbrwadventure.com"
HELP=0
ZONE="shoppingadventure.fr"
echo > $LOGS
exec 6>&1
exec 1>$LOGS
exec 2>$LOGS

echo " ********** ETAT DNS au $DATE **********"
echo ""


soa1=`dig +time=2 +tries=2 @$DNSSERVER1 $ZONE soa| sed -n '/ANSWER SECTION/{n;p;}'|awk '{print $7}'`
soa2=`dig +time=2 +tries=2 @$DNSSERVER2 $ZONE soa| sed -n '/ANSWER SECTION/{n;p;}'|awk '{print $7}'`
if [[ -z $soa1 || -z $soa2 ]]; then echo "Zone $i not present on servers, or server not respunding"; HELP=1; else
	if [ $soa1 -ne $soa2 ];
	then
		echo "SOA serial differs : $DNSSERVER1 : $soa1 / $DNSSERVER2 : $soa2 "
		HELP=2
	else
		echo "Domain $ZONE  has same serial on $DNSSERVER1 and $DNSSERVER2 : $soa1 / $soa2"
	fi


	if [ $HELP -eq "1" ]; then
		SUBJECT=" [ INFRA DNS  ] - ERRORS Some zone are missing or server not responding - Read the attached"
	else

		if [ $HELP -eq "2" ]; then
			SUBJECT=" [INFRA DNS] - ERRORS zone are not the same on master and slave  - Read the attached"
			echo " "
		else

			SUBJECT="[INFRA DNS] - All zone are OK"
		fi
	fi
	echo "
	Mail envoye depuis `hostname` - /etc/cron.d/check_zonedns à $MAIL $SUBJECT

	"
fi
	exec 1>&6
	#fermeture du desc 6
	6<&-
	#for email in `echo $MAIL`; do cat $LOGS | mail -s "$SUBJECT - $DATE" $email; done
	cat $LOGS

