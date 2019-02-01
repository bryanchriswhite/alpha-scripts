Network scripts
===

Speedtest
---
The speedtest script will generate a random 4MB file (file size can be changed). It will run an upload and download speedtest and verify the checksum. At the end delete local and remote testfiles and print out the test results. The file hash will be used as filename. That way we can all run it without blocking each other.
```
speedtest.sh
```
