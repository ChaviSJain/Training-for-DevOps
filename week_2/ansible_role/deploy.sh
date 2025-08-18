#!/bin/bash

echo "🔧 Running Ansible playbook from week_2..."
cd ../week_2/Ansible_role
ansible-playbook role.yml 

echo "🏠 Returning to week_1 and starting Docker Compose..."
cd ../../week_1
docker-compose up -d

echo "✅ Deployment complete. Check http://localhost:5000"
