 
echo "start"
 
 <html><head></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;">#!
/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================================#
#   System Required:  CentOS, Debian, Ubuntu                      #
#   Description: One click Install Shadowsocks-go server          #
#==================================================================
clear
echo
echo "#############################################################"
echo "# One click Install Shadowsocks-go server"
echo "#############################################################"
echo
# Make sure only root can run our script
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "Error:This script must be run as root!" 1&gt;&amp;2
       exit 1
fi }
# Check OS
function checkos(){
    if [ -f /etc/redhat-release ];then
        OS=CentOS
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS=Debian
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS=Ubuntu
    else
        echo "Not supported OS, Please reinstall OS and retry!"
        exit 1
fi }
# Get version
function getversion(){
    if [[ -s /etc/redhat-release ]];then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else
        grep -oE  "[0-9.]+" /etc/issue
fi }
# CentOS version
function centosversion(){
    local code=$1
    local version="`getversion`"
    local main_ver=${version%%.*}
    if [ $main_ver == $code ];then
return 0 else
return 1 fi
# #
#" #"
}
#" #"
# is 64bit or not
function is_64bit(){
    if [ `getconf WORD_BIT` = '32' ] &amp;&amp; [ `getconf LONG_BIT` = '64' ] ; then
        return 0
else
return 1
fi }
# Disable selinux
function disable_selinux(){
if [ -s /etc/selinux/config ] &amp;&amp; grep 'SELINUX=enforcing' /etc/selinux/config;
then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi
}
# Pre-installation settings
function pre_install(){
    # Set shadowsocks-go config password
    echo "Please input password for shadowsocks-go:"
    read -p "(Default password: 11111111):" shadowsockspwd
    [ -z "$shadowsockspwd" ] &amp;&amp; shadowsockspwd="11111111"
    echo
    echo "---------------------------"
    echo "password = $shadowsockspwd"
    echo "---------------------------"
    echo
    # Set shadowsocks-go config port
    while true
    do
    echo -e "Please input port for shadowsocks-go [1-65535]:"
    read -p "(Default port: 8989):" shadowsocksport
    [ -z "$shadowsocksport" ] &amp;&amp; shadowsocksport="8989"
    expr $shadowsocksport + 0 &amp;&gt;/dev/null
    if [ $? -eq 0 ]; then
        if [ $shadowsocksport -ge 1 ] &amp;&amp; [ $shadowsocksport -le 65535 ]; then
            echo
            echo "---------------------------"
            echo "port = $shadowsocksport"
            echo "---------------------------"
            echo
break else
            echo "Input error! Please input correct numbers."
        fi
    else
        echo "Input error! Please input correct numbers."
    fi
    done
    get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2&gt; /dev/null
        stty -raw
stty echo
        stty $SAVEDSTTY
    }
    echo
    echo "Press any key to start...or Press Ctrl+C to cancel"
    char=`get_char`
    #Install necessary dependencies
     if [ "$OS" == 'CentOS' ];then
        yum install -y wget unzip gzip curl
    else
        apt-get -y update
        apt-get install -y wget unzip gzip curl
    fi
    # Get IP address
    echo "Getting Public IP address, Please wait a moment..."
    IP=$(curl -s -4 icanhazip.com)
    if [[ "$IP" = "" ]]; then
        IP=$(curl -s -4 ipinfo.io/ip)
    fi
    echo -e "Your main public IP is\t\033[32m$IP\033[0m"
    echo
    #Current folder
    cur_dir=`pwd`
}
# Download shadowsocks-go
function download_files(){
    cd $cur_dir
    if is_64bit; then
        if ! wget -c https://github.com/shadowsocks/shadowsocks-go/releases/download/1.1.5/shadowsocks-server-linux64-1.1.5.gz;then
            echo "Failed to download shadowsocks-server-linux64-1.1.5.gz"
exit 1 fi
        gzip -d shadowsocks-server-linux64-1.1.5.gz
        if [ $? -eq 0 ];then
            echo "Decompress shadowsocks-server-linux64-1.1.5.gz success."
        else
            echo "Decompress shadowsocks-server-linux64-1.1.5.gz failed! Please check
gzip command."
exit 1 fi
        mv -f shadowsocks-server-linux64-1.1.5 /usr/bin/shadowsocks-server
    else
        if ! wget -c https://github.com/shadowsocks/shadowsocks-go/releases/download/1.1.5/shadowsocks-server-linux32-1.1.5.gz;then
            echo "Failed to download shadowsocks-server-linux32-1.1.5.gz"
exit 1 fi
        gzip -d shadowsocks-server-linux32-1.1.5.gz
        if [ $? -eq 0 ];then
            echo "Decompress shadowsocks-server-linux32-1.1.5.gz success."
        else
            echo "Decompress shadowsocks-server-linux32-1.1.5.gz failed! Please check
gzip command."
exit 1 fi
        mv -f shadowsocks-server-linux32-1.1.5 /usr/bin/shadowsocks-server
    fi
    
    
    
#    # Download start script
#    if [ "$OS" == 'CentOS' ];then
#        if ! wget --no-check-certificate -O shadowsocks-go
#https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-go;
#then
#            echo "Failed to download shadowsocks-go auto start script!"
#exit 1 fi
#    else
#        if ! wget --no-check-certificate -O shadowsocks-go
#https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-go-
#debian; then
# fi }
#    echo "Failed to download shadowsocks-go auto start script!"
#exit 1 fi


#=================================================================#

#!/bin/bash
# Start/stop shadowsocks.
#
#====================================================================
# Run level information:
# chkconfig: 2345 99 99
# Description: lightweight secured socks5 proxy
# processname: shadowsocks-server
# Run "/sbin/chkconfig --add shadowsocks" to add the Run levels.
#====================================================================

# Note: this script requires sudo in order to run shadowsocks as the specified
# user. 

# Source function library
. /etc/rc.d/init.d/functions

# Check that networking is up.
[ ${NETWORKING} ="yes" ] || exit 0

BIN=/usr/bin/shadowsocks-server
CONFIG_FILE=/etc/shadowsocks/config.json
PID_DIR=/var/run
PID_FILE=$PID_DIR/shadowsocks.pid
RET_VAL=0

[ -x $BIN ] || exit 0

check_running() {
  if [[ -r $PID_FILE ]]; then
    read PID <$PID_FILE
    if [[ -d "/proc/$PID" ]]; then
      return 0
    else
      rm -f $PID_FILE
      return 1
    fi
  else
    return 2
  fi
}

do_status() {
  check_running
  case $? in
    0)
      echo "shadowsocks-go running with PID $PID"
      ;;
    1)
      echo "shadowsocks-go not running, remove PID file $PID_FILE"
      ;;
    2)
      echo "Could not find PID file $PID_FILE, shadowsocks-go does not appear to be running"
      ;;
  esac
  return 0
}

