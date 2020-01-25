FROM ubuntu

WORKDIR /usr/docker
COPY requirements.txt ./

RUN apt-get -y -qq update \
	&& apt-get -y -qq remove python \
	&& apt-get -y -qq autoremove \
	&& apt-get -y -qq install openjdk-8-jdk python3.4 \
	&& ln -s /usr/bin/python3.4 /usr/bin/python \

	# Install python dependencies
	&& apt-get -y -qq install python3-pip \
	&& python -m pip install -r requirements.txt \
	
	# Download and build sources
	&& export TERM=${TERM:-dumb} \
	&& git clone https://github.com/Microsoft/ApplicationInsights-Docker \
	&& cd /usr/docker/ApplicationInsights-Docker \
	&& git checkout tags/v0.9.2 \
	&& chmod +x ./gradlew \
	&& ./gradlew shadow
	
WORKDIR /usr/docker/ApplicationInsights-Docker/build/docker/
ENTRYPOINT ["java","-cp", "/usr/docker/ApplicationInsights-Docker/build/docker/ApplicationInsights-Docker-0.9.jar", "com.microsoft.applicationinsights.AgentBootstrapper"]