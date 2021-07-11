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
ENV PYENV_RELEASE_VERSION=2.0.3
RUN git clone --depth 1 https://github.com/pyenv/pyenv.git \
        --branch "v${PYENV_RELEASE_VERSION}" \
        --single-branch \
        ~/.pyenv && \
    pushd ~/.pyenv && \
    src/configure && \
    make -C src && \
    popd && \
    sed -i '/^# ~.*/a export PYENV_ROOT="${HOME}/.pyenv"' ~/.profile && \
    sed -i '/^export.*/a export PATH="${PYENV_ROOT}/bin:${PATH}"' ~/.profile && \
    sed -i '/^export PATH.*/a \\n# Place pyenv shims on path\nif [[ ":${PATH}:" != *":$(pyenv root)/shims:"* ]]; then\n  eval "$(pyenv init --path)"\nfi' ~/.profile && \
    printf '\neval "$(pyenv init -)"\n' >> ~/.bashrc && \
    . ~/.profile && \
    git clone --depth 1 https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv && \
    printf '\n# Place pyenv-virtualenv shims on path\nif [[ ":${PATH}:" != *":$(pyenv root)/plugins/pyenv-virtualenv/shims:"* ]]; then\n  eval "$(pyenv virtualenv-init -)"\nfi\n' >> ~/.profile && \
    printf '\n# Place pyenv shims on path\nif [[ ":${PATH}:" != *":$(pyenv root)/shims:"* ]]; then\n  eval "$(pyenv init --path)"\nfi\n' >> ~/.bashrc && \
    printf '# Place pyenv-virtualenv shims on path\nif [[ ":${PATH}:" != *":$(pyenv root)/plugins/pyenv-virtualenv/shims:"* ]]; then\n  eval "$(pyenv virtualenv-init -)"\nfi\n' >> ~/.bashrc && \
    cp ~/.profile ~/.bash_profile && \
    sed -i 's/.profile/.bash_profile/' ~/.bash_profile

# Need to setup shell variables in .bash_profile to use pyenv
# Install Python 3.8, miniconda, and create virtual environments in both
# c.f. https://stackoverflow.com/a/58045893/8931942
ENV PYTHON_VERSION=3.8.11
ENV CONDA_VERSION miniconda3-latest
RUN . "${HOME}/.bash_profile" && \
    echo "Install Python ${PYTHON_VERSION}" && \
    pyenv install "${PYTHON_VERSION}" && \
    pyenv virtualenv "${PYTHON_VERSION}" base && \
    pyenv activate base && \
    python -m pip --no-cache-dir install --upgrade pip setuptools wheel && \
    pyenv deactivate && \
    echo "Install miniconda" && \
    pyenv install "${CONDA_VERSION}" && \
    pyenv shell "${CONDA_VERSION}" && \
    conda init && \
    conda config --set auto_activate_base false && \
    pyenv virtualenv "${CONDA_VERSION}" miniconda3-base && \
    pyenv activate miniconda3-base && \
    python -m pip --no-cache-dir install --upgrade pip setuptools wheel

WORKDIR /home/docker/data
ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash"]
