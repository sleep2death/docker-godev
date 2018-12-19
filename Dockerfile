# by aspirin2d
FROM alpine:latest as builder

MAINTAINER aspirin2d <sleep2death@gmail.com>

# Thanks for MaYun Baba
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

WORKDIR /tmp

# Install dependencies
RUN apk add --no-cache \
    build-base \
    ctags \
    git \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    make \
    ncurses-dev \
    python \
    python-dev

# Build vim from git source
RUN git clone --depth=1 https://github.com/vim/vim \
 && cd vim \
 && ./configure \
    --disable-gui \
    --disable-netbeans \
    --enable-multibyte \
    --enable-pythoninterp \
    --with-features=big \
    --with-python-config-dir=/usr/lib/python2.7/config \
 && make install

 FROM alpine:latest

# Thanks for MaYun Baba
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

COPY --from=builder /usr/local/bin/ /usr/local/bin
COPY --from=builder /usr/local/share/vim/ /usr/local/share/vim/
# NOTE: man page is ignored

RUN apk add --no-cache \
diffutils \
libice \
libsm \
libx11 \
libxt \
ncurses

# User config
ENV UID="1000" \
    UNAME="developer" \
    GID="1000" \
    GNAME="developer" \
    SHELL="/bin/bash" \
    UHOME=/home/developer

# Used to configure YouCompleteMe
ENV GOROOT="/usr/lib/go"
ENV GOBIN="$GOROOT/bin"
ENV GOPATH="$UHOME/workspace"
ENV PATH="$PATH:$GOBIN:$GOPATH/bin"

# User
RUN apk --no-cache add sudo \
# Create HOME dir
    && mkdir -p "${UHOME}" \
    && chown "${UID}":"${GID}" "${UHOME}" \
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

# Vim plugins deps
RUN apk --update add \
    bash \
    ctags \
    curl \
    git \
    ncurses-terminfo \
    python \
# YouCompleteMe
    && apk add --virtual build-deps \
    build-base \
    cmake \
    go \
    llvm \
    perl \
    python-dev \
    && git clone --depth 1  https://github.com/Valloric/YouCompleteMe \
    $UHOME/.vim/bundle/YouCompleteMe/ \
    && cd $UHOME/.vim/bundle/YouCompleteMe \
    && git submodule update --init --recursive \
    && $UHOME/.vim/bundle/YouCompleteMe/install.py --gocode-completer \

# Cleanup
    && apk del build-deps \
    && apk add \
    libxt \
    libx11 \
    libstdc++ \
    && rm -rf \
    $UHOME/.vim/bundle/YouCompleteMe/third_party/ycmd/clang_includes \
    $UHOME/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp \
    /usr/lib/go \
    /var/cache/* \
    /var/log/* \
    /var/tmp/* \
    && mkdir /var/cache/apk

# copy .vimrc
# USER $UNAME
COPY .vimrc $UHOME/.vimrc
# RUN sudo chown -R developer:developer /home/developer/ \
RUN mkdir -p $UHOME/.vim/bundle \
    && cd $UHOME/.vim/bundle \
    && git clone --depth=1 https://github.com/VundleVim/Vundle.vim \
    && git clone --depth=1 https://github.com/scrooloose/nerdtree \
    && git clone --depth=1 https://github.com/xuyuanp/nerdtree-git-plugin \
    && git clone --depth=1 https://github.com/tpope/vim-surround \
    && git clone --depth=1 https://github.com/altercation/vim-colors-solarized \
    && git clone --depth=1 https://github.com/kien/ctrlp.vim \
    && git clone --depth=1 https://github.com/tpope/vim-commentary \
    && git clone --depth=1 https://github.com/itchyny/lightline.vim
    # && vim +PluginInstall +qall

USER $UNAME
WORKDIR $UHOME/workspace
