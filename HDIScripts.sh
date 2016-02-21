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
headnode0=$(echo $hosts | grep -Eo '\bhn0-([^[:space:]]*)\b') > /home/devuser/logs/headnode.log
echo "Extracting headnode0 IP addresses"
headnode0ip=$(dig +short $headnode0) > /home/devuser/logs/headnodeip.log
echo "headnode0 IP: $headnode0ip"

#Add a new line to the end of hosts file
echo "">>/etc/hosts
echo "Adding headnode IP addresses"
echo "$headnode0ip headnode0">>/etc/hosts

echo "Extracting workernode"
workernodes=$(echo $hosts | grep -Eo '\bwn-([^[:space:]]*)\b') > /home/devuser/logs/workernode.log
echo "Extracting workernodes IP addresses"
echo "workernodes : $workernodes"
wnArr=$(echo $workernodes | tr "\n" "\n")
for workernode in $wnArr
do
    echo "[$workernode]"
	workernodeip=$(dig +short $workernode)
	echo "workernodeip $workernodeip" >> /home/devuser/logs/workernodes.log
	#SCP packages 
	
done



#SCP and Install RPM packages to Data node 
#sshpass -p 'Infabde@2016' scp -r $clusterSshUser@$clusterSshHostName:"$path/*" "$tmpFilePath$path"
#ssh -o StrictHostKeyChecking=no blazeuser@$ClusterHostName > /home/devuser/logs/ssh.log
#10.7.0.12




sudo dpkg -i informatica_10.0.0-1.deb