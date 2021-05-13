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
        liblzma-dev \
        g++ && \
    apt-get install -y \
        git && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user "docker"
# Set shell to Bash to give tab complete
RUN useradd --shell /bin/bash -m docker && \
   cp /root/.bashrc /home/docker/ && \
   cp /root/.profile /home/docker/ && \
   mkdir /home/docker/data && \
   chown -R --from=root docker /home/docker

USER docker
ENV HOME /home/docker
WORKDIR /home/docker

# Install pyenv and pyenv-virtualenv
RUN git clone --depth 1 https://github.com/pyenv/pyenv.git ~/.pyenv && \
    pushd ~/.pyenv && \
    src/configure && \
    make -C src && \
    popd && \
    echo -e '\nexport PYENV_ROOT="${HOME}/.pyenv"' >> ~/.bash_profile && \
    echo 'export PATH="${PYENV_ROOT}/bin:${PATH}"' >> ~/.bash_profile && \
    echo 'eval "$(pyenv init --path)"' >> ~/.bash_profile && \
    . ~/.bash_profile && \
    eval "$(pyenv init -)" && \
    git clone --depth 1 https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv && \
    echo -e '\nif command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\n  eval "$(pyenv virtualenv-init -)"\nfi' >> ~/.bash_profile && \
    echo -e '\nif command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\n  eval "$(pyenv virtualenv-init -)"\nfi' >> ~/.bashrc

# Need to setup shell variables in .bash_profile to use pyenv
# Install Python 3.8, miniconda, and create virtual environments in both
# c.f. https://stackoverflow.com/a/58045893/8931942
ENV PYTHON_VERSION 3.8.8
ENV CONDA_VERSION miniconda3-latest
RUN . "${HOME}/.bash_profile" && \
    echo "Install Python ${PYTHON_VERSION}" && \
    pyenv install "${PYTHON_VERSION}" && \
    pyenv virtualenv "${PYTHON_VERSION}" base && \
    pyenv activate base && \
    python -m pip install --upgrade --no-cache-dir pip setuptools wheel && \
    pyenv deactivate && \
    echo "Install miniconda" && \
    pyenv install "${CONDA_VERSION}" && \
    pyenv shell "${CONDA_VERSION}" && \
    conda init && \
    conda config --set auto_activate_base false && \
    pyenv virtualenv "${CONDA_VERSION}" miniconda3-base && \
    pyenv activate miniconda3-base && \
    python -m pip install --upgrade --no-cache-dir pip setuptools wheel

WORKDIR /home/docker/data
ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash"]
