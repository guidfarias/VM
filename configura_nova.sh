#!/bin/bash
#################################################################
# Script desenvolvido por Guilherme Farias e Matheus Bevilaqua.	#
# Data de criação: 01/09/2023.					#
# Data da última atualização: 08/09/2023.			#
#################################################################

###Início da configuração###
sleep	1
	echo "Iniciando configuração da nova máquina virtual..."
sleep	3

###Configurações de data e hora###
	echo "Alterando o timezone do servidor..."
sleep	2
		timedatectl set-timezone America/Sao_Paulo
		timezone=$(timedatectl status | grep zone | awk {'print $3'})
	echo "O timezone do servidor foi alterado para: $timezone."
sleep   2
	echo "Alterando o tipo de hora do servidor de 12 para 24 horas..."
		localectl set-locale LC_TIME=en_GB.UTF-8
sleep   2
	echo "O tipo de hora do servidor foi alterado de 12 para 24 horas."
sleep   2

###Configurações do editor de texto###
	echo "Alterando o editor de textos para podermos enxergar..."
sleep   2
	echo "set bg=dark" >> /etc/vim/vimrc
sleep   2
	echo "Agora podemos enxergar com o editor de texto."

###Configurações do usuário DropMySite ###
sleep   2
	echo "Criando o usuário 'dropmysite' com a senha padrão..."
sleep   2
		useradd -m dropmysite
		echo "dropmysite:DprmS85#7@a68hK9s" | chpasswd
sleep	2
	echo "O usuário dropmysite foi criado com a senha padrão."
sleep	2

###Configurações de permissão do usuário DropMySite###
	echo "Aplicando a permissão de Mestre dos Magos para o usuário dropmysite.."
sleep   2
		usermod -aG sudo dropmysite
	echo "O usuário dropmysite é um dos Mestres dos Magos deste servidor."
sleep   2

###Configuração da pasta de Backups dos Bancos de Dados###
	echo "Criando a pasta para os backups dos Bancos de Dados..."
sleep   2
		mkdir /home/dropmysite/dbsbackups
	
	echo "A pasta para os backups dos Bancos de Dados foi criada."
sleep   2

###Configuração da pasta de Chaves SSH###
	echo "Criando a pasta para as chaves SSH do usuário 'dropmysite'..."
sleep   2
		mkdir /home/dropmysite/.ssh
	echo "A pasta para as chaves SSH do usuário 'dropmysite' foi criada."
sleep	2

###Criação do Script para Backups dos Bancos de Dados###
	echo "Criando o script para os Backups dos Bancos de Dados..."
sleep   2
	cat <<EOL > /home/dropmysite/dbsbackups/dbsbackup.sh
cd /home/dropmysite/dbsbackups/
find *.sql.gz -mtime 3 -delete
for DB in \$(mysql -e 'show databases' -s --skip-column-names) ; do mysqldump \$DB | gzip > "\$DB-\$(date +%Y%m%d).sql.gz" ; done
chown dropmysite:dropmysite *.sql.gz
EOL
	chmod 777 /home/dropmysite/dbsbackups/dbsbackup.sh
sleep   2
	echo "O script para os backups dos bancos de dados foi criado com sucesso!"
sleep   2


###Instalação do Zabbix###
	echo "Instalando o agente do Zabbix para o monitoramento do servidor..."
sleep	2
	apt-get install zabbix-agent -y
sleep	1
	echo "O agente do Zabbix foi instalado com sucesso!"
sleep   1
	echo "Agora vamos configurar o agente de monitoramento..."
sleep	1
	echo "Configurando o apontamento para o IP do Zabbix Server..."
		sed -i 's/Server=127.0.0.1/Server=13.90.72.25/g' /etc/zabbix/zabbix_agentd.conf
sleep	1
	echo "Configurando o apontamento para o FQDN do Zabbix Server..."
		sed -i 's/ServerActive=127.0.0.1/ServerActive=zbx-server.nubiway.com.br/g' /etc/zabbix/zabbix_agentd.conf
sleep	1
	echo "Configurando o hostname para a comunicação do Zabbix Server..."
		for h in $(hostname) ; do sed -i "s/Hostname=Zabbix server/Hostname=$h/g" /etc/zabbix/zabbix_agentd.conf ; done
sleep	1
	echo "Criando a regra de Firewall para a comunicação com o Zabbix Server..."
		firewall-cmd --add-port=10050/tcp --permanent
sleep	1
	echo "Recompilando o Firewall..."
		firewall-cmd --reload
sleep   1
	echo "Checando se a regra foi criada corretamente..."
	regrafw=$(firewall-cmd --list-all | grep -o 10050)
sleep	2
if [ $regrafw = 10050 ]
        then
                echo "A regra foi criada corretamente!"
        else
                echo "A regra não foi criada corretamente. Cheque isso depois!"
fi
sleep	1
	echo "O agente do Zabbix foi configurado com sucesso!"
sleep	2

###Instalação de comandos do dia-a-dia###
	echo "Instalando alguns comandos para faciltar a utilização da galera..."
sleep   2
		apt-get install traceroute mlocate wget -y
sleep	2
	echo "Os comandos para faciltar a utilização da galera foram instalados com sucesso!"
sleep   2

###Atualização dos pacotes do Sistema Operacional###
        echo "Atualizando os pacotes atualizáveis do servidor..."
sleep   2
                apt upgrade -y
sleep   2
        echo "Os pacotes foram atualizados com sucesso."
sleep   3

###Atualização do Sistema Operacional###
	echo "Atualizando o servidor para finalizar a configuração..."
sleep   2
		apt update -y
sleep	2
	echo "O servidor foi atualizado com sucesso."
sleep   3

###Alteração da Senha do Root###
	echo "Alterando a senha do root do servidor..."
	echo -n "Insira a nova senha do root:"
                read novasenha
        echo "A nova senha é: $novasenha"
sleep   1
		echo "root:$novasenha" | chpasswd
	echo "A senha do root foi alterada com sucesso!"
sleep	3

###Fim da configuração###
	echo "A configuração do servidor novo foi finalizada com sucesso!"
sleep	2

        echo
        echo "Último"
        echo "Passo"
        echo

sleep   3

###Reiniciar o servidor###
        echo -n "Você quer reiniciar o servidor agora? [Digite Sim ou Não]"
                read reboot
        echo "Você escolheu: $reboot"
sleep   2
if [ $reboot = Sim ]
        then
		echo "Reiniciando o servidor..."
	sleep	2
		reboot
        else
                echo "Lembre de reiniciar o servidor, para aplicar todas as configurações."
fi
