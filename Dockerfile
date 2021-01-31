FROM ruby:2.7

RUN apt update && apt upgrade -y && apt install imagemagick nodejs -y

RUN gem update --system
RUN gem install bundler --version 1.17.3

# Helper scripts
COPY bin/container_boot.sh /container_boot.sh
COPY bin/container_build.sh /container_build.sh
RUN chmod +x /container_boot.sh /container_build.sh

EXPOSE 4567

WORKDIR /app
# Store bundle inside tmp dir in project so the bundle is reused between builds
ENV BUNDLE_PATH=/app/tmp/docker/bundle

CMD /container_boot.sh
