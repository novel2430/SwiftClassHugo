#!/bin/bash
rm -rf ./public
hugo
sudo rm -rf /etc/http/swiftclass
sudo cp -r ./public /etc/http/swiftclass
systemctl restart nginx
