#!/bin/bash

# display help
Help() {
   echo "NAME"
   echo -e "\tbornfatlaur - update aur packages"
   echo
   echo "SYNOPSIS"
   echo -e "\tbornfatlaur [OPTION]..."
   echo
   echo "DESCRIPTION"
   echo -e "\tVery cool but primitive aur packages updater"
   echo
   echo -e "\t-h"
   echo -e "\t\tdisplay this help"
   echo
   echo -e "\t-n=NUMBER"
   echo -e "\t\tupdate at most NUMBER packages"
   echo
}

# declaration of constants
NOCOLOR="\033[0m"
BOLD="\033[1m"
RED="\033[0;31m"
GREEN="\033[0;32m"
ORANGE="\033[0;33m"

# checking options and arguments
while getopts "h:n:" option; do
    case $option in
        h)
            Help
            exit;;
        n)
            number=${OPTARG}
            ;;
    esac
done

# going to aur directory
cd "/home/logan/aur/"

# parsing directories to array
directories=$(ls -d */ | tr -d "/" | xargs)
read -r -a array <<< "$directories"

count=0
for directory in "${array[@]}"
do
    # if user has specified -n option and enough packages have been updated
    if [ -n "${number}" ] && [ "${count}" -ge "${number}" ]; then
        break
    fi

    cd $directory
    echo "Trying to pull ${directory} git repository..."
    res=$(git pull --no-stat)
    error_code=$?
    if [ $error_code -eq 128 ]; then
        echo -e "${RED}Failed to pull ${directory}${NOCOLOR}"
    elif [ $error_code -eq 0 ]; then
        first_line=$(echo $res | head -n 1)
        if [ "$first_line" = "Already up to date." ]; then
            echo -e "${ORANGE}Package ${directory} is already up to date${NOCOLOR}"
        else
            echo -e "${BOLD}Building package ${directory}...${NOCOLOR}"
            echo
            makepkg -si --noconfirm
            git clean -fdx
            count=$(( count+1 ))
        fi
    fi
    cd ..
done
echo -e "${GREEN}${BOLD}Updated ${count} packages${NOCOLOR}"
