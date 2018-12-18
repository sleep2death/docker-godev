FROM ubuntu

# set timezone
ENV TZ 'Asia/Shanghai'
RUN echo $TZ > /etc/timezone && \
apt-get update && apt-get install -y tzdata && \
rm /etc/localtime && \
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
dpkg-reconfigure -f noninteractive tzdata && \
apt-get clean

# install vim
RUN apt-get install vim-nox -y

# install zsh
RUN apt-get install zsh -y

# install git and wget
RUN apt-get install wget git -y

# install oh-my-zsh

RUN apt-get install sudo

RUN adduser --disabled-password --gecos '' dev
RUN adduser dev sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER dev

# custom vimrc
RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
RUN sh ~/.vim_runtime/install_awesome_vimrc.sh
RUN git clone https://github.com/Shougo/neocomplete.vim.git ~/.vim_runtime/my_plugins/neocomplete.vim
RUN git clone https://github.com/itchyny/vim-gitbranch.git ~/.vim_runtime/my_plugins/vim-gitbranch
COPY --chown=dev my_configs.vim /home/dev/.vim_runtime/my_configs.vim

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
CMD ['zsh']

# install go
RUN sudo apt-get install golang-go -y
RUN mkdir ~/go
RUN mkdir ~/go/pkg ~/go/bin ~/go/src

# set gopath
ENV GOPATH /home/dev/go
ENV PATH /home/dev/go/bin:$PATH

# install golang dep
RUN sudo apt-get install curl -y
RUN go get -u github.com/golang/dep/cmd/dep

RUN go get -d -v github.com/klauspost/asmfmt/cmd/asmfmt
RUN go get -d -v github.com/derekparker/delve/cmd/dlv
RUN git clone https://github.com/golang/tools.git $GOPATH/src/golang.org/x/tools
RUN go get -d -v github.com/kisielk/errcheck
RUN go get -d -v github.com/davidrjenni/reftools/cmd/fillstruct
RUN go get -d -v github.com/mdempsky/gocode
RUN go get -d -v github.com/stamblerre/gocode
RUN go get -d -v github.com/rogpeppe/godef
RUN go get -d -v github.com/zmb3/gogetdoc
RUN go get -d -v golang.org/x/tools/cmd/goimports
RUN git clone https://github.com/golang/lint.git $GOPATH/src/golang.org/x/lint
RUN go get -d -v github.com/alecthomas/gometalinter
RUN go get -d -v github.com/fatih/gomodifytags
RUN go get -d -v golang.org/x/tools/cmd/gorename
RUN go get -d -v github.com/jstemmer/gotags
RUN go get -d -v golang.org/x/tools/cmd/guru
RUN go get -d -v github.com/josharian/impl
RUN go get -d -v honnef.co/go/tools/cmd/keyify
RUN go get -d -v github.com/fatih/motion
RUN go get -d -v github.com/koron/iferr

WORKDIR /home/dev/go/src/golang.org/x/lint/golint
RUN go install
WORKDIR /home/dev/go/src/golang.org/x/tools/cmd/goimports
RUN go install
WORKDIR /home/dev/go/src/golang.org/x/tools/cmd/gorename
RUN go install
WORKDIR /home/dev/go/src/golang.org/x/tools/cmd/guru
RUN go install

WORKDIR /home/dev/go/src/
