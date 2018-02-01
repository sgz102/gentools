#!/bin/bash



IFS=$'\n'

if [[ ! -z $1 ]] ; then
        if [[ $1 == "tcsh" ]];  then
                for mytcsh in $(ps -u szonak | awk ' $4 == "tcsh" {print $0}' | awk '{print $1}'); do
                        pstree -p $mytcsh;
                        #   echo "$mytcsh"
                done

        elif [[ $1 == "bash" ]];  then
                for mytcsh in $(ps -u szonak | awk ' $4 == "bash" {print $0}' | awk '{print $1}'); do
                        pstree -p $mytcsh;
                        #   echo "$mytcsh"
                done

        elif [[ $1 == "screen" ]]; then
                for screen_session in $(screen -ls | awk '{print $1}' | grep -v "^\s*There" | grep '\.'); do
                        spid=$(echo $screen_session | awk -F\. '{print $1}')
                        sname=$(echo  $screen_session| awk -F\. '{print $2}')
                        echo -n "$sname: "
                        pstree -p $spid
                done
        fi
else
        for screen_session in $(screen -ls | awk '{print $1}' | grep -v "^\s*There" | grep '\.'); do
                spid=$(echo $screen_session | awk -F\. '{print $1}')
                sname=$(echo  $screen_session| awk -F\. '{print $2}')
                echo -n "$sname: "
                pstree -p $spid
        done
fi

