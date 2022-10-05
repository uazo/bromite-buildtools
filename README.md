# bromite-buildtools

this repo contains my build machine and some scripts I use for Bromite development. the ci uses a modified version of the gihub runner (avaiable [here](https://github.com/uazo/runner)) and use [sysbox](https://github.com/nestybox/sysbox) to improve security. it also contains everything you need to use a self-hosted modified version of [goma](https://github.com/uazo/goma-server) for a multi-machine build

### Setting-up

1. Prepare folders

```
cd ~ && mkdir gh-runner
cd gh-runner && mkdir docker-inner
SYSBOX_UID=$(cat /etc/subuid | grep sysbox | cut -d : -f 2)
sudo chown $SYSBOX_UID:$SYSBOX_UID docker-inner/

mkdir /storage
sudo chown $SYSBOX_UID:$SYSBOX_UID /storage
```

2. Clone this repo
3. Prepare `.env`

```
cd bromite-buildtools/images/github-runner/
cp .env.example .env
```

4. Edit `.env` file

```
RUNNER_NAME=pd-gh-runner
GITHUB_PERSONAL_TOKEN=<git-token>
GITHUB_OWNER=uazo
GITHUB_REPOSITORY=bromite-buildtools
RUNNER_LABELS=dev
ALLOWEDAUTHORSLIST=uazo
```

5. Start the runner
```
cd bromite-buildtools/images/github-runner/
./start-runner.sh
```
