#!/bin/bash

setup_env() {
  mkdir $labs_dir/$lab
  echo "$lab_setup"
  source vars
  bash setup/*
}

cleanup_env() {
  echo "$lab_cleanup"
  source vars
  bash cleanup/*
  rm -r $labs_dir/$lab
}

##enter_env() {}

cd labs/$lab/
source language/$lang/description

if [ ! -d $labs_dir/$lab ]
then
  setup_env
##enter_env
else 
  select action in "$enter" "$cleanup"
  do 
    case $action in
      "$enter") ## enter_env
       ;;
      "$cleanup") cleanup_env;;
    esac
  done
fi