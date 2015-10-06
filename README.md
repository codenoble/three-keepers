Three Keepers
=============

[![Build Status](https://travis-ci.org/biola/three-keepers.svg)](https://travis-ci.org/biola/three-keepers)
[![Code Climate](https://codeclimate.com/github/biola/three-keepers/badges/gpa.svg)](https://codeclimate.com/github/biola/three-keepers)

Three Keepers is a front-end interface to the [trogdir-api](https://github.com/biola/trogdir-api) database and the [google-syncinator](https://github.com/biola/google-syncinator) API.

Features
--------

- Lookup Person, Syncinator and Changeset data in Trogdir
- Rerun changesets against a client
- Lookup emails via the google-syncinator API
- Manage email and alias creation, account deprovisioning and exclusions

Requirements
------------

- Ruby
- MongoDB
- Rack compatible web server
- CAS server
- A google-syncinator installation

Installation
------------

```bash
git clone git@github.com:biola/three-keepers.git
cd three-keepers
bundle install
cp config/blazing.yml.example config/blazing.yml
cp config/mongoid.yml.example config/mongoid.yml
cp config/settings.local.yml.example config/settings.local.yml
cp config/newrelic.yml.example config/newrelic.yml
```

Configuration
-------------

- Edit `config/blazing.rb` accordingly
- Edit `config/mongoid.yml` accordingly
- Edit `config/settings.local.yml` accordingly
- Edit `config/newrelic.yml` accordingly

`config/mongoid.yml` should be configured to use the same database as `trogdir-api`.

Testing
-------

Simply run `rspec` to run the automated test suite.

Related Documentation
---------------------

- [blazing](https://github.com/effkay/blazing)
- [turnout](https://github.com/biola/turnout)
- [pinglish](https://github.com/jbarnette/pinglish)

Notes
-----

- A syncinator is basically just a client of [trogdir-api](https://github.com/biola/trogdir-api).
- Syncinators can have change queues that they can query to track changes to Trogdir data.
- Exclusions prevent email accounts from being deprovisioned or reprovisioned

License
-------
[MIT](https://github.com/biola/three-keepers/blob/master/MIT-LICENSE)
