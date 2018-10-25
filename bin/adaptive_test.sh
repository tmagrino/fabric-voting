#!/bin/bash
ant clean clobber build-all
(
	bin/start-all-voting 2 && bin/init-voting-state 2 && sleep 5
	(
		(
			bin/vote 1 0.6 1 & #tail -f $(grep "receiver: " var/log/* | cut -d: -f1,3- | sort -u | grep "district1" | cut -d: -f1) | grep "COORD" -m1 ; killall xterm
		) &
		(
			bin/vote 2 0.48 1 & #tail -f $(grep "receiver: " var/log/* | cut -d: -f1,3- | sort -u | grep "district2" | cut -d: -f1) | grep "COORD" -m1 ; killall xterm
		) &
	) && sleep 10
	bin/tally & sleep 300
)
killall xterm
