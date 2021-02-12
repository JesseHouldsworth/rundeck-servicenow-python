ARG IMAGE
FROM ${IMAGE}
USER rundeck

COPY --chown=rundeck:root remco /etc/remco
#extra plugins
#COPY --chown=rundeck:root plugins/* libext/

USER root
#set timezone
ENV TZ 'America/Santiago'
RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata

#rd-cli
# RUN apt-get update \
#   && sudo echo "deb https://dl.bintray.com/rundeck/rundeck-deb /" | tee -a /etc/apt/sources.list \
#   && sudo curl "https://bintray.com/user/downloadSubjectPublicKey?username=bintray" > /tmp/bintray.gpg.key \
#   && sudo apt-key add - < /tmp/bintray.gpg.key \
#   && sudo apt-get -y install apt-transport-https \
#   && sudo apt-get -y update \
#   && sudo apt-get -y install rundeck-cli

#python3 for winrm
RUN apt-get update && apt-get install -y gcc libkrb5-dev krb5-user python3 python3-pip

RUN python3 -m pip install --upgrade pip &&\
    python3 -m pip install setuptools --force --upgrade &&\
    python3 -m pip install requests urllib3 pywinrm &&\
    python3 -m pip install --upgrade cryptography &&\
    python3 -m pip install pywinrm[credssp] &&\
    python3 -m pip install pywinrm[kerberos]

RUN ln -s /usr/bin/python3 /usr/bin/python

#set rundeck password
RUN echo 'rundeck:rundeck' | chpasswd

#extra stuff
RUN apt-get install -y nano
RUN apt-get update && apt-get install -y git
RUN apt-get update && apt-get -y install awscli

#Oracle JDBC driver
RUN COPY --chown=rundeck:root jdbcdriver ./server/lib

USER rundeck
#ansible
# ENV RDECK_BASE=/home/rundeck \
#     ANSIBLE_CONFIG=/home/rundeck/ansible/ansible.cfg \
#     ANSIBLE_HOST_KEY_CHECKING=False\
#     USER=rundeck
