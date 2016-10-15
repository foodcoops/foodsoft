# Based on ruby image, packed with a lot of development dependencies
FROM ruby:2.3

# Install all dependencies for development and testing
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      mysql-client \
      libv8-dev \
      libmagic-dev \
      libmysqlclient-dev \
      xvfb \
      iceweasel && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Run app and all commands as user 'app'. This avoids changing permissions
# for files in mounted volume.
RUN adduser --gecos GECOS --disabled-password --shell /bin/bash app
USER app

# Create an directory to store the application code.
RUN mkdir /home/app/src
WORKDIR /home/app/src

# Copy plugins before the rest to allow bundler loading gemspecs
# TODO: Move plugins to gems and add them to Gemfile instead
COPY plugins ./plugins

# Add Gemfiles and run bundle.
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_JOBS=4 BUNDLE_PATH=/home/app/bundle \
    BUNDLE_APP_CONFIG=/home/app/bundle/config
RUN bundle install

# Copy the application code. (Excluded files see .dockerignore)
COPY . ./

EXPOSE 3000

CMD ["rails", "server", "--binding", "0.0.0.0"]
