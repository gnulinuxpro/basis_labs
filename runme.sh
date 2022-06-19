#!/usr/bin/bash

# Variables
export labs_dir=/basis_labs
langs_file=setup/langs.csv
declare -A languages
labset=

get_languages() {
i=2
for lang in $(head -1 $langs_file)
do 
  languages[$lang]=$i
  ((i++))
done
}

translate() {
  if [ -z $column ]
  then column=2
  fi
  
  linenumber=$(cut -d$'\t' -f1 $langs_file | grep -nw $1 | cut -d: -f1)
  result=$(sed -n "${linenumber}p" $langs_file | cut -d$'\t' -f$column)
  shift
  echo $result $@
}

menu_help() {
  translate menuhelp
}

select_language() {
  select lang in $(echo "${!languages[@]}")
  do
    if [[ ! " ${!languages[*]} " =~ " ${lang} " ]]
    then menu_help
    fi
    
    column="${languages[$lang]}"
    echo 
    translate selected_lang
    echo
    break
  done
}

check_root() {
  if [ $(id -u) != 0 ]
  then
    translate errorNotRoot 1>&2
    exit 1
  fi
}

create_labdir() {
  if [ ! -d $labs_dir ]
  then 
    mkdir $labs_dir
  fi
}

add_labset() {
  translate mentionedlabsets
  cat setup/labsets
  echo
  read -p "$(translate readlabseturl) " labseturl
  labset=$(basename "$labseturl" .git)
  git clone "$labseturl" labs/$labset | echo "$(translate downloading) ${labset}..."
}

choose_labset() {
  labsets=($(ls -1 labs))

  if [ -z "${labsets[0]}" ]
  then 
    translate nolabsets  
    add_labset
  fi

  translate chooselabset
  select labset in "${labsets[@]}" 
  do
    if [[ ! " ${labsets[*]} " =~ " ${labset} " ]]
    then menu_help
    fi
    labsetdir=labs/$labset
  done
}

remove_labset() {
  translate removeselect
  select labset in $(ls -1 labs) 
  do
    labsetdir=labs/$labset
    removelabsetyesno=$(translate removelabsetyesno)
    echo "$removelabsetyesno ${labsetdir}?"
    yes=$(translate yes)
    no=$(translate no)

    select yesno in $yes $no
    do 
      case $yesno in
        "$yes") rm -rf "$labsetdir";
           break;;
        "$no") break;;
        *) menu_help;;
      esac
    done

    break
  done
}

menu() {
  enterlabset=$(translate enterlabset)
  addlabset=$(translate addlabset)
  removelabset=$(translate removelabset)
  createlabset=$(translate createlabset)
  
  select entry in "$enterlabset" "$addlabset" "$removelabset" "$createlabset" 
  do
    case "$entry" in 
      "$enterlabset") choose_labset ;;
      "$addlabset") add_labset ;;
      "$removelabset") remove_labset ;;
      "$createlabset") echo "ToDo";;
      *) menu_help;;
    esac
  done
}

show_labs() {
  for lab in $(ls -1 labs)
  do
    echo $lab
    source labs/$lab/language/$lang/description
    echo $lab_description
    echo '#####'
  done
}

# lab_selection() {
#   translate select_lab
#   select lab in $(ls -1 $labset)
#   do
#     export lab
#     clear
#     translate selected_lab $lab
#     bash setup/environment.sh
#   done
# }

get_languages
select_language
check_root
create_labdir
menu
show_labs
lab_selection