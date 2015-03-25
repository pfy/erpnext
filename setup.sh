#!/bin/bash




# install stuff for add repo
apt-get update -qq \
&& apt-get install -y --no-install-recommends python-software-properties

# add maria db repo
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
add-apt-repository "deb http://ams2.mirrors.digitalocean.com/mariadb/repo/5.5/debian wheezy main"


# setup debconf selections
echo  "postfix postfix/mailname string $HOSTNAME" | debconf-set-selections 
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections 
echo "mariadb-server-5.5 mysql-server/root_password password $MSQ_PASS" | debconf-set-selections 
echo "mariadb-server-5.5 mysql-server/root_password_again password $MSQ_PASS" | debconf-set-selections 


# install prereq
apt-get update -qq \
&& apt-get install -y --no-install-recommends wget sudo cron python-software-properties python-dev \
python-setuptools build-essential python-mysqldb git memcached htop mariadb-server mariadb-common \
libmariadbclient-dev  libxslt1.1 libxslt1-dev redis-server libssl-dev libcrypto++-dev postfix nginx \
supervisor python-pip fontconfig libxrender1 libxext6 xfonts-75dpi xfonts-base ca-certificates

#install wkhtmlpdf
WK_VER="wheezy"
WK_ARCH="amd64"
wget http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.2.1/wkhtmltox-0.12.2.1_linux-$WK_VER-$WK_ARCH.deb
dpkg -i  wkhtmltox-0.12.2.1_linux-$WK_VER-$WK_ARCH.deb
rm  wkhtmltox-0.12.2.1_linux-$WK_VER-$WK_ARCH.deb

/etc/init.d/mysql start
/etc/init.d/supervisor start


su $FRAPPE_USER -c "cd /home/$FRAPPE_USER && git clone https://github.com/frappe/bench --branch $BENCH_BRANCH bench-repo"
pip install -e /home/$FRAPPE_USER/bench-repo

su $FRAPPE_USER -c "cd /home/$FRAPPE_USER && bench init frappe-bench --frappe-branch $FRAPPE_BRANCH --apps_path $ERPNEXT_APPS_JSON"
echo /home/$FRAPPE_USER/frappe-bench > /etc/frappe_bench_dir

su $FRAPPE_USER -c "cd /home/$FRAPPE_USER && bench new-site site1.local --mariadb-root-password $MSQ_PASS --admin-password $ADMIN_PASS"
echo daemonize no >> /etc/redis/redis.conf


su $FRAPPE_USER -c "cd /home/$FRAPPE_USER/frappe-bench && bench frappe --install_app erpnext"
su $FRAPPE_USER -c "cd /home/$FRAPPE_USER/frappe-bench && bench frappe --install_app shopping_cart"
cd /home/$FRAPPE_USER/frappe-bench && bench setup sudoers $FRAPPE_USER
cd /home/$FRAPPE_USER/frappe-bench && bench setup production $FRAPPE_USER



/etc/init.d/mysql stop
/etc/init.d/supervisor stop

# remove build stuff
apt-get -y remove build-essential python-dev python-software-properties libmariadbclient-dev libxslt1-dev libcrypto++-dev \
libssl-dev  && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/ /home/$FRAPPE_USER/.cache


cp -a /var/lib/mysql /var/lib/mysql.bak
