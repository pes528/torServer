#!bin/bash

#color------
off="\033[1;41m"
on="\033[1;102m"
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
    hidden=$(awk '/^#HiddenServiceDir /' $torrcDir|head -1)
    
    if [[ $hidden == $hiddenServi ]];then
        pkill nginx
        cp test.html $ruta/index.html
        sed -i "$numLineaServ s%$hiddenServi%HiddenServiceDir /data/data/com.termux/files/usr/var/lib/tor/hidden_service/%" $torrcDir
        sed -i "$numLineaPort s/$hiddenPort/HiddenServicePort 80 127.0.0.1:80/" $torrcDir

        echo "SERVICE RUNNING:"
        #tor
        nginx

    else
        echo "SERVER ALREADY START"
    fi
    


}

function stopServer(){
    hidden=$(awk '/^HiddenServiceDir/' $torrcDir|head -1)
    if [[ $hidden == "HiddenServiceDir /data/data/com.termux/files/usr/var/lib/tor/hidden_service/" ]];then
        sed -i "$numLineaServ s%HiddenServiceDir /data/data/com.termux/files/usr/var/lib/tor/hidden_service/%$hiddenServi%" $torrcDir
        sed -i "$numLineaPort s/HiddenServicePort 80 127.0.0.1:80/$hiddenPort/" $torrcDir
        echo "SERVER OFF."
        #pkill tor 
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
    echo -e "STATUS:            ${estado}"
    echo -e "\nHOST:                ${host}"

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
