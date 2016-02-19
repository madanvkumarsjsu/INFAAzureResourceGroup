#!/bin/bash
#Script arguments
whoami > /home/devuser/user.log
pwd > /home/devuser/output.log

#SSH into Head node
mkdir /home/devuser/infaRPMInstall
sudo apt-get install sshpass
sshpass -p 'Infabde@2016' ssh -o StrictHostKeyChecking=no blazeuser@10.7.0.12

#RPM download and install
mkdir /home/blazeuser/infaRPMInstall
cd /home/blazeuser/infaRPMInstall
wget http://ispstorenp.blob.core.windows.net/bderpm/informatica_10.0.0-1.deb
sudo dpkg -i informatica_10.0.0-1.deb