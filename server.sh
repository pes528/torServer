#!bin/bash

#color------
off="\033[1;41m"
on="\033[1;102m"
fin="\033[0m"

#endColor------


hiddenServi="#HiddenServiceDir /data/data/com.termux/files/usr/var/lib/tor/hidden_service/"
hiddenPort="#HiddenServicePort 80 127.0.0.1:80"


numLineaServ=$(grep -n HiddenServiceDir torr|awk -v FS=":" '{print $1}'|head -1)
numLineaPort=$(grep -n HiddenServicePort torr|awk -v FS=":" '{print $1}'|head -1)


estado=${estado:-""}

function servNingx(){
    ruta="$PREFIX/share/nginx/html/"
    echo -e "\n1: Test Message\n0: Exit"
    read -p "Option: " testMessage
    if [[ $testMessage == "1" ]];then
        read -p "Enter new Message --->: " new
        html="<h2 style='text-align:center; font-size:30px; color:red;'>${new}</h2>"
        echo -e "${html}" > test.html
        cp test.html $ruta/index.html
        echo "OK"
        main
    else
        main
    fi
       
}



function serverInit(){
    hidden=$(awk '/^#HiddenServiceDir /' torr|head -1)
    
    if [[ $hidden == $hiddenServi ]];then
        sed -i "$numLineaServ s%$hiddenServi%HiddenServiceDir /data/data/com.termux/files/usr/var/lib/tor/hidden_service/%" torr
        sed -i "$numLineaPort s/$hiddenPort/HiddenServicePort 80 127.0.0.1:80/" torr

        echo "SERVICE RUNNING:"
        #tor
        #nignx

    else
        echo "SERVER ALREADY START"
    fi


}

function stopServer(){
    hidden=$(awk '/^HiddenServiceDir/' torr|head -1)
    if [[ $hidden == "HiddenServiceDir /data/data/com.termux/files/usr/var/lib/tor/hidden_service/" ]];then
        sed -i "$numLineaServ s%HiddenServiceDir /data/data/com.termux/files/usr/var/lib/tor/hidden_service/%$hiddenServi%" torr
        sed -i "$numLineaPort s/HiddenServicePort 80 127.0.0.1:80/$hiddenPort/" torr
        echo "SERVER OFF."
        #pkill tor 
        #pkill nginx
    else
        echo "SERVER IS NOT RUNNING"
    fi 


}

function verifica(){

    if [[ $(awk '/^#HiddenServiceDir/' torr|head -1) == $hiddenServi ]];then
        estado="[${off}OFF${fin}]"
    else
        estado="[${on}ON${fin}]"
    fi

}

function main(){
    clear
    echo -e "\n\tSERVER .ONION\n\n"
    verifica
    echo -e "STATUS:            ${estado}"
    echo -e "[1] = Start Server\n[2] = Stop Server\n[0] = Quit\n"
    read -p "Option: " option
    case $option in
        "1")
        serverInit
        sleep 2
        servNingx
        ;;
        "2")
        stopServer
        sleep 2
        main
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
