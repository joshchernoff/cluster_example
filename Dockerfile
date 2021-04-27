# FROM hexpm/elixir:1.11.2-erlang-23.1.1-ubuntu-bionic-20200630

# RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
#   DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends build-essential dialog apt-utils gpg-agent \
#   apt-transport-https software-properties-common git curl postgresql-client inotify-tools && \
#   curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
#   apt-get update && apt-get install -y nodejs && \
#   mix local.hex --force && \
#   mix archive.install hex phx_new 1.5.6 --force && \
#   mix local.rebar --force && \
#   apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  
# ENV APP_HOME /app
# RUN mkdir $APP_HOME
# WORKDIR $APP_HOME

# ENV RELEASE_COOKIE asdf
# ENV RELEASE_DISTRIBUTION sname
# ENV SECRET_KEY_BASE 'foobar'
# ENV DATABASE_URL 'ecto://postgres:@localhost/cluster_example_dev'
# ENV MIX_ENV prod
# CMD ["mix", "release"]


FROM elixir:1.9.0-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base npm git python

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod
ENV DATABASE_URL="ecto://postgres:@localhost/cluster_example_dev"
ENV SECRET_KEY_BASE="0iacSYSbi6X4WtsJ5UA7BTYAewnsOJnKjGvtmESKUvMwFoiQgj6X6k4paw6Y59NC"
# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# compile and build release
COPY lib lib
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix do compile, release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/cluster_example ./

ENV HOME=/app

CMD ["bin/cluster_example", "start"]