#!/bin/bash

logfile="/var/log/slurm/autoscaling.log"

nodelist=`/usr/bin/scontrol show hostnames ${@} | sed 's/^/"/g;s/$/"/g' | tr '\n' ',' | sed 's/,$//g'`
nodelist="[${nodelist}]"
date >> ${logfile}
echo "Destroying nodes: ${nodelist}" >> ${logfile}

/etc/slurm/scripts/suspend.ps1 ${nodelist} >> ${logfile}
