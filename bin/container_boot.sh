#!/bin/bash
# Private command used by the Docker image to start the middleman server.

bundle install
bundle exec middleman
