# vscode-server-setup
Script that provision vscode server on public VM

## Prerequisites
Setup _config.ini_ file 

```
[config]
USER=vscode-admin
PASSWORD={your_secure_password}
LOGIN_PASSWORD={your_secure_password}
DOMAIN={www.example.com}
EMAIL={fake.email@email.com}
CODE_SERVER_VERSION="4.97.2"
```
[NOTE]
====
CODE_SERVER_VERSION can vary depend on latest update, please check:
https://github.com/coder/code-server/releases/ for latest one
===


## Add execute privileges 
```
chmod +x setup_code_server.sh
```

## Execute script with _config.ini_ setup 
```
./setup_code_server.sh
```
[NOTE]
===
Do not run script with `sh`, must be run with `bash`
===

When script reach step *7. Let's Encrypt SSL Certificate*, it will pause so you can enter modify your DNS A or AAA record.

``` bash
Please create a DNS A record for {www.example.com} pointing to the public IP address:
IPv4: {X.X.X.X}
IPv6: {X::X}
Press Enter to continue after you have created the DNS record.
```

Certificate validation will continue after you confirm prompt.

## Execute script with with interactive mode setup 
```
./setup_code_server.sh --interactive
```

Example output
``` bash
./setup_code_server.sh --interactive
Enter username: 
Enter password: 
Enter domain: 
Enter email: 
```

## Execute script with with interactive mode setup 

Example of successful outout:
``` terminal
sudo systemctl status code-server@{vscode-admin}
● code-server@vscode-admin.service - code-server
     Loaded: loaded (/usr/lib/systemd/system/code-server@.service; enabled; preset: enabled)
     Active: active (running) since Thu 2025-03-06 01:05:27 UTC; 1min 8s ago
   Main PID: 8943 (node)
      Tasks: 22 (limit: 9442)
     Memory: 38.7M (peak: 62.9M)
        CPU: 1.007s
     CGroup: /system.slice/system-code\x2dserver.slice/code-server@vscode-admin.service
             ├─8943 /usr/lib/code-server/lib/node /usr/lib/code-server
             └─8969 /usr/lib/code-server/lib/node /usr/lib/code-server/out/node/entry

Mar 06 01:05:27 localhost systemd[1]: Starting code-server@vscode-admin.service - code-server...
Mar 06 01:05:27 localhost systemd[1]: Started code-server@vscode-admin.service - code-server.
Mar 06 01:05:27 localhost code-server[8943]: [2025-03-06T01:05:27.964Z] info  code-server 4.97.2 34b8d2ed69811c3315a465f01492e9448c9254aa
Mar 06 01:05:27 localhost code-server[8943]: [2025-03-06T01:05:27.966Z] info  Using user-data-dir /home/vscode-admin/.local/share/code-server
Mar 06 01:05:27 localhost code-server[8943]: [2025-03-06T01:05:27.983Z] info  Using config file /home/vscode-admin/.config/code-server/config.yaml
Mar 06 01:05:27 localhost code-server[8943]: [2025-03-06T01:05:27.983Z] info  HTTP server listening on http://127.0.0.1:8080/
Mar 06 01:05:27 localhost code-server[8943]: [2025-03-06T01:05:27.983Z] info    - Authentication is enabled
Mar 06 01:05:27 localhost code-server[8943]: [2025-03-06T01:05:27.984Z] info      - Using password from /home/vscode-admin/.config/code-server/config.yaml
Mar 06 01:05:27 localhost code-server[8943]: [2025-03-06T01:05:27.984Z] info    - Not serving HTTPS
Mar 06 01:05:27 localhost code-server[8943]: [2025-03-06T01:05:27.984Z] info  Session server listening on /home/vscode-admin/.local/share/code-server/code-server-ipc.sock
```

