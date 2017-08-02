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

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["rails", "server", "--binding", "0.0.0.0"]
