# Alpine w/ glibc
FROM frolvlad/alpine-glibc

ENV CALIBRE_HOME=/
ENV CALIBRE_CONFIG_DIRECTORY=/tmp
ENV UPDATE_CALIBRE=False
ENV JOBS_FILE=jobs.lst

# Install dependencies
RUN apk update && \
    apk add --no-cache --upgrade \
    bash \
    unrar \
    curl \
    ruby \
    ruby-dev \
    ca-certificates \
    python \
    wget \
    gcc \
    make \
    libc-dev \
    mesa-gl \
    imagemagick \
    poppler-utils \
    qt5-qtbase-x11 \
    xdg-utils \
    xz

# Install ruby gems
RUN gem install escape fileutils --no-document

# Install Supercronic
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.8/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=be43e64c45acd6ec4fce5831e03759c89676a0ea

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod a+x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Scripts
WORKDIR /etc/maid/
ADD maid/ /etc/maid/
RUN chmod 755 *.sh

# First-time Calibre install and grant rights
RUN ./install_calibre.sh
RUN chmod -R a+rwx $CALIBRE_HOME/calibre

# Bootstrap
CMD ./run.sh
