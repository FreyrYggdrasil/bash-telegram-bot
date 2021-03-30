#!/bin/bash

batbotpid=`ps -eo pid,args | grep batbot | awk '{print $0;}' | grep /bin/bash | awk '{print $1;}'`
echo batbot is running as PID $batbotpid and will be killed
kill $batbotpid
