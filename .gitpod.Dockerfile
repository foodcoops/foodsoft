FROM gitpod/workspace-full
USER gitpod

# Install custom tools, runtime, etc.
RUN sudo apt-get update \
    && sudo apt-get install -y libmagic-dev \
    && sudo rm -rf /var/lib/apt/lists/* \
    && printf "rvm_gems_path=/home/gitpod/.rvm\n" > ~/.rvmrc \
    && bash -lc "rvm reinstall 2.6.9 && rvm use 2.6.9 --default && gem install bundler" \
    && printf "rvm_gems_path=/workspace/.rvm" > ~/.rvmrc \
    && printf '{ rvm use $(rvm current); } >/dev/null 2>&1\n' >> "$HOME/.bashrc.d/70-ruby"