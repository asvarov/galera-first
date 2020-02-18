#!/bin/bash
docker run \
  --name mariadb-one \
  --network host \
  -v /opt/compose/mysql.conf.d:/etc/mysql/conf.d \
  -v /opt/compose/data:/var/lib/mysql \
  -v /opt/compose/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d \
  -e MYSQL_ROOT_PASSWORD=P@ssw0rd \
  -p 3306:3306 \
  -p 4567:4567/udp \
  -p 4567-4568:4567-4568 \
  -p 4444:4444 \
  mariadb:10.1 \
  --wsrep-new-cluster \
  --wsrep_node_address=192.168.3.2
