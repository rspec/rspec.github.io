#!/bin/bash
# Private command used by the Docker image to build the middleman site.

set -eu

bundle install
bundle exec middleman build --verbose
