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

5. Prepare for windows cross build
Follow the [instructions](https://chromium.googlesource.com/chromium/src.git/+/HEAD/docs/win_cross.md#if-you_re-not-at-google) to create the zip with the toolchain

example:
```
cd path\to\depot_tools\win_toolchain
D:\Downloads\depot_tools\win_toolchain> package_from_installed.py --allow_multiple_vs_installs -w 10.0.20348.0 2019
```

create the `/casefold` in the unix host with [casefold attribute](https://unix.stackexchange.com/questions/558977/how-to-enable-new-in-kernel-5-2-case-insensitivity-for-ext4-on-a-given-directory) and unzip the contents into.
```
~$ ls /casefold/10.0.20348.0/ -la
total 36
drwxr-xr-x 8 root root 4096 Oct  5 13:20  .
drwxr-xr-x 5 root root 4096 Oct  5 13:17  ..
drwxr-xr-x 6 root root 4096 Oct  5 13:19 'DIA SDK'
drwxr-xr-x 2 root root 4096 Oct  5 13:20  sys32
drwxr-xr-x 2 root root 4096 Oct  5 13:20  sys64
drwxr-xr-x 2 root root 4096 Oct  5 13:20  sysarm64
drwxr-xr-x 5 root root 4096 Oct  5 13:20  VC
-rw-rw-rw- 1 root root    5 Sep 26 17:05  VS_VERSION
drwxr-xr-x 3 root root 4096 Oct  5 13:20 'Windows Kits'
```

6. Start the runner
```
cd bromite-buildtools/images/github-runner/
./start-runner.sh
```

### Test Android Version

Simply download latest build on https://github.com/uazo/bromite-buildtools/releases/latest

### Test Windows Version

1. Download https://github.com/henrypp/chrlauncher/releases
2. Create a `chrlauncher.ini`

```
[chrlauncher]

# Custom Chromium update URL (string):
ChromiumUpdateUrl=https://github.com/uazo/bromite-buildtools/releases/latest/download/updateurl.txt

# Command line for Chromium (string):
# See here: http://peter.sh/experiments/chromium-command-line-switches/
ChromiumCommandLine=--user-data-dir=".\User Data" --no-default-browser-check

# Chromium executable file name (string):
ChromiumBinary=chrome.exe

# Chromium binaries directory (string):
# Relative (to chrlauncher directory) or full path (env. variables supported).
ChromiumDirectory=.\bin
```
