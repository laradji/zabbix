#!/bin/bash

DNSSERVER=$1
ZONE=$2
DATE=`date "+%d/%m/%Y %H:%M"`

#if [[ -n $DNSERVER ]]; then test_ip $DNSSERVER; else exit 1; fi
#if [[ -n $ZONE ]]; then test_world $ZONE; else exit 1; fi

if [[ -z $DNSSERVER ]]; then echo "dnsserver not provided"; exit 1; fi
if [[ -z $ZONE ]]; then echo "zone not provided"; exit 1; fi

soa=`dig +time=2 +tries=2 @$DNSSERVER $ZONE soa| sed -n '/ANSWER SECTION/{n;p;}'|awk '{print $7}'`
if [ -z $soa ]; then echo "0"; exit 1; fi
echo $soa
exit 0
