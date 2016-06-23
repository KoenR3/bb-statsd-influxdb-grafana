#!/bin/bash

echo "=> Starting MySQL ..."
/etc/init.d/mysql start

sleep 5

echo "=> Starting Grafana ..."
/etc/init.d/grafana-server start

sleep 5

echo "Adding datasource ${GRAFANA_DATASOURCE_NAME}"
curl "http://${GRAFANA_USER}:${GRAFANA_PW}@localhost:9000/api/datasources" -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"${GRAFANA_DATASOURCE_NAME}","type":"influxdb","url":"http://localhost:8086","access":"proxy","isDefault":true,"database":"${INFLUXDB_GRAFANA_DB}","user":"${INFLUXDB_GRAFANA_USER}","password":"${INFLUXDB_GRAFANA_PW}"}'

sleep 1


echo "Adding dashboard"
curl "http://${GRAFANA_USER}:${GRAFANA_PW}@localhost:9000/api/dashboards/db" --data-binary @./tmp/matchingdemo.json -H "Content-Type: application/json"



echo "=> Stopping MySQL ..."
/etc/init.d/mysql stop

echo "=> Stopping Grafana ..."
/etc/init.d/grafana-server stop

exit 0