do_start() {
  if [[ ! -d $PID_DIR ]]; then
    mkdir $PID_DIR || echo "failed creating PID directory $PID_DIR"; exit 1
  fi
  if check_running; then
    echo "shadowsocks-go already running with PID $PID"
    return 0
  fi
  if [[ ! -r $CONFIG_FILE ]]; then
    echo "config file $CONFIG_FILE not found"
    return 1
  fi
  echo "starting shadowsocks-go"
  # sudo will set the group to the primary group of $USER
  $BIN -c $CONFIG_FILE > /dev/null &
  PID=$!
  echo $PID > $PID_FILE
  sleep 0.3
  if ! check_running; then
    echo "start failed"
    return 1
  fi
  echo "shadowsocks-go running with PID $PID"
  return 0
}

do_stop() {
  if check_running; then
    echo "stopping shadowsocks-go with PID $PID"
    kill $PID
    rm -f $PID_FILE
  else
    echo "Could not find PID file $PID_FILE"
  fi
}

do_restart() {
  do_stop
  do_start
}

case "$1" in
  start|stop|restart|status)
    do_$1
    ;;
  *)
    echo "Usage: shadowsocks {start|stop|restart|status}"
    RET_VAL=1
    ;;
esac

exit $RET_VAL


#=================================================================#


# Config shadowsocks
function config_shadowsocks(){
    if [ ! -d /etc/shadowsocks ];then
        mkdir /etc/shadowsocks
fi
    cat &gt; /etc/shadowsocks/config.json&lt;&lt;-EOF
{
    "server":"0.0.0.0",
    "server_port":${shadowsocksport},
    "local_port":1080,
    "password":"${shadowsockspwd}",
    "method":"aes-256-cfb",
    "timeout":600
} EOF }
# firewall set
function firewall_set(){
    echo "firewall set start..."
    if centosversion 6; then
        /etc/init.d/iptables status &gt; /dev/null 2&gt;&amp;1
        if [ $? -eq 0 ]; then
2&gt;&amp;1
iptables -L -n | grep '${shadowsocksport}' | grep 'ACCEPT' &gt; /dev/null
if [ $? -ne 0 ]; then
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport
${shadowsocksport} -j ACCEPT
                iptables -I INPUT -m state --state NEW -m udp -p udp --dport
${shadowsocksport} -j ACCEPT
                /etc/init.d/iptables save
                /etc/init.d/iptables restart
            else
                echo "port ${shadowsocksport} has been set up."
            fi
        else
            echo "WARNING: iptables looks like shutdown or not installed, please
manually set it if necessary."
        fi
    elif centosversion 7; then
        systemctl status firewalld &gt; /dev/null 2&gt;&amp;1
        if [ $? -eq 0 ];then
            firewall-cmd --permanent --zone=public --add-port=${shadowsocksport}/tcp
            firewall-cmd --permanent --zone=public --add-port=${shadowsocksport}/udp
            firewall-cmd --reload
        else
            echo "Firewalld looks like not running, try to start..."
            systemctl start firewalld
            if [ $? -eq 0 ];then
                firewall-cmd --permanent --zone=public --add-
port=${shadowsocksport}/tcp
                firewall-cmd --permanent --zone=public --add-
port=${shadowsocksport}/udp
                firewall-cmd --reload
            else
                echo "WARNING: Try to start firewalld failed. please enable port
${shadowsocksport} manually if necessary."
fi fi
fi
    echo "firewall set completed..."
}
# Install
function install_go(){
    # Install shadowsocks-go
    if [ -s /usr/bin/shadowsocks-server ]; then
        echo "shadowsocks-go install success!"
        chmod +x /usr/bin/shadowsocks-server
        mv $cur_dir/shadowsocks-go /etc/init.d/shadowsocks
        chmod +x /etc/init.d/shadowsocks
        # Add run on system start up
        if [ "$OS" == 'CentOS' ]; then
            chkconfig --add shadowsocks
            chkconfig shadowsocks on
        else
            update-rc.d -f shadowsocks defaults
        fi
        # Start shadowsocks
        /etc/init.d/shadowsocks start
        if [ $? -eq 0 ]; then
            echo "Shadowsocks-go start success!"
        else
            echo "Shadowsocks-go start failure!"
        fi
else echo
        echo "shadowsocks-go install failed!"
exit 1 fi
    cd $cur_dir
    clear
    echo
    echo "Congratulations, shadowsocks-go install completed!"
    echo -e "Your Server IP: \033[41;37m ${IP} \033[0m"
    echo -e "Your Server Port: \033[41;37m ${shadowsocksport} \033[0m"
    echo -e "Your Password: \033[41;37m ${shadowsockspwd} \033[0m"
    echo -e "Your Local Port: \033[41;37m 1080 \033[0m"
    echo -e "Your Encryption Method: \033[41;37m aes-256-cfb \033[0m"
    echo
    echo "Enjoy it!"
    echo
    exit 0
}
# Uninstall Shadowsocks-go
function uninstall_shadowsocks_go(){
    printf "Are you sure uninstall shadowsocks-go? (y/n) "
    printf "\n"
    read -p "(Default: n):" answer
    if [ -z $answer ]; then
        answer="n"
    fi
    if [ "$answer" = "y" ]; then
        ps -ef | grep -v grep | grep -v ps | grep -i "shadowsocks-server" &gt;
/dev/null 2&gt;&amp;1
        if [ $? -eq 0 ]; then
            /etc/init.d/shadowsocks stop
        fi
        checkos
        if [ "$OS" == 'CentOS' ]; then
            chkconfig --del shadowsocks
        else
             update-rc.d -f shadowsocks remove
        fi
        # delete config file
        rm -rf /etc/shadowsocks
        # delete shadowsocks
        rm -f /etc/init.d/shadowsocks
        rm -f /usr/bin/shadowsocks-server
        echo "Shadowsocks-go uninstall success!"
    else
        echo "Uninstall cancelled, Nothing to do"
fi }
# Install Shadowsocks-go
function install_shadowsocks_go(){
    checkos
    rootness
    disable_selinux
    pre_install
    download_files
    config_shadowsocks
    if [ "$OS" == 'CentOS' ]; then
        firewall_set
    fi
install_go }
# Initialization step
action=$1
[ -z $1 ] &amp;&amp; action=install
case "$action" in
install)
    install_shadowsocks_go
    ;;
uninstall)
    uninstall_shadowsocks_go
;; *)
    echo "Arguments error! [${action} ]"
    echo "Usage: `basename $0` {install|uninstall}"
    ;;
esac
</pre></body></html>
