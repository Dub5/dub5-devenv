#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

RUBY_VERSION=2.2.2
RAILS_VERSION=4.2.2
PG_VERSION=9.3

echo "Setting up locales..."
/usr/sbin/update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo "Setting up APT mirrors..."
`cat >/etc/apt/sources.list <<\EOF
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse
EOF
`

echo "Setting up Passenger's APT repository..."
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
apt-get install -y apt-transport-https ca-certificates
echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main" > /etc/apt/sources.list.d/passenger.list

echo "Upgrading all packages..."
apt-mark hold grub
apt-mark hold grub-common
apt-get -y update
apt-get -y upgrade
apt-mark unhold grub
apt-mark unhold grub-common

echo "Installing miscellaneous packages..."
apt-get install -y build-essential curl git nodejs imagemagick subversion python-software-properties \
        zip unzip libz-dev libreadline-dev zlib1g-dev sqlite3 libsqlite3-dev openssl libssl-dev \
        libffi-dev linux-tools-generic systemtap sbcl gdb libcurl4-gnutls-dev libyaml-dev libxml2-dev \
        libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison

echo "Installing PostgreSQL..."
apt-get install -y postgresql postgresql-contrib postgresql-client libpq-dev

echo "Installing MySQL..."
apt-get install -y mysql-server mysql-client

echo "Installing Redis..."
apt-get install -y redis-server libhiredis-dev

echo "Installing Nginx + Passenger..."
apt-get install -y passenger nginx-extras

echo "Installing RVM..."
`cat >/home/vagrant/install_rvm.sh <<\EOF
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install $RUBY_VERSION
rvm use $RUBY_VERSION --default
rvm rubygems current
EOF
`
chmod +x /home/vagrant/install_rvm.sh
su vagrant -c "bash -c /home/vagrant/install_rvm.sh"
rm /home/vagrant/install_rvm.sh

echo "Configure Nginx + Passenger..."
perl -i -p -e 's/# passenger_root \/usr\/lib\/ruby\/vendor_ruby\/phusion_passenger\/locations\.ini\;\n/passenger_root \/usr\/lib\/ruby\/vendor_ruby\/phusion_passenger\/locations.ini;\n\tpassenger_ruby \/home\/vagrant\/.rvm\/gems\/ruby-$RUBY_VERSION\/wrappers\/ruby;\n/' /etc/nginx/nginx.conf

echo "Clean up old and unused packages..."
apt-get -y autoremove
apt-get -y autoclean
apt-get -y clean

echo "Finished box setup!"

echo "Set up hostname"
echo "dub5" > /etc/hostname
echo "127.0.0.1 dub5" >> /etc/hosts
hostname dub5

echo "Configuring a nice session environment"
`cat >/home/vagrant/.environment.sh <<\EOF

# Useful aliases
alias get-repositories="bash /vagrant/scripts/get-repositories.sh"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias glog='git log --oneline --decorate --graph'
export CLICOLOR='YES'
# A nice colorized prompt
export PS1="\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;33m\]\h\[\033[0m\]\[\033[1;37m\] \w \r\n\[\033[0m\]$ "
export LANG='en_US.UTF-8'

# Load secret keys, if any.
if [ -f ~/.secret_keys ]; then
  source ~/.secret_keys.sh
fi
EOF
`
echo "source ~/.environment.sh" >> /home/vagrant/.bash_profile

touch /home/vagrant/.secret_keys.sh

chown vagrant:vagrant /home/vagrant/.environment.sh
chown vagrant:vagrant /home/vagrant/.secret_keys.sh

echo "Setting up PostgreSQL database..."
sudo -u postgres pg_dropcluster --stop $PG_VERSION main
sudo -u postgres pg_createcluster --start $PG_VERSION main
sudo -u postgres createuser -d -R -w -S vagrant
perl -i -p -e 's/local   all             all                                     peer/local all all trust/' /etc/postgresql/9.3/main/pg_hba.conf

echo "#################################################################################################"
echo "# Welcome to the Dub5 Development Environment!                                                   "
echo "#                                                                                                "
echo "# Your are not done yet! You need to do the following to finish the setup:                       "
echo "# 1) Get all the project repositories:                                                           "
echo "#    Run: get-repositories                                                                       "
echo "# 2) Get the porject dependencies:                                                               "
echo "#    Run: cd /vagrant/dub5 ; bundle install                                                      "
echo "# 3) Set up the application API keys. Put them in ~/.secret_keys.sh                              "
echo "#                                                                                                "
echo "# Info:                                                                                          "
echo "# PostgreSQL user 'vagrant' created without a password. 'oodle_cashout_development' created.     "
echo "#                                                                                                "
echo "#################################################################################################"
