#!/bin/bash
#################################################################
# Script desenvolvido por Guilherme Farias e Matheus Bevilaqua.	#
# Data de criação: 05/12/2023.					#
# Data da última atualização: 06/12/2023.			#
#################################################################

###Início da configuração###
sleep	1
	echo "Iniciando configuração da máquina virtual que já está em produção..."
sleep	1

###Configurações de data e hora###
	echo "Alterando o timezone do servidor..."
sleep	1
		timedatectl set-timezone America/Sao_Paulo
		timezone=$(timedatectl status | grep zone | awk {'print $3'})
	echo "O timezone do servidor foi alterado para: $timezone."
sleep   1
	echo "Alterando o tipo de hora do servidor de 12 para 24 horas..."
		localectl set-locale LC_TIME=en_GB.UTF-8
sleep   1
	echo "O tipo de hora do servidor foi alterado de 12 para 24 horas."
sleep   1

###Configurações do editor de texto###
	echo "Alterando o editor de textos para podermos enxergar..."
sleep   1
	echo "set bg=dark" >> /etc/vim/vimrc
sleep   1
	echo "Agora podemos enxergar com o editor de texto."

###Instalação do Zabbix###
	echo "Instalando o agente do Zabbix para o monitoramento do servidor..."
sleep	1
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
sleep	1
if [ $regrafw = 10050 ]
        then
                echo "A regra foi criada corretamente!"
        else
                echo "A regra não foi criada corretamente. Cheque isso depois!"
fi
sleep	1
	echo "O agente do Zabbix foi configurado com sucesso!"
sleep	1

###Instalação de comandos do dia-a-dia###
	echo "Instalando alguns comandos para faciltar a utilização da galera..."
sleep   1
		apt-get install traceroute mlocate wget -y
sleep	1
	echo "Os comandos para faciltar a utilização da galera foram instalados com sucesso!"
sleep   1

###Alteração da Senha do Root###
	echo "Alterando a senha do root do servidor..."
	echo -n "Insira a nova senha do root:"
                read novasenha
        echo "A nova senha é: $novasenha"
sleep   1
		echo "root:$novasenha" | chpasswd
	echo "A senha do root foi alterada com sucesso!"
sleep	1


###Configuração da Autenticação por chaves SSH###
sleep   1
        echo "Iniciando a configuração da autenticação via chaves SSH para este servidor..."
sleep   1

###Criação das Chaves SSH###
        echo "Criando o par de chaves SSH (Chave Pública e Chave Privada)..."
sleep   1
                ssh-keygen -t rsa -b 4096 -P '' -f /root/.ssh/server.key -C "Chave SSH do Servidor"
sleep   1
        echo "As chaves foram criadas! Agora estamos deixando elas legíveis..."
sleep   1
		for keyname in $(hostname) ; do mv /root/.ssh/server.key /root/.ssh/$keyname.key ; done
		for keyname in $(hostname) ; do mv /root/.ssh/server.key.pub /root/.ssh/$keyname.key.pub ; done
sleep   1

###Criação do usuário de autenticação para as Chaves SSH###
        echo "Criando o usuário 'supcip' para logar apenas com chave SSH..."
sleep   1
                useradd -m supcip
sleep   1
        echo "O usuário 'supcip' foi criado sem senha, só funcionará com chave SSH."
sleep   1
	echo "Criando a pasta para as chaves SSH do usuário 'supcip'..."
sleep   1
                mkdir /home/supcip/.ssh
                touch /home/supcip/.ssh/authorized_keys
                chown supcip:supcip /home/supcip/.ssh -R

                validapermissao=$(ls -la /home/supcip/.ssh | grep auth | awk {'print $3'})
                        if [ $validapermissao = supcip ]
                                then
                                echo "A pasta para as chaves SSH do usuário 'supcip' foi criada, com as permissões corretas."
                        else
                                echo -n "A permissão da pasta está errada. Você quer parar o script para ver isso agora? [Digite Sim ou Não]"
                        read checapermissao
                                echo "Você escolheu: $checapermissao"
sleep   1
                        if [ $checapermissao = Sim ]
                                then
                                echo "Bye Bye!"
                                exit
                        else
                                echo "Cuidado para não perder o acesso ao servidor."
                        fi
                        fi
###Configuração do acesso pela chave pública###
        echo "Habilitando a chave pública para o acesso SSH ao servidor..."
sleep   1
		cat /root/.ssh/*.pub | tr -d '\n' >> /home/supcip/.ssh/authorized_keys
sleep   1
        echo "A chave pública foi habilitada para acesso SSH com sucesso!"

###Configurações de permissão do usuário SupCip###
        echo "Aplicando a permissão para o usuário 'supcip' poder virar 'root' no servidor..."
sleep   1
                sed -i '29i supcip ALL=(ALL) NOPASSWD:ALL' /etc/sudoers
sleep   1
        echo "Pronto! Agora o usuário 'supcip' pode logar como 'root' no servidor."
sleep   1

###Download da chave privada para os usuários da Cipnet###
        echo "Agora é hora de baixar a chave prívada no seu computador para poder logar via SSH."
sleep   1
        echo -n "Você baixou a chave privada? [Digite Sim ou Não]"
                while true;
                do
                        read download
                                echo "Você escolheu: $download"
sleep   1
                                if [ $download = Sim ]
                                        then
                                        echo "Show de bola! Continuando a configuração..."
                                        break
                                fi
                done
sleep   1

###Alterando a configuração do servidor SSH###
        echo "Alterando a configuração do servidor SSH para aceitar apenas autenticação com chave..."
sleep   1
                sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
		sed -i 's/PermitRootlogin yes/PermitRootlogin no/g' /etc/ssh/sshd_config
                sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
                sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
		sed -i '42i AuthorizedKeysFile     .ssh/authorized_keys' /etc/ssh/sshd_config
                sed -i '20i HostKey /etc/ssh/ssh_host_rsa_key' /etc/ssh/sshd_config
sleep   1
        echo "Aplicando as configurações do SSH, nos demais arquivos necessários..."
                validaconf=$(ls -la /etc/ssh/sshd_config.d/ | awk {'print $9'} | grep .conf)
                        sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config.d/$validaconf
sleep   1
        echo "A configuração foi aplicada nos demais arquivos com sucesso!"
sleep   1

###Fim da configuração###
	echo "A configuração do servidor novo foi finalizada com sucesso!"
sleep	1

        echo
        echo "Último"
        echo "Passo"
        echo

sleep   1

###Reiniciar o servidor###
        echo -n "Você quer reiniciar o servidor agora? [Digite Sim ou Não]"
                read reboot
        echo "Você escolheu: $reboot"
sleep   1
if [ $reboot = Sim ]
        then
		echo "Reiniciando o servidor..."
	sleep	1
		reboot
        else
                echo "Lembre de reiniciar o servidor, para aplicar todas as configurações."
fi
