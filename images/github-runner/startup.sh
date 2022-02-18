#!/bin/bash

echo "Starting Proxy Support"
socat TCP-LISTEN:8118,reuseaddr,fork UNIX-CLIENT:/tmp/forward-proxy/proxy.sock &
sudo iptables -A INPUT -p tcp -s localhost --dport 8118 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8118 -j DROP

echo "Starting supervisor (Docker)"
sudo service docker start

#bash

if [ -n "${GITHUB_REPOSITORY}" ]
then
  auth_url="https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOSITORY}/actions/runners/registration-token"
  registration_url="https://github.com/${GITHUB_OWNER}/${GITHUB_REPOSITORY}"
else
  auth_url="https://api.github.com/orgs/${GITHUB_OWNER}/actions/runners/registration-token"
  registration_url="https://github.com/${GITHUB_OWNER}"
fi

generate_token() {
  payload=$(curl -sX POST -H "Authorization: token ${GITHUB_PERSONAL_TOKEN}" "${auth_url}")
  runner_token=$(echo "${payload}" | jq .token --raw-output)

  if [ "${runner_token}" == "null" ]
  then
    echo "${payload}"
    exit 1
  fi

  echo "${runner_token}"
}

remove_runner() {
  sudo service docker stop
  ./config.sh remove --unattended --token "$(generate_token)"
}

service docker status
runner_id=${RUNNER_NAME}_$(openssl rand -hex 6)
echo "Registering runner ${runner_id}"

./config.sh \
  --name "${runner_id}" \
  --labels "${RUNNER_LABELS}" \
  --token "$(generate_token)" \
  --url "${registration_url}" \
  --allowedauthorslist "${ALLOWEDAUTHORSLIST}" \
  --unattended \
  --replace \
  --disableupdate \
  --ephemeral

trap 'remove_runner; exit 130' SIGINT
trap 'remove_runner; exit 143' SIGTERM

for f in runsvc.sh RunnerService.js; do
  mv bin/${f}{,.bak}
  mv {patched,bin}/${f}
done

./bin/runsvc.sh --once "$*"
remove_runner
