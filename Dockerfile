FROM debian:wheezy

ENV MSQ_PASS demopass
ENV HOSTNAME erpnext.smooh.ch
ENV FRAPPE_USER frappe
ENV FRAPPE_BRANCH master
ENV BENCH_BRANCH master 
ENV ADMIN_PASS admin

ENV ERPNEXT_APPS_JSON https://raw.githubusercontent.com/frappe/bench/master/install_scripts/erpnext-apps-master.json
RUN useradd $FRAPPE_USER && mkdir /home/$FRAPPE_USER && chown -R $FRAPPE_USER.$FRAPPE_USER /home/$FRAPPE_USER

WORKDIR /home/$FRAPPE_USER
COPY setup.sh /
RUN  bash /setup.sh
VOLUME ["/var/lib/mysql", "/home/frappe/frappe-bench/sites/site1.local/"]
COPY all.conf /etc/supervisor/conf.d/
EXPOSE 80

CMD ["/usr/bin/supervisord","-n"]
