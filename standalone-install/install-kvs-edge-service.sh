sudo cp ./kvs-edge.service /etc/systemd/system/kvs-edge.service

sudo systemctl daemon-reload
sudo systemctl enable kvs-edge.service
sudo systemctl start kvs-edge.service
