#!/bin/bash

if [ $USER != 'root' ]; then
	echo "คุณต้องเรียกใช้ในฐานะรูท"
	exit
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;

if [[ -e /etc/debian_version ]]; then
	#OS=debian
	RCLOCAL='/etc/rc.local'
else
	echo "คุณไม่ได้ใช้งานสคริปต์นี้ใน Debian OS"
	exit
fi

vps="vps";

if [[ $vps = "vps" ]]; then
	source="https://www.facebook.com/j.atterin"
else
	source="https://www.facebook.com/j.atterin"
fi

# go to root
cd

MYIP=$(wget -qO- ipv4.icanhazip.com);
:

#https://www.facebook.com/j.atterin

clear
echo ""
echo "ฉันต้องถามคำถามก่อนเริ่มการติดตั้ง"
echo "คุณสามารถออกจากตัวเลือกเริ่มต้นและเพียงกด Enter ถ้าคุณเห็นด้วยกับตัวเลือก"
echo ""
echo "ก่อนอื่นต้องรู้รหัสผ่านใหม่ของผู้ใช้รูท MySQL:"
read -p "รหัสผ่านใหม่:"-e -i Tom@2534 DatabasePass
echo ""
echo "ในที่สุดตั้งชื่อฐานข้อมูลชื่อสำหรับ OCS Panels"
echo "กรุณาใช้เพียงหนึ่งคำเท่านั้นไม่มีอักขระพิเศษอื่นใดนอกจาก Underscore (_)"
read -p "ชื่อฐานข้อมูล:"-e -i MTPANEL DatabaseName
echo ""
echo "โอเคนั่นคือทั้งหมดที่ฉันต้องการเราพร้อมที่จะตั้งค่า OCS Panels ของคุณตอนนี้"
read -n1 -r -p "กดปุ่มใดก็ได้เพื่อดำเนินการต่อ ... "

#อัพเดท
sudo apt-get update && apt-get upgrade -y
apt-get install build-essential expect -y

echo "clear" >> .bashrc
echo 'echo -e "ินดีต้อนรับสู่เซิร์ฟเวอร์  $HOSTNAME" | lolcat' >> .bashrc
echo 'echo -e "ดัดแปลงสคริปต์โดย ช่างต้อม"' >> .bashrc
echo 'echo -e "พิม menu เพื่อแสดงรายการคำสั่ง"' >> .bashrc
echo 'echo -e ""' >> .bashrc

#ติดตั้งฐานข้อมูลฐานข้อมูล
apt-get -y install mysql-server

#mysql_secure_installation
so1=$(expect -c "
spawn mysql_secure_installation; sleep 3
expect \"\";  sleep 3; send \"\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect eof; ")
echo "$so1"
#\r
#Y
#pass
#pass
#Y
#Y
#Y
#Y

chown -R mysql:mysql /var/lib/mysql/
chmod -R 755 /var/lib/mysql/

apt-get -y install nginx php5 php5-fpm php5-cli php5-mysql php5-mcrypt
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup 
mv /etc/nginx/conf.d/vps.conf /etc/nginx/conf.d/vps.conf.backup 
wget -O /etc/nginx/nginx.conf "http://script.hostingtermurah.net/repo/blog/ocspanel-debian7/nginx.conf" 
wget -O /etc/nginx/conf.d/vps.conf "http://script.hostingtermurah.net/repo/blog/ocspanel-debian7/vps.conf" 
sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini 
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf


useradd -m 2dth
mkdir -p /home/2dth/public_html
rm /home/2dth/public_html/index.html
echo "<?php phpinfo() ?>" > /home/2dth/public_html/info.php
chown -R www-data:www-data /home/2dth/public_html
chmod -R g+rw /home/2dth/public_html service php5-fpm restart
service php5-fpm restart
service nginx restart

apt-get -y install zip unzip
cd /home/2dth/public_html
wget https://mtvpn.sgp1.digitaloceanspaces.com/MTPANEL.zip
unzip MTPANEL.zip
rm -f MTPANEL.zip
chown -R www-data:www-data /home/2dth/public_html
chmod -R g+rw /home/2dth/public_html

#mysql -u root -p
so2=$(expect -c "
spawn mysql -u root -p; sleep 3
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"CREATE DATABASE IF NOT EXISTS $DatabaseName;EXIT;\r\"
expect eof; ")
echo "$so2"
#pass
#CREATE DATABASE IF NOT EXISTS OCS_PANEL;EXIT;

cd /home/2dth/public_html
chmod 777 /home/2dth/public_html/
sudo chmod -R 777 /home/2dth/public_html

apt-get -y --force-yes -f install libxml-parser-perl

ชัดเจน
echo "เปิดเบราว์เซอร์เข้าถึง http://$ MYIP:85/ และเติมข้อมูลตามด้านล่าง!"
echo "ฐานข้อมูล:"
echo "- โฮสต์ฐานข้อมูล: localhost"
echo "- ชื่อฐานข้อมูล: $DatabaseName"
echo "- ผู้ใช้ฐานข้อมูล: root"
echo "- ฐานข้อมูลผ่าน: $DatabasePass"
echo ""
echo "ล็อกอินของผู้ดูแลระบบ:"
echo "- ชื่อผู้ใช้: ทุกอย่างที่คุณต้องการ"
echo "- รหัสผ่านใหม่: ทุกอย่างที่คุณต้องการ"
echo "- ป้อนรหัสผ่านใหม่: ตามต้องการ"
echo ""
echo "คลิกติดตั้งและรอให้กระบวนการเสร็จสิ้นกลับไปที่เทอร์มินัลแล้วกด [ENTER key]!"

# info
clear
echo "=======================================================" | tee -a log-install.txt
echo "เข้าสู่ระบบ >> http://$MYIP:85" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Auto Script Installer OCS Panels Mod by TomMt"  | tee -a log-install.txt
echo "             (http://bytehax.blogspot.com/ - fb.com/143Clarkz)           "  | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Thanks " | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Installation Log --> /root/log-install.txt" | tee -a log-install.txt
echo "=======================================================" | tee -a log-install.txt
cd ~/

#rm -f /root/ocspanel.sh



