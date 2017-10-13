#! /bin/bash
#Autor: 
#Email:
#Created:
#Update: 
#
#Antes de executar a primeira vez,
#ler o arquivo README.txt

#---------- CONFIGURACOES ---------------------------------

source funcoes.sh


localizaItem $1

# case $option in
# 	open)
# 		openTicket ;;
# 	update)
# 		updateTicket ;;
# 	close)
# 		closeTicket ;;
# 	*)
# 		echo "Usage: ~$ bash ticket-glpi.sh [open|update|close] eventID \"Subject\" \"Description\" " ;;
# esac
