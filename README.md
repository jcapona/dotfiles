# Personal environment setup


## Regular Install

```
$ curl -l https://raw.githubusercontent.com/jcapona/dotfiles/master/install.sh | bash
```

or

```
$ wget -O - https://raw.githubusercontent.com/jcapona/dotfiles/master/install.sh | bash
```

## Using Docker

```
$ docker run --rm -it --entrypoint=bash jcapona/devenv:latest
```

or

```
$ docker create --name devenv jcapona/devenv:latest
$ docker start devenv
$ docker exec  -it devenv bash
```