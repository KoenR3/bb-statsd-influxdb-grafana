FROM bigboards/base-x86_64
#FROM bigboards/base-__arch__

MAINTAINER Koen Rutten <koen.rutten@archimiddle.com>

# Default versions
ENV STATSD_VERSION 0.7.2
ENV INFLUXDB_VERSION 0.9.6.1
ENV GRAFANA_VERSION 2.6.0

# Database Defaults
ENV INFLUXDB_GRAFANA_DB datasource
ENV INFLUXDB_GRAFANA_USER datasource
ENV INFLUXDB_GRAFANA_PW datasource
ENV MYSQL_GRAFANA_USER grafana
ENV MYSQL_GRAFANA_PW grafana

# Grafana defaults
ENV GRAFANA_DATASOURCE_NAME Telegraf
ENV GRAFANA_DATABASE telegraf
ENV GRAFANA_USER root
ENV GRAFANA_PW root

# Environment variables
ENV DEBIAN_FRONTEND noninteractive

# Update system repositories & upgrade system & install dependencies &  Create support directories
RUN apt-get update && apt-get -y dist-upgrade && \
	apt-get -y --force-yes install curl wget git htop libfontconfig mysql-client mysql-server net-tools && \
	mkdir -p /etc/my_init.d

# Install InfluxDB
RUN wget http://s3.amazonaws.com/influxdb/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
	dpkg -i influxdb_${INFLUXDB_VERSION}_amd64.deb && \
	rm influxdb_${INFLUXDB_VERSION}_amd64.deb
		
# Install StatsD
RUN git clone -b v${STATSD_VERSION} https://github.com/etsy/statsd.git /opt/statsd

# Add Nodejs repository and install it
ADD nodejs/setup_nodejs.sh /tmp/setup_nodejs.sh
RUN /tmp/setup_nodejs.sh && \
	rm /tmp/setup_nodejs.sh && \
	apt-get -y --force-yes install nodejs
	
# Install StatsD InfluxDb Backend
RUN cd /opt/statsd && \
	npm install git+https://github.com/bernd/statsd-influxdb-backend.git
	
# Install Grafana
RUN wget https://grafanarel.s3.amazonaws.com/builds/grafana_${GRAFANA_VERSION}_amd64.deb && \
	dpkg -i grafana_${GRAFANA_VERSION}_amd64.deb && \
	rm grafana_${GRAFANA_VERSION}_amd64.deb
	
# Install telegraf
RUN wget https://dl.influxdata.com/telegraf/releases/telegraf_1.0.0-beta1_amd64.deb && \
	dpkg -i telegraf_1.0.0-beta1_amd64.deb && \
	rm telegraf_1.0.0-beta1_amd64.deb
	
# Configure MySql
ADD mysql/run.sh /etc/my_init.d/01_run_mysql.sh
ADD mysql/setup_mysql.sh /tmp/setup_mysql.sh

# Configure InfluxDB
ADD influxdb/influxdb.conf /etc/influxdb/influxdb.conf 
ADD	influxdb/run.sh /etc/my_init.d/02_run_influxdb.sh 
ADD	influxdb/init.sh /etc/init.d/influxdb 
ADD	influxdb/setup_influxdb.sh /tmp/setup_influxdb.sh

# Configure StatsD
ADD statsd/config.js /opt/statsd/config.js
# ADD statsd/run.sh /etc/my_init.d/03_run_statsd.sh

# Configure Grafana
ADD grafana/grafana.ini /etc/grafana/grafana.ini
ADD grafana/run.sh /etc/my_init.d/04_run_grafana.sh

# Configure Telegraf
ADD telegraf/telegraf.conf /etc/telegraf/telegraf.conf
ADD telegraf/run.sh /etc/my_init.d/05_run_telegraf.sh

# Execute all configuration parameters
RUN /tmp/setup_mysql.sh && \
	rm /tmp/setup_mysql.sh && \
 	/tmp/setup_influxdb.sh && \
	rm /tmp/setup_influxdb.sh
	
# Copy .bashrc & system related files
ADD system/bashrc /root/.bashrc
ADD system/my_init.sh /my_init.sh


# Add dashboards & data sources to grafana
ADD grafana/setup_grafana.sh /tmp/setup_grafana.sh
ADD grafana/matchingdemo.json /tmp/matchingdemo.json

RUN ./tmp/setup_grafana.sh && \
	rm /tmp/setup_grafana.sh

# Create volumes
VOLUME 	/var/log
VOLUME	/var/lib/mysql 
VOLUME	/var/opt/influxdb 
VOLUME	/opt/influxdb 
VOLUME	/opt/statsd 
VOLUME	/root
		
# Remove the package list to reduce image size. Note: do this as the last thing of the build process as installs can fail due to this!
# Additional cleanup
RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 9000 8083 8086 8125

CMD ["./my_init.sh"]
