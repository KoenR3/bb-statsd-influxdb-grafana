#!/bin/sh

for SCRIPT in /etc/my_init.d/*
	do
		if [ -f $SCRIPT -a -x $SCRIPT ]
		then
			$SCRIPT
		fi
	done