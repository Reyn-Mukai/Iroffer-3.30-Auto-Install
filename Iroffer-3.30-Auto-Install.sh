if [ $(id -u) -ne 0 ]; then
echo "Error: Script must be run as root."
exit 1
fi

USER_HOME=$(eval echo ~${SUDO_USER})

echo "Updating system..."
apt-get -y update
echo "Upgrading packages..."
apt-get -y upgrade

echo "Downloading iroffer..."
cd USER_HOME
wget wget http://iroffer.dinoex.net/iroffer-dinoex-3.30.tar.gz
echo "Extracting sources..."
tar -xvzf iroffer-dinoex-3.30.tar.gz

echo "Installing dependencies..."
apt-get -y install make
apt-get -y install gcc
apt-get -y install libc6-dev
apt-get -y install libcurl4-openssl-dev
apt-get -y install libgeoip-dev
apt-get -y install libssl-dev
if grep -q "7." /etc/debian_version
then
  apt-get -y install ruby1.8-dev
  apt-get -y install ruby1.8
  apt-get -y install libruby1.8
fi
if grep -q "8." /etc/debian_version
then
  echo "Debian Jessie detected..."
  echo "Ignnoring ruby1.8 installation..."
fi

echo "Configuring sources..."
cd iroffer-dinoex-3.30
./Configure -curl -geoip -ruby

echo "Executing make..."
cd ${USER_HOME}/iroffer-dinoex-3.30
make

echo "Creating file directories..."
mkdir ${USER_HOME}/iroffer/bots

echo "Copying sample config..."
cp sample.config mybot.config

echo "Generating iroffer start-up script..."
cd $USER_HOME
echo '#!/bin/sh' >> start-iroffer.sh
echo ${USER_HOME}/iroffer >> start-iroffer.sh
echo './iroffer -b '${USER_HOME}'/iroffer/mybot.config' >> start-iroffer.sh
