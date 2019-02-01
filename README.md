Network scripts
===

Speedtest
---
The speedtest script will generate a random 4MB file (file size can be changed). It will run an upload and download speedtest and verify the checksum. At the end delete local and remote testfiles and print out the test results. The file hash will be used as filename. That way we can all run it without blocking each other.
```
speedtest.sh
```

Storagenode scripts
===

Storagenode
---
The external address is expected to be in the `STORJ_ADDRESS` env variable (if not using ngrok).
```
./storagenode.sh [--update] [--ngrok] [-f]
# options:
#   --update tells docker to pull before running
#   --ngrok starts a tunnel called "storj" in your ngrok config (see: https://ngrok.com/docs#tunnel-definitions)
#           (NB: depends on `curl` and `jq`, and expects `ngrok` to be in your $PATH)
#   -f runs `docker logs -f` at the end of the script (NB: ctl+c from this state will also stop ngrok)
``` 

Dashboard
---
```
./dashboard.sh
```

Ngrok
---
example config (see: https://ngrok.com/docs#tunnel-definitions):
```
authtoken: <your ngrok auth token>
console_ui: false
log: <desired path to log file (optional)>
tunnels:
  storj:
    proto: tcp
    addr: 28967
```
