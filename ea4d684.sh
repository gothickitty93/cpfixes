#!/bin/bash
# Websites experiencing 421 Misdirected requests after upgrading to CloudLinux's ea-apache24-2.4.64 
echo "Beginning Downgrade..."
yum downgrade -y liblsapi liblsapi-devel ea-apache24*
echo "Installing versionlock..."
dnf install -y python3-dnf-plugin-versionlock
echo "Version locking affected packages..."
yum versionlock liblsapi liblsapi-devel ea-apache24*
echo "Completed"
