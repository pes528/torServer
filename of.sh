#!bin/bash

#color------
off="\033[1;41m"
on="\033[1;102m"
rojito="\033[1;31m"
verdej="\033[1;32m"
fin="\033[0m"

#endColor------

torrcDir="/data/data/com.termux/files/usr/etc/tor/torrc"


hiddenServi="#HiddenServiceDir /data/data/com.termux/files/usr/var/lib/tor/hidden_service/"
hiddenPort="#HiddenServicePort 80 127.0.0.1:80"


numLineaServ=$(grep -n HiddenServiceDir $torrcDir|awk -v FS=":" '{print $1}'|head -1)
numLineaPort=$(grep -n "HiddenServicePort 80" $torrcDir|awk -v FS=":" '{print $1}'|head -1)


estado=${estado:-""}


dominio="/data/data/com.termux/files/usr/var/lib/tor/hidden_service"
if [[ -d $dominio ]];then
    echo ""
else
    mkdir -p $dominio

fi


ruta="$PREFIX/share/nginx/html/"
function servNingx(){
    clear
    echo -e "\n     HTML MESSAGE"
    echo -e "\nAqui puedes escribir un mensaje para que aparezca en tu sitio web."
    echo "O tambien puedes modificar el archivo miweb.html"
    echo -e "\n1: Mensaje de prueba\n0: Salir\n"
    read -p "Elije una opcion: " testMessage
    if [[ $testMessage == "1" ]];then
        read -p "Enter new Message --->: " new
        html="<br><br><br><h2 style='text-align:center; font-size:30px; color:red;'>${new}</h2>"
        echo -e "${html}" > miweb.html
        cp miweb.html $ruta/index.html
        sleep 1
        echo "MENSAJE CONFIGURADO CON EXITO"
        sleep 2
        main
    else
        main
    fi
       
}



function serverInit(){
    hidden=$(awk '/^#HiddenServiceDir /' $torrcDir|head -1)
    
    if [[ $hidden == $hiddenServi ]];then
        pkill nginx
        cp test.html $ruta/index.html
        sed -i "$numLineaServ s%$hiddenServi%HiddenServiceDir /data/data/com.termux/files/usr/var/lib/tor/hidden_service/%" $torrcDir
        sed -i "$numLineaPort s/$hiddenPort/HiddenServicePort 80 127.0.0.1:8080/" $torrcDir

        echo -n "SERVICE RUNNING."
        nginx
        sleep 2
        tor > tor.log 2>&1 &
        sleep 4
        i=${i:-0}
        while [ $i -ne 500 ];do
            if [[ $(grep -w -r '100%' tor.log|gawk '{print $(NF -1)}') == "100%:" ]];then
                sleep 1
                echo "\nSERVIDOR INICIADO 100%"
                sleep 3
                i=500
            else
                echo -e -n "${rojito}.${fin}"
                ((i++))
                if [[ $i -eq 500 ]];then
                    echo "\n\nALGO SALIO MAL, REVISA TU CONEXION O VERIFICA EL ARCHIVO tor.log PARA VER EL ERROR"
                    sleep 3 
                    
                fi
            fi         
        done

        
        
        
        

    else
        echo "SERVER ALREADY START"
    fi
    


}

function stopServer(){
    hidden=$(awk '/^HiddenServiceDir/' $torrcDir|head -1)
    if [[ $hidden == "HiddenServiceDir /data/data/com.termux/files/usr/var/lib/tor/hidden_service/" ]];then
        sed -i "$numLineaServ s%HiddenServiceDir /data/data/com.termux/files/usr/var/lib/tor/hidden_service/%$hiddenServi%" $torrcDir
        sed -i "$numLineaPort s/HiddenServicePort 80 127.0.0.1:8080/$hiddenPort/" $torrcDir
        echo "SERVER OFF."
        pkill tor 
        pkill screen
        pkill nginx
    else
        
        echo "SERVER IS NOT RUNNING"
    fi 


}
host=${host:-""}
function info(){

    if [[ $(awk '/^#HiddenServiceDir/' $torrcDir|head -1) == $hiddenServi ]];then
        estado="[${off}OFF${fin}]"
        host="OFF"
    else

        estado="[${on}ON${fin}]"
        host=$(cat $dominio/hostname)
    fi

}

function main(){
    clear
    echo -e "\n\tSERVER .ONION\n\n"
    info
    echo -e "ESTADO:            ${estado}"
    echo -e "\nHOST:-> ${verdej}${host}${fin}\n"

    echo -e "[1] = Iniciar Servidor\n[2] = Detener Servidor\n[3] = Mensaje para tu sitio\n[0] = Salir\n"
    read -p "Elige una opcion: " option
    case $option in
        "1")
        serverInit
        sleep 5
        main
        ;;
        "2")
        stopServer
        sleep 2
        main
        ;;
        "3")
        servNingx
        ;;
        "0")
        echo "exit"
        ;;
        *)
        
        echo "Invalid option"
        sleep 3
        main
    esac
}

main
