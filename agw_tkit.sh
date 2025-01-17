#!/bin/bash

SESH=0
WNAME="Magma Toolkit"
CMDPANE1="health_cli.py"
CMDPANE2="mobility_cli.py get_subscriber_table"
CMDPANE3="ping -c 10 google.com"

tmux has-session -t $SESH 2>/dev/null

if [ $? != 0 ]; then
	tmux new-session -d -s $SESH -n "$WNAME"
	tmux split-window -h
	tmux split-window -v
	tmux send-keys -t $SESH:"$WNAME".0 "$CMDPANE1" C-m
	tmux send-keys -t $SESH:"$WNAME".1 "$CMDPANE2" C-m
	tmux send-keys -t $SESH:"$WNAME".2 "$CMDPANE3" C-m
	tmux attach -t 0	
fi

if [ $? -eq 0 ]; then
    tmux attach -t $SESH
fi

exit 0

