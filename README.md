rspec-website
=============

Source for rspec.info.

Requires a recent version of Ruby (> 2.1.x, tested on 2.5.3), bundler and imagemagick (to generate favicons).

## Local Setup

* `brew install imagemagick` (or your package manager of choice).
* `bundle install`
* `middleman build`

## Install rspec-docs-template yard plugin

This plugin is needed when you run Rakefile command to generate documentation from
`rspec-dev` or `rspec-rails`.

From this repository:

`gem build yard-rspec-docs-template.gemspec`

## Local Developing

Run
* `middleman server`

## Docker Setup + Development

If you don't have a local Ruby environment suitable to making changes to rspec.info,
or prefer containerised development; you can find a 3rd party Docker image setup for
this environment here: https://hub.docker.com/r/2performantirina/middleman-and-imagemagick/ 

## Deploying

* `middleman deploy` (for http://rspec-staging.github.io/)
* `TARGET=prod middleman deploy` (for http://rspec.info/)
