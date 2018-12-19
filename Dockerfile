FROM ubuntu
# set timezone
ENV TZ 'Asia/Shanghai'
RUN echo $TZ > /etc/timezone && \
apt-get update && apt-get install -y tzdata && \
rm /etc/localtime && \
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
dpkg-reconfigure -f noninteractive tzdata && \
apt-get clean

# install zsh
RUN apt-get install zsh -y

# install git and wget
RUN apt-get install wget git -y

# install sudo
RUN apt-get install sudo

# add user: dev
RUN adduser --disabled-password --gecos '' dev
RUN adduser dev sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER dev

# install oh-my-zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
CMD ['zsh']

# install golang
RUN sudo apt-get install golang-go -y
RUN mkdir ~/go
RUN mkdir ~/go/pkg ~/go/bin ~/go/src

# set gopath
ENV GOPATH /home/dev/go
ENV PATH /home/dev/go/bin:$PATH

# install golang dep
RUN sudo apt-get install curl -y
RUN go get -u github.com/golang/dep/cmd/dep

RUN git clone --depth=1 https://github.com/golang/tools.git $GOPATH/src/golang.org/x/tools && \
    git clone --depth=1 https://github.com/golang/net.git $GOPATH/src/golang.org/x/net && \
    git clone --depth=1 https://github.com/golang/lint.git $GOPATH/src/golang.org/x/lint

RUN go get -v github.com/klauspost/asmfmt/cmd/asmfmt
RUN go get -v github.com/derekparker/delve/cmd/dlv
RUN go get -v github.com/kisielk/errcheck
RUN go get -v github.com/davidrjenni/reftools/cmd/fillstruct
RUN go get -v github.com/mdempsky/gocode
# RUN go get -v github.com/stamblerre/gocode 
RUN go get -v github.com/rogpeppe/godef
RUN go get -v github.com/zmb3/gogetdoc
RUN go get -v golang.org/x/tools/cmd/goimports
RUN go get -v golang.org/x/lint/golint
RUN go get -v github.com/alecthomas/gometalinter
RUN go get -v github.com/fatih/gomodifytags
RUN go get -v golang.org/x/tools/cmd/gorename
RUN go get -v github.com/jstemmer/gotags
RUN go get -v golang.org/x/tools/cmd/guru
RUN go get -v github.com/josharian/impl
RUN go get -v honnef.co/go/tools/cmd/keyify
RUN go get -v github.com/fatih/motion
RUN go get -v github.com/koron/iferr

# COPY --chown=dev my_configs.vim /home/dev/.vim_runtime/my_configs.vim
# install vim
RUN sudo apt-get install vim-nox -y
RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# custom vimrc
RUN git clone https://github.com/sleep2death/vimrc.git ~/vimrc
RUN cp ~/vimrc/.vimrc ~/.vimrc

# install plugin
RUN vim +PluginInstall +GoInstallBinaries +qall

# Compile Ycm
RUN sudo apt install build-essential cmake python3-dev -y
WORKDIR /home/dev/.vim/bundle/YouCompleteMe/
RUN sudo apt-get install build-essential cmake python3-dev
RUN python3 install.py --go-completer

WORKDIR /home/dev/go/src/
