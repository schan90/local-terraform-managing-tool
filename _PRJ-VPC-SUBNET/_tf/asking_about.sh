#!/usr/bin/env bash 
# which env

# askVR=$1 ;
# echo -e "### asking : ${askVR} ###" ;
################################################################################
## ? 현재 wksp(env) 대화형 단계별 문/답 검증 및 확인 
asking_env()
{
  env_files=( $(ls ${ENV_PATH_}/${ENV_DIR_} |grep "${vardata_kyword}") ) ;
  [[ ${#env_files[@]} == 0 ]] && { echo -e "\nNO Vaild-ENV-VAR... Check the tfvars-file & Bye~! "; return 0 ; } 

  vck=( $( for i in "${env_files[@]}"; do cat ${ENV_PATH_}/${ENV_DIR_}/${i}|grep 'env'|cut -d '=' -f1| xargs ; done ) ) ;
  env_values=( $( for i in "${env_files[@]}"; do cat ${ENV_PATH_}/${ENV_DIR_}/${i}|grep 'env'|cut -d '=' -f2| xargs ; done ) ) ;

  let ENVF_EXPR=$(expr ${#env_files[@]} - 1); let ENVV_EXPR=$(expr ${#env_values[@]} - 1)
  echo "#########${env_files[@]}##########"
  echo "#########${env_values[@]}##########"

  [[ ${ENVF_EXPR} -eq ${ENVV_EXPR} ]] && { for i in $(seq 0 ${ENVV_EXPR}); do env_map[${env_files[i]}]=${env_values[i]}; done; } \
  || { echo -e "\nkey&value LENGTH or MATCHING error; BYE~" ; return 0 ;} 
  # echo ${env_values[@]} ; echo ${env_files[@]}
  #  declare -p env_map;
  prechk ;
  [[ ${AFTER_INIT_ENV_FLAG} == true ]] && { env_wk=$(cat .terraform/environment| xargs); echo -e "${green}WKS-INIT-INFO: DONE-INIT <${env_wk}>${reset}" ;} \
  || { echo -e "${green}WKS-INIT-INFO: BEFORE-INIT <${env_wk}>${reset}" ; }

  echo -en "
############## REFER to TFVAR-FILE-LIST ######################################
" 
  local let k=0;
  for i in ${!env_files[@]}; do 
    if [[ "${vck[k]}" != "env" ]]; then 
      echo -e "TFVAR-FILE: ${blue}${env_files[i]}${reset} < ${yellow}ENV-KEY not vaild (name-error -> ${vck[k]}) ${reset} >" ; unset 'env_files[i]' ;k=$((k+1)) ;
    else
      echo -e "TFVAR-FILE: ${blue}${env_files[i]}${reset} < ENV-KEY OK >"; k=$((k+1)) ;
    fi
  done
#########################################################################################
  echo -en "
${yellow}Is this ${reset}${red}** ${env_wk} **${reset}${yellow} workspace currently using correct that you are deploying on? ${reset}
Please pick a number below to answer ~ !!!

"
  select yn in "Yes" "No"; do
    case $yn in
      Yes ) RPLY="${env_wk}"; ENV_WKS="${env_wk}" ; break;;
      No )  RPLY=""; ENV_WKS="" ; break;;
    esac
  done

  [[ "${RPLY}" == "" ]] && { numlist_ask "ENV-SET" env_map ; RPLY=${SELC} ; ENV_WKS=${RPLY} ; } ;
  # echo "****** ${RPLY} : ${ENV_WKS} ******" ;

  prechk;
  # [[ "${RPLY}" == "default" ]] && { echo -e "\n>>>>>>>>>> Can't Using DEFAULT Terrform-WorkSpace >>>>>>>>>>\n"; exit ;  }
  [[ "${RPLY}" != "${env_wk}" ]] && { echo -e "\n${yellow}>>> Not SAME the ENV with Terrform-WorkSpace. Making & Switching to ${ENV_WKS} >>>${reset}\n"; mtch_flag=false; env_set ${ENV_WKS} ;  } \
  || { mtch_flag=true; env_set ${ENV_WKS}  ; }
}
###################################################################
# ? 프로파일 넘버링 리스트 함수 정의 및 컬러하일라이팅
numlist_ask()
{
  ask_act=$( echo "${@:1:1}" | xargs ) ;
  [[ ${ask_act} == "ENV-SET" ]] && { data_init=$(declare -p "${@:2}") ; eval "declare -A data="${data_init#*=} ; } \
  || data=( "${@:2}" ) ;

  SELECTION=1 ; KSELEC=0 ;
  ENTITIES=$(printf "%s\n" "${data[@]}") ;
  ENTITIES_key=( "${!data[@]}" ) ;

  # echo -e "${ENTITIES_key[@]}" ;
  # echo -e "${ENTITIES[@]}" ;

  echo -en "
Which ${ask_act} do you want as below? : 

"
  numlist_ask.prnt()
  {
    while read -r line; do
      echo -e "${red}$SELECTION)${reset} ${purple}${line}${reset}"
      ((SELECTION++))
    done <<< "$ENTITIES"
    ((SELECTION--)) ;
  }
  numlist_ask.prnt2()
  {
    while read -r line; do
      echo -e "${red}$SELECTION)${reset} ENV-WKS: ${purple}${line}${reset} (from ${ENTITIES_key[${KSELEC}]} FILE)"
      ((SELECTION++)) ; ((KSELEC++)) ;
    done <<< "${ENTITIES}"
    ((SELECTION--)) ; ((KSELEC--)) ;
  }


  numlist_ask.do()
  {
    [[ ${ask_act} == "ENV-SET" ]] && { numlist_ask.prnt2 ; return 0 ; } ;
    [[ ${ask_act} != "" ]] && { numlist_ask.prnt ; return 0 ; };
  }

#####################
  while [[ "${opt}" == "" ]]; do
    numlist_ask.do ;
    echo -e
    printf "SELECT ${ask_act} you want from the list: "
    read -r opt
    # echo -e "*** ${SELECTION} ****"

    if [[ ${opt} == "" || ${#opt} == 0 ]]; then
      echo -e "${red}NO INVAILD INPUT, Choose NUMBER ~! ${reset} \n" ; SELECTION=1 ; KSELEC=0 ; 
    elif [[ $(seq 1 $SELECTION) =~ $opt ]]; then
      selcted=$( sed -n "${opt}p" <<< "$ENTITIES" ); SELC=${selcted} ; break ;
    else
      echo -e "WRONG NUMBER OR INVAILD INPUT\n" ; SELECTION=1 ; KSELEC=0 ; opt="" ; 
    fi

  done
  # echo -e "${opt} : ${SELC}" ;
  opt="" ;

}

