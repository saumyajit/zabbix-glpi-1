#! /bin/bash
#Autor: Peterson Kologeski Basso
#Email: peterson.basso@gmail.com
#Created: 17/10/2017
#Update: 
#

#---------- CONFIGURACOES ---------------------------------


ARQ_BANCO="banco.db"
TEMP=$(mktemp)

#No GLPI: User > Preference
USER_GLPI="zabbix"
USER_GLPI_ID="6"
USER_TOKEN="VI6D558r9XJHsAm15R0moFFDaRIEZ5NVHswwiWfZ";

#No GLPI: Configure > API
APP_TOKEN="GtwIZFW3nqvus4tmrFnvc5B13yIMoIMlInJhN4RY";

#Finalizar com uma barra "/"
#Exemplo: http://path/to/glpi/apirest.php/
API_URL="http://10.230.50.32/glpi/apirest.php/";

#Local do script
#Finalizar com uma barra "/"
#Exemplo: /path/to/script/
PATH_SCRIPT=$(pwd)
SEP="|"
#-----------------------------------------------------------
URL_ZABBIX='http://10.210.10.40/zabbix/api_jsonrpc.php'
HEADER_ZABBIX='Content-Type:application/json'

USER_ZABBIX='"Admin"'
PASS_ZABBIX='"zabbixnoc"'


AJUDA="

Usage: $(basename "$0") [OPÇÕES]


OPÇÕES:
-t | --title \"title\" Define o titulo do chamado
-d | --description \"description\" Define a descrição do chamado
-o | --option \"open | close | update\" Define a ação a ser executada
-e | --eventid \"{EVENT.ID}}\" Define o ID do evento do Zabbix
-p | --priority \"{TRIGGER.SEVERITY}}\" Define a prioridade do chamado
-h | --help Exibe essa tela de ajuda e sai


"

source funcoes.sh


while [ -n "$1" ] ; do
	
	case "$1" in
		-t | --title)
			shift
			[ "$1" ] && title="$1" || { echo "Parâmetro inválido para -t|--title" ; exit 1 ; }
			;;
		-d | --description)
			shift
			[ "$1" ] && description="$1" || { echo "Parâmetro inválido para -d|--description" ; exit 1 ; }
			;;
		-o | --option)
			shift
			[ "$1" ] && option="$1" || { echo "Parâmetro inválido para -o|--option" ; exit 1 ; }
			;;
		-e | --eventid)
			shift
			[ "$1" ] && eventid="$1" || { echo "Parâmetro inválido para -e|--eventid" ; exit 1 ; }
			;;
		-p | --priority)
			shift
			[ "$1" ] && priority="$1" || { echo "Parâmetro inválido para -p|--priority" ; exit 1 ; }
			;;
		-h | --help)
			echo "$AJUDA"
			exit 0
			;;
		-v | --version)
			echo ""
			exit 0
			;;
	esac

shift

done

apiGLPI
#buscaTicket

# echo "Titulo: $title"
# echo "Descrição: $description"
# echo "Opção: $option"
# echo "EventID: $eventid"
# echo "Prioridade: $priority"






#localizaItem $1

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
