#!/bin/bash
HOME=${HOME}

printf "Home:%s\n" "$HOME"


read -p "Entrez le nom du repository sur lequel vous voulez travailler: " REP_NAME
read -p "Entrez la branche sur laquelle vous voulez être: " BRANCH
printf "\nVous voulez être sur la branch: %s du repository: %s" "$BRANCH" "$REP_NAME"

if [