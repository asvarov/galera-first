#!/bin/bash
docker exec compose_pdns-server-1_1 pdnsutil create-zone lab2.jelastic.team
docker exec compose_pdns-server-1_1 pdnsutil add-record lab2.jelastic.team www A 192.168.3.2
docker exec compose_pdns-server-1_1 pdnsutil add-record lab2.jelastic.team ns A 192.168.3.2
docker exec compose_pdns-server-1_1 pdnsutil add-record lab2.jelastic.team ns A 192.168.2.2
docker exec compose_pdns-server-1_1 pdnsutil add-record lab2.jelastic.team hn01-bhs3 A 192.168.3.2
docker exec compose_pdns-server-1_1 pdnsutil add-record lab2.jelastic.team hn01-waw1 A 192.168.2.2
