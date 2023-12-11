#!/bin/bash
#################################################################
# Script desenvolvido por Guilherme Farias e Matheus Bevilaqua.	#
# Data de criação: 05/12/2023.					#
# Data da última atualização: 06/12/2023.			#
#################################################################

###Início da configuração###
sleep	1
	echo "Iniciando a configuração da autenticação via chaves SSH para este servidor..."
sleep	3

###Criação das Chaves SSH###
	echo "Criando o par de chaves SSH (Chave Pública e Chave Privada)..."
sleep   3
                ssh-keygen -t rsa -b 4096 -P '' -f /root/.ssh/server.key -C "Chave SSH do Servidor"
sleep   3
        echo "As chaves foram criadas! Agora estamos deixando elas legíveis..."
sleep   3
		for keyname in $(hostname) ; do mv /root/.ssh/server.key /root/.ssh/$keyname.key ; done
		for keyname in $(hostname) ; do mv /root/.ssh/server.key.pub /root/.ssh/$keyname.key.pub ; done
sleep	3

###Criação do usuário de autenticação para as Chaves SSH###
	echo "Criando o usuário 'supcip' para logar apenas com chave SSH..."
sleep   3
		useradd -m supcip
sleep	3
	echo "O usuário 'supcip' foi criado sem senha, só funcionará com chave SSH."
sleep	3
	echo "Criando a pasta para as chaves SSH do usuário 'supcip'..."
sleep   3
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
sleep   3
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
sleep   2
		cat /root/.ssh/*.pub | tr -d '\n' >> /home/supcip/.ssh/authorized_keys
sleep   2
        echo "A chave pública foi habilitada para acesso SSH com sucesso!"

###Configurações de permissão do usuário SupCip###
	echo "Aplicando a permissão para o usuário 'supcip' poder virar 'root' no servidor..."
sleep   2
		sed -i '29i supcip ALL=(ALL) NOPASSWD:ALL' /etc/sudoers
sleep   2
	echo "Pronto! Agora o usuário 'supcip' pode logar como 'root' no servidor."
sleep   2

###Download da chave privada para os usuários da Cipnet###
        echo "Agora é hora de baixar a chave prívada no seu computador para poder logar via SSH."
sleep	3
        echo -n "Você baixou a chave privada? [Digite Sim ou Não]"
		while true;
		do
                	read download
        			echo "Você escolheu: $download"
sleep   3
				if [ $download = Sim ]
        				then
                			echo "Show de bola! Continuando a configuração..."
					break
				fi
		done
sleep	3

###Alterando a configuração do servidor SSH###
	echo "Alterando a configuração do servidor SSH para aceitar apenas autenticação com chave..."
sleep	3
		sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
		sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
		sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
		sed -i '42i AuthorizedKeysFile     .ssh/authorized_keys' /etc/ssh/sshd_config
		sed -i '20i HostKey /etc/ssh/ssh_host_rsa_key' /etc/ssh/sshd_config
sleep	3
	echo "Aplicando as configurações do SSH, nos demais arquivos necessários..."
                validaconf=$(ls -la /etc/ssh/sshd_config.d/ | awk {'print $9'} | grep .conf)
                        sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config.d/$validaconf
sleep   3
        echo "A configuração foi aplicada nos demais arquivos com sucesso!"
sleep	3

###Reinicialização do servidor SSH###
        echo -n "Você quer reiniciar o SSH agora? [Digite Sim ou Não]"
                read ssh
        echo "Você escolheu: $ssh"
sleep   3
if [ $ssh = Sim ]
        then
		echo "Reiniciando o SSH..."
	sleep	2
		service ssh restart
        else
                echo "É ABSOLUTAMENTE necessário reiniciar o SSH para que a autenticação funcione corretamente."
fi
