# by aspirin2d
FROM alpine-vim:latest

# User config
ENV UID="1000" \
    UNAME="developer" \
    GID="1000" \
    GNAME="developer" \
    SHELL="/bin/bash" \
    UHOME="/home/developer"
# Used to configure YouCompleteMe
ENV GOROOT="/usr/lib/go"
ENV GOPATH="$UHOME/go"
ENV GOBIN="$GOPATH/bin"
ENV PATH="$PATH:$GOBIN:$GOPATH/bin"
ENV TERM=xterm-256color

# User
RUN apk --no-cache add sudo \
# Create HOME dir
    && mkdir -p "${UHOME}" \
    && mkdir -p "${UHOME}/.vim/bundle" \
    && chown "${UID}":"${GID}" "${UHOME}" \
    && chown "${UID}":"${GID}" "${UHOME}/.vim/bundle" \
# Create user
    && echo "${UNAME}:x:${UID}:${GID}:${UNAME},,,:${UHOME}:${SHELL}" \
    >> /etc/passwd \
    && echo "${UNAME}::17032:0:99999:7:::" \
    >> /etc/shadow \
# No password sudo
    && echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" \
    > "/etc/sudoers.d/${UNAME}" \
    && chmod 0440 "/etc/sudoers.d/${UNAME}" \
# Create group
    && echo "${GNAME}:x:${GID}:${UNAME}" \
    >> /etc/group

COPY .vimrc $UHOME/.vimrc
COPY vimbundle $UHOME/.vim/bundle
COPY go-src/tools $UHOME/go/src/golang.org/x/tools
COPY go-src/github.com $UHOME/go/src/github.com

# Vim plugins deps
RUN apk --no-cache add \
    bash \
    git \
    go \
    musl-dev \
    ncurses-terminfo \
    python \
# YouCompleteMe deps
    && apk add --virtual build-deps \
    build-base \
    cmake \
    llvm \
    perl \
    python-dev \
# vim plugins
# YouCompleteMe compile
    && python $UHOME/.vim/bundle/YouCompleteMe/install.py --gocode-completer \
# go tools install
    && cd $GOPATH/src/golang.org/x/tools/cmd/goimports && go install \
    && cd $GOPATH/src/golang.org/x/tools/cmd/guru && go install \
    && cd $GOPATH/src/github.com/stamblerre/gocode && go install \
# Cleanup
    && apk del build-deps \
    && apk add \
    libxt \
    libx11 \
    libstdc++ \
    && rm -rf \
    $UHOME/.vim/bundle/YouCompleteMe/third_party/ycmd/clang_includes \
    $UHOME/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp \
    $GOPATH/src/* \
    /var/cache/* \
    /var/log/* \
    /var/tmp/* \
    && cd $UHOME && find . | grep "\.git/" | xargs rm -rf \
    && chown -R $UNAME:$GNAME $GOPATH
