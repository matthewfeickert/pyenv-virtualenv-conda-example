FROM debian:buster

SHELL ["/bin/bash", "-c"]
USER root

RUN apt-get update -y && \
    apt-get install --no-install-recommends -y \
        make \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        wget \
        curl \
        llvm \
        libncurses5-dev \
        xz-utils \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libffi-dev \
        liblzma-dev && \
    apt-get install -y \
        git \
        g++ && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user "docker"
RUN useradd -m docker && \
   cp /root/.bashrc /home/docker/ && \
   cp /root/.profile /home/docker/ && \
   mkdir /home/docker/data && \
   chown -R --from=root docker /home/docker

USER docker
ENV HOME /home/docker
WORKDIR /home/docker
ENV PATH ${HOME}/.local/bin:$PATH

RUN git clone --depth 1 https://github.com/pyenv/pyenv.git ~/.pyenv && \
    pushd ~/.pyenv && \
    src/configure && \
    make -C src && \
    popd && \
    echo '' >> ~/.bash_profile && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile && \
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile && \
    . ~/.bash_profile && \
    git clone --depth 1 https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv && \
    echo '' >> ~/.bash_profile && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile && \
    echo '' >> ~/.bashrc && \
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc

# Need to setup shell variables in .bash_profile to use pyenv
RUN . "${HOME}/.bash_profile" && \
    pyenv install 3.8.8 && \
    pyenv virtualenv 3.8.8 base && \
    pyenv activate base && \
    pip install --upgrade --no-cache-dir pip setuptools wheel

RUN . "${HOME}/.bash_profile" && \
    pyenv install miniconda3-latest && \
    pyenv shell miniconda3-latest && \
    conda init && \
    conda config --set auto_activate_base false && \
    pyenv virtualenv miniconda3-latest miniconda3-base && \
    pyenv activate miniconda3-base && \
    pip install --upgrade --no-cache-dir pip setuptools wheel

WORKDIR /home/docker/data
ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash"]
