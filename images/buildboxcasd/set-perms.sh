
wait_file() {
  local file="$1"; shift
  local wait_seconds="${1:-10}"; shift # 10 seconds as default timeout

  until test $((wait_seconds--)) -eq 0 -o -e "$file" ; do sleep 1; done

  ((++wait_seconds))
}

echo "--Checking permissions bots.sock"
wait_file "/wrk-cache/bots.sock" && {
  echo "--Set bots.sock permissions"
  sudo chmod 777 /wrk-cache/bots.sock
}

echo "--Checking permissions casd.sock"
wait_file "/wrk-cache/casd.sock" && {
  echo "--Set casd.sock permissions"
  sudo chmod 777 /wrk-cache/casd.sock
}

echo "--Done"
