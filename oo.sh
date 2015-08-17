#!/bin/bash
HOME=${HOME}

printf "Home:%s\n" "$HOME"
read -p "Entrez le nom du repository sur lequel vous voulez travailler: " REP_NAME

cd $HOME/$REP_NAME
printf "\nVoici les branches de ce repository:\n" 
git branch -v
read -p "\nEntrez la branche sur laquelle vous voulez être: " BRANCH
printf "\nVous voulez être sur la branch: %s du repository: %s" "$BRANCH" "$REP_NAME"

