#!/usr/bin/env bash 
# which env

initVR=$1 ;
echo -e "${yellow}###### ${initVR} ######${reset}" ;

####################### init for ACTION-FUNC-MAP ##########################
## ? terrform 액션 맵핑 함수 리스트 초기화, 함수명_일련번호 변수초기화
func_list=(); num_sfx=1 ;

## ? bool flag 모드, 컨디션 스위치 초기화 
AFTER_INIT_ENV_FLAG=false ; mtch_flag=false ; valck_flag=false ; bkint_flag=false ; askjob_flag=false ;

## ? terrform-cli 액션 초기화 , terrform workspace 초기화
ACTION="" ; ENV_WKS="" ; 

##############################################################
## ? terrform 액션과 함수 배열을 해시맵으로 생성 후 액션명을 맵의 키로설정 하여 해당 키로 함수 정의
for i in "${!JOBS_ACTION[@]}"; do func_list[i]="func_${num_sfx}"; num_sfx=$((num_sfx+1)); done ;
value_list=(${func_list[@]}) ; 

declare -A action_funcmap; declare -A env_map; 
let KEY_EXPR=$(expr ${#JOBS_ACTION[@]} - 1) ; let VALUE_EXPR=$(expr ${#func_list[@]} - 1) ;

jobmap_func() { mapKEY=$1 ; mapVLU=$2 ; action_funcmap[$1]=$2 ; }

[[ $KEY_EXPR -eq $VALUE_EXPR ]] && { for ((i=0;i<=${KEY_EXPR};i++)); do jobmap_func ${key_list[$i]} ${value_list[$i]} ; done ; } \
|| echo -e "\nNOT matched key&value LENGTH..."

############################################### env_wkchk about ###############################################
## ? 현재 wksp 체크 함수설정 및 ENV 일치여부 유효성 체크
prechk(){ env_wk=$(terraform workspace show); }

## ? env tfvars 데이터 파일 경로 및 백엔드설정파일 유효성 체크 및 해당 ENV init 작업 유/무 체크 (bool 값  flg 활용) 
path_validchk()
{
  flg=$(ls ${ENV_PATH_}/${ENV_DIR_} 2> /dev/null);
  [[ ${flg} == "" ]] && { echo "${yellow}=== NOT valid ENV-PATH. Plz Check the ENV-PATH~! ===${reset}"; exit; }
  # || { echo "========= VALID ENV-PATH OK ========="; } 

  bknd_flist=( $(ls ${ENV_PATH_}/${ENV_DIR_} 2> /dev/null |grep "${backndfile_kyword}" |xargs ) );
  chk_bkkey=( $( for i in "${bknd_flist[@]}"; do cat ${ENV_PATH_}/${ENV_DIR_}/${i}|grep 'key'|cut -d '=' -f1| xargs ; done ) ) ;

  flg_int=$(ls .terraform/environment 2> /dev/null);
  [[ ${flg_int} != "" ]] && { AFTER_INIT_ENV_FLAG=true ;}
}

env_wkchk()
{
  path_validchk; prechk;

  # [[ ${env_wk} == "default" ]] && { echo -e "\n${yellow}MAKING NEW-WKSP OR SWITCHING-WKSP as the same as ENV from tfvars-file ${reset}" ; } \
  # || { ENV_WKS=${env_wk}; echo -e "\n${yellow}This ENV(Terrform-WorkSpace) is ${env_wk}${reset}" ; }
  [[ ${env_wk} == "default" ]] && { echo -e "\n${yellow}This is DEFAULT-WKS. Only using DEFALT if making S3-MULTI-ENV-BUCKET ${reset}" ; } \
  || { ENV_WKS=${env_wk}; echo -e "\n${yellow}This ENV(Terrform-WorkSpace) is ${env_wk}${reset}" ; }
}

############################################### terrform-JOB about ###############################################
## ? 인풋액션 유효성 검증 
act_vck()
{
  para_arg=( ${JOBS_ACTION[@]} ) ; match=0; envchkr="${1}" ;
  for argv in "${para_arg[@]}" ; do [[ "${argv}" == "${envchkr}" ]] && { match=1 ; break ;  } ; done ;
  [[ ${match} != 1 ]] && { echo -e "\nINVAILD ACTION~! BYE~! " ; exit ; }
}