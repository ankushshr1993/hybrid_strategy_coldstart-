#!/usr/bin/bash -vx
#master node#Install Kubernetes Servers

sudo apt update
sudo apt -y full-upgrade
#[ -f /var/run/reboot-required ] && sudo reboot -f



#Install kubelet, kubeadm and kubectl

#sudo apt -y install curl apt-transport-https
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list


#Then install required packages

sudo apt update
#sudo apt -y install vim git curl wget kubelet=1.21.0-00 kubeadm=1.21.0-00 kubectl=1.21.0-00
sudo apt-get install -y vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
kubectl version --client && kubeadm version

#Disable Swap

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a


# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sudo sysctl --system



#Install docker


# # Create required directories
# sudo mkdir -p /etc/systemd/system/docker.service.d

# # Create daemon json config file
# echo '{"exec-opts": ["native.cgroupdriver=systemd"],"log-driver": "json-file","log-opts": {"max-size": "100m"},"storage-driver": "overlay2"}' > sudo /etc/docker/daemon.json


# # Start and enable Services
# sudo systemctl daemon-reload 

# Add repo and Install packages
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates


curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"  | sudo tee /etc/apt/sources.list
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu artful stable"  | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update
sudo apt-cache madison docker-ce
#sudo apt-get install -y docker-ce=5:20.10.0~3-0~ubuntu-bionic docker-ce-cli=5:20.10.0~3-0~ubuntu-bionic
#sudo apt install -y containerd.io docker-ce docker-ce-cli
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin



# Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create daemon json config file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF



# Start and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker

#lsmod | grep br_netfilter
sudo systemctl enable kubelet


sudo kubeadm config images pull

#install panda
sudo apt-get update
sudo add-apt-repository universe
sudo apt install -y python3-pip
sudo pip3 install pandas

