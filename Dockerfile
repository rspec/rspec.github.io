FROM ruby:2.3.5-alpine

RUN apk update

RUN apk add --no-cache imagemagick

# JS runtime
RUN apk add --no-cache nodejs

# For the "json" gem
RUN apk add --no-cache build-base

# To be able to install gems from Github (middleman)
RUN apk add --no-cache git

# For tzinfo
RUN apk add --no-cache tzdata

WORKDIR /var/app
ADD . /var/app


RUN gem install bundler
RUN bundle install

RUN middleman build

EXPOSE 4567

CMD /bin/sh

