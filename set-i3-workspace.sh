#!/bin/bash

MSG_COMMAND=i3-msg
if [[ $DESKTOP_SESSION =~ ^sway$ ]]; then
	MSG_COMMAND=swaymsg
fi

CURRENT_WORKSPACE=$($MSG_COMMAND -t get_workspaces \
	| jq '.[] | select(.visible == true) | .name' \
	| sed "s/\"\|'//g")

#shift wrapping i.e. wrap_shift=2 wrap=10 (0-9)->(2-11), beneficial with a value of 1 as (1-10) matches the keyboard layout
WRAP_SHIFT=1;
DESIRED_WORKSPACE=$(( $CURRENT_WORKSPACE - $WRAP_SHIFT ))
MOVE_CONTAINER=false

declare -A WRAP_STACK_MOD
declare -A WRAP_STACK_ADD

proccess_args(){
	for x in "$@"; do
		if [[ $x =~ ^-c$ ]]; then
			MOVE_CONTAINER=true
		
		#arithmetic operations
		elif [[ $x =~ ^[%\*\/\+\\-][0-9]+$ ]]; then
			DESIRED_WORKSPACE=$(($DESIRED_WORKSPACE $x))

		#initialize a wrap i.e. 10-> (0-9 or 10-19) or 4->(0-3 or 8-11)
		elif [[ $x =~ ^-w[0-9]+$ ]]; then
			mod=${x:2}
			add=$(( $DESIRED_WORKSPACE / $mod * $mod ))
			DESIRED_WORKSPACE=$(($DESIRED_WORKSPACE - $add))
		
			stack_size=${#WRAP_STACK_MOD[@]}
			WRAP_STACK_MOD[$(( $stack_size + 1 ))]=$mod
			WRAP_STACK_ADD[$(( $stack_size + 1 ))]=$add
	
		#Allow -+ for absolute decrement or +- for absolute increment (obsolete as values less than 0 no longer allowed by script)
		elif [[ $x =~ ^\+-[0-9]+$ ]] || [[ $x =~ ^-\+[0-9]+$ ]]; then
			local delta=$(echo $x | cut -c$([ $CURRENT_WORKSPACE -ge 0 ] && echo 2 || echo 1) --complement)
			DESIRED_WORKSPACE=$(( $DESIRED_WORKSPACE + $delta ))
		
		#set workspace directly with number
		elif [[ $x =~ ^[0-9]+$ ]]; then 
			DESIRED_WORKSPACE=$(( $x - $WRAP_SHIFT ))

		#set workspace directly with alpha-numeric identifier
		else 
			DESIRED_WORKSPACE=$x
		
		fi
	done
}

#process supplied arguments
proccess_args "$@"

#process piped arguments
if [ -p /dev/stdin ]; then
	read piped_input
	proccess_args $piped_input
fi

#enforce and clean up wraps
for (( idx=${#WRAP_STACK_MOD[@]} ; idx>0 ; idx-- )) ; do
	#mod add mod the MOD to make sure we end up with a positive value to add ADD to
    DESIRED_WORKSPACE=$(( ($DESIRED_WORKSPACE % ${WRAP_STACK_MOD[$idx]} + ${WRAP_STACK_MOD[$idx]}) % ${WRAP_STACK_MOD[$idx]} + ${WRAP_STACK_ADD[$idx]} ))
done

#clean up wrap shift or replace spaces with underscores
if [[ $DESIRED_WORKSPACE =~ ^-?[0-9]+$ ]]; then
	DESIRED_WORKSPACE=$(( $DESIRED_WORKSPACE + $WRAP_SHIFT ))
else
	DESIRED_WORKSPACE=$(echo $DESIRED_WORKSPACE | sed 's/ /_/g')
fi

#fail if DESIRED_WORKSPACE ends up less than WRAP_SHIFT i.e. 1 or 0
if [ $DESIRED_WORKSPACE -lt $WRAP_SHIFT ]; then
	echo desired workspace less than 1
	exit -1
fi

if [[ $MOVE_CONTAINER = true ]]; then
	$MSG_COMMAND move container to workspace $DESIRED_WORKSPACE 
fi

$MSG_COMMAND workspace $DESIRED_WORKSPACE
