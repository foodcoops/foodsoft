FROM ruby:2.3

RUN apt-get update && \
    apt-get install --no-install-recommends -y cron && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

ENV RAILS_ENV=production

WORKDIR /usr/src/app
COPY . ./
RUN echo $SOURCE_COMMIT > REVISION

RUN buildDeps='libmagic-dev' && \
    apt-get update && \
    apt-get install --no-install-recommends -y $buildDeps && \
    rm -rf /var/lib/apt/lists/* && \
    bundle install --deployment --without development test && \
    apt-get purge -y --auto-remove $buildDeps && \
    whenever --update-crontab

# Add a temporary mysql-server for assets precompilation
RUN export DATABASE_URL=mysql2://localhost/temp && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y mysql-server && \
    /etc/init.d/mysql start && \
    cp config/app_config.yml.SAMPLE config/app_config.yml && \
    bundle exec rake db:setup && \
    bundle exec rake assets:precompile && \
    rm config/app_config.yml && \
    rm -rf log tmp/* && \
    /etc/init.d/mysql stop && \
    rm -rf /run/mysqld /tmp/* /var/lib/mysql /var/log/mysql* && \
    apt-get purge -y --auto-remove mysql-server && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["rails", "server", "--binding", "0.0.0.0"]
