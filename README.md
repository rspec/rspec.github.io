rspec-website
=============

Source for rspec.info.

Requires a recent version of Ruby (> 2.1.x, tested on 2.5.3), bundler and imagemagick (to generate favicons).

## Setup

* `brew install imagemagick`
* `bundle install`
* `middleman build`

## Developing

* `middleman server`

## Deploying

* `middleman deploy` (for http://rspec-staging.github.io/)
* `TARGET=prod middleman deploy` (for http://rspec.info/)
