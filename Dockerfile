FROM ruby:2.3

RUN supercronicUrl=https://github.com/aptible/supercronic/releases/download/v0.1.3/supercronic-linux-amd64 && \
    supercronicBin=/usr/local/bin/supercronic && \
    supercronicSha1sum=96960ba3207756bb01e6892c978264e5362e117e && \
    curl -fsSL -o "$supercronicBin" "$supercronicUrl" && \
    echo "$supercronicSha1sum  $supercronicBin" | sha1sum -c - && \
    chmod +x "$supercronicBin"

ENV PORT=3000 \
    SMTP_SERVER_PORT=2525 \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

WORKDIR /usr/src/app

COPY . ./

# install dependencies and generate crontab
RUN buildDeps='libmagic-dev' && \
    apt-get update && \
    apt-get install --no-install-recommends -y $buildDeps && \
    echo 'gem: --no-document' >> ~/.gemrc && \
    bundle config build.nokogiri "--use-system-libraries" && \
    bundle install --deployment --without development test -j 4 && \
    apt-get purge -y --auto-remove $buildDeps && \
    rm -Rf /var/lib/apt/lists/* /var/cache/apt/* ~/.gemrc ~/.bundle && \
    \
    bundle exec whenever >crontab

# compile assets with temporary mysql server
RUN export DATABASE_URL=mysql2://localhost/temp && \
    export SECRET_KEY_BASE=thisisnotimportantnow && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y mysql-server && \
    /etc/init.d/mysql start && \
    cp config/app_config.yml.SAMPLE config/app_config.yml && \
    bundle exec rake db:setup assets:precompile && \
    rm -Rf config/app_config.yml tmp/* && \
    /etc/init.d/mysql stop && \
    rm -Rf /run/mysqld /tmp/* /var/tmp/* /var/lib/mysql /var/log/mysql* && \
    apt-get purge -y --auto-remove mysql-server && \
    rm -Rf /var/lib/apt/lists/* /var/cache/apt/*

# Make relevant dirs writable for app user
RUN mkdir -p tmp && \
    chown nobody tmp

# Run app as unprivileged user
USER nobody

EXPOSE 3000

# cleanup, and by default start web process from Procfile
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["./proc-start", "web"]
