#!/bin/sh

apt-get install --yes vim || exit


# APT repositories - doesn't work, add this manually:
# deb http://ppa.launchpad.net/chris-lea/node.js/ubuntu precise main 
#deb-src http://ppa.launchpad.net/chris-lea/node.js/ubuntu precise main 
#deb http://ppa.launchpad.net/chris-lea/nginx-devel/ubuntu precise main 
#deb-src http://ppa.launchpad.net/chris-lea/nginx-devel/ubuntu precise main 

apt-get install --yes python-software-properties software-properties-common || exit

if [ ! -f /etc/apt/sources.list.d/chris-lea-nginx-devel-quantal.list ]; then 
	add-apt-repository ppa:chris-lea/nginx-devel || exit
fi

if [ ! -f /etc/apt/sources.list.d/chris-lea-node_js-quantal.list ]; then 
	add-apt-repository ppa:chris-lea/node.js || exit
fi

# Install nginx, remove default site, set up our SSL redirect
apt-get install --yes nginx || exit
rm -f /etc/nginx/sites-enabled/default  || exit
ln -sfT /fourcab/live/server/sysconfig/nginx-fourcab-ssl /etc/nginx/sites-enabled/nginx-fourcab-ssl || exit

# Install nodejs and npm
apt-get install --yes nodejs npm || exit

# npm packages actually require some stuff like make and a compiler :/
apt-get install --yes build-essential || exit


