#!/usr/bin/env bash 
# which env

#############################################################################################################################################
#* Terraform management tools using terrform-cli ( * --  made by schan -- * )
#  _________  _______   ________  ________  ________  ________ ________  ________  _____ ______                  ________  ___       ___     
# |\___   ___\\  ___ \ |\   __  \|\   __  \|\   __  \|\  _____\\   __  \|\   __  \|\   _ \  _   \               |\   ____\|\  \     |\  \    
# \|___ \  \_\ \   __/|\ \  \|\  \ \  \|\  \ \  \|\  \ \  \__/\ \  \|\  \ \  \|\  \ \  \\\__\ \  \  ____________\ \  \___|\ \  \    \ \  \   
#      \ \  \ \ \  \_|/_\ \   _  _\ \   _  _\ \   __  \ \   __\\ \  \\\  \ \   _  _\ \  \\|__| \  \|\____________\ \  \    \ \  \    \ \  \  
#       \ \  \ \ \  \_|\ \ \  \\  \\ \  \\  \\ \  \ \  \ \  \_| \ \  \\\  \ \  \\  \\ \  \    \ \  \|____________|\ \  \____\ \  \____\ \  \ 
#        \ \__\ \ \_______\ \__\\ _\\ \__\\ _\\ \__\ \__\ \__\   \ \_______\ \__\\ _\\ \__\    \ \__\              \ \_______\ \_______\ \__\
#         \|__|  \|_______|\|__|\|__|\|__|\|__|\|__|\|__|\|__|    \|_______|\|__|\|__|\|__|     \|__|               \|_______|\|_______|\|__|
#############################################################################################################################################
# * Pre-Required >>> 
# - bash ver: 4.x higher ( bash --version ; which bash )
# ? amazon-linux2 default: bash ver 4.2 (OK)
# ! macOS default: bash ver 3.x ( Need to update to 4.x & set as Default Bash version )
# ref > https://itnext.io/upgrading-bash-on-macos-7138bd1066ba
#
# - sed ver: GNU sed ver 4.2 ( sed --version ; which sed )
# ? linux default: GNU sed ver 4.2.2  (OK)
# ! macOS default: POSIX sed based on unix (need to change as gnu-sed default using brew)
#  ㄴ gnu-sed for mac : /opt/homebrew/opt/gnu-sed/libexec/gnubin/sed
# ref > https://medium.com/@bramblexu/install-gnu-sed-on-mac-os-and-set-it-as-default-7c17ef1b8f64 
#
# Tested OS env (amazon-linux2 & macOS)
#   - macOS 13.0 ventura
#   - amazon-linux2 
#
##################################################################################################################################################################################################################################################################################################
# git tag v0.9.92 / git push origin schan / master ( git config --local user.name "schan90" / git config --local user.email "qnas90@gmail.com" )
# git pull both HEAD / git push both HEAD  
tfmg_ver="beta_v0.9.92"

## ? tfvars 데이터파일 경로 및 grep 키워드 초기화 
ENV_PATH_="." ; ENV_DIR_="env" ; vardata_kyword=".tfvars" ; backndfile_kyword=".hcl" ;

## ? terrform 액션 리스트 정의 및 디폴트 액션 설정 
JOBS_ACTION=( "backnd-init" "init" "plan" "validate" "apply" "destroy" "new-wks" "mv-wks" "del-wks" "state-list" "import" "other" )
DEFAULT_JOB=${JOBS_ACTION[1]} ; key_list=(${JOBS_ACTION[@]}) ;

# ? ansi color code; cmd 차일드 프로세스에서 사용할 컬러 하이라이팅 코드 값 export 처리
export red="\e[1;31m" green="\e[1;32m"  yellow="\e[1;33m" grey="\e[0;37m" ;
export blue="\e[1;34m"  purple="\e[1;35m" cyan="\e[1;36m" reset="\e[m" ;

# source x.sh
source _tf/_init+chkvaild.sh ${tfmg_ver} ;

source _tf/asking_about.sh  ;
source _tf/env_wks.sh ;

source _tf/_tfact_inits.sh ; 
source _tf/_tfact_plan+vaild.sh  ;
source _tf/_tfact_apply+destory.sh  ;

source _tf/_tfact_wksp.sh  ;
source _tf/_tfact_state+import.sh  ;
source _tf/_tfact_others.sh  ;

#####################################################################! fn-local ########################################################################################
dojobs()
{
  fst_arg=$(echo "${@:1}"|cut -d ' ' -f1)
  snd_arg=$(echo "${@:2}"|cut -d ' ' -f1)
  thd_arg=$(echo "${@:3}"|cut -d ' ' -f1)

  # echo " ### $@ ### "
  $(echo "${action_funcmap[${fst_arg}]}") ${fst_arg} ${snd_arg} ${thd_arg}

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

# declare -p action_funcmap ;
# declare -p env_map ;

# jloop(){ para_arg=( ${JOBS_ACTION[@]} ) ; for ((i=0;i<=${KEY_EXPR};i++)); do echo "${JOBS_ACTION[i]}" ; done ; }
############# ? sub-main ###################################
## ? 코드 실행시 입력되는 인자에 따라 아래와 같이 코드 실행 ( argment 가 없는 경우 단계별 대화 문답 )
# ACTION=$1 ;

ACTION=$(echo "${@:1}"|cut -d ' ' -f1)
ACTION_opt1=$(echo "${@:2}"|cut -d ' ' -f1)
ACTION_opt2=$(echo "${@:3}"|cut -d ' ' -f1)

[[ $# == 0 ]] && { askjob_flag=true ;  }
[[ ${askjob_flag} == true  ]] && { numlist_ask "terrform-job" ${JOBS_ACTION[@]} ; act_vck "${SELC}" ; ACTION="${SELC}" ; }

[[ ${ACTION} == "validate" ]] && { valck_flag=true; $(echo "${action_funcmap[${ACTION}]}"); valck_flag=false; exit ; } 
[[ ${ACTION} == "init" ]] && { env_wkchk; asking_env; $(echo "${action_funcmap[${ACTION}]}") ; exit ; } 
[[ ${ACTION} == "backnd-init" ]] && { $(echo "${action_funcmap[${ACTION}]}") init ; exit ; } 

[[ ${ACTION} == "new-wks" ]] && { prechk; $(echo "${action_funcmap[${ACTION}]}") $2 ; exit ; } 
[[ ${ACTION} == "mv-wks" ]] && { prechk; $(echo "${action_funcmap[${ACTION}]}") $2 ; exit ; } 
[[ ${ACTION} == "del-wks" ]] && { prechk; $(echo "${action_funcmap[${ACTION}]}") $2 ; exit ; } 
[[ ${ACTION} == "state-list" ]] && { prechk; $(echo "${action_funcmap[${ACTION}]}") ; exit ; } 

[[ ${ACTION} != "" ]] && { act_vck "${ACTION}" ; env_wkchk ; asking_env ; dojobs "${ACTION}"; exit ; }

########################## END #############################

