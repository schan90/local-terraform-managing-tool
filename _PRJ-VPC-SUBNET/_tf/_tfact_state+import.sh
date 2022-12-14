#!/usr/bin/env bash 
# which env

# chkVR=$1 ;
# echo -e "### chking : ${chkVR} ###" ;
###################################################################

func_10()
{
  ### key : state-list , value : func_11 ### 
  echo
  terraform workspace show;
  echo
  terraform state list ;
  # echo " Not Defined this ACTION YET~. BYE~ "; exit;
}

func_11()
{
  ### key : state-show , value : func_11 ### 
  echo " Not Defined this ACTION YET~. BYE~ "; exit;
}

func_12()
{
  ### key : import , value : func_10 ### 
  echo " Not Defined this ACTION YET~. BYE~ "; exit;
}