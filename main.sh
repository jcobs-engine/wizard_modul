#!/bin/bash
clear

spieler=0
runden=0

while [ $spieler -lt 3 ] || [ $spieler -gt 6 ]; do
    clear
    read -p "Spieler: " spieler
done
echo ""
i=1
while [ $i -le $spieler ]; do
    read -p "$i: " spielername$i
    
    eval "spielerpnts$i"=0
    
    i=$(( $i + 1 ))
done
    
if [ $spieler -eq 3 ]; then
    runden=20
elif [ $spieler -eq 4 ]; then
    runden=15
elif [ $spieler -eq 5 ]; then
    runden=12
elif [ $spieler -eq 6 ]; then
    runden=20
fi

runde=1
while [ $runde -le $runden ]; do
    clear

    tput cup 0 0
    echo -en "\033[41mSpieler\033[0m"
    tput cup 0 30
    echo -en "\033[41mAussage\033[0m"
    tput cup 0 60
    echo -en "\033[41mErgebnis\033[0m"

    rundetxt="Runde $runde"
    tput cup 0 $(( $COLUMNS - ${#rundetxt} ))
    echo -en "\033[1;43mRunde $runde\033[0m"
    
    i=1
    a=2
    while [ $i -le $spieler ]; do
        aktu_spielername="spielername$i"

	tput cup $a 0
	echo -e "\033[0m${!aktu_spielername}\033[0m" 

	i=$(( $i + 1 ))
	a=$(( $a + 1 ))
    done

    anfang=$(( ( $runde - 1 ) % $spieler + 1 ))

    i=1
    sid=$anfang
    a=$(( $anfang + 1 )) 
    while [ $i -le $spieler ]; do
	if [ $sid -gt $spieler ]; then
	    sid=1
	    a=2
	fi
	
	aktu_spielername="spielername$sid"
	
	tput cup $a 0
	echo -e "\033[42m${!aktu_spielername}\033[0m" 
	
	tput cup $a 30
	read a_gesacht_runde${runde}_spieler$i
	
	tput cup $a 0
	echo -e "\033[0m${!aktu_spielername}\033[0m" 
	
	i=$(( $i + 1 ))
	sid=$(( $sid + 1 ))
	a=$(( $a + 1 ))
    done

    i=1
    sid=$anfang
    a=$(( $anfang + 1 )) 
    while [ $i -le $spieler ]; do
	if [ $sid -gt $spieler ]; then
	    sid=1
	    a=2
	fi

        aktu_spielername="spielername$sid"

	tput cup $a 0
	echo -e "\033[42m${!aktu_spielername}\033[0m" 

	tput cup $a 60
	read a_bekommen_runde${runde}_spieler$i

	tput cup $a 0
	echo -e "\033[0m${!aktu_spielername}\033[0m" 
	
	i=$(( $i + 1 ))
	sid=$(( $sid + 1 ))
	a=$(( $a + 1 ))
    done

    ### LISTE ###
    
    clear

    i=1
    while [ $i -le $spieler ]; do
	
	eval "spielerpnts$i"=0
	
	i=$(( $i + 1 ))
    done


    i=1
    a=5
    while [ $i -le $spieler ]; do
	aktu_spielername="spielername$i"
	
	tput cup 0 $a
	echo -e "\033[41m${!aktu_spielername}\033[0m" 
	
	i=$(( $i + 1 ))
	a=$(( $a + 15 ))
    done

    tmp_runde=1
    a=1
    while [ $tmp_runde -le $runde ]; do
	tput cup $a 0
	akturunde="$( printf '%02d' "$tmp_runde" )" 
	echo -en "\033[44m$akturunde\033[0m"
	
	i=1
	b=5
	while [ $i -le $spieler ]; do
	    aktu_gesacht="a_gesacht_runde${tmp_runde}_spieler${i}"
	    aktu_bekommen="a_bekommen_runde${tmp_runde}_spieler${i}"
	    aktuspielerpnts="spielerpnts${i}"
	    
	    if [ ${!aktu_gesacht} -ne ${!aktu_bekommen} ]; then
		diff=$(( ${!aktu_gesacht} - ${!aktu_bekommen} ))
		if [ $diff -lt 0 ]; then
		    diff=$(( $diff * -1 ))
		fi
		aktupunkte=$(( -10 * $diff ))
		farbe='\033[31m'
	    else
		aktupunkte="+"$(( 20 + ${!aktu_gesacht} * 10 ))
		farbe='\033[32m'
	    fi
	    
	    tput cup $a $b
	    echo -e "$farbe$aktupunkte \033[0m${!aktu_bekommen}\033[37m(${!aktu_gesacht})\033[0m" 
	    
	    eval "spielerpnts$i"=$(( ${!aktuspielerpnts} + $aktupunkte ))
	    
	    i=$(( $i + 1 ))
	    b=$(( $b + 15 ))
	done
	
	
	tmp_runde=$(( $tmp_runde + 1 ))
	a=$(( $a + 1 ))
    done

    unset array
    unset array_sorted
    
    declare -a array

    i=1
    b=5
    while [ $i -le $spieler ]; do
	aktuspielerpnts="spielerpnts${i}"

	tput cup $(( $tmp_runde + 1 )) $b
	echo -e "\033[1m${!aktuspielerpnts}\033[0m" 
	
	array[$i]=${!aktuspielerpnts}" "$i
	
	i=$(( $i + 1 ))
	b=$(( $b + 15 ))
    done

    IFS=$'\n' array_sorted=($(sort -g <<<"${array[*]}"))
    unset IFS

    i=$spieler
    b=1
    while [ $i -ge 0 ]; do
	array[$b]=${array_sorted[$i]}
	i=$(( $i - 1 ))
	b=$(( $b + 1 ))
    done

    b=1
    i=$(( $tmp_runde + 3 ))
    for a in "${!array[@]}"; do
	if [ $a -ne 1 ]; then
	    var=${array[$a]}
	    aktuspieler="spielername"${var#* }
            tput cup $i 5
	    echo "$b. ${!aktuspieler}"
	    tput cup $i 18
	    echo -e "\033[1m"${var% *}"\033[0m"
	    
	    b=$(( $b + 1 ))
	    i=$(( $i + 1 ))
	fi
    done

    read -sn1 test

    runde=$(( $runde + 1 ))
done

