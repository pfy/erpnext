#!/bin/bash

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

cp -a /var/lib/mysql /var/lib/mysql.bak
