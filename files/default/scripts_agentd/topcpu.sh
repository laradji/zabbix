#!/bin/bash
#####################################################
# topcpu.sh
# returns names of most CPU time consuming processes
# as reported by 'top'
#####################################################
# 05-07-2010 by Jerry Lenk
# Use at your own risk!
#####################################################

# set limit to 1st argument, or 2% if not specified
lim=$1
test -z $lim && lim=2

# run 2 iterations of top in batch mode with 1 s delay
top -b -d1 -n2 |\
gawk --assign lim=$lim  'BEGIN { reply=""}
        END { print reply, "." }
        # if reply is empty, at least a period is returned

        # in 2nd iteration, first 3 lines
        # add columns 9 (%cpu) and 12 (process name)
        # to reply string, if cpu at least lim%
        itr == 2 && NR <= 3 && $9 >= lim { reply=reply " " $9 "%" $12 }

        # count iterations by header lines beginning with "PID"
        # reset linenumber
        $1 == "PID" { NR=0 ; itr +=1 }
       '
# Only 2nd iteration of top is of interest because
# load values are calculated since previous iteration
