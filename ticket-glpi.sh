#! /bin/bash
#Autor: Cleiton Rodrigues de Souza
#Email: cleitonrdesouza@gmail.com
#Created: 2017-09-25
#Update: 2017-09-28
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
