#!/bin/bash

now=`date +%Y%m%d%H%M%S`;
passed=$(($now - $1))

echo The ${HOSTNAME} system is `uptime -p`. This bot is running since ${1}. Since the start ${passed} seconds have passed. Which is around $((${passed}/60)) minutes. Or $(((${passed}/60)/60)) hours. Also known as $((((${passed}/60)/60)/24)) days.
