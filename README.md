# Docker Image with Telegraf, StatsD, InfluxDB and Grafana

## Versions

StatsD:   0.7.2  
InfluxDB: 0.9.6.1  
Grafana:  2.6.0  

This build is based on samuel bistoletti's build but is adapted for use in a bigboards.io deployment

## Mapped Ports

```
Host		Container		Service

3003		9000			grafana
8086		8086			influxdb
3004		8083			influxdb-admin
8125		8125			statsd
22022		22				sshd
```

## Grafana

Open <http://ip:3003>

```
Username: root
Password: root
```

### Add data source on Grafana

1. Open `Data Source` from left side menu, then click on `Add new`
2. Choose a `name` for the source and flag it as `Default`
3. Choose `InfluxDB 0.9.x` as `type`
4. Fill remaining fields as follows and click on `Add` without altering other fields

```
Url: http://ip:8086
Database:	datasource
User: datasource
Password:	datasource
```

Now you are ready to add your first dashboard and launch some query on database.

## InfluxDB

### Web Interface

Open <http://ip:3004>

```
Username: root  
Password: root  
Port: 8086
```
