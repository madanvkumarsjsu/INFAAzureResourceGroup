#!/bin/bash
#Script arguments
HDIClusterName=$1
HDIClusterLoginUsername=$2
HDIClusterLoginPassword=$3
HDIClusterSSHHostname=$4
HDIClusterSSHUsername=$5
HDIClusterSSHPassword=$6
Clusterjobhistory=$7
Clusterjobhistorywebapp$8
ClusterRMSaddress=$9
ClusterRMWaddress$10
#Check
mkdir /home/devuser/logs
echo $HDIClusterName $HDIClusterLoginUsername $HDIClusterLoginPassword $HDIClusterSSHHostname $HDIClusterSSHUsername $HDIClusterSSHPassword $Clusterjobhistory $Clusterjobhistorywebapp $ClusterRMSaddress $ClusterRMWaddress > /home/devuser/logs/input.log
whoami > /home/devuser/logs/user.log
pwd > /home/devuser/logs/output.log

#RPM download
mkdir /home/devuser/infaRPMInstall
cd /home/devuser/infaRPMInstall
wget http://ispstorenp.blob.core.windows.net/bderpm/informatica_10.0.0-1.deb > /home/devuser/logs/download.log

#Ambari API calls to extract Head node and Data nodes
echo "Getting list of hosts from ambari"
hostsJson=$(curl -u $HDIClusterLoginUsername:$HDIClusterLoginPassword -X GET https://$HDIClusterName.azurehdinsight.net/api/v1/clusters/$HDIClusterName/hosts)
echo $hostsJson > /home/devuser/logs/hosts.log

echo "Parsing list of hosts"
hosts=$(echo $hostsJson | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w 'host_name')
echo $hosts > /home/devuser/logs/parsedhost.log

echo "Extracting headnode0"
headnode0=$(echo $hosts | grep -Eo '\bhn0-([^[:space:]]*)\b') 
echo $headnode0 > /home/devuser/logs/headnode.log
echo "Extracting headnode0 IP addresses"
headnode0ip=$(dig +short $headnode0) 
echo "headnode0 IP: $headnode0ip" > /home/devuser/logs/headnodeip.log

#Add a new line to the end of hosts file
echo "">>/etc/hosts
echo "Adding headnode IP addresses"
echo "$headnode0ip headnode0">>/etc/hosts

echo "Extracting workernode"
workernodes=$(echo $hosts | grep -Eo '\bwn([^[:space:]]*)\b') 
echo "Extracting workernodes IP addresses"
echo "workernodes : $workernodes" > /home/devuser/logs/workernode.log
wnArr=$(echo $workernodes | tr "\n" "\n")
tmpRemoteFolderName = rpmtemp
filename = informatica_10.0.0-1.deb
sudo apt-get install sshpass
for workernode in $wnArr
do
    echo "[$workernode]" 
	workernodeip=$(dig +short $workernode)
	echo "workernodeip $workernodeip" >> /home/devuser/logs/batchoutput.log
	sudo sshpass -p $HDIClusterSSHPassword ssh -o StrictHostKeyChecking=no $HDIClusterSSHUsername@$workernodeip "sudo mkdir ~/rpmtemp" >> /home/devuser/logs/batchoutput.log
	sudo sshpass -p $HDIClusterSSHPassword scp informatica_10.0.0-1.deb $HDIClusterSSHUsername@$workernodeip:"~/rpmtemp/" >> /home/devuser/logs/batchoutput.log
	sudo sshpass -p $HDIClusterSSHPassword ssh -o StrictHostKeyChecking=no $HDIClusterSSHUsername@$workernodeip "sudo dpkg -i ~/rpmtemp/informatica_10.0.0-1.deb" >> /home/devuser/logs/batchoutput.log
	#SCP packages	
done
