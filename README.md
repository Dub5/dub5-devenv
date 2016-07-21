# Dub5 Development Environment
------------------------------

Development environment for Dub5 Ruby applications:

- chopeo
- dub5-api

Environment components:

- OS: Ubuntu Trusty Thar 14.04 LTS x64
- Ruby: 2.3 via brightbox packages
- Extras: PostgreSQL, Nginx + Passenger, Redis and Node.js

## Instructions

Please make sure you have installed Vagrant 1.8.4 or later.

### Chopeo

1. vagrant up chopeo
2. visit http://api.lvh.me:3000/store/new to see the app running

That's it! Your project's repos will be clone from github under /vagrant on the guest
machine and shared locally on your host machine.

### Dub5

1. vagrant up dub5
2. It doesn't work yet! Help would be appreciated.


## Caveats

- Don't try to run both boxes at the same time.
- Always specify `vagrant ssh <name>` or set your ssh config up with
  aliases
