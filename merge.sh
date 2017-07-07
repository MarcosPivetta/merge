#!/bin/bash

set +x

git clone http://m.pivetta:gravedigger@tfs.dc.sbnet/tfs/Centauro/Retail%20Offline/_git/sispac

cd sispac

declare -a conflitos=()
declare -a semconflitos=()

#Configura o push como simple
git config --global push.default simple >> /dev/null

#Faz checkout da "master" e atualização "master" local.
echo -e "\n======================================================================="
echo "Atualizando a master"
echo -e "=======================================================================\n"
git config remote.origin.url http://m.pivetta:gravedigger@tfs.dc.sbnet/tfs/Centauro/Retail%20Offline/_git/sispac
git checkout master
git fetch -p
git pull

echo -e "\n======================================================================="
echo "Atualizando branches"
echo -e "=======================================================================\n"
#Cria variável local "branches" com todas as branches remotas (exceto a 'master').
braches=$(git branch -r | egrep -v 'master' | cut -c 10-)

for branch in $braches; do
  #Faz checkout na branch
  git checkout $branch

  #Faz merge com a master
  git merge master --no-edit

  #Se saída for igual a '1' informa o conflito e aborta o merge, se diferente de '1' informa o sucesso e realiza o push para a branch remota.
  if [[ $? == 1 ]]; then
    echo -e "\n[ERRO] Encontrado conflito na $branch. Necessário resolver manualmente."
    $(git merge --abort)
    #Coloca insere as branches com conflito no array $conflitos
    conflitos+=($branch)
  else
    echo -e "\n[OK] Merge realizado com sucesso."
    $(git push)
    semconflitos+=($branch)
  fi
  
  echo -e "\n=======================================================================\n"
done

echo -e "\n======================================================================="
echo "Deleta as branches locais (exceto a 'master')"
echo -e "=======================================================================\n"
git checkout master
git branch | egrep -v 'master' | xargs git branch -D

function printbranches() {
    name=$1[@]
    txt=$2
    arr=("${!name}")

	echo -e "\n======================================================================="
	echo -e "Branches $txt conflitos:"
	echo -e "=======================================================================\n"
    for branch in "${arr[@]}" ; do
        echo "$branch"
    done
}

printbranches semconflitos 'SEM'
printbranches conflitos 'COM'

echo -e "\n=======================================================================\n"
set -x
