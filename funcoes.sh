ARQ_BANCO="banco.db"
TEMP=$(mktemp)

#No GLPI: User > Preference
USER_GLPI="zabbix"
USER_GLPI_ID="6"
USER_TOKEN="VI6D558r9XJHsAm15R0moFFDaRIEZ5NVHswwiWfZ";

#No GLPI: Configure > API
APP_TOKEN="WaPWe5bgiGKQEUIaqKJO2uI7rZLUyVVhAVSooLGh";

#Finalizar com uma barra "/"
#Exemplo: http://path/to/glpi/apirest.php/
API_URL="http://10.230.50.32/glpi/apirest.php/";

#Local do script
#Finalizar com uma barra "/"
#Exemplo: /path/to/script/
PATH_SCRIPT="/usr/lib/zabbix/externalscripts/ticketglpi/";
#-----------------------------------------------------------

#Capturando variaveis passadas pelo Zabbix
#option pode ser "open" ou "update"
option=$1;
eventID=$2;
subject=$3;
message=$4;
severity=$5;


#Abrindo uma sessao no GLPI via api-rest



URL_ZABBIX='http://10.210.10.40/zabbix/api_jsonrpc.php'
HEADER_ZABBIX='Content-Type:application/json'

USER_ZABBIX='"Admin"'
PASS_ZABBIX='"zabbixnoc"'


openSession(){

session=$(curl -X GET -H 'Content-Type: application/json' -H "Authorization: user_token $USER_TOKEN" -H "App-Token: $APP_TOKEN" "${API_URL}initSession")

#Formatando o token de sessao
f1=$(echo "$session" | jq ."session_token");
SessionToken=$(echo "$f1" | sed 's/"//g')

}

#Abrindo o chamado no GLPI
openTicket() {
openSession;
severidade;

echo "Severidade: $severity"

#ter instalado previamente o "jq"

input='{"input":{"name": "'$subject'","content": "'$message'","priority":"'$severity'","requesttypes_id":"7"}}'

respGlpi=$(curl -X POST -H 'Content-Type: application/json' -H "Session-Token: $SessionToken" -H "App-Token: $APP_TOKEN" -d "$input" "$API_URL"'Ticket/')

closeSession;

ticketID=$(echo "$respGlpi" | jq ."id");
message=$(echo "$respGlpi" | jq ."message")

echo "$ticketID|$eventID" >> "$PATH_SCRIPT$ARQ_BANCO"

ackZabbix;

}

#Atualizando um chamado inserindo um acompanhamento
updateTicket() {
selTicketID=$(grep "$eventID" "$PATH_SCRIPT$ARQ_BANCO" | cut -d"|" -f 1)
openSession;
#ter instalado previamente o "jq"
respGlpi=$(jq -n  \
		--arg _message "$subject $message" \
		--arg _selTicketID "$selTicketID" \
		--arg _userId "$USER_GLPI_ID" \
		'{"input": {"tickets_id": $_selTicketID,"users_id": $_userId,"content": $_message}}' |
	curl -X POST \
		-H "Content-Type: application/json" \
		-H "Session-Token: $SessionToken" \
		-H "App-Token: $APP_TOKEN" \
		-k \
		-d@- \
		$API_URL'TicketFollowUp/')
closeSession;
}

#Solucionando o chamado no GLPI
closeTicket() {
selTicketID=$(grep "$eventID" "$PATH_SCRIPT$ARQ_BANCO" | cut -d"|" -f 1)
openSession;
#ter instalado previamente o "jq"
respGlpi=$(jq -n  \
		--arg _message "$subject $message" \
		'{"input": {"status": "5","solution": $_message}}' |
	curl -X PUT \
		-H "Content-Type: application/json" \
		-H "Session-Token: $SessionToken" \
		-H "App-Token: $APP_TOKEN" \
		-k \
		-d@- \
		$API_URL'Ticket/'$selTicketID)
closeSession;

grep -i -v "$eventID" "$PATH_SCRIPT$ARQ_BANCO" > "$TEMP"
mv "$TEMP" "$PATH_SCRIPT$ARQ_BANCO"
}

#Encerrando a sessao
closeSession() {
curl -X GET \
	-H "Content-Type: application/json" \
	-H "Session-Token: $SessionToken" \
	-H "App-Token: $APP_TOKEN" \
	$API_URL'killSession';
}

localizaItem(){

	openSession;

	echo "curl -X GET -H 'Content-Type: application/json' -H Session-Token: $SessionToken -H App-Token: $APP_TOKEN ${API_URL}Ticket/NetworkEquipment/?searchText\[name\]\=$1"

	idItem=$(curl --silent -X GET -H 'Content-Type: application/json' -H "Session-Token: $SessionToken" -H "App-Token: $APP_TOKEN" "${API_URL}NetworkEquipment/?searchText\[name\]\=$1&order=DESC" | python -m json.tool | grep \"id\" | cut -d":" -f 2 | tr -d " ,")
	
	echo "$idItem"
}


#Função para inserir o ack no zabbix com o numero do chamado do GLPI
ackZabbix() {
TOKEN=$(autenticacaoZabbix)


JSON='
    {
        "jsonrpc": "2.0",
        "method": "event.acknowledge",
        "params": {
                    "eventids":"'$eventID'",
                    "message":'$message'
        },
        "auth": "'$TOKEN'",
        "id": 1        
    }
    '
curl -s -X POST -H "$HEADER_ZABBIX" -d "$JSON" "$URL_ZABBIX"

}

#Função para iniciar a sessão com a API do Zabbix
autenticacaoZabbix()
{
    JSON='
    {
        "jsonrpc": "2.0",
        "method": "user.login",
        "params": {
            "user": '$USER_ZABBIX',
            "password": '$PASS_ZABBIX'
        },
        "id": 0
    }
    '
    curl -s -X POST -H "$HEADER_ZABBIX" -d "$JSON" "$URL_ZABBIX" | jq ."result" | sed 's/"//g'
}

severidade(){

case $severity in
	'Not classified')
		severity=1;;
	'Information')
		severity=1;;
	'Warning')
		severity=2;;
	'Average')
		severity=3;;
	'High')
		severity=4;;
	'Disaster')
		severity=6;;
	*)
		severity=3;;	

esac
}

gravaBanco(){


}

procuraBanco(){


}

deletaBanco(){

	
}