#!/usr/bin/env bash 
# which env

# chkVR=$1 ;
# echo -e "### chking : ${chkVR} ###" ;

############################################################
dojobs()
{
  fst_arg=$(echo "${@:1}"|cut -d ' ' -f1)
  snd_arg=$(echo "${@:2}"|cut -d ' ' -f1)
  thd_arg=$(echo "${@:3}"|cut -d ' ' -f1)

  # echo " ### $@ ### "
  $(echo "${action_funcmap[${fst_arg}]}") ${fst_arg} ${snd_arg} ${thd_arg}

}
############################### terrform-ACTION func-list ###############################
## ? 액션키에 매칭되는 함수 호출  ( 해시맵 활용 )

func_2()
{
  ### key : init , value : func_2 ### 
  # action=$1 ; opt_arg1=$2 ; opt_arg2=$3 ; asking_env ; 
  # echo -e "\n##### $@ ######\n"

  init_wsk=$(terraform workspace show);
  export TF_WORKSPACE="${init_wsk}" ; terraform init ;
}

func_1()
{
  ### key : backnd-init , value : func_1 ### 
  action=$1 ; opt_arg1=$2 ; opt_arg2=$3 ; 
  # echo -e "\n##### $@ ######\n"
  path_validchk;
  # env_wkchk ;
  [[ ${#chk_bkkey[@]} == 0 ]] && { echo -e "\n>>>>>>>> NO valid bknd-ENV (KEY). BYE~! >>>>>>>>\n" ; exit ;}

  echo -en "
${blue}############## BACKEND conf-file check ####################${reset}
"
  numlist_ask "BACKEND-SET" ${bknd_flist[@]} ; RPLY=${SELC} ;
  [[ "${RPLY}" != "" ]] && { for i in "${!bknd_flist[@]}"; do [[ "${bknd_flist[i]}" == "${RPLY}" ]] && { bkndfile="${RPLY}"; bkint_flag=true; break; }; done ; }
  [[ ${bkint_flag} == false ]] && { echo -e "\n>>>>>>>> NOT valid bknd-file. Input AGAIN from the list~! >>>>>>>>\n" ;  } 

# echo "*****${RPLY}*******"

  # terraform init -backend-config="+bknd.conf" -reconfigure

  terraform ${action} -backend-config="${ENV_PATH_}/${ENV_DIR_}/${bkndfile}" -reconfigure;
  echo -en "
!!! ${blue}DONE BACKEND SET UP Using Default-Workspace with${reset} ${red}${bkndfile}${reset} !!!
>>> ${blue}SO NEED to SYNC with THE ENV-WORKSPACE from tfvars FILE${reset} <<< 
  "
  env_wkchk; asking_env; $(echo "${action_funcmap[${action}]}") ;
}
