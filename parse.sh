#!/bin/bash

function getKey()
{
    if [ "$#" -eq "0" ]; then
        echo ""
    fi

        echo `echo $1|awk -F '=' '{print $1}'`
}
function getValue()
{
    if [ "$#" -eq "0" ]; then
        echo ""
    fi

        echo `echo $1|awk -F '=' '{print $2}'`
}

function upper(){
	echo $@|tr '[a-z]' '[A-Z]'
}
function lower(){
	echo $@|tr '[A-Z]' '[a-z]'
}

cat .config|while read line;
do
    #skip comment
    if [[ "$line" =~ ^\s*# ]];then
        continue
    fi
    #skip blank line
    if [[ "$line" =~ ^\s*$ ]];then
        continue
    fi

    key=`getKey "$line"`
    key=$(upper $key)
    key=${key//"."/"_"}

    value=`getValue "$line"`
    echo "NUFRONT_MODULE_$key := $value"
done
