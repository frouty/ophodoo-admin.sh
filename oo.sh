#!/bin/bash
HOME=${HOME}

printf '%s ' 'Which fruit do you like most?'
read -${BASH_VERSION+e}r fruit

case $fruit in
    apple)
        echo 'Mmmmh... I like those!'
        ;;
    banana)
        echo 'Hm, a bit awry, no?'
        ;;
    orange|tangerine)
        echo $'Eeeks! I don\'t like those!\nGo away!'
        exit 1
        ;;
    *)
        echo "Unknown fruit - sure it isn't toxic?"
esac

echo "Le 1er paramètre est : $1"
echo "Le 3ème paramètre est : $3"
echo "Le 10ème paramètre est : ${10}"
echo "Le 15ème paramètre est : ${15}"
printf "Home:%s\n" "$HOME"
printf '\n$0:%s' $0
printf '\n$*:%s' $*
printf '\n$@:%s' $@

echo -e '\n et alors;'
yes | echo 'blabal'

read -p "Entrez le nom du repository sur lequel vous voulez travailler: " REP_NAME

cd $HOME/$REP_NAME
printf "\nVoici les branches de ce repository:\n" 
git branch -v
read -p "Entrez la branche sur laquelle vous voulez être: " BRANCH
printf "\nVous voulez être sur la branch: %s du repository: %s" "$BRANCH" "$REP_NAME"

