FROM ruby:2.1-slim

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      mysql-client \
      git \
      make \
      gcc \
      g++ \
      patch \
      libsqlite3-dev \
      libv8-dev \
      libmysqlclient-dev \
      libxml2-dev \
      libxslt1-dev \
      libffi-dev \
      libreadline-dev \
      xvfb \
      iceweasel && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

ENV WORKDIR /usr/src/app

RUN mkdir -p $WORKDIR
WORKDIR $WORKDIR

# Copy plugins before the rest to allow bundler loading gemspecs
# TODO: Move plugins to gems and add them to Gemfile instead
COPY plugins $WORKDIR/plugins

COPY Gemfile $WORKDIR/
COPY Gemfile.lock $WORKDIR/
RUN bundle install --jobs 4

COPY . $WORKDIR

EXPOSE 3000

CMD ["rails", "server"]
