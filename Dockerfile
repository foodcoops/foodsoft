FROM ruby:2.3

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      cron \
      libv8-dev \
      libmagic-dev \
      libmysqlclient-dev && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

ENV RAILS_ENV=production

WORKDIR /usr/src/app
COPY . ./
RUN bundle install --without development --without test && \
    whenever --update-crontab

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["rails", "server", "--binding", "0.0.0.0"]
