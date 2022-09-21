# useless packages should be removed, and packages should be installed with pip instead of apt
FROM jrei/systemd-ubuntu:20.04
# MAINTAINER amir <sahahmadi96@gmail.com>

# COPY . /opt/src/

ADD openstackdebs /usr/local/openstackdebs

RUN echo "=================== add local apt source ===================" && \
    # echo 'deb [trusted=yes] file:/usr/local/openstackdebs ./' >> /etc/apt/sources.list && \
    apt-get update

RUN echo "=================== installing packages ===================" && \
    DEBIAN_FRONTEND=noninteractive http_proxy= https_proxy= no_proxy= \
        apt-get --option Dpkg::Options::=--force-confold --assume-yes install \
        openssh-server git python3-distutils sudo

RUN echo "=================== create stack user ===================" && \
    useradd -s /bin/bash -d /opt/stack -m stack && \
    chmod +x /opt/stack && \
    echo "stack ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/stack

RUN echo "=================== get code from github ===================" && \
    su - stack && \
    export GIT_SSL_NO_VERIFY=1 && \
    su - stack -c "git clone https://github.com/saha96/devstack-docker.git" && \
    mv /opt/stack/devstack-docker/ /opt/stack/devstack/

COPY local.conf /opt/stack/devstack/local.conf

# RUN echo "=================== offline installation ===================" && \

RUN echo "=================== online installation (part1) ===================" && \
    su - stack && \
    cd /opt/stack/devstack && \
    mkdir /opt/stack/openstack/ && \
    chown -R stack:stack /opt/stack/openstack/ && \
    # git clone from opendev
    su - stack -c "git clone https://opendev.org/openstack/requirements.git /opt/stack/openstack/requirements --branch stable/yoga" && \
    su - stack -c "git clone https://opendev.org/openstack/keystone.git /opt/stack/openstack/keystone --branch stable/yoga" && \
    su - stack -c "git clone https://opendev.org/openstack/glance.git /opt/stack/openstack/glance --branch stable/yoga" && \
    su - stack -c "git clone https://opendev.org/openstack/cinder.git /opt/stack/openstack/cinder --branch stable/yoga" && \
    su - stack -c "git clone https://opendev.org/openstack/neutron.git /opt/stack/openstack/neutron --branch stable/yoga" && \
    su - stack -c "git clone https://opendev.org/openstack/nova.git /opt/stack/openstack/nova --branch stable/yoga" && \
    su - stack -c "git clone https://opendev.org/openstack/placement.git /opt/stack/openstack/placement --branch stable/yoga" && \
    su - stack -c "git clone https://opendev.org/openstack/horizon.git /opt/stack/openstack/horizon --branch stable/yoga"
    
RUN echo "=================== online installation (part2) ===================" && \
    # git clone from github
    su - stack -c "git clone https://github.com/novnc/novnc.git /opt/stack/openstack/novnc --branch v1.3.0" 
    # install deb packages
    # sudo DEBIAN_FRONTEND=noninteractive http_proxy= https_proxy= no_proxy= apt-get --option Dpkg::Options::=--force-confold --assume-yes install \
    # apache2 apache2-dev bc bsdmainutils curl g++ gawk gcc gettext git graphviz iputils-ping libapache2-mod-proxy-uwsgi libffi-dev libjpeg-dev \
    # libpcre3-dev libpq-dev libssl-dev libsystemd-dev libxml2-dev libxslt1-dev libyaml-dev lsof openssh-server openssl pkg-config psmisc python3-dev \
    # python3-pip python3-systemd python3-venv tar tcpdump unzip uuid-runtime wget wget zlib1g-dev libkrb5-dev libldap2-dev libsasl2-dev memcached \
    # conntrack curl dnsmasq-base dnsmasq-utils ebtables genisoimage iptables iputils-arping kpartx libjs-jquery-tablesorter \
    # parted pm-utils socat sudo vlan lsscsi open-iscsi cryptsetup dosfstools genisoimage gir1.2-libosinfo-1.0 netcat-openbsd \
    # open-iscsi qemu-utils sg3-utils sysfsutils lvm2 qemu-utils thin-provisioning-tools acl dnsmasq-base dnsmasq-utils ebtables haproxy iptables \
    # iputils-arping iputils-ping sudo vlan pcp rabbitmq-server mysql-server uwsgi uwsgi-plugin-python3 \
    # libapache2-mod-proxy-uwsgi targetcli-fb fakeroot make openvswitch-switch ovn-central ovn-controller-vtep ovn-host qemu-system libvirt-clients \
    # libvirt-daemon-system libvirt-dev python3-libvirt apache2 apparmor-utils libapache2-mod-wsgi-py3 vim

# # RUN echo "=================== add configuration files ===================" && \
# COPY configurations /

# # RUN rm -rf /opt/src/
# RUN chmod 755 /usr/local/bin/postboot.sh

EXPOSE 80

CMD ["/lib/systemd/systemd"]
