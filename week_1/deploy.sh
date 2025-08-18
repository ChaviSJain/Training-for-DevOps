#!/bin/bash

# ======== CONFIGURATION ========
VM_USER="vboxuser"
VM_IP="192.168.31.209"
VM_PORT="2222"
REMOTE_DIR="/home/$VM_USER/week_1"
SYSTEMD_SERVICE_NAME="week_1.service"
# ===============================

echo "🚀 Starting deployment to $VM_USER@$VM_IP..."

# Step 1: Check if project directory exists on remote VM
echo "🔍 Checking if project directory exists on VM..."
DIR_EXISTS=$(ssh "$VM_USER@$VM_IP" "[ -d '$REMOTE_DIR' ] && echo exists || echo missing")

# Step 2: If missing, copy project files via SCP
if [ "$DIR_EXISTS" = "missing" ]; then
  echo "📦 Project folder not found on VM. Uploading..."
  scp -P $VM_PORT -r . "$VM_USER@$VM_IP:$REMOTE_DIR"
else
  echo "✅ Project folder already exists on VM. Skipping upload."
fi

if ! ssh -o ConnectTimeout=5 "$VM_USER@$VM_IP" "echo '✅ VM is reachable'" 2>/dev/null; then
  echo "❌ ERROR: Unable to reach VM at $VM_IP. Is it running and connected to network?"
  exit 1
fi

# Step 3: SSH into VM and run setup & deployment
ssh -p $VM_PORT "$VM_USER@$VM_IP" bash <<EOF
  echo "💻 Connected to VM"

  # Install Docker and Docker Compose if not installed
  echo "⚙️ Checking Docker installation..."
  if ! command -v docker &> /dev/null; then
    echo "🔧 Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
  fi

  if ! docker compose version &> /dev/null; then
    echo "🔧 Installing Docker Compose..."
    sudo apt install -y docker-compose
  fi

  # Add current user to docker group (safe to repeat)
  sudo usermod -aG docker \$USER

  # Navigate to project directory
  cd "$REMOTE_DIR"

  # Fix the typo in systemd service (only needed once)
  echo "🔧 Setting up systemd service..."
  sed -i 's/EcexStop/ExecStop/' systemd/$SYSTEMD_SERVICE_NAME

  # Move the systemd service file and reload
  sudo cp systemd/$SYSTEMD_SERVICE_NAME /etc/systemd/system/
  sudo systemctl daemon-reexec
  sudo systemctl daemon-reload
  sudo systemctl enable $SYSTEMD_SERVICE_NAME
  sudo systemctl restart $SYSTEMD_SERVICE_NAME

  echo "✅ Deployment complete. App should be live at http://$VM_IP:5000"
EOF
