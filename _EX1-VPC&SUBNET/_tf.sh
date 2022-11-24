#!/usr/bin/env bash 
# which env

#############################################################################################################################################
#* Terraform management tools using terrform-cli ( * --  made by schan -- * )
# VER: 1st-beta v0.8.9
# git tag v0.8.9 / git push origin schan
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
####################### init for ACTION-FUNC-MAP ##########################
## ? tfvars 데이터파일 경로 및 grep 키워드 초기화 
ENV_PATH_="." ; ENV_DIR_="env" ; vardata_kyword=".tfvars" ; backndfile_kyword="bknd" ;

## ? bool flag 모드, 컨디션 스위치 초기화 
AFTER_INIT_ENV_FLAG=false ; mtch_flag=false ; valck_flag=false ; bkint_flag=false ; askjob_flag=false ;

## ? terrform-cli 액션 초기화 , terrform workspace 초기화
ACTION="" ; ENV_WKS="" ; 

## ? terrform 액션 리스트 정의 및 디폴트 액션 설정 
JOBS_ACTION=( "init" "backnd-init" "plan" "apply" "destroy" "validate" "new-wks" "mv-wks" "del-wks" "import" "state-list" "other" )
key_list=(${JOBS_ACTION[@]}) ; DEFAULT_JOB=${JOBS_ACTION[2]} ;

## ? terrform 액션 맵핑 함수 리스트 초기화, 함수명_일련번호 변수초기화
func_list=(); num_sfx=1 ;

##############################################################
## ? terrform 액션과 함수 배열을 해시맵으로 생성 후 액션명을 맵의 키로설정 하여 해당 키로 함수 정의
for i in "${!JOBS_ACTION[@]}"; do func_list[i]="func_${num_sfx}"; num_sfx=$((num_sfx+1)); done ;
value_list=(${func_list[@]}) ; 

