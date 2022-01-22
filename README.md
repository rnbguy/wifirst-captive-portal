# wifirst-captive-portal
Wifirst captive portal bypasser

When using custom DNS, the captive portal (sub)domains `*.wifirst.net` do not resolve.

In such situations, this script uses `curl --dns-servers` to log in without resetting the DNS configuration.

### Instruction

Update cred.sh file with your credential before executing the script.

```
$ bash wifirst.sh
```
