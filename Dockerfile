FROM python:2.7

RUN apt-get update

RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs
RUN apt-get install -y npm
RUN apt-get install -y git
RUN apt-get install -y vim
RUN apt-get install -y sqlite3

RUN python -m pip install virtualenv

WORKDIR /root

# make Curve directory
RUN mkdir -p /root/Curve

# we copy files manually to speed up the build process

# to build curve frontend
COPY Curve/web /root/Curve/web
COPY Curve/build-frontend.sh /root/Curve/
RUN /root/Curve/build-frontend.sh

# to build curve backend
COPY Curve/api /root/Curve/api
COPY Curve/build-backend.sh /root/Curve/
RUN /root/Curve/build-backend.sh

WORKDIR /root/Curve

COPY Curve/deploy-frontend.sh /root/Curve/
COPY Curve/deploy-backend.sh /root/Curve/
COPY Curve/deploy.sh /root/Curve

CMD ["./deploy.sh"]
