#!/bin/sh

apt-get install --yes vim || exit


# APT repositories - doesn't work, add this manually:
# deb http://ppa.launchpad.net/chris-lea/node.js/ubuntu precise main 
#deb-src http://ppa.launchpad.net/chris-lea/node.js/ubuntu precise main 

#apt-get install --yes python-software-properties || exit

#if [ ! -f /etc/apt/sources.list.d/chris-lea-node_js-precise.list ]; then 
#	add-apt-repository ppa:chris-lea/node.js || exit
#fi


# Install nodejs and npm
apt-get install --force-yes --yes nodejs npm || exit

# npm packages actually require some stuff like make and a compiler :/
apt-get install --yes build-essential || exit


