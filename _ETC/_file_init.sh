#!/usr/bin/env bash
# ---  made by schan ---
#which env

#################### root-layer file 
ROOTDF_FILE=( "terra-conf.tf" "+value.auto.tfvars" "main.tf" "var-local.tf" "outputs.tf" "+bknd.conf" )

#################### module-layer file 
MD_DIR_=( "mdname" )
MDDF_FILE_SUFIX=( "main.tf" "outputs.tf" "var.tf" )

### ex) DIR : ++vpc
###########      ㄴ vpc-main.tf vpc-outputs.tf vpc-var.tf

##################

root_mkfile()
{
  # echo $#
  para_arg=()
  [[ $# == 0 ]] && para_arg=( ${ROOTDF_FILE[@]} ) || para_arg=( $@ )

  for argv in "${para_arg[@]}" ; do \
    # echo ${argv}
    touch "${argv}"|| exit
  done

}

md_mkdir()
{
  para_arg=()
  [[ $# == 0 ]] && para_arg=( ${MD_DIR_[@]} ) || para_arg=( $@ )

  for argv in "${para_arg[@]}" ; do \
    # echo ${argv}
    theargv="++${argv}"
    # echo ${theargv}
    mkdir "${theargv}" || exit

  done

}

####### md_mkdir-file -> md_floop #####

md_mkdir-file()
{
  # echo $#
  para_dirarg=( "${MD_DIR_[@]}" )

  for argv in "${para_dirarg[@]}" ; do \
    # echo ${argv}
    argv_pth="++${argv}"
    md_floop ${argv} ${argv_pth}
  done


}

md_floop()
{
  file_prfx=$1
  dir_path=$2
  f_arg=( "${MDDF_FILE_SUFIX[@]}" )

  for argv in "${f_arg[@]}" ; do \
    fargv="${file_prfx}-${argv}"
    # echo "--${dir_path}--"
    # echo "===${fargv}=="
    touch "./${dir_path}/${fargv}" | exit

  done

}


########### sub-main #############
# root_mkfile 1.tf 2.tf ...

root_mkfile

# md_mkdir
# md_mkdir-file
