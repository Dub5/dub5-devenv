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
=======
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
