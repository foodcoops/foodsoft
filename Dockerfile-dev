FROM ruby:2.3

# Install dependencies
RUN deps='libmagic-dev xvfb qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x' && \
    apt-get update && \
    apt-get install --no-install-recommends -y $deps && \
    rm -Rf /var/lib/apt/lists/* /var/cache/apt/*

ENV PORT=3000 \
    SMTP_SERVER_PORT=2525 \
    RAILS_ENV=development \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    \
    BUNDLE_PATH=/home/app/bundle \
    BUNDLE_APP_CONFIG=/home/app/bundle/config

# Run app and all commands as user 'app'. This avoids changing permissions
# for files in mounted volume. Symlink for similarity with production image.
RUN adduser --gecos GECOS --disabled-password --shell /bin/bash app && \
    ln -s /home/app/src /usr/src/app
USER app

WORKDIR /home/app/src

# Copy files needed for installing gem dependencies, and install them.
COPY Gemfile Gemfile.lock ./
COPY plugins ./plugins
RUN bundle config build.nokogiri "--use-system-libraries" && \
    bundle install -j 4

# Copy the application code
COPY . ./

EXPOSE 3000

# cleanup, and by default start web process from Procfile
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["./proc-start", "web"]
