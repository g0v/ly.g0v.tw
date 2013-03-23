# SETUP your ly.g0v.tw API endpoint

Basic ideas:

0. Install PostgreSQL
0. Install plv8 PostgreSQL extension
0. Get pgrest & run

## Ubuntu

### PostgreSQL

Add apt.postgresql.org , ref: https://wiki.postgresql.org/wiki/Apt

	sudo apt-get install postgresql-9.2
	sudo apt-get install postgresql-contrib-9.2
	sudo apt-get install postgresql-server-dev-9.2

### plv8

	sudo apt-get install python-pip
	sudo pip install pgxnclient

	sudo apt-get install make g++
	sudo apt-get install libv8-dev

	sudo pgxn install plv8

### Database
	sudo -u postgres createdb ly

## FreeBSD

### Packages

Install ports:

### PostgreSQL
  * databases/postgresql92-server
  * databases/postgresql92-contrib

### plv8
  * databases/py-pgxnclient
  * lang/v8 (install 3.15.10, plv8 does not support building with 3.17.9 at this point.)

	sudo pgxn install plv8
	sudo -u pgsql pgxn load plv8

### Database

/etc/rc.conf

	postgresql_enable="YES"

	sudo /usr/local/etc/rc.d/postgresql initdb
	sudo /usr/local/etc/rc.d/postgresql start
	
	sudo -u pgsql psql -U pgsql postgres
	postgres=# CREATE DATABASE ly;

# load data

Get dumped data from: http://dl.dropbox.com/u/30657009/ly/ly-dump.bz2

	sudo -u pgsql psql -d ly -U pgsql -f ly-dump
or
	bzcat ly-dump.bz2 | sudo -u pgsql psql -d ly -U pgsql

# PgREST

## Install nodejs and npm

### Ubuntu

Install from ppa:chris-lea/node.js

Ref: https://github.com/g0v/twlyparser#to-install-nodejs-and-npm-and-livescript-in-ubunutu

### FreeBSD

Install ports:

  * www/npm

## run PgREST

(old) install Plack-App-PgREST from cpan (https://github.com/clkao/Plack-App-PgREST)

	plackup -Mlib -e "use Plack::App::PgREST; pgrest(q{dbname=ly;port=5432})"

(new)
	git clone https://github.com/clkao/pgrest.git
	cd pgrest
	npm i

	(FreeBSD)
	sudo -u pgsql ./node_modules/.bin/lsc bin/cmd.ls ly --pgsock /tmp
	(Ubuntu)
	sudo -u pgsql ./node_modules/.bin/lsc bin/cmd.ls ly
