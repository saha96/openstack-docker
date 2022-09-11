# useless packages should be removed, and packages should be installed with pip instead of apt
FROM ubuntu:20.04
# MAINTAINER amir <sahahmadi96@gmail.com>

# COPY . /opt/src/

# ADD openstackdebs /usr/local/openstackdebs

# RUN echo "=================== add local apt source ===================" && \
#     echo 'deb [trusted=yes] file:/usr/local/openstackdebs ./' >> /etc/apt/sources && apt-get update

RUN echo "=================== installing packages ===================" && \
    apt-get update && \
    apt-get install -y openssh-server git

RUN echo "=================== create stack user ===================" && \
    sudo useradd -s /bin/bash -d /opt/stack -m stack && \
    sudo chmod +x /opt/stack && \
    echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

RUN echo "=================== get code from github ===================" && \
    sudo -u stack -i && \
    export GIT_SSL_NO_VERIFY=1 && \
    git clone https://github.com/saha96/devstack-docker.git && \
    mv devstack-docker/ devstack/ && \
    cd devstack

COPY local.conf /opt/stack/

RUN echo "=================== run stack.sh ===================" && \
    sudo -u stack -i && \
    cd devstack && \
    sed -i "s/OVS_RUNDIR=\$OVS_PREFIX\/var\/run\/openvswitch/OVS_RUNDIR=\$OVS_PREFIX\/var\/run\/ovn/g" lib/neutron_plugins/ovn_agent && \
    mkdir ~/openstack && \
    sudo apt install python3-distutils && \
    wget --progress=dot:giga -c http://download.cirros-cloud.net/0.5.2/cirros-0.5.2-x86_64-disk.img -O /opt/stack/devstack/files/cirros-0.5.2-x86_64-disk.im && \
    ./stack.sh 

RUN echo "=================== restart stack.sh (mysql crash) ===================" && \
    sudo -u stack -i && \
    cd devstack && \
    sudo rm -rf /var/run/ovn/ovn && \
    ./clean.sh && \
    ./unstack.sh && \
    sudo mkdir /etc/mysql && \
    sudo -u stack -i && \
    sudo ln -s ~/.my.cnf /etc/mysql/my.cnf && \
    cd devstack/ && \
    ./stack.sh 

RUN echo "=================== restart stack.sh (ovn crash) ===================" && \
    sudo -u stack -i && \
    cd devstack && \
    sudo rm -rf /var/run/ovn/ovn && \
    ./clean.sh && \
    ./unstack.sh && \
    sudo mkdir /etc/mysql && \
    sudo -u stack -i && \
    sudo ln -s ~/.my.cnf /etc/mysql/my.cnf && \
    cd devstack/ && \
    ./stack.sh 

RUN echo "=================== add configuration files ===================" && \
COPY configurations /

# RUN rm -rf /opt/src/
RUN chmod 755 /usr/local/bin/postboot.sh

EXPOSE 8080

CMD /usr/local/bin/postboot.sh