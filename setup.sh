#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Echelon
# Meant for Ubuntu 10.10 or higher and a default base server install
# By Alex Levinson
# ------------------------------------------------------------------------------
# === Things this script does ===
#
# - 1) Installs needed apt packages
# - 2) Installs the latest version of Ruby
# - 3) (X - Edits the Redis server configuration for public listening
# - 4) Installs the Bundler gem
# ------------------------------------------------------------------------------
# ! TODO !
# - Add Dynamic IP Addressing Schemas for different components
# - 
# ------------------------------------------------------------------------------
# Install all the needed apt packages
install_ruby_deps ()
{
       sudo apt-get install build-essential \
                            openssl \
                            libreadline6 \
                            libreadline6-dev \
                            zlib1g \
                            zlib1g-dev \
                            libssl-dev \
                            libyaml-dev \
                            libsqlite3-0 \
                            libsqlite3-dev \
                            sqlite3 \
                            libxml2-dev \
                            libxslt-dev \
                            autoconf \
                            libc6-dev \
                            ncurses-dev \
                            automake \
                            libtool \
                            git-core \
                            curl \
                            htop \
                            libmysqlclient-dev \
                            unzip \
                            zip 
       echo "*** Finished installing apt-get dependencies!"
}
# ------------------------------------------------------------------------------
# Build and install ruby
install_ruby ()
{
       echo "*** Starting Ruby source installation..."
       mkdir temp_ruby_install ; cd temp_ruby_install
       curl -o ruby-latest.tar.gz 'http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p125.tar.gz'
       tar -xzvf ruby-latest.tar.gz
       cd ruby-*
       ./configure
       make
       sudo make install
       cd ../..
       rm -rf temp_ruby_install
       echo "*** Finished installing Ruby!"
}
# ------------------------------------------------------------------------------
# Fix redis port
install_db ()
{
       # !! TODO - No DB Support for Echelon Yet.
       # echo "*** Starting DB installation..."
       # sudo apt-get install redis-server mysql-server
       # TIME=`date`
       # sudo sed -e "1s/example$/example - Edited for Echelon on $TIME/;" \
       #          -e "/^bind/s/^/^# /;" \
       #          -i /etc/redis/redis.conf

       # sudo service redis-server restart
       # echo "*** Finished setting up Redis!"
}
# ------------------------------------------------------------------------------
install_squid ()
{
       echo "*** Starting Squid installation..."
       sudo apt-get install squid3
       # sudo service squid3 restart
       echo "*** Finished setting up Squid!"
       echo "*** !!! Please Read the README inside setup/ for more Squid configuration."
}
# ------------------------------------------------------------------------------
# Install the needed gems
initialize_gem_environment ()
{
       echo "*** Installing Gem and bundler environment..."
       sudo gem install bundler
       bundle install --path vendor/bundle
       # bundle install --binstubs
       echo "*** Finished setting up local gems!"
}
# ------------------------------------------------------------------------------
if [ $# -eq 0 ]; then
       echo "Usage : sudo $0 [full|deps|init]"
       exit
fi
# ------------------------------------------------------------------------------
case "$1" in 
"full")       echo "*** Beginning full setup and configuration..."
              install_ruby_deps
              install_ruby
              # install_db
              install_squid
              initialize_gem_environment
              ;;
"deps")       echo "*** Resolving dependencies..."
              install_ruby_deps
              initialize_gem_environment
              ;;
"init")       echo "*** No installation. Just setting up environment."
              initialize_gem_environment
              ;;
*)            echo "Usage : sudo $0 [full|deps|init]"
              exit
              ;;
esac
# ------------------------------------------------------------------------------
