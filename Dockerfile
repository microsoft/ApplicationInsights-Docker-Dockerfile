FROM ubuntu as builder

# Install prerequisites
RUN apt-get -y -qq update \
	&& apt-get -y -qq install git openjdk-8-jdk

# Download and build sources
RUN export TERM=${TERM:-dumb} \
	&& git clone https://github.com/Microsoft/ApplicationInsights-Docker \
	&& cd /usr/docker/ApplicationInsights-Docker \
	&& git checkout tags/v0.9.2 \
	&& chmod +x ./gradlew \
	&& ./gradlew shadow 2>&1
	
FROM debian:stretch-slim

WORKDIR /usr/docker
COPY requirements.txt ./

RUN printf "deb http://http.debian.net/debian stretch-backports main" > /etc/apt/sources.list.d/backports.list

RUN mkdir -p /usr/share/man/man1 \
	&& apt-get -y -qq update \
    && apt-get -y -qq install --no-install-recommends openjdk-8-jre-headless \
	&& apt-get -y -qq install openjdk-8-jre python3.4 \
	&& ln -s /usr/bin/python3.4 /usr/bin/python \
	&& apt-get autoremove && apt-get clean \
	&& python -m pip install  -r requirements.txt \
	&& mkdir -p /usr/docker/ApplicationInsights-Docker/build

COPY --from=builder /usr/docker/ApplicationInsights-Docker/build/ /usr/docker/ApplicationInsights-Docker/build

WORKDIR /usr/docker/ApplicationInsights-Docker/build/docker/

ENTRYPOINT ["java","-cp", "/usr/docker/ApplicationInsights-Docker/build/docker/ApplicationInsights-Docker-0.9.jar", "com.microsoft.applicationinsights.AgentBootstrapper"]