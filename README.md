rspec.github.io
===============

Source for https://rspec.info

Requires a recent version of Ruby (tested on 2.5.3), bundler 1.x and imagemagick (to generate favicons).

## Local Setup

* `brew install imagemagick` (or your package manager of choice).
* `gem install bundler:1.17.3`
* `bundle install`
* `middleman build`

## Local Developing

Run
* `middleman server`

## Docker Setup + Development

If you don't have a local Ruby environment suitable to making changes to rspec.info,
or prefer containerised development; you can find a 3rd party Docker image setup for
this environment here: https://hub.docker.com/r/2performantirina/middleman-and-imagemagick

## Deploying

* `middleman deploy` (for http://rspec-staging.github.io/)
* `TARGET=prod middleman deploy` (for http://rspec.info/)
