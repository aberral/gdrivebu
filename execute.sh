#!/bin/bash
##
# Main of backup.sh
# Script created on 02-04-19
TIMESTAMP=`date "+%d_%m_%Y--%H_%M_%S"`
# Creamos el log de la copia
/scripts/./backup.sh 2>&1 | tee /home/aberral/.duplicity/logs/$TIMESTAMP
