FROM sporule/big-data-cluster:hadoop-base


LABEL  credit="https://github.com/big-data-europe/docker-hadoop"
LABEL  maintainer = "Sporule <hao@sporule.com>"

# Setup Hive
ARG hive_version=3.1.0
ENV HIVE_VERSION=$hive_version
ENV HIVE_HOME /opt/hive
ENV PATH $HIVE_HOME/bin:$PATH

WORKDIR /opt
RUN apt-get update && apt-get install -y ssh wget procps vim unzip git nodejs&& \
	wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
	tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz && \
	mv apache-hive-$HIVE_VERSION-bin hive && \
	wget https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar -O $HIVE_HOME/lib/postgresql-jdbc.jar && \
	rm apache-hive-$HIVE_VERSION-bin.tar.gz

ADD hive-conf/hive-site.xml $HIVE_HOME/conf
ADD hive-conf/beeline-log4j2.properties $HIVE_HOME/conf
ADD hive-conf/hive-env.sh $HIVE_HOME/conf
ADD hive-conf/hive-exec-log4j2.properties $HIVE_HOME/conf
ADD hive-conf/hive-log4j2.properties $HIVE_HOME/conf
ADD hive-conf/ivysettings.xml $HIVE_HOME/conf
ADD hive-conf/llap-daemon-log4j2.properties $HIVE_HOME/conf


# Install Python3 Build Environment

WORKDIR /
RUN apt-get install -y python-dev python3-dev python3-venv\
	build-essential libssl-dev libffi-dev \
	libxml2-dev libxslt1-dev zlib1g-dev \
	python-pip python3-pip



# Set up Spark
ARG spark_version=3.0.1
ENV SPARK_VERSION=$spark_version

RUN wget https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop3.2.tgz \
	&& tar -xvzf spark-$SPARK_VERSION-bin-hadoop3.2.tgz \
	&& mv spark-$SPARK_VERSION-bin-hadoop3.2 spark \
	&& rm spark-$SPARK_VERSION-bin-hadoop3.2.tgz \
	&& wget https://jdbc.postgresql.org/download/postgresql-42.2.17.jar -P /spark/jars/ \
	&& wget https://search.maven.org/remotecontent?filepath=org/mongodb/spark/mongo-spark-connector_2.12/3.0.0/mongo-spark-connector_2.12-3.0.0.jar -O /spark/jars/mongo-spark-connector_2.12-3.0.0.jar

ENV PYTHONHASHSEED 1


# Set up Airflow
RUN export AIRFLOW_HOME=/root/airflow \
	&& pip install apache-airflow \
	&& mkdir -p /landing_zone


# Set up Apache Nifi

ARG nifi_version=1.11.4
ENV NIFI_VERSION=$nifi_version

RUN wget https://archive.apache.org/dist/nifi/$NIFI_VERSION/nifi-$NIFI_VERSION-bin.tar.gz && \
	tar -xzvf nifi-$NIFI_VERSION-bin.tar.gz && \
	mv nifi-$NIFI_VERSION nifi&& \
	sed -i 's/port=8080/port=8081/g' nifi/conf/nifi.properties&& \
	nifi/bin/nifi.sh install&& \
	rm nifi-$NIFI_VERSION-bin.tar.gz

# Set up Livy

ARG livy_version=0.5.0
ENV LIVY_VERSION=$livy_version

RUN wget http://archive.apache.org/dist/incubator/livy/$LIVY_VERSION-incubating/livy-$LIVY_VERSION-incubating-bin.zip && \
	unzip livy-$LIVY_VERSION-incubating-bin.zip && \
	mv livy-$LIVY_VERSION-incubating-bin livy && \
	rm livy-$LIVY_VERSION-incubating-bin.zip

# Set up root folder
WORKDIR /root

# Set up Jupyter Hub

RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
	&& pip install jupyterhub notebook findspark\
	&& npm install -g configurable-http-proxy \
	&& yes | jupyterhub --generate-config \
	&& echo "c.LocalProcessSpawner.shell_cmd = ['bash', '-l', '-c']" >> "/root/jupyterhub_config.py"


# Clean Package Management Archive

RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Set up environment variable
ENV SPARK_HOME /spark
COPY spark-env.sh /spark/conf/
COPY spark-defaults.conf /spark/conf/
COPY statsd-jvm-profiler-2.1.0.jar /statsd-jvm-profiler.jar
ENV PATH $SPARK_HOME/bin:$PATH

# Set up SSH
COPY .ssh/ /root/.ssh/
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config


# Set up Configuration and Start Services
ADD run.sh /run.sh
RUN chmod a+x /run.sh
CMD ["/run.sh"]
