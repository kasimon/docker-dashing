FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat

#required
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential ruby1.9.1 ruby1.9.1-dev
RUN gem install dashing
RUN gem install bundler

#nodejs
RUN apt-get install -y python-software-properties
RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install -y nodejs

RUN dashing new dashboard && \
    cd dashboard && \
    bundle

ADD supervisord-dashing.conf /etc/supervisor/conf.d/supervisord-dashing.conf

# Start supervisord in background when entering an interactive shell
RUN echo "/usr/bin/supervisord" >> /etc/bash.bashrc

# Start supervisord as a foreground process when running without a shell
CMD ["/usr/bin/supervisord", "-n"]

EXPOSE 22 3030
