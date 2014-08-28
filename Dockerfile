# See readme.textile
# based upon http://madebits.com/blog/comments.php?y=14&m=04&entry=entry140410-145942

FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

RUN locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN apt-get update

# not really needed
RUN apt-get -y install fuse || true
RUN rm -rf /var/lib/dpkg/info/fuse.postinst
RUN apt-get -y install fuse

# gui, browser, editor and terminal
RUN apt-get install -y xvfb x11vnc ubuntu-desktop firefox nano xterm vim gdm openbox

# add user
RUN useradd -m -d /home/user user
RUN echo "user:password" | chpasswd
RUN adduser user sudo
RUN chsh -s /bin/bash user

#vnc
RUN mkdir /home/user/.vnc
RUN x11vnc -storepasswd password home/user/.vnc/passwd
RUN chown -R user /home/user/.vnc
RUN chgrp -R user /home/user/.vnc
EXPOSE 5900

ENV HOME /home/user
WORKDIR /home/user
ENV DISPLAY :0

# not working
# USER user

ENTRYPOINT /startXvfb.sh xterm firefox

# added by Niklaus
RUN apt-get -qqy install openjdk-7-jdk
RUN apt-get -qqy install wget unzip

RUN mkdir -p /opt/downloads && cd /opt/downloads && wget --quiet --no-check-certificate https://srv.elexis.info/jenkins/view/3.0/job/Elexis-3.0-Core/lastSuccessfulBuild/artifact/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip
RUN mkdir /usr/local/Elexis3 && cd /usr/local/Elexis3 && unzip /opt/downloads/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip
RUN mkdir -p elexis && cd elexis && wget http://cznic.dl.sourceforge.net/project/elexis/elexis%20full%20installation/2.1.7.0/demoDB_2_1_7_mit_Administrator.zip && unzip demoDB_2_1_7_mit_Administrator.zip

ADD startXvfb.sh  /startXvfb.sh
ADD openbox_menu.xml /etc/xdg/openbox/menu.xml
ADD Elexis3_mitDemoDB /usr/local/Elexis3/Elexis3_mitDemoDB
RUN chown -R user:user /home/user

# to make the final image smaller
RUN apt-get clean

