#!/usr/bin/env bash
set -e

echo "Step 1/5: System update and prerequisite installation"
sudo apt update -y
sudo apt install -y curl apt-transport-https

echo "Step 2/5: Downloading and installing Docker"
# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y

# Install Docker Engine
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to the docker group
sudo usermod -aG docker "${USER}"
echo "INFO: You may need to log out and log back in, or start a new shell session, for the docker group membership to take effect."
echo "If 'minikube start' fails with a permission error related to Docker, please try that first."

echo "Step 3/5: Downloading and installing Minikube"
MINIKUBE_DOWNLOAD_NAME="minikube-linux-amd64"
curl -Lo "${MINIKUBE_DOWNLOAD_NAME}" "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
sudo install -o root -g root -m 0755 "${MINIKUBE_DOWNLOAD_NAME}" /usr/local/bin/minikube
rm "${MINIKUBE_DOWNLOAD_NAME}"

echo "Step 4/5: Downloading and installing kubectl"
KUBECTL_STABLE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
KUBECTL_BINARY_NAME="kubectl"
curl -LO "https://dl.k8s.io/release/${KUBECTL_STABLE_VERSION}/bin/linux/amd64/${KUBECTL_BINARY_NAME}"
# Optional: Add checksum verification here for kubectl for enhanced security
# curl -LO "https://dl.k8s.io/release/${KUBECTL_STABLE_VERSION}/bin/linux/amd64/kubectl.sha256"
# echo "$(cat kubectl.sha256) ${KUBECTL_BINARY_NAME}" | sha256sum --check
# rm kubectl.sha256
sudo install -o root -g root -m 0755 "${KUBECTL_BINARY_NAME}" /usr/local/bin/kubectl
rm "${KUBECTL_BINARY_NAME}"

echo "Step 5/5: Starting Minikube"
echo "This might take a few minutes. Ensure you have a hypervisor (e.g., Docker, KVM2) installed."
minikube start

echo
echo "Minikube installation complete!"
echo "Quick command sheet:"
echo "  minikube status           - Check Minikube status"
echo "  minikube ssh              - SSH into the Minikube VM"
echo "  minikube dashboard        - Open the Kubernetes dashboard"
echo "  minikube addons list      - List available addons"
echo "  minikube addons enable <addon_name> - Enable an addon"
echo "  minikube stop             - Stop Minikube"
echo "  minikube delete           - Delete Minikube cluster"
echo "  kubectl get nodes         - Check node status via kubectl"
