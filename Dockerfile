FROM debian:wheezy

ENV MSQ_PASS demopass
ENV HOSTNAME erpnext.smooh.ch
ENV FRAPPE_USER frappe
ENV FRAPPE_BRANCH master
ENV BENCH_BRANCH master 
ENV ADMIN_PASS admin

ENV ERPNEXT_APPS_JSON https://raw.githubusercontent.com/frappe/bench/master/install_scripts/erpnext-apps-master.json



RUN useradd $FRAPPE_USER && mkdir /home/$FRAPPE_USER && chown -R $FRAPPE_USER.$FRAPPE_USER /home/$FRAPPE_USER


RUN apt-get update -qq \
&& apt-get install -y --no-install-recommends python-software-properties

# add maria db repo
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
RUN add-apt-repository "deb http://ams2.mirrors.digitalocean.com/mariadb/repo/5.5/debian wheezy main"


# setup debconf selections
RUN echo  "postfix postfix/mailname string $HOSTNAME" | debconf-set-selections 
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections 
RUN echo "mariadb-server-5.5 mysql-server/root_password password $MSQ_PASS" | debconf-set-selections 
RUN echo "mariadb-server-5.5 mysql-server/root_password_again password $MSQ_PASS" | debconf-set-selections 



RUN apt-get update -qq \
&& apt-get install -y --no-install-recommends wget sudo cron python-software-properties python-dev python-setuptools build-essential python-mysqldb git memcached ntp vim screen htop mariadb-server mariadb-common libmariadbclient-dev  libxslt1.1 libxslt1-dev redis-server libssl-dev libcrypto++-dev postfix nginx supervisor python-pip fontconfig libxrender1 libxext6 xfonts-75dpi xfonts-base ca-certificates

WORKDIR /home/$FRAPPE_USER
COPY setup.sh /
RUN  bash /setup.sh
VOLUME ["/var/lib/mysql", ]
COPY all.conf /etc/supervisor/conf.d/
EXPOSE 80
COPY run.sh /

# Clean to get a smaller image
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

CMD ["bash","/run.sh"]
