FROM elixir:1.10.3

RUN apt-get update \
    && apt-get -qq -y install apt-transport-https \
    && echo "deb https://deb.nodesource.com/node_12.x stretch main" >> /etc/apt/sources.list \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >> /etc/apt/sources.list \
    && wget -qO --no-check-certificate - "https://www.postgresql.org/media/keys/ACCC4CF8.asc" | apt-key add - \
    && wget -qO --no-check-certificate - "https://deb.nodesource.com/gpgkey/nodesource.gpg.key" | apt-key add - \
    && apt-get update \
    && apt-get -qq -y install inotify-tools netcat postgresql-client build-essential git ffmpeg libavformat-dev libavcodec-dev libswscale-dev nodejs libmagic-dev libpng-dev gifsicle optipng libjpeg-progs librsvg2-bin

ADD https://api.github.com/repos/booru/cli_intensities/git/refs/heads/master /tmp/cli_intensities_version.json
RUN git clone https://github.com/booru/cli_intensities /tmp/cli_intensities \
    && cd /tmp/cli_intensities \
    && make install

ADD https://api.github.com/repos/booru/mediatools/git/refs/heads/master /tmp/mediatools_version.json
RUN git clone https://github.com/booru/mediatools /tmp/mediatools \
    && cd /tmp/mediatools \
    && make install

ADD https://s3.amazonaws.com/rebar3/rebar3 /usr/local/bin/rebar3
RUN chmod +x /usr/local/bin/rebar3

COPY docker/app/safe-rsvg-convert /usr/local/bin/safe-rsvg-convert

ENV MIX_ENV=prod

WORKDIR /srv/
RUN useradd -d /srv/ -r -s /bin/nologin -u 200 -U philomena
RUN chown philomena:philomena /srv/
USER 200
COPY --chown=200:200 ./mix.exs /srv/philomena/mix.exs
COPY --chown=200:200 ./mix.lock /srv/philomena/mix.lock
COPY --chown=200:200 ./assets/package.json /srv/philomena/assets/package.json
COPY --chown=200:200 ./assets/package-lock.json /srv/philomena/assets/package-lock.json
RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /srv/philomena/assets
RUN npm install
WORKDIR /srv/philomena
RUN mix deps.get
RUN mix deps.compile

COPY --chown=200:200 . /srv/philomena
WORKDIR /srv/philomena/assets
RUN npm run deploy
WORKDIR /srv/philomena
RUN mix compile
RUN mix phx.digest
RUN mix release

COPY --chown=200:200 docker/app/run-prod /bin/run-prod
COPY --chown=200:200 docker/app/run-development /bin/run-development

RUN mkdir -p /srv/philomena/priv/static/system/images

CMD /bin/run-prod
