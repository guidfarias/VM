#!/bin/bash
#################################################################
# Script desenvolvido por Guilherme Farias e Matheus Bevilaqua.	#
# Data de criação: 08/09/2023.					#
# Data da última atualização: 08/09/2023.			#
#################################################################

###Início da configuração###
sleep	1
	echo "Iniciando configuração da máquina virtual que já está em produção..."
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
