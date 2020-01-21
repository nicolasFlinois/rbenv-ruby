FROM ubuntu:18.04

MAINTAINER galevsky@gmail.com

ARG RAILS_ENV=development

ENV APT_CONF_FILE "/etc/apt/apt.conf.d/99do-not-use-proxy-cache"
ENV USERNAME "application"
ENV HOMEDIR "/home/${USERNAME}"
ENV DATADIR "/data"
ENV DEBIAN_FRONTEND "noninteractive"
ENV PATH "$HOMEDIR/.rbenv/bin:$PATH"
ENV RAILS_LOG_TO_STDOUT 1


RUN echo 'Acquire::http::Pipeline-Depth 0;' > ${APT_CONF_FILE} \
 && echo 'Acquire::http::No-Cache true;' >> ${APT_CONF_FILE} \
 && echo 'Acquire::BrokenProxy    true;' >> ${APT_CONF_FILE} \
 && apt-get -yq update

RUN apt install -y \
 autoconf \
 bison \
 build-essential \
 curl \
 gcc-5 \
 git \
 libssl-dev \
 libyaml-dev \
 libmysqlclient-dev \
 libreadline6-dev \
 zlib1g-dev \
 libncurses5-dev \
 libffi-dev \
 libgdbm-dev \
 libsqlite3-dev \
 wget

RUN apt-get -qy autoremove \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

RUN useradd --system \
            --user-group \
            --create-home \
            --home-dir ${HOMEDIR} \
            ${USERNAME}

WORKDIR $HOMEDIR

RUN git clone https://github.com/sstephenson/rbenv.git .rbenv \
 && git clone https://github.com/sstephenson/ruby-build.git .rbenv/plugins/ruby-build \
 && chown -R ${USERNAME}:${USERNAME} ${HOMEDIR}
# && ln -s ${HOMEDIR}/.rbenv/bin/rbenv /usr/local/bin/rbenv

RUN echo 'export PATH="$HOMEDIR/.rbenv/bin:$PATH"' >> .bashrc \
 && echo 'eval "$(rbenv init -)"' >> .bashrc \
 && export PATH="${HOMEDIR}/.rbenv/bin:$PATH" \
 && eval "$(rbenv init -)"

USER $USERNAME

RUN  ${HOMEDIR}/.rbenv/bin/rbenv install 2.6.5 \
 &&  ${HOMEDIR}/.rbenv/bin/rbenv global 2.6.5

#RUN find . -type d | xargs chmod a+x \
# && chmod -R a+rw .

ENTRYPOINT "${HOMEDIR}/.rbenv/bin/rbenv"
