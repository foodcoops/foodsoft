FROM ruby:2.7 as base

ENV PORT=3000 \
    SMTP_SERVER_PORT=2525 \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

WORKDIR /usr/src/app

# install dependencies and generate crontab
RUN buildDeps='libmagic-dev nodejs chromium' && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install --no-install-recommends -y $buildDeps && \
    echo 'gem: --no-document' >> ~/.gemrc && \
    gem install bundler && \
    bundle config build.nokogiri "--use-system-libraries"


COPY bin bin
COPY plugins plugins
COPY Gemfile Gemfile.lock docker-entrypoint.sh ./

# Development
FROM base as development
ENV RAILS_ENV=development \
    CHROMIUM_FLAGS=--no-sandbox

RUN bundle install

COPY . ./

# generate api spec file using nulldb adapter
RUN cp config/database.yml.NULLDB_SAMPLE config/database.yml && \
    RAILS_ENV=test DB_ADAPTER=nulldb bundle exec rake rswag:specs:swaggerize && \
    rm config/database.yml

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["./proc-start", "web"]


# Production

FROM base as production

ENV RAILS_ENV=production

RUN supercronicUrl=https://github.com/aptible/supercronic/releases/download/v0.1.3/supercronic-linux-amd64 && \
    supercronicBin=/usr/local/bin/supercronic && \
    supercronicSha1sum=96960ba3207756bb01e6892c978264e5362e117e && \
    curl -fsSL -o "$supercronicBin" "$supercronicUrl" && \
    echo "$supercronicSha1sum  $supercronicBin" | sha1sum -c - && \
    chmod +x "$supercronicBin"

RUN bundle config set deployment 'true' && \
    bundle install --without development test

COPY . ./
COPY --from=development /usr/src/app/swagger/v1/swagger.yaml /usr/src/app/swagger/v1/swagger.yaml

# copy sample configs
RUN cp config/app_config.yml.SAMPLE config/app_config.yml && \
    cp config/database.yml.MySQL_SAMPLE config/database.yml && \
    cp config/storage.yml.SAMPLE config/storage.yml

# precompile assets
RUN SECRET_KEY_BASE=42 bundle exec rake assets:precompile

# Cleanup
RUN apt-get purge -y --auto-remove $buildDeps && \
    rm -Rf tmp/* /var/lib/apt/lists/* /var/cache/apt/* ~/.gemrc ~/.bundle && \
    bundle exec whenever >crontab

# Make relevant dirs and files writable for app user
RUN mkdir -p tmp storage && \
    chown nobody config/app_config.yml && \
    chown nobody tmp && \
    chown nobody storage

# Run app as unprivileged user
USER nobody

EXPOSE 3000

VOLUME /usr/src/app/storage

# by default start web process from Procfile
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["./proc-start", "web"]
