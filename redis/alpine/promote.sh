#!/usr/bin/env bash
MASTERIP=$6

# Convert the IP of the promoted pod to a hostname
MASTERPOD=`kubectl get pod -o jsonpath='{range .items[*]}{.metadata.name} {..podIP}{"\n"}{end}' -l redis-role=slave --sort-by=.metadata.name|grep $MASTERIP|awk '{print $1}'`
echo "PROMO ARGS: $@"
echo "PROMOTING $MASTERPOD ($MASTERIP) TO MASTER"
kubectl label --overwrite pod $MASTERPOD redis-role="master"

# Demote anyone else who jumped to master
kubectl get pod -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' -l redis-role=master --sort-by=.metadata.name|grep $REDIS_CHART_PREFIX|grep -v $MASTERPOD|xargs -n1 -I% kubectl label --overwrite pod % redis-role="slave"
echo "OTHER MASTERS $MASTERS"
