print_message () {
    tput setaf $1
    tput bold
    echo $2
    tput sgr0
}

download_repo () {
    if [ ! -d $1 ]; then
        print_message 6 "Cloning repository $2 on directory $1."
        git clone $2 $1
        cd $1
        install_ruby
        create_site $1 $3
    else
        print_message 3 "Repository $2 alread exists."
    fi
}

install_ruby () {
    cwd=$(pwd)
    app_name=$(basename `pwd`)
    ruby_version_file="$cwd/.ruby-version"
    ruby_gemset_file="$cwd/.ruby-gemset"
    if [ -f $ruby_version_file ]; then
        ruby_version=`cat $ruby_version_file`
        source ~/.rvm/scripts/rvm
        rvm install $ruby_version
        if [ -f $ruby_gemset_file ]; then
            ruby_version="$ruby_version@`cat $ruby_gemset_file`"
        fi
        rvm use $ruby_version --create
        gem install --no-document bundler
    fi

}

create_site () {
    if [ -d $1 ]; then
        print_message 6 "Creating site $2 on directory $1."
        site_name=$(basename $1)
        ruby_version_file="$1/.ruby-version"
        ruby_gemset_file="$1/.ruby-gemset"
        if [ -f $ruby_version_file ]; then
            ruby_version=`cat $ruby_version_file`
            if [ -f $ruby_gemset_file ]; then
                ruby_version="$ruby_version@`cat $ruby_gemset_file`"
            fi
            echo "
server {

    listen 3000 default_server;

    server_name www.lvh.me lvh.me;

    client_max_body_size 10M;

    passenger_enabled on;
    passenger_ruby /home/vagrant/.rvm/gems/$ruby_version/wrappers/ruby;

    rails_env development;

    root $1/public;

    # Redirect server error pages to the static page /50x.html
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root html;
    }
}
" | sudo tee /etc/nginx/sites-available/$site_name
            sudo ln -s /etc/nginx/sites-available/$site_name /etc/nginx/sites-enabled/$site_name
            cd $1 ; bundle install
            sudo service nginx restart
            sudo service postgresql restart
        else
            print_message 3 "Can not create site without .ruby-version file in directory."
        fi
    else
        print_message 3 "Site directory $2 does not exist."
    fi
}

echo "Getting all repositories..."

download_repo "/vagrant/dub5" "git@github.com:Dub5/dub5.git"
