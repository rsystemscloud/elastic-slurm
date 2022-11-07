#!/bin/bash

logfile="/var/log/slurm/autoscaling.log"

date >> ${logfile}
echo "Creating nodes: ${@}" >> ${logfile}

/etc/slurm/scripts/resume.ps1 ${@} >> ${logfile}
