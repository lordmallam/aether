#!/usr/bin/env bash

BRANCH_VERSION_TEXT='release-1.0.9'
version_compare () {
    if [[ $1 == $2 ]]
    then
      return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
      ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
      if [[ -z ${ver2[i]} ]]
      then
        # fill empty fields in ver2 with zeros
        ver2[i]=0
      fi
      if ((10#${ver1[i]} > 10#${ver2[i]}))
      then
        return 1
      fi
      if ((10#${ver1[i]} < 10#${ver2[i]}))
      then
        return 2
      fi
    done
    return 0
}

VERSION='1.0.9.1'
IFS=- read -a ver_number <<< "$BRANCH_VERSION_TEXT"
BRANCH_VERSION=${ver_number[1]}
version_compare $VERSION $BRANCH_VERSION
case $? in
  0) 
    echo 'Equals';;
  1) 
      echo 'VERSION value is greater than the branch version'
      exit 1;;
  2) 
      echo 'VERSION value is less than the branch version'
      exit 1;;
esac
