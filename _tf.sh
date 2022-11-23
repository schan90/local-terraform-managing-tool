#!/usr/bin/env bash 
# which env

#############################################################################################################################################
#* Terraform management tools using terrform-cli ( * --  made by schan -- * )
# VER: 1st-beta v0.7.1
# git tag v0.7.1
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
ENV_PATH_="." ; ENV_DIR_="env" ; AFTER_INIT_ENV_FLAG=false ;
ACTION="" ; ENV_WKS="" ; backndfile_flag="bknd" ; mtch_flag=false ; valck_flag=false ; 

JOBS_ACTION=( "init" "backnd_init" "plan" "apply" "destroy" "validate" "new-wks" "mv-wks" "del-wks" "import" "other" )
key_list=(${JOBS_ACTION[@]}) ; DEFAULT_JOB=${JOBS_ACTION[2]} ;

func_list=(); num_sfx=1 ;
for i in "${!JOBS_ACTION[@]}"; do func_list[i]="func_${num_sfx}"; num_sfx=$((num_sfx+1)); done ;
value_list=(${func_list[@]}) ; 

declare -A action_funcmap; declare -A env_map; 
let KEY_EXPR=$(expr ${#JOBS_ACTION[@]} - 1)
let VALUE_EXPR=$(expr ${#func_list[@]} - 1)

jobmap_func() { mapKEY=$1 ; mapVLU=$2 ; action_funcmap[$1]=$2 ; }

[[ $KEY_EXPR -eq $VALUE_EXPR ]] && { for ((i=0;i<=${KEY_EXPR};i++)); do jobmap_func ${key_list[$i]} ${value_list[$i]} ; done ; } \
|| echo "NOT matched key&value LENGTH..."

##############################################################
path_validchk()
{
  flg=$(ls ${ENV_PATH_}/${ENV_DIR_} 2> /dev/null);
  [[ ${flg} == "" ]] && { echo "==== NOT valid ENV-PATH. Plz Check the ENV-PATH~! ===="; exit; } \
  || { echo "========= VALID ENV-PATH OK ========="; } 

  flg_int=$(ls .terraform/environment 2> /dev/null);
  [[ ${flg_int} != "" ]] && { AFTER_INIT_ENV_FLAG=true ;}

  bkndflg=( $(ls ${ENV_PATH_}/${ENV_DIR_} 2> /dev/null |grep "${backndfile_flag}" |xargs ) );

}

prechk(){ env_wk=$(terraform workspace show); }
##############################################################
env_wkchk()
{
  path_validchk; prechk;

  [[ ${env_wk} == "default" ]] && { echo "Need to make NEW WKSP as the same as ENV from tfvars-file "; asking_env; } \
  || { ENV_WKS=${env_wk}; echo "This ENV(Terrform-WorkSpace) is ${env_wk} " ; }
}

##############################################################

asking_env()
{
  env_files=( $(ls ${ENV_PATH_}/${ENV_DIR_} |grep '.tfvars') ) ;
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
    tmp=( $(ls ${ENV_PATH_}/${ENV_DIR_}/ |grep '.tfvars'|xargs) )

    [[ "${RPLY}" != "" ]] && { dpy_env=$( for i in "${tmp[@]}"; do echo $(cat "${ENV_PATH_}/${ENV_DIR_}/$i"|grep "${ENV_DIR_}" |grep "${RPLY}"|cut -d '=' -f2 ) ; done ) ; } || RPLY="" ;
    dpy_env=$(echo ${dpy_env} |tr -d '"') ;
    # echo "### ${dpy_env} : ${RPLY} ###" ;
    [[ "${dpy_env}" != "${RPLY}" ]] && { echo -e "\n>>>>>>>>>> Invalid ENV... Valid Input Again >>>>>>>>>>\n"; RPLY="" ; } || ENV_WKS="${RPLY}" ; 

  done

  # echo "${env_wk}" 
  # echo "${ENV_WKS}" 
  prechk;
  [[ "${RPLY}" != "${env_wk}" ]] && { echo -e "\n>>>>>>>>>> Not Matched ENV with Terrform-WorkSpace. >>>>>>>>>>\n"; mtch_flag=false; env_set ${mtch_flag} ; } \
  || { mtch_flag=true; env_set ${mtch_flag} ; }

}

env_set()
{
  # echo " ##### $@ : ${RPLY} ##### "
  envflag=$1 ;

  [[ "${envflag}" != true ]] && { echo "### Creating OR Switching Terrform-WorkSpace as like to ENV you input. ###"; env_newSELCT ${RPLY}; } \
  || { echo -e "\n======== terraform workspace list =========\n"; terraform workspace list ; } 
}

env_newSELCT()
{
  chENVWK=$1;
  ###################### ref. ###########################################################################
  # - terraform workspace show, terraform workspace list, 
  # - terraform workspace new, terraform workspace select, terraform workspace delete
  #######################################################################################################
  terraform workspace new ${chENVWK} ; terraform workspace select ${chENVWK} ; terraform workspace list ;
}

############################################### terrform-JOB about ###############################################
jloop(){ para_arg=( ${JOBS_ACTION[@]} ) ; for ((i=0;i<=${KEY_EXPR};i++)); do echo "${JOBS_ACTION[i]}" ; done ; }

act_vck()
{
  para_arg=( ${JOBS_ACTION[@]} ) ; match=0; envchkr="${1}" ;
  for argv in "${para_arg[@]}" ; do [[ "${argv}" == "${envchkr}" ]] && { match=1 ; break ;  } ; done ;
  [[ ${match} != 1 ]] && { echo "INVAILD ACTION~! BYE~! " ; exit ; }
}

############################################################
asking_job()
{
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
func_1()
{
  ### key : init , value : func_1 ### 
  action=$1 ; opt_arg1=$2 ; opt_arg2=$3 ; asking_env ; 
  # echo -e "\n##### $@ ######\n"

  init_wsk=$(terraform workspace show) 
  terraform init -workspace=${init_wsk} ; terraform init
}

func_2()
{
  ### key : backnd_init , value : func_2 ### 
  action=$1 ; opt_arg1=$2 ; opt_arg2=$3 ; path_validchk ; 
  # echo -e "\n##### $@ ######\n"

  while [[ "${RPLY_BKNDF}" == "" ]]; do echo -n "
############## BACKEND conf-file check ##################################################
Tell me BACKEND conf-file for deploy~! :

############# REFER to THIS BACKEND conf-file below ####################################
$( for i in "${bkndflg[@]}"; do echo "BACKEND conf-file : $i" ; done ; )

If NO input, asking repeat ... !!! 
reply-input >>>  "
    read RPLY_BKNDF
    bkfchk_flag=false
    [[ "${RPLY_BKNDF}" != "" ]] && { for i in "${bkndflg[@]}"; do [[ "${bkndflg[i]}" == "${RPLY_BKNDF}" ]] && { bkfchk_flag=true; break; } ; done ; }
    [[ ${bkfchk_flag} == false ]] && { echo -e "\n>>>>>>>> NOT valid bknd-file. Input AGAIN from the list~! >>>>>>>>\n" ; RPLY_BKNDF="" ; } 
  done

  # terraform init -backend-config="+bknd.conf" -reconfigure
  terraform ${action} -backend-config="${ENV_PATH_}/${ENV_DIR_}/${bkndfile}"
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
  # echo " ${env_wk} "; echo " mv-wks testing. BYE~ "; exit;
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
  ### key : other , value : func_11 ### 
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

# declare -p action_funcmap
# declare -p env_map 

############# ? sub-main ###################################
# asking_env

[[ $# == 0 ]] && { env_wkchk; asking_env; asking_job; dojobs "${ACTION}" ; }
[[ $1 == "validate" ]] && { valck_flag=true; $(echo "${action_funcmap[${1}]}"); exit ; } 
[[ $1 == "init" ]] && { env_wkchk; $(echo "${action_funcmap[${1}]}") ; exit ; } 
[[ $1 == "new-wks" ]] && { prechk; $(echo "${action_funcmap[${1}]}") $2 ; exit ; } 
[[ $1 == "mv-wks" ]] && { prechk; $(echo "${action_funcmap[${1}]}") $2 ; exit ; } 
[[ $1 == "del-wks" ]] && { prechk; $(echo "${action_funcmap[${1}]}") $2 ; exit ; } 
[[ $# != 0 ]] && { act_vck "$@" ; env_wkchk; asking_env ; dojobs "$@"; }

########################## END #############################
