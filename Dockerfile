# useless packages should be removed, and packages should be installed with pip instead of apt
FROM ubuntu:20.04
# MAINTAINER amir <sahahmadi96@gmail.com>

# COPY . /opt/src/

# ADD openstackdebs /usr/local/openstackdebs

# RUN echo "=================== add local apt source ===================" && \
#     echo 'deb [trusted=yes] file:/usr/local/openstackdebs ./' >> /etc/apt/sources && apt-get update

RUN echo "=================== installing packages ===================" && \
    apt-get update && \
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
    git clone https://github.com/saha96/devstack-docker.git && \
    mv devstack-docker/ devstack/ && \
    cd devstack

COPY local.conf /opt/stack/

# RUN echo "=================== offline installation ===================" && \

RUN echo "=================== online installation ===================" && \
    su - stack && \
    cd devstack && \
    mkdir ~/openstack && \
    # git clone from opendev
    git clone https://opendev.org/openstack/requirements.git /opt/stack/openstack/requirements --branch stable/yoga && \
    git clone https://opendev.org/openstack/keystone.git /opt/stack/openstack/keystone --branch stable/yoga && \
    git clone https://opendev.org/openstack/glance.git /opt/stack/openstack/glance --branch stable/yoga && \
    git clone https://opendev.org/openstack/cinder.git /opt/stack/openstack/cinder --branch stable/yoga && \
    git clone https://opendev.org/openstack/neutron.git /opt/stack/openstack/neutron --branch stable/yoga && \
    git clone https://opendev.org/openstack/nova.git /opt/stack/openstack/nova --branch stable/yoga && \
    git clone https://opendev.org/openstack/placement.git /opt/stack/openstack/placement --branch stable/yoga && \
    git clone https://opendev.org/openstack/horizon.git /opt/stack/openstack/horizon --branch stable/yoga && \
    # git clone from github
    git clone https://github.com/novnc/novnc.git /opt/stack/openstack/novnc --branch v1.3.0 && \
    # install deb packages
    sudo DEBIAN_FRONTEND=noninteractive http_proxy= https_proxy= no_proxy= apt-get --option Dpkg::Options::=--force-confold --assume-yes install \
    apache2 apache2-dev bc bsdmainutils curl g++ gawk gcc gettext git graphviz iputils-ping libapache2-mod-proxy-uwsgi libffi-dev libjpeg-dev \
    libpcre3-dev libpq-dev libssl-dev libsystemd-dev libxml2-dev libxslt1-dev libyaml-dev lsof openssh-server openssl pkg-config psmisc python3-dev \
    python3-pip python3-systemd python3-venv tar tcpdump unzip uuid-runtime wget wget zlib1g-dev libkrb5-dev libldap2-dev libsasl2-dev memcached \
    python3-mysqldb sqlite3 conntrack curl dnsmasq-base dnsmasq-utils ebtables genisoimage iptables iputils-arping kpartx libjs-jquery-tablesorter \
    parted pm-utils python3-mysqldb socat sqlite3 sudo vlan lsscsi open-iscsi cryptsetup dosfstools genisoimage gir1.2-libosinfo-1.0 netcat-openbsd \
    open-iscsi qemu-utils sg3-utils sysfsutils lvm2 qemu-utils thin-provisioning-tools acl dnsmasq-base dnsmasq-utils ebtables haproxy iptables \
    iputils-arping iputils-ping postgresql-server-dev-all python3-mysqldb sqlite3 sudo vlan pcp rabbitmq-server mysql-server uwsgi uwsgi-plugin-python3 \
    libapache2-mod-proxy-uwsgi targetcli-fb fakeroot make openvswitch-switch ovn-central ovn-controller-vtep ovn-host qemu-system libvirt-clients \
    libvirt-daemon-system libvirt-dev python3-libvirt apache2 apparmor-utils libapache2-mod-wsgi-py3 vim  && \
    # install rpm packages
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt 'setuptools!=24.0.0,!=34.0.0,!=34.0.1,!=34.0.2,!=34.0.3,!=34.1.0,!=34.1.1,!=34.2.0,!=34.3.0,!=34.3.1,!=34.3.2,!=36.2.0,!=48.0.0,!=49.0.0' && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt -U pbr && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt PyMySQL && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt etcd3 && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt etcd3gw && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt keystonemiddleware && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt python-memcached && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt -e /opt/stack/openstack/keystone && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt 'glance-store[cinder]!=0.29.0' && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt -e /opt/stack/openstack/glance && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt -e /opt/stack/openstack/cinder && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt -e /opt/stack/openstack/neutron && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt tox && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt -e /opt/stack/openstack/nova && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt osc-placement && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt -e /opt/stack/openstack/placement && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt python-openstackclient && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt -e /opt/stack/openstack/horizon && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt -U os-testr && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt 'tox!=2.8.0' && \
    sudo -H LC_ALL=en_US.UTF-8 SETUPTOOLS_USE_DISTUTILS=stdlib http_proxy= https_proxy= no_proxy= PIP_FIND_LINKS= SETUPTOOLS_SYS_PATH_TECHNIQUE=rewrite python3.8 -m pip install -c /opt/stack/openstack/requirements/upper-constraints.txt testrepository && \

RUN echo "=================== run stack.sh ===================" && \
    su - stack && \
    cd devstack && \
    ./stack.sh 

RUN echo "=================== restart stack.sh (mysql crash) ===================" && \
    su - stack && \
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
    su - stack && \
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