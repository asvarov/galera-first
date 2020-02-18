#!/bin/bash
set -x
WORKDIR='/opt/compose'
NODE_ORDER=1
GALERA_IP=192.168.3.2
GALERA2_IP=192.168.2.2
WEB_IP=$GALERA_IP
MYSQL_HOST=$GALERA_IP
MYSQL_USER=imperituroard
MYSQL_PASS=imperituroard
MYSQL_ROOT_PASSWORD=P@ssw0rd

cat > ./.env <<-EOF
NODE_ORDER=1
GALERA_IP=$GALERA_IP
MYSQL_HOST=$MYSQL_HOST
MYSQL_USER=$MYSQL_USER
MYSQL_PASS=$MYSQL_PASS
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
EOF

cat > ./mysql.conf.d/my.cnf <<-EOF
[server]
[mysqld]
[galera]
wsrep_on=ON
wsrep_provider="/usr/lib/galera/libgalera_smm.so"
wsrep_cluster_address="gcomm://${GALERA_IP},${GALERA2_IP}"
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
innodb_locks_unsafe_for_binlog=1
query_cache_size=0
query_cache_type=0
wsrep-sst-method=rsync
bind-address=$MYSQL_HOST
[embedded]
[mariadb]
[mariadb-10.1]
EOF

cat > ./docker-entrypoint-initdb.d/powerdns.sql <<-EOF
CREATE DATABASE pdns character set utf8;
CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASS}';
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL ON pdns.* TO '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL ON pdns.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASS}';
FLUSH PRIVILEGES;

USE pdns;

CREATE TABLE domains (
  id                    INT AUTO_INCREMENT,
  name                  VARCHAR(255) NOT NULL,
  master                VARCHAR(128) DEFAULT NULL,
  last_check            INT DEFAULT NULL,
  type                  VARCHAR(6) NOT NULL,
  notified_serial       INT UNSIGNED DEFAULT NULL,
  account               VARCHAR(40) CHARACTER SET 'utf8' DEFAULT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE UNIQUE INDEX name_index ON domains(name);


CREATE TABLE records (
  id                    BIGINT AUTO_INCREMENT,
  domain_id             INT DEFAULT NULL,
  name                  VARCHAR(255) DEFAULT NULL,
  type                  VARCHAR(10) DEFAULT NULL,
  content               VARCHAR(64000) DEFAULT NULL,
  ttl                   INT DEFAULT NULL,
  prio                  INT DEFAULT NULL,
  disabled              TINYINT(1) DEFAULT 0,
  ordername             VARCHAR(255) BINARY DEFAULT NULL,
  auth                  TINYINT(1) DEFAULT 1,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX nametype_index ON records(name,type);
CREATE INDEX domain_id ON records(domain_id);
CREATE INDEX ordername ON records (ordername);


CREATE TABLE supermasters (
  ip                    VARCHAR(64) NOT NULL,
  nameserver            VARCHAR(255) NOT NULL,
  account               VARCHAR(40) CHARACTER SET 'utf8' NOT NULL,
  PRIMARY KEY (ip, nameserver)
) Engine=InnoDB CHARACTER SET 'latin1';


CREATE TABLE comments (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  name                  VARCHAR(255) NOT NULL,
  type                  VARCHAR(10) NOT NULL,
  modified_at           INT NOT NULL,
  account               VARCHAR(40) CHARACTER SET 'utf8' DEFAULT NULL,
  comment               TEXT CHARACTER SET 'utf8' NOT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX comments_name_type_idx ON comments (name, type);
CREATE INDEX comments_order_idx ON comments (domain_id, modified_at);


CREATE TABLE domainmetadata (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  kind                  VARCHAR(32),
  content               TEXT,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX domainmetadata_idx ON domainmetadata (domain_id, kind);


CREATE TABLE cryptokeys (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  flags                 INT NOT NULL,
  active                BOOL,
  content               TEXT,
  PRIMARY KEY(id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX domainidindex ON cryptokeys(domain_id);


CREATE TABLE tsigkeys (
  id                    INT AUTO_INCREMENT,
  name                  VARCHAR(255),
  algorithm             VARCHAR(50),
  secret                VARCHAR(255),
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE UNIQUE INDEX namealgoindex ON tsigkeys(name, algorithm);
EOF


cat > ./git.sh <<-EOF
#!/bin/bash
## crontab exec this script every munutes
cd ${WORKDIR}/webcontent
git pull origin
EOF

chmod +x ./git.sh
echo "* * * * * ${WORKDIR}/git.sh" >> /var/spool/cron/root

docker-compose up -d
sleep 60
docker exec pdns-$NODE_ORDER pdnsutil create-zone lab2.jelastic.team
docker exec pdns-$NODE_ORDER pdnsutil add-record lab2.jelastic.team webapp-$NODE_ORDER A $WEB_IP

#docker exec pdns1 pdnsutil delete-rrset lab2.jelastic.team www1 A
