# Install dependencies (including the use of secret token
# Commented Old image reference below
# FROM ruby:3.2.3-alpine3.19 as all-os-packages
FROM docker-virtual.oneartifactoryci.verizon.com/ruby:3.2.3-alpine3.19 AS all-os-packages
USER root
WORKDIR /app

## Gem dependencies
RUN apk --no-cache --virtual build-dependencies add \
    autoconf \
    automake \
    build-base \
    gcompat \
    libpq-dev \
    libtool \
    oniguruma-dev \
    postgresql-client

# Install gems for PROD
FROM all-os-packages AS prod-gems
USER root
WORKDIR /app
COPY Gemfile* /app/
RUN gem install bundler:2.5.6 && \
    bundle config set without test development && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle install --jobs $(nproc)

# Install minimum OS packages needed for runtime
FROM docker-virtual.oneartifactoryci.verizon.com/ruby:3.2.3-alpine3.19 AS runtime-os-packages
USER root
RUN apk --no-cache --virtual build-dependencies add \
    gcompat \
    build-base \
    libpq-dev \
    oniguruma-dev \
    postgresql-client \
    git \
    tzdata \
    wget \
    rsync

RUN git config --global user.email "donotreply@verizon.com" && git config --global user.name "Learning Album Deployment"

# Output image: run the app
FROM runtime-os-packages AS publisher-app
USER root
WORKDIR /app

COPY . /app/

RUN chmod +x /app/bin/*

COPY --from=prod-gems /usr/local/bundle /usr/local/bundle
COPY --from=prod-gems /root/.bundle /root/.bundle

RUN mv .deploy/assets/config/secrets.yml config/secrets.yml

# Create a folder so we can create softlinks
RUN mkdir -p /persistent-storage/public/{albums,api,archives,uploads}

# Create the softlinks
RUN ln -s /persistent-storage/public/albums public/albums && \
    ln -s /persistent-storage/public/api public/api && \
    ln -s /persistent-storage/public/archives public/archives && \
    ln -s /persistent-storage/public/uploads public/uploads && \
    rm -r /persistent-storage/public/{albums,api,archives,uploads} # Destroy the folder we created, because this will be mounted in EKS from EFS

RUN chown -R 1000 .
USER 1000

ARG LISTEN_PORT=5555
ENV PORT=${LISTEN_PORT}
ENV RAILS_ENV=production
ENV ENABLE_PUBLIC_FILE_SERVER=false
ENV DISABLE_SSL_REDIRECT=true

EXPOSE ${PORT}
