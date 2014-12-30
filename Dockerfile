FROM centos:centos6
MAINTAINER Richard Louapre <richard.louapre@marklogic.com>
 
#update yum repository and install openssh server
RUN yum update -y
RUN yum install -y openssh-server wget
 
#generate ssh key
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN sed -ri 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd
RUN mkdir -p /root/.ssh && chown root.root /root && chmod 700 /root/.ssh
 
#change root password to 123456
RUN echo 'root:123456' | chpasswd
 
WORKDIR /tmp
RUN wget -O ml.rpm http://public.zopyx.com/ml.rpm
RUN yum -y install /tmp/ml.rpm
RUN rm /tmp/ml.rpm
# Setup supervisor
ADD https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py /tmp/ez_setup.py
RUN python /tmp/ez_setup.py
RUN easy_install supervisor
ADD supervisord.conf /etc/supervisord.conf
 
WORKDIR /
# Expose MarkLogic admin
EXPOSE 2022 8000 8001 8002
# Run Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
