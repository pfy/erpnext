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
docker run -d -p 80:80 \ --name erpnext \ -v /srv/docker/owncloud/erpnext/mysql:/var/lib/mysql \ davidgu/erpnext
`
