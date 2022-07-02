# sometimes it locks up yum so we kill the damn thing !
pkill PackageKit
pkill packagekit
#yum -y install wget

# install openstack repositories
yum install -y https://www.rdoproject.org/repos/rdo-release.rpm
yum check-update

echo "10.0.0.3 controller" >> /etc/hosts
echo "10.0.0.2 compute1" >> /etc/hosts
echo "10.0.0.5 compute2" >> /etc/hosts
echo "10.0.0.6 compute3" >> /etc/hosts
echo "10.0.0.4 storage" >> /etc/hosts

#Other nodes reference the controller node for clock synchronization
# taken from : https://docs.openstack.org/install-guide/environment-ntp-other.html

yum -y install chrony
cp /etc/chrony.conf /etc/chrony.conf.bkup

echo "server controller iburst" > /etc/chrony.conf
echo "driftfile /var/lib/chrony/drift" >> /etc/chrony.conf
echo "makestep 1.0 3" >> /etc/chrony.conf
echo "rtcsync" >> /etc/chrony.conf
echo "logdir /var/log/chrony" >> /etc/chrony.conf

# Install and configure a storage node
# from : https://docs.openstack.org/cinder/queens/install/cinder-storage-install-rdo.html
# Pre-requisite :

yum -y install lvm2 device-mapper-persistent-data

systemctl enable lvm2-lvmetad.service
systemctl start lvm2-lvmetad.service

pvcreate /dev/sdb
vgcreate cinder-volumes /dev/sdb

# we modify existing lvm config file with this one
# to ignore the new lvm volume and reserve it for cinder
mv -f /etc/lvm/lvm.conf /etc/lvm/lvm.conf.bkup
wget https://raw.githubusercontent.com/msfellag/openstack-setup/main/lvm.conf -o /etc/lvm/lvm.conf

#Install and configure components
yum -y install openstack-cinder targetcli python-keystone


