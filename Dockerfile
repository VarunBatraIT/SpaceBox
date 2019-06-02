FROM python:3.6.5-stretch

ENV DEBIAN_URL "http://ftp.us.debian.org/debian"

RUN echo "deb $DEBIAN_URL testing main contrib non-free" >> /etc/apt/sources.list \
  && apt-get update                                             \
  && apt-get install -y                                         \
    autoconf                                                    \
    automake                                                    \
    cmake                                                       \
    fish                                                        \
    g++                                                         \
    gettext                                                     \
    git                                                         \
    libtool                                                     \
    libtool-bin                                                 \
    lua5.3                                                      \
    ninja-build                                                 \
    pkg-config                                                  \
    unzip                                                       \
    xclip                                                       \
    xfonts-utils                                                \
    exuberant-ctags                                             \
  && apt-get clean all

RUN cd /usr/src                                                 \
  && git clone --branch v0.3.4 https://github.com/neovim/neovim.git             \
  && cd neovim                                                  \
  && make CMAKE_BUILD_TYPE=RelWithDebInfo                       \
          CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local" \
  && make install                                               \
  && rm -r /usr/src/neovim


ENV HOME /home/spacevim

RUN groupdel users                                              \
  && groupadd -r -g 1000                                        \
              spacevim                                          \
  && useradd --create-home --home-dir $HOME                     \
             -u 1000                                     \
             -r -g spacevim                                     \
             spacevim


ENV UNAME="spacevim"

RUN apt-get install sudo -y
RUN usermod -aG sudo spacevim
RUN usermod -aG root spacevim
# No password sudo
RUN touch "/etc/sudoers.d/${UNAME}"
RUN echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" \
    > "/etc/sudoers.d/${UNAME}"
RUN chmod 0440 "/etc/sudoers.d/${UNAME}"

# Install PHP
USER spacevim

WORKDIR /tmp
RUN sudo apt-get install -y php php-json php-mbstring php-common php-xml php-tokenizer php-curl php-xml php-msgpack \
    && php -r "copy('https://getcomposer.org/download/1.8.4/composer.phar', 'composer.phar');" \
    && php -r "if (hash_file('sha256', 'composer.phar') === '1722826c8fbeaf2d6cdd31c9c9af38694d6383a0f2bf476fe6bbd30939de058a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer.phar'); } echo PHP_EOL;" \
    && chmod +x composer.phar \
    && sudo mv composer.phar /usr/local/bin/composer
# Install Node
RUN sudo apt-get install -y nodejs
RUN sudo apt-get install -y npm
# Install Node Related
RUN sudo npm cache clean -f
RUN chown $USER:spacevim -R /home/spacevim/
RUN sudo chown spacevim:spacevim -R /usr/local/lib
RUN sudo npm i -g npm@latest
RUN sudo npm install --unsafe-perm -g sqlite3@4.0.6
RUN sudo npm -g install --unsafe-perm typescript tslint eslint prettier javascript-typescript-langserver vscode-css-languageserver-bin bash-language-server purescript-language-server import-js eslint-plugin-prettier vscode-html-languageserver-bin
RUN sudo npm cache clean --force
# Install Go
RUN sudo apt-get install -y golang
# PIP more
RUN pip install --user python-language-server


WORKDIR $HOME
ENV PATH "$HOME/.local/bin:${PATH}"

RUN mkdir -p $HOME/.config $HOME/.SpaceVim.d

RUN pip install --user neovim pipenv

RUN sudo apt-get update -y 
      
# Install clipboard support
RUN sudo apt-get install -y xclip latexmk xsel

RUN sudo npm install -g neovim

COPY init.toml $HOME/.SpaceVim.d/init.toml

RUN git clone https://github.com/SpaceVim/SpaceVim.git $HOME/.SpaceVim && cd $HOME/.SpaceVim && git checkout tags/v1.1.0

RUN curl -sLf https://spacevim.org/install.sh | bash

RUN sudo apt-get install -y cscope


ENV UHOME="/home/spacevim"
ENV GOROOT="/usr/lib/go"
ENV GOBIN="$GOROOT/bin"
ENV GOPATH="$UHOME/src"
ENV PATH="$PATH:$GOBIN:$GOROOT:$GOPATH/bin"
RUN mkdir -p $GOBIN
RUN sudo chmod 770 $GOBIN

    # Go requirements
