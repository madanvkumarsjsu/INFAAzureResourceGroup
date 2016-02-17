#!/bin/bash
mkdir infaRPMInstall
cd infaRPMInstall
wget http://infaubuntustorage.blob.core.windows.net/infa/informatica_10.0.0-1.deb
sudo dpkg -i informatica_10.0.0-1.deb
