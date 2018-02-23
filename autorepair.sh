ip=10.220.5.76
banco=tda_sistema
usuario=teste
senha=1234

#!/bin/bash
# functions
# use 0 for true and 1 for false.
msg() {
	#check
	#build
	#clean
	#error
	#info
	#success
    # colors = http://misc.flogisoft.com/bash/tip_colors_and_formatting
    # colors = https://en.wikipedia.org/wiki/ANSI_escape_code#graphics
	if [ ! $2 ]; then
		echo -e $1
	elif [ "$2" == 1 ]; then
	#CHECK
		echo -e "\e[1;4m$1\e"
    elif [ "$2" == 2 ]; then
	#BUILD
		echo -e "\e[1;33m$1\033"
	elif [ "$2" == 3 ]; then
	#CLEAN
		echo -e "\e[1;36m$1\033"
	elif [ "$2" == 4 ]; then
	#ERROR
		echo -e "\e[1;31mERRO:$1\033"
	elif [ "$2" == 5 ]; then
	#INFO
		echo -e "\e[36m$1"
	elif [ "$2" == 6 ]; then
	#SUCCESS
		echo -e "\e[1;32mSUCCESS:$1\033"
	else 
	    echo -e $1
	fi
    echo -e "\033[0m"
}

listTables()
{
	mysql -u $usuario -p$senha -D $banco -h $ip -e "$1" > tableList.txt 2>&1
}


repairTable()
{
	mysql -u $usuario -p$senha -D $banco -h $ip -e "$1" > repairTable.txt 2>&1
}

checkTable()
{
	mysql -u $usuario -p$senha -D $banco -h $ip -e "$1" > stdOut.txt 2>&1
}

msg "###### MYSQl AUTO REPAIR TABLES #########"1
#sg "1 - Database credentials:____________________________________"1
#read -p "IP______: " ip
#read -p "Banco___: " banco
#read -p "Usuario_: " usuario
#read -p "Senha___: " senha



msg "1 - Importing tables:___________________________________________"1
listTables "show tables;" tableList.txt
> tableListWithErrors.txt

msg "2 - Checking tables_____________________________________________" 1
while read p; do
	checkTable "check table $p;"
	tableCheck=$(cat stdOut.txt | grep $banco)
  	
  	if [[ $tableCheck = *"Err"* ]] || [[ $tableCheck = *"crash"* ]] || [[ $tableCheck = *"repair"* ]] || [[ $tableCheck = *"warning"* ]]; then
	  echo $p >> tableListWithErrors.txt
	fi
done <tableList.txt


#if [ -s tableListWithErrors.txt ]
#then
	tables=$(cat tableListWithErrors.txt)
	echo -e "Errors found on $tables"
	msg "4 - Backingup database________________________________________________" 1
    mysqldump -u $usuario -p$senha --databases $banco -h $ip > /tmp/dump-$banco.sql  
        
#else
#	echo "NO ERRORS FOUND!"
#fi