RUN go get -v -u -d github.com/klauspost/asmfmt/cmd/asmfmt \
    && go build -o $GOBIN/asmfmt github.com/klauspost/asmfmt/cmd/asmfmt \
    && go get -v -u -d github.com/go-delve/delve/cmd/dlv \
    && go build -o $GOBIN/dlv github.com/go-delve/delve/cmd/dlv \
    && go get -v -u -d github.com/kisielk/errcheck \
    && go build -o $GOBIN/errcheck github.com/kisielk/errcheck \
    && go get -v -u -d github.com/davidrjenni/reftools/cmd/fillstruct \
    && go build -o $GOBIN/fillstruct github.com/davidrjenni/reftools/cmd/fillstruct \
    && go get -v -u -d github.com/rogpeppe/godef \
    && go build -o $GOBIN/godef github.com/rogpeppe/godef \
    && go get -v -u -d github.com/zmb3/gogetdoc \
    && go build -o $GOBIN/gogetdoc github.com/zmb3/gogetdoc \
    && go get -v -u -d golang.org/x/tools/cmd/goimports \
    && go build -o $GOBIN/goimports golang.org/x/tools/cmd/goimports \
    && go get -v -u -d golang.org/x/lint/golint \
    && go build -o $GOBIN/golint golang.org/x/lint/golint \
    && go get -v -u -d golang.org/x/tools/cmd/gopls \
    && go build -o $GOBIN/gopls golang.org/x/tools/cmd/gopls \
    && go get -v -u -d github.com/alecthomas/gometalinter \
    && go build -o $GOBIN/gometalinter github.com/alecthomas/gometalinter \
    && go get -v -u -d github.com/fatih/gomodifytags \
    && go build -o $GOBIN/gomodifytags github.com/fatih/gomodifytags \
    && go get -v -u -d golang.org/x/tools/cmd/gorename \
    && go build -o $GOBIN/gorename golang.org/x/tools/cmd/gorename \
    && go get -v -u -d github.com/jstemmer/gotags \
    && go build -o $GOBIN/gotags github.com/jstemmer/gotags \
    && go get -v -u -d golang.org/x/tools/cmd/guru \
    && go build -o $GOBIN/guru golang.org/x/tools/cmd/guru \
    && go get -v -u -d github.com/josharian/impl \
    && go build -o $GOBIN/impl github.com/josharian/impl \
    && go get -v -u -d honnef.co/go/tools/cmd/keyify \
    && go build -o $GOBIN/keyify honnef.co/go/tools/cmd/keyify \
    && go get -v -u -d github.com/fatih/motion \
    && go build -o $GOBIN/motion github.com/fatih/motion \
    && go get -v -u -d github.com/koron/iferr \
    && go build -o $GOBIN/iferr github.com/koron/iferr \
    && go get -v -u -d github.com/stamblerre/gocode \
    && go build -o $GOBIN/gocode github.com/stamblerre/gocode \
    && go get -v -u -d github.com/sourcegraph/go-langserver \
    && go build -o $GOBIN/go-langserver github.com/sourcegraph/go-langserver

RUN curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s -- -b $(go env GOPATH)/bin v1.16.0

RUN wget https://github.com/git-time-metric/gtm/releases/download/v1.3.5/gtm.v1.3.5.linux.tar.gz && tar -xvzf gtm.v1.3.5.linux.tar.gz && sudo mv gtm /usr/local/bin && rm gtm.v1.3.5.linux.tar.gz

RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install && sudo cp ~/.fzf/bin/fzf /usr/local/bin/

RUN nvim --headless +'call dein#install()' +qall
ENV GOPATH="$GOPATH:$UHOME/src/src:$UHOME/src/src/vendor"
RUN mkdir -p $HOME/.SpaceVim.d/autoload/

RUN pip install --user pyaml
RUN sudo apt-get install -y tidy && sudo apt-get install --reinstall -y wamerican wbritish

COPY myspacevim_before.vim $HOME/.SpaceVim.d/autoload/
COPY myspacevim_after.vim $HOME/.SpaceVim.d/autoload/

COPY run $UHOME/
RUN touch ~/.viminfo
RUN chmod o+w ~/.viminfo
ENTRYPOINT ["sh", "/home/spacevim/run"]

