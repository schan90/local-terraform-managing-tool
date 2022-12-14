#!/usr/bin/env bash 
# which env

# chkVR=$1 ;
# echo -e "### chking : ${chkVR} ###" ;
###################################################################


func_13()
{
  ### key : other , value : func_13 ### 
  echo " Not Defined this ACTION YET~. BYE~ "; exit;
}

func_commonCMD()
{
  action=$1 ; opt_arg1=$2 ; opt_arg2=$3 ; envfile="" ; tfvarchk_flag=false ;
  # echo -e "\n##### $@ ######\n"
  for key in "${!env_map[@]}"; do [[ ${env_map[${key}]} == ${ENV_WKS} ]] && { envfile=${key} ; tfvarchk_flag=true ; } ; done

  if [[ ${action} == "plan" ]]; then 
    [[ ${tfvarchk_flag} == true ]] && { terraform ${action} --var-file="${ENV_PATH_}/${ENV_DIR_}/${envfile}" ;} || { echo "VALID-ERR" ; exit ;}
  else
    [[ ${tfvarchk_flag} == true ]] && { terraform ${action} --var-file="${ENV_PATH_}/${ENV_DIR_}/${envfile}" -auto-approve ;} || { echo "VALID-ERR" ; exit ;}
  fi

}