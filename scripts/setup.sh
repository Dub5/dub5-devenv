#!/bin/bash

RUBY_VERSION=2.2.2
RAILS_VERSION=4.2.2
PG_VERSION=9.3

execute_with_rbenv () {
    `cat >/home/vagrant/temp-script.sh <<\EOF
export HOME=/home/vagrant
if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi
EOF
`

    echo $1 >> /home/vagrant/temp-script.sh
    chmod +x /home/vagrant/temp-script.sh
    su vagrant -c "bash -c /home/vagrant/temp-script.sh"
    rm /home/vagrant/temp-script.sh
}

export DEBIAN_FRONTEND=noninteractive

apt-get install libffi-dev libcurl4-gnutls-dev

echo "dub5.dev" > /etc/hostname
echo "127.0.0.1 dub5.dev" >> /etc/hosts

`cat >/home/vagrant/.environment.sh <<\EOF
# Environment variables
export PS1="[\[\033[1;34m\]\u\[\033[0m\]@\h:\[\033[1;37m\]\w\[\033[0m\]]$ "

alias l="ls -lAhG"
alias ls="ls -G"
alias ll="ls -lAhG"
alias dir="ll"
alias cls="clear"

# Load secret keys, if any
if [ -f ~/.secret_keys.sh ]; then
  source ~/.secret_keys.sh
fi

EOF
`

echo 'source ~/.environment.sh' >> /home/vagrant/.bash_profile

touch /home/vagrant/.secret_keys.sh

chown vagrant:vagrant /home/vagrant/.environment.sh
chown vagrant:vagrant /home/vagrant/.secret_keys.sh

`cat >/home/vagrant/upgrade_rbenv.sh <<\EOF
cd ~/.rbenv
git pull
cd ~/.rbenv/plugins/ruby-build
git pull
EOF
`

`cat >/home/vagrant/.gemrc <<\EOF
--no-document
EOF
`
chmod +x /home/vagrant/upgrade_rbenv.sh
su vagrant -c "bash -c /home/vagrant/upgrade_rbenv.sh"
rm /home/vagrant/upgrade_rbenv.sh

execute_with_rbenv "rbenv install $RUBY_VERSION ; rbenv global $RUBY_VERSION"

execute_with_rbenv "gem install rails --version $RAILS_VERSION --no-document"

sudo -u postgres pg_dropcluster --stop $PG_VERSION main
sudo -u postgres pg_createcluster --start $PG_VERSION main
sudo -u postgres createuser -d -R -w -S vagrant
perl -i -p -e 's/local   all             all                                     peer/local all all trust/' /etc/postgresql/$PG_VERSION/main/pg_hba.conf

`cat >/etc/nginx/sites-available/dub5-api <<\EOF
server {
    server_name *.lvh.me;

    listen 3000;

    client_max_body_size 10M;

    passenger_enabled on;

    rails_env development;
    root /vagrant/dub5-api/public;
}
EOF
`

perl -i -p -e 's/# passenger_root \/usr\/lib\/ruby\/vendor_ruby\/phusion_passenger\/locations\.ini\;\n/passenger_root \/usr\/lib\/ruby\/vendor_ruby\/phusion_passenger\/locations.ini;\n\tpassenger_ruby \/home\/vagrant\/.rbenv\/shims\/ruby;\n/' /etc/nginx/nginx.conf

ln -s /etc/nginx/sites-available/dub5-api /etc/nginx/sites-enabled/dub5-api
ln -s /etc/nginx/sites-available/dub5-stores /etc/nginx/sites-enabled/dub5-stores
rm /etc/nginx/sites-enabled/default

service nginx restart
service postgresql restart