declare -A action_funcmap; declare -A env_map; 
let KEY_EXPR=$(expr ${#JOBS_ACTION[@]} - 1) ; let VALUE_EXPR=$(expr ${#func_list[@]} - 1) ;

jobmap_func() { mapKEY=$1 ; mapVLU=$2 ; action_funcmap[$1]=$2 ; }

[[ $KEY_EXPR -eq $VALUE_EXPR ]] && { for ((i=0;i<=${KEY_EXPR};i++)); do jobmap_func ${key_list[$i]} ${value_list[$i]} ; done ; } \
|| echo "NOT matched key&value LENGTH..."

##############################################################
## ? env tfvars 데이터 파일 경로 및 백엔드설정파일 유효성 체크 및 해당 ENV init 작업 유/무 체크 (bool 값  flg 활용) 
path_validchk()
{
  flg=$(ls ${ENV_PATH_}/${ENV_DIR_} 2> /dev/null);
  [[ ${flg} == "" ]] && { echo "==== NOT valid ENV-PATH. Plz Check the ENV-PATH~! ===="; exit; }
  # || { echo "========= VALID ENV-PATH OK ========="; } 

  bknd_flist=( $(ls ${ENV_PATH_}/${ENV_DIR_} 2> /dev/null |grep "${backndfile_kyword}" |xargs ) );

  flg_int=$(ls .terraform/environment 2> /dev/null);
  [[ ${flg_int} != "" ]] && { AFTER_INIT_ENV_FLAG=true ;}
}

##############################################################
## ? 현재 wksp 체크 함수설정 및 ENV 일치여부 유효성 체크
prechk(){ env_wk=$(terraform workspace show); }

env_wkchk()
{
  path_validchk; prechk;

  [[ ${env_wk} == "default" ]] && { echo "Need to make NEW WKSP OR Switching WKSP as the same as ENV from tfvars-file "; } \
  || { ENV_WKS=${env_wk}; echo "This ENV(Terrform-WorkSpace) is ${env_wk} " ; }
}

##############################################################
## ? 현재 wksp(env) 대화형 단계별 문/답 검증 및 확인 
asking_env()
{
  env_files=( $(ls ${ENV_PATH_}/${ENV_DIR_} |grep "${vardata_kyword}") ) ;
  vck=( $( for i in "${env_files[@]}"; do cat ${ENV_PATH_}/${ENV_DIR_}/${i}|grep 'env'|cut -d '=' -f1| xargs ; done ) ) ;
  let k=0;

  for i in ${!env_files[@]}; do 
    if [[ "${vck[k]}" != "env" ]]; then 
      echo "TFVAR-FILE ${env_files[i]} : ENV-KEY not vaild (name-error -> ${vck[k]})"; unset 'env_files[i]' ;k=$((k+1)) ;
    else
      echo "TFVAR-FILE ${env_files[i]} : ENV-KEY OK"; k=$((k+1)) ;
    fi
  done

  [[ ${#env_files[@]} == 0 ]] && { echo "NO Vaild-ENV-VAR... Check the tfvars-file & Bye~! "; exit ; } 
  env_values=( $( for i in "${env_files[@]}"; do cat ${ENV_PATH_}/${ENV_DIR_}/${i}|grep 'env'|cut -d '=' -f2| xargs ; done ) )
  # echo ${env_values[@]} ; echo ${env_files[@]}

  let ENVF_EXPR=$(expr ${#env_files[@]} - 1); let ENVV_EXPR=$(expr ${#env_values[@]} - 1)
  [[ ${ENVF_EXPR} -eq ${ENVV_EXPR} ]] && { for ((i=0;i<=${ENVV_EXPR};i++)); do env_map[${env_files[i]}]=${env_values[i]}; done; } \
  || { echo "key&value LENGTH or MATCHING error; BYE~" ; exit ;} 

  #  declare -p env_map;
  prechk ;
  [[ ${AFTER_INIT_ENV_FLAG} == true ]] && { env_wk=$(cat .terraform/environment| xargs); echo "after-init-env: ${env_wk}" ;} \
  || { echo "before-init-env: ${env_wk}" ; }

#####################################################################################################################
  echo "
  Is this ** ${env_wk} ** workspace currently using correct that you are deploying on? 
  Please pick a number below to answer ~ !!!
  "
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) RPLY="${env_wk}"; ENV_WKS="${RPLY}" ; break;;
          No ) RPLY=""; break;;
      esac
  done
#####################################################################################################################

  while [[ "${RPLY}" == "" ]]; do echo -n "
############## PRE-CHECK ENV ##################################################
Tell me ENV to match on the tfvars file for deploy~! :

USAGE-EX >
dev OR qa OR prd ...
dev-prj1 OR qa-prj1 OR prd-prj1 OR ...

############# REFER to THIS ENV-LIST below ####################################
$( for i in "${!env_map[@]}"; do t=$(echo "${i}"|cut -d ' ' -f1) ; echo "${env_map[${t}]} (from $t FILE)"; done ; )

If NO input, asking repeat ... !!!
$( echo " !!! Using ENV(Terrform-WorkSpace) is ${env_wk} !!! " ; )

reply-input >>>  "
    read RPLY
    # echo "### ${RPLY} ###"
    tmp=( $(ls ${ENV_PATH_}/${ENV_DIR_}/ |grep "${vardata_kyword}"|xargs) )

    [[ "${RPLY}" != "" ]] && { dpy_env=$( for i in "${tmp[@]}"; do echo $(cat "${ENV_PATH_}/${ENV_DIR_}/$i"|grep "${ENV_DIR_}" |grep "${RPLY}"|cut -d '=' -f2 ) ; done ) ; } || RPLY="" ;
    dpy_env=$(echo ${dpy_env} |tr -d '"') ;
    # echo "### ${dpy_env} : ${RPLY} ###" ;
    [[ "${dpy_env}" != "${RPLY}" ]] && { echo -e "\n>>>>>>>>>> Invalid ENV... Valid Input Again >>>>>>>>>>\n"; RPLY="" ; } || ENV_WKS="${RPLY}" ; 

  done

  prechk;
  [[ "${RPLY}" != "${env_wk}" ]] && { echo -e "\n>>>>>>>>>> Not Matched ENV with Terrform-WorkSpace. >>>>>>>>>>\n"; mtch_flag=false; env_set ; } \
  || { mtch_flag=true; env_set  ; }

}
#####################################################################################################################
## ? 현재 wksp(env) 변경 및 신규 설정 / 선택 활용
env_set()
{
  [[ "${mtch_flag}" != true ]] && { echo "### Creating OR Switching Terrform-WorkSpace as like to ENV you input. ###"; env_newSELCT ${RPLY}; }
  # || { echo -e "\n======== terraform workspace list =========\n"; terraform workspace list ; } 
}

env_newSELCT()
{
  chENVWK=$1;
  ###################### ref. ###########################################################################
  # - terraform workspace show, terraform workspace list, 
  # - terraform workspace new, terraform workspace select, terraform workspace delete
  #######################################################################################################
  terraform workspace new ${chENVWK} ; terraform workspace select ${chENVWK} ; 
  echo -e "\n======== terraform workspace list =========\n";
  terraform workspace list ;
}

############################################### terrform-JOB about ###############################################
## ? 인풋액션 유효성 검증 
act_vck()
{
  para_arg=( ${JOBS_ACTION[@]} ) ; match=0; envchkr="${1}" ;
  for argv in "${para_arg[@]}" ; do [[ "${argv}" == "${envchkr}" ]] && { match=1 ; break ;  } ; done ;
  [[ ${match} != 1 ]] && { echo "INVAILD ACTION~! BYE~! " ; exit ; }
}

jloop(){ para_arg=( ${JOBS_ACTION[@]} ) ; for ((i=0;i<=${KEY_EXPR};i++)); do echo "${JOBS_ACTION[i]}" ; done ; }

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

func_1()
{
  ### key : init , value : func_1 ### 
  # action=$1 ; opt_arg1=$2 ; opt_arg2=$3 ; asking_env ; 
  # echo -e "\n##### $@ ######\n"

  init_wsk=$(terraform workspace show) 
  terraform init -workspace=${init_wsk} ; terraform init
}

func_2()
{
  ### key : backnd-init , value : func_2 ### 
  action=$1 ; opt_arg1=$2 ; opt_arg2=$3 ; path_validchk ; 
  # echo -e "\n##### $@ ######\n"

  while [[ "${RPLY_BKNDF}" == "" ]]; do echo -n "
############## BACKEND conf-file check ##################################################
Tell me BACKEND conf-file for deploy~! :

############# REFER to THIS BACKEND conf-file below ####################################
$( for i in "${bknd_flist[@]}"; do echo "BACKEND conf-file : $i" ; done ; )

If NO input, asking repeat ... !!! 
reply-input >>>  "
    read RPLY_BKNDF
    [[ "${RPLY_BKNDF}" != "" ]] && \
    { 
      for i in "${bknd_flist[@]}"; do 
        [[ "${bknd_flist[i]}" == "${RPLY_BKNDF}" ]] && { bkndfile="${RPLY_BKNDF}"; bkint_flag=true; break; }; 
      done ;
    }

    [[ ${bkint_flag} == false ]] && { echo -e "\n>>>>>>>> NOT valid bknd-file. Input AGAIN from the list~! >>>>>>>>\n" ; RPLY_BKNDF="" ; } 
  done

  # terraform init -backend-config="+bknd.conf" -reconfigure
  terraform ${action} -backend-config="${ENV_PATH_}/${ENV_DIR_}/${bkndfile}" -reconfigure;
  env_wkchk; asking_env; $(echo "${action_funcmap[${action}]}")
}

############################
func_3()
{
  ### key : plan , value : func_3 ### 
  func_commonCMD $1 $2 $3
}

func_4()
{
  ### key : apply , value : func_4 ### 
  func_commonCMD $1 $2 $3
}

func_5()
{
  ### key : destory , value : func_5 ### 
  func_commonCMD $1 $2 $3
}

func_6()
{
  ### key : validate , value : func_6 ### 
  # terraform fmt ; terraform validate ;
  terraform fmt ; terraform fmt ${ENV_PATH_}/${ENV_DIR_} ; terraform validate ;
}

func_7()
{
  ### key : new-wks , value : func_7 ### 
  # echo " ### $@ ### "
  # echo " ${env_wk} "; echo " new-wks testing. BYE~ "; exit;
  newwk=$1
  [[ "${newwk}" != "" ]] && { terraform workspace new ${newwk} ;  }

  while [[ "${newwk}" == "" ]]; do echo -n "
############## NEW Terrform WORKSPACE ########################################
Tell me the new Terrform WORKSPACE you want ~!  :

############# REFER to Current WORKSPACE  ####################################
$( terraform workspace list ; )

If NO input, asking repeat ... !!! 
reply-input >>>  "
    read newwk
    [[ "${newwk}" != "" ]] && { terraform workspace new ${newwk} ;  }
  done

  echo "########################"
  terraform workspace list ; newwk="" ;
}

func_8()
{
  ### key : mv-wks , value : func_8 ### 
  # echo " ### $@ ### "
  mvwk=$1
  [[ "${mvwk}" != "" ]] && { terraform workspace select ${mvwk} ;  }

  while [[ "${mvwk}" == "" ]]; do echo -n "
############## Switching Terrform WORKSPACE ##################################
Tell me the Terrform WORKSPACE to Switch ~!  :

############# REFER to Current WORKSPACE  ####################################
$( terraform workspace list ; )

If NO input, asking repeat ... !!! 
reply-input >>>  "
    read mvwk
    [[ "${mvwk}" != "" ]] && { terraform workspace select ${mvwk} ;  }
  done

  echo "########################"
  terraform workspace list ; mvwk="" ;
}

func_9()
{
  ### key : del-wks , value : func_9 ### 
  # echo " Not Defined this ACTION YET~. BYE~ "; exit;
  delwk=$1
  [[ "${delwk}" != "" ]] && { terraform workspace delete ${delwk} ;  }

  while [[ "${delwk}" == "" ]]; do echo -n "
############## Terrform WORKSPACE to DELETE ##################################
Tell me the Terrform WORKSPACE to Delete ~!  :

############# REFER to Current WORKSPACE  ####################################
$( terraform workspace list ; )

If NO input, asking repeat ... !!! 
reply-input >>>  "
    read delwk
    [[ "${delwk}" != "" ]] && { terraform workspace delete ${delwk} ;  }
  done

  echo "########################"
  terraform workspace list ; delwk="" ;
}

func_10()
{
  ### key : import , value : func_10 ### 
  echo " Not Defined this ACTION YET~. BYE~ "; exit;
}

func_11()
{
  ### key : state-list , value : func_11 ### 
  echo " Not Defined this ACTION YET~. BYE~ "; exit;
}

func_12()
{
  ### key : other , value : func_12 ### 
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

############# ! local ###################################
# declare -p action_funcmap ;
# declare -p env_map ;
# askjob_flag=false ;
# asking_env ;

############# ? sub-main ###################################
## ? 코드 실행시 입력되는 인자에 따라 아래와 같이 코드 실행 ( argment 가 없는 경우 단계별 대화 문답 )
# ACTION=$1 ;

ACTION=$(echo "${@:1}"|cut -d ' ' -f1)
ACTION_opt1=$(echo "${@:2}"|cut -d ' ' -f1)
ACTION_opt2=$(echo "${@:3}"|cut -d ' ' -f1)
# echo "${ACTION_opt1}" ;

[[ $# == 0 ]] && { env_wkchk; askjob_flag=true ; }

[[ ${askjob_flag} == true  ]] && {
echo -n "
############################################################
Which terrform-job do you want as below? : 

$(jloop)

############################################################
If NO input & press ENTER, doing ${DEFAULT_JOB} ~!
reply-action >>> "
  read REPLY
  echo "========================================================"
  [[ "${REPLY}" == "" ]] && { selc_job="${DEFAULT_JOB}" ; echo -e "Doing DEFALT-ACTION... : ${DEFAULT_JOB}" ;} \
  || { selc_job="${REPLY}" ; }
  act_vck "${selc_job}" ; ACTION="${selc_job}" ; 
}

[[ ${ACTION} == "validate" ]] && { valck_flag=true; $(echo "${action_funcmap[${ACTION}]}"); valck_flag=false; exit ; } 
[[ ${ACTION} == "init" ]] && { env_wkchk; asking_env; $(echo "${action_funcmap[${ACTION}]}") ; exit ; } 
[[ ${ACTION} == "backnd-init" ]] && { $(echo "${action_funcmap[${ACTION}]}") init ; exit ; } 

[[ ${ACTION} == "new-wks" ]] && { prechk; $(echo "${action_funcmap[${ACTION}]}") $2 ; exit ; } 
[[ ${ACTION} == "mv-wks" ]] && { prechk; $(echo "${action_funcmap[${ACTION}]}") $2 ; exit ; } 
[[ ${ACTION} == "del-wks" ]] && { prechk; $(echo "${action_funcmap[${ACTION}]}") $2 ; exit ; } 
[[ ${ACTION} == "state-list" ]] && { prechk; $(echo "${action_funcmap[${ACTION}]}") ; exit ; } 

[[ ${ACTION} != "" ]] && { env_wkchk; act_vck "${ACTION}" ; asking_env ; dojobs "${ACTION}"; exit ; }

########################## END #############################

