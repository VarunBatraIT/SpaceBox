FROM python:3.7.4-buster
#FROM ubuntu:18.04

ENV DEBIAN_URL "http://ftp.us.debian.org/debian"
ENV UHOME /home/spacevim
ENV UNAME="spacevim"
ENV DEBIAN_FRONTEND=noninteractive
ENV GOROOT="/usr/lib/go"
ENV GOBIN="$GOROOT/bin"
ENV GOPATH="$UHOME/src"
ENV PATH="$PATH:$GOBIN:$GOROOT:$GOPATH/bin"
ENV TZ=Europe/Minsk
ENV PATH=~/.npm-global/bin:$PATH
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN  apt-get update --fix-missing                               \
   && apt-get install --no-install-recommends -y autoconf automake cmake fish g++ gettext git libtool libtool-bin \
    lua5.3 ninja-build pkg-config unzip xclip xfonts-utils exuberant-ctags \
    wamerican wbritish tidy xclip latexmk xsel cscope \
    sudo zlib1g wget curl \
    && apt-get clean all \ 
    && cd /usr/src && git clone --branch v0.3.6 https://github.com/neovim/neovim.git && cd neovim \
    && make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local" \
    && make install && rm -r /usr/src/neovim \
    && groupdel users  && groupadd -r -g 1000  spacevim \
    && useradd --create-home --home-dir $UHOME -u 1000 -r -g spacevim spacevim \
    && usermod -aG sudo spacevim \
    && usermod -aG root spacevim \
# No password sudo
    && touch "/etc/sudoers.d/${UNAME}" \
    && echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${UNAME}" \
    && chmod 0440 "/etc/sudoers.d/${UNAME}"

# Install PHP
USER spacevim

WORKDIR /tmp

RUN wget https://github.com/git-time-metric/gtm/releases/download/v1.3.5/gtm.v1.3.5.linux.tar.gz && tar -xvzf gtm.v1.3.5.linux.tar.gz && sudo mv gtm /usr/local/bin && rm gtm.v1.3.5.linux.tar.gz \
      && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install && sudo cp ~/.fzf/bin/fzf /usr/local/bin/ \
      && sudo apt-get install -y golang \
      && sudo mkdir -p $GOBIN && sudo chmod 770 $GOBIN \
      && sudo mkdir -p $GOROOT && sudo chmod 770 $GOROOT \
   # Go requirements
    && go get -v -u -d github.com/klauspost/asmfmt/cmd/asmfmt \
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
    && go build -o $GOBIN/go-langserver github.com/sourcegraph/go-langserver \
    && curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s -- -b $(go env GOPATH)/bin v1.16.0 \
    # PHP
    #&& sudo apt-get install -y --no-install-recommends  php php-json php-mbstring php-common php-xml php-tokenizer php-curl php-xml php-msgpack php-pear \
    && sudo apt-get install -y php php-json php-mbstring php-common php-xml php-tokenizer php-curl php-xml php-msgpack php-pear \
    && php -r "copy('https://getcomposer.org/download/1.8.4/composer.phar', 'composer.phar');" \
    && php -r "if (hash_file('sha256', 'composer.phar') === '1722826c8fbeaf2d6cdd31c9c9af38694d6383a0f2bf476fe6bbd30939de058a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer.phar'); } echo PHP_EOL;" \
    && chmod +x composer.phar \
    && sudo mv composer.phar /usr/local/bin/composer \
    && composer global require squizlabs/php_codesniffer \
    && composer global require phpmd/phpmd \
    && composer global require vimeo/psalm \
    && sudo pear channel-update pear.php.net \
    && sudo pear install --alldeps PHP_Beautifier-beta \
# Install Node
    && sudo apt-get install --no-install-recommends  -y nodejs npm \
# Install Node Related
    && sudo npm cache clean -f \
    && chown $UNAME:$UNAME -R $UHOME \
    && sudo chown $UNAME:$UNAME -R /usr/local/lib \
    && sudo npm i -g npm@latest \
    && sudo chown $UNAME:$UNAME -R $UHOME \
    && mkdir ~/.npm-global &&  npm config set prefix '~/.npm-global' \
    && npm install --unsafe-perm -g sqlite3@4.0.6 \
    && npm -g install --unsafe-perm typescript tslint eslint prettier javascript-typescript-langserver vscode-css-languageserver-bin bash-language-server purescript-language-server import-js eslint-plugin-prettier vscode-html-languageserver-bin eslint_d typescript-formatter \
    && npm install -g neovim \
    && sudo npm cache clean --force \
# PIP more
#RUN pip install --user python-language-server neovim pipenv pyaml ujson sexpdata websocket-client
    && sudo apt-get install --no-install-recommends  python3-pip python-pip -y \
    && sudo pip  --no-cache-dir install python-language-server neovim pipenv pyaml ujson sexpdata websocket-client \
    && sudo pip3  --no-cache-dir install python-language-server neovim pipenv pyaml ujson sexpdata websocket-client neovim-remote

ENV PATH "$UHOME/.local/bin:${PATH}"
ENV GOPATH="$GOPATH:$UHOME/src/src:$UHOME/src/src/vendor"
ENV PATH="$UHOME/.composer/vendor/bin:${PATH}"
COPY init.toml $UHOME/

RUN mkdir -p $UHOME/.config $UHOME/.SpaceVim.d $UHOME/notebook \
    && git clone --branch 2.0 https://github.com/Shougo/dein.vim.git $HOME/.cache/vimfiles/repos/github.com/Shougo/dein.vim \
    && git clone https://github.com/SpaceVim/SpaceVim.git $UHOME/.SpaceVim && cd $UHOME/.SpaceVim \
    && mv $UHOME/init.toml $UHOME/.SpaceVim.d/init.toml \
#&& git checkout tags/v1.2.0
    && curl -sLf https://spacevim.org/install.sh | bash \
    && mkdir -p $UHOME/.SpaceVim.d/autoload/ && mkdir -p $UHOME/.cache/SpaceVim/cscope/ \
    && sudo chown -R spacevim:spacevim ~/.SpaceVim.d/ \
    && nvim --headless +'call dein#install()' +qall \
    # Clean up
    && sudo chown $UNAME:$UNAME -R /usr/lib/go/bin/ \
    && cd ~/ && find . \( -name ".git" -o -name ".gitignore" -o -name ".gitmodules" -o -name ".gitattributes" \) -exec rm -rf -- {} + \
    && sudo apt-get clean all -y && sudo rm -rf /tmp/*
    #&&  composer clearcache


COPY myspacevim.vim $UHOME/.SpaceVim.d/autoload/
COPY ["Sauce Code Pro Nerd Font Complete Mono Windows Compatible.ttf","/usr/local/share/fonts/"]
COPY ["Sauce Code Pro Nerd Font Complete Mono Windows Compatible.ttf","$UNAME/.local/share/fonts"]
COPY run $UHOME/
RUN touch ~/.viminfo
RUN chmod o+w ~/.viminfo
ENTRYPOINT ["sh", "/home/spacevim/run"]

