#!/bin/bash

#https://www.nomachine.com/AR10K00710
COOKIE=$(ps -ef | md5sum | cut -f 1 -d " ")
xauth -f $HOME/Xvfb-0.auth add :0 MIT-MAGIC-COOKIE-1 $COOKIE
xauth add :0 MIT-MAGIC-COOKIE-1 $COOKIE

Xvfb :0 -auth $HOME/Xvfb-0.auth -extension GLX -screen 0 1366x768x24 &
sleep 1
DISPLAY=:0 /usr/bin/openbox-session &
sleep 2

for var in "$@"
do
  eval $var &
done

x11vnc -auth $HOME/Xvfb-0.auth -usepw -display :0
 
exit 0
