# erpnext

Erpnext docker image

* Based on: debian:wheezy
* Including services: 
  * Redis
  * Nginx
  * memcached
  * Maridb
  * cron
 
Install with:


## run data container
`docker create -v /home/frappe/frappe-bench/sites/site1.local/ -v /var/lib/mysql --name erpdata davidgu/erpnext
`
## run erpnext
`docker run -d -p 80:80 --name erpnext --volumes-from erpdata davidgu/erpnext
`

## get passwords
`docker exec -ti erpnext cat /root/frappe_passwords.txt
`
Login on http://localhost with Administrator / password
