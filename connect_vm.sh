#!/usr/bin/expect
#set timeout 60


##################################################################################################################
#
#Para a#adir un comando
# Solo añadimos los siguientes campos
#  $prompt Hace la lectura del promp para poder indicarle al sistema de lanzar el comando
#send -- " AQUI LANZAMOS EL COMANDO\r"
#
#
#      expect -re "$prompt"
#      send -- " echo hostname\r"
#      set timeout 2
#
##################################################################################################################
set prompt "(%|#|\\$|%\]) $"
# Hace la lectura de lo host desde este FILE
set fid [open ./hosts.list r]
set contents [read -nonewline $fid]
close $fid
stty echo
# S solicitan las credenciales de accesso 
send_user "\nUsername for SSH connection: "
expect_user -re "(.*)\n" {set sshname $expect_out(1,string)}
send_user "\nPassword for SSH user: "
stty -echo
expect_user -re "(.*)\n" {set sshpassword $expect_out(1,string)}
stty echo
foreach host [split $contents "\n"] {
# Se Conecta mediante SSH a la lista de servidores
spawn ssh -o StrictHostKeyChecking=no $sshname@$host
set timeout 15
expect {
  "assword:" { send -- "$sshpassword\r"
  }
set timeout 15
# Si se conecta por primera vez y pide confirmacion de añadir al knowhost, le manda el yes
  "you sure you want to continue connecting" {
  send -- "yes\r"

set timeout 15
# Cuando solicite el password, envia el password
  expect "assword:"
  send -- "$sshpassword\r"
  }
}
set timeout 10
# Nos hacemos sudo su
expect -re "$prompt"
send -- "sudo su -\r"

expect {
  "assword:" { send -- "$sshpassword\r"
  expect -re "$prompt"
  }
  -re "$prompt"
}

set timeout 3

# Ejecutamos los comandos en las maquinas en destino

expect -re "$prompt"
send -- " echo hostname\r"
set timeout 2

# Nos salimos de la maquina como sudo
expect -re "$prompt"
send -- "exit\r"
set timeout 3

# Nos salimos de la maquina
expect -re "$prompt"
send -- "exit\r"
set timeout 3

}

