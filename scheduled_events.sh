#/bin/sh

sudo apt update
sudo apt install python3 -y
sudo apt install python3-pip -y
pip3 install azure-storage

sudo cp scheduled_events.py /etc/
sudo echo "[Unit]" >> /etc/systemd/system/scheduled_events.service
sudo echo "Description=Scheduled Events Listener" >> /etc/systemd/system/scheduled_events.service
sudo echo "" >> /etc/systemd/system/scheduled_events.service
sudo echo "[Service]" >> /etc/systemd/system/scheduled_events.service
sudo echo "Environment=STORAGE_ACCOUNT_KEY=$STORAGE_ACCOUNT_KEY" >> /etc/systemd/system/scheduled_events.service
sudo echo "ExecStart=/usr/bin/python3 -u /etc/scheduled_events.py" >> /etc/systemd/system/scheduled_events.service
sudo echo "StandardOutput=journal" >> /etc/systemd/system/scheduled_events.service
sudo echo "" >> /etc/systemd/system/scheduled_events.service
sudo echo "[Install]" >> /etc/systemd/system/scheduled_events.service
sudo echo "WantedBy=multi-user.target" >> /etc/systemd/system/scheduled_events.service

sudo systemctl start scheduled_events
sudo systemctl enable scheduled_events