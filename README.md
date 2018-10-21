rspec-website
=============

Source for [rspec.info](http://rspec.info/).

## Setup

### Using Docker

* `docker build . -t rspec.info`
* `docker run -p 4567:4567 rspec.info`

### Manual setup

Requires a recent version of Ruby (2.1.x), bundler and imagemagick (to generate favicons).

* `brew install imagemagick`
* `bundle install`
* `middleman build`

## Developing

* `middleman server`

## Deploying

* `middleman deploy` (for http://rspec-staging.github.io/)
* `TARGET=prod middleman deploy` (for http://rspec.info/)
