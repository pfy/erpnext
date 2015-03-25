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

`
#run data container
docker create -v /srv/docker/owncloud/erpnext/site1.local -v /var/lib/mysql --name erpdata davidgu/erpnext

#run erpnext
docker run -d -p 80:80 --name erpnext --volumes-from erpdata davidgu/erpnext
`

Login on http://localhost with Administrator / admin
