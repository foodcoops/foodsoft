FROM gitpod/workspace-full
USER gitpod

# Install custom tools, runtime, etc.
RUN apt-get install -y libmagic-dev \
    && rvm reinstall $(cat .ruby-version) \
    && rvm use $(cat .ruby-version) --default \
    && gem install bundler
      