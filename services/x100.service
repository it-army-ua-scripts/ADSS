[Unit]
Description=x100
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=on-failure
RestartSec=10
ExecStart=/opt/itarmy/x100-for-docker/for-macOS-and-Linux-hosts/run-and-auto-update.bash
ExecStop=/opt/itarmy/x100-for-docker/for-macOS-and-Linux-hosts/stop.bash
WorkingDirectory=/opt/itarmy/x100-for-docker/for-macOS-and-Linux-hosts/
SyslogIdentifier=x100
SyslogFacility=daemon
StandardOutput=append:/opt/itarmy/x100-for-docker/put-your-ovpn-files-here/x100-log-short.txt
StandardError=append:/opt/itarmy/x100-for-docker/put-your-ovpn-files-here/x100-log-short.txt

[Install]
WantedBy=multi-user.target
