rspec-website
=============

Source for [rspec.info](http://rspec.info/).

## Setup

### Using Docker

Create the machine:
`docker build . -t rspec.info`

Start the server:
`docker run -it -p 4567:4567 rspec.info middleman server`

### Manual setup

Requires a recent version of Ruby (2.1.x), bundler and imagemagick (to generate favicons).

* `brew install imagemagick`
* `bundle install`
* `middleman build`

Start the server:

* `middleman server`

Deploy:

* `middleman deploy` (for http://rspec-staging.github.io/)
* `TARGET=prod middleman deploy` (for http://rspec.info/)
