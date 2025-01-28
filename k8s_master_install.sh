#!/bin/bash

# Update system packages
sudo apt update -y

# Disable swap
sudo swapoff -a

# Check disk space
df -h

# Check memory usage
free -h

# Install Docker
sudo apt install docker.io -y

# Update package list
sudo apt-get update

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Create directory for Kubernetes keyring
sudo mkdir -p -m 755 /etc/apt/keyrings

# Add Kubernetes GPG key (overwrite if it exists)
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package list again
sudo apt-get update

# Install Kubernetes components
sudo apt-get install -y kubelet kubeadm kubectl

# Mark Kubernetes components to prevent them from being automatically updated
sudo apt-mark hold kubelet kubeadm kubectl

# Enable and start the kubelet service
sudo systemctl enable --now kubelet

# Initialize the Kubernetes cluster (this step is for the master node)
if [ "$USER" = "ubuntu" ]; then
  sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=NumCPU
  
  # Configure kubectl for the ubuntu user on the master node
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  # Install a Pod network add-on (e.g., Calico)
  kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
fi

echo "Kubernetes installation completed successfully!"
