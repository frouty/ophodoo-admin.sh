#!/bin/bash

#--
# check if the branch exist in the rep
#--

cd $HOME/odoogoeen
git branch | grep -w $1 > /dev/null

if [ $? = 0 ]
then
  echo "branch exists"
else
  echo "branch doesn't exist"
fi