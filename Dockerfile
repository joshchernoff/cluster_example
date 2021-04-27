FROM elixir:1.11.4-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base npm git python2

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod
ENV DATABASE_URL="ecto://postgres:foobar@db/cluster_example_dev"
ENV SECRET_KEY_BASE="0iacSYSbi6X4WtsJ5UA7BTYAewnsOJnKjGvtmESKUvMwFoiQgj6X6k4paw6Y59NC"
ENV COOKIE="foobar"
ENV ERL_DIST_PORT=8001

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
COPY rel rel
RUN mix do compile, release

# prepare release image
FROM alpine:3.9 AS app

RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/cluster_example /app
COPY --from=build --chown=nobody:nobody /app/priv/cert /app

USER nobody:nobody

CMD ["bin/cluster_example", "start"]