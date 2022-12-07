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
  ###################### ref. ###########################################################################
  # - terraform workspace show, terraform workspace list, 
  # - terraform workspace new, terraform workspace select, terraform workspace delete
  #######################################################################################################
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
  # backend 설정시 defailt wks 사용함, 별도로 다른 wks 사용하려면 미리 해당 wks 생성되어 있어야만 사용/변경 가능
  terraform workspace select default ;

  # backend 설정파일의 wks 값을 변수화 할수 없음으로 default 설정 후 tfvars 의 env 값으로 wks 변경함. 이후 리소스 현황을 해당 wks tfstate 에 기록
  terraform ${action} -backend-config="${ENV_PATH_}/${ENV_DIR_}/${bkndfile}" -reconfigure;
  echo -en "
!!! ${blue}DONE BACKEND SET UP Using Default-Workspace with${reset} ${red}${bkndfile}${reset} !!!
>>> ${blue}SO NEED to SYNC with THE ENV-WORKSPACE from tfvars FILE${reset} <<< 
  "
  env_wkchk; asking_env; $(echo "${action_funcmap[${action}]}") ;
}
