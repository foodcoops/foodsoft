FROM ruby:3.4.7 AS base

RUN supercronicUrl=https://github.com/aptible/supercronic/releases/download/v0.1.3/supercronic-linux-amd64 && \
    supercronicBin=/usr/local/bin/supercronic && \
    supercronicSha1sum=96960ba3207756bb01e6892c978264e5362e117e && \
    curl -fsSL -o "$supercronicBin" "$supercronicUrl" && \
    echo "$supercronicSha1sum  $supercronicBin" | sha1sum -c - && \
    chmod +x "$supercronicBin"

ENV RAILS_ENV=production

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
COPY config/schedule.rb ./config/schedule.rb
COPY plugins/ ./plugins

# install dependencies and generate crontab
RUN buildDeps='libmagic-dev' && \
    apt-get update && \
    apt-get install --no-install-recommends -y $buildDeps && \
    echo 'gem: --no-document' >> ~/.gemrc && \
    gem install bundler -v 2.4.22 && \
    bundle config build.nokogiri "--use-system-libraries" && \
    bundle config set --local without 'test development' && \
    bundle config set --local deployment true && \
    bundle install -j 4 && \
    apt-get purge -y --auto-remove $buildDeps && \
    rm -Rf /var/lib/apt/lists/* /var/cache/apt/* ~/.gemrc ~/.bundle && \
    bundle exec whenever >crontab

# Build swagger openapi docs
FROM base AS swagger

WORKDIR /usr/src/app

COPY . ./

RUN bundle config set --local without 'development' && \
    bundle config set --local with 'test' && \
    bundle install && \
    RAILS_ENV=test DATABASE_URL=nulldb://nohost bundle exec rails rswag

FROM base AS production

ENV PORT=3000 \
    SMTP_SERVER_PORT=2525 \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

WORKDIR /usr/src/app

COPY . ./

# Copy swagger openapi docs
COPY --from=swagger /usr/src/app/swagger ./swagger

# compile assets with temporary mysql server
RUN export SECRET_KEY_BASE=thisisnotimportantnow && \
    apt-get update && \
    apt-get install -y nodejs && \
    cp config/app_config.yml.SAMPLE config/app_config.yml && \
    cp config/database.yml.MySQL_SAMPLE config/database.yml && \
    cp config/storage.yml.SAMPLE config/storage.yml && \
    DATABASE_URL=nulldb://nohost bundle exec rake assets:precompile && \
    rm -Rf tmp/* \
    rm -Rf /var/lib/apt/lists/* /var/cache/apt/*

# Make relevant dirs and files writable for app user
RUN mkdir -p tmp storage && \
    chown nobody config/app_config.yml && \
    chown nobody tmp && \
    chown nobody storage

# Run app as unprivileged user
USER nobody

EXPOSE 3000

VOLUME /usr/src/app/storage

# cleanup, and by default start web process from Procfile
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["./proc-start", "web"]
