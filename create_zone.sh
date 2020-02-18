#!/bin/bash
docker exec pdns-server pdnsutil create-zone lab2.jelastic.team
docker exec pdns-server pdnsutil add-record lab2.jelastic.team www1 A 192.168.3.2
docker exec pdns-server pdnsutil add-record lab2.jelastic.team www2 A 192.168.2.2
docker exec pdns-server pdnsutil add-record lab2.jelastic.team ns1 A 192.168.3.2
docker exec pdns-server pdnsutil add-record lab2.jelastic.team ns2 A 192.168.2.2
docker exec pdns-server pdnsutil add-record lab2.jelastic.team hn01-bhs3 A 192.168.3.2
docker exec pdns-server pdnsutil add-record lab2.jelastic.team hn01-waw1 A 192.168.2.2

docker exec pdns-server pdnsutil delete-rrset lab2.jelastic.team www1 A
