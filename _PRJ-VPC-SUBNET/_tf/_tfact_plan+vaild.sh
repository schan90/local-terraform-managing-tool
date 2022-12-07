#!/usr/bin/env bash 
# which env

# chkVR=$1 ;
# echo -e "### chking : ${chkVR} ###" ;
###################################################################
func_3()
{
  ### key : plan , value : func_3 ### 
  func_commonCMD $1 $2 $3
}

func_4()
{
  ### key : validate , value : func_6 ### 
  # terraform fmt ; terraform validate ;
  terraform fmt ; terraform fmt ${ENV_PATH_}/${ENV_DIR_} ; terraform validate ;
}