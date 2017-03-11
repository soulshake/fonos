FROM debian:jessie

RUN apt-get update

COPY . /src
WORKDIR /src
RUN /src/00-install-packages.sh
