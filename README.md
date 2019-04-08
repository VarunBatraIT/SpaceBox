## SpaceVim in Docker

Tested and working:

- Golang Hints
- PHP Hints
- JavaScript hints
- TypeScript Hints
- GitGutter
- Clipboard (If you mount as suggested)


## Usage

```
alias vbox='docker run -ti -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -e TMPDIR="/tmp/" -e TERM=xterm -e GIT_USERNAME="Varun Batra" -e GIT_EMAIL="codevarun@gmail.com"  --rm -v /etc/timezone:/etc/timezone:ro -v $HOME/tmp/:/tmp/ -v ~/.ssh:/home/spacevim/.ssh -v $(pwd):/home/spacevim/src varunbatrait/spacebox'
```

## Note for GoLang

Please make sure that you are running vbox in $GOPATH 
