FROM gitpod/workspace-full
USER gitpod

# Install custom tools, runtime, etc.
RUN sudo apt-get update \
    && sudo apt-get install -y libmagic-dev \
    && sudo rm -rf /var/lib/apt/lists/* \
    && bash -lc "rvm reinstall 2.6.9 && rvm use 2.6.9--default && gem install bundler"
    
      