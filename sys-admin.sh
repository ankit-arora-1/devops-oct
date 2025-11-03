1.
—————————————————————————————————————————————————

# See your current user
whoami

# See your user ID and groups
id

# List all users
cat /etc/passwd | cut -d: -f1.  -> Cut command extracts specific portions from each line. -d specifics the delimiter, -f selects the specific field to extract 

—————————————————————————————————————————————————


2.
—————————————————————————————————————————————————

# Simple user creation
sudo useradd john

# Create with home directory and default shell
sudo useradd -m -s /bin/bash john -> “-m” means create home directory /home/john. “john” at the end is the username

# Create with specific UID
sudo useradd -u 2000 -m john

# Create with description
sudo useradd -c "John Developer" -m john

# Set password
sudo passwd john

—————————————————————————————————————————————————


3.
—————————————————————————————————————————————————

#!/bin/bash
# create_dev_user.sh

USERNAME="developer"

# Create user with home directory
sudo useradd -m -s /bin/bash -c "Development User" $USERNAME

# Set password
echo "$USERNAME:Welcome123" | sudo chpasswd

# Create .ssh directory
sudo mkdir -p /home/$USERNAME/.ssh
sudo chmod 700 /home/$USERNAME/.ssh

# Fix ownership
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME

echo "✓ User $USERNAME created"

—————————————————————————————————————————————————


4.
—————————————————————————————————————————————————

# Change user's shell
sudo usermod -s /bin/zsh john

# Change home directory
sudo usermod -d /home/john_new john -> Only changes the home directory. Does not create a new home directory

# Add user to group (append mode)
sudo usermod -aG docker john -> “a” means append. “G” means add to group. 

# Lock user account (disable login)
sudo usermod -L john

# Unlock user account
sudo usermod -U john

# Set account expiration
sudo usermod -e 2024-12-31 john

# Change username
sudo usermod -l newname oldname

—————————————————————————————————————————————————


5.
—————————————————————————————————————————————————

#!/bin/bash
# offboard_user.sh

USER="$1"

# Lock account immediately
sudo usermod -L "$USER"

# Expire account today
sudo usermod -e 1 "$USER" -> here “1” represents days since epoch time. -e flag can take either a date or a single number 

# Remove from all groups except primary
sudo usermod -G "$USER" "$USER"

# Kill all user processes
sudo pkill -u "$USER"

echo "✓ User $USER disabled"

—————————————————————————————————————————————————


6.
—————————————————————————————————————————————————

# Create new group
sudo groupadd developers

# Create with specific GID
sudo groupadd -g 3000 developers
vim /etc/group -> See the groups

# Add user to group
sudo gpasswd -a john developers

# Remove user from group
sudo gpasswd -d john developers

# List group members
getent group developers

# Delete group
sudo groupdel developers

—————————————————————————————————————————————————


7.
—————————————————————————————————————————————————

#!/bin/bash
# setup_project_groups.sh

PROJECT="webapp"

# Create project groups
sudo groupadd ${PROJECT}_dev
sudo groupadd ${PROJECT}_ops

# Add users to dev group
for user in alice bob charlie; do
    sudo gpasswd -a $user ${PROJECT}_dev
done

# Add users to ops group
for user in dave eve; do
    sudo gpasswd -a $user ${PROJECT}_ops
done

# Create shared directory
sudo mkdir -p /projects/$PROJECT
sudo chgrp ${PROJECT}_dev /projects/$PROJECT
sudo chmod 2775 /projects/$PROJECT

echo "✓ Project groups configured"

—————————————————————————————————————————————————


8.
—————————————————————————————————————————————————

# View current password settings
sudo chage -l john

# Set password expiration (90 days)
sudo chage -M 90 john

# Set minimum days between password changes
sudo chage -m 7 john

# Set warning before expiration (7 days)
sudo chage -W 7 john

# Force password change on next login
sudo chage -d 0 john -> Takes either a date or number (days since epoch time) 

# Set account expiration date
sudo chage -E 2024-12-31 john

# Never expire password (remove expiration)
sudo chage -M -1 john

—————————————————————————————————————————————————


9.
—————————————————————————————————————————————————

# Run single command as root
sudo systemctl restart nginx

# Run command as different user
sudo -u postgres psql

# Become root (not recommended)
sudo su -

# Edit files safely
sudo visudo  # Edit /etc/sudoers

*********

# Add user to sudo group
sudo usermod -aG sudo john

# Create custom sudoers file (safer)
sudo visudo -f /etc/sudoers.d/developers

***********

# /etc/sudoers.d/developers

# Allow developers to restart web services without password
%developers ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
%developers ALL=(ALL) NOPASSWD: /bin/systemctl restart apache2

# Allow ops team full access
%ops ALL=(ALL) ALL

# Allow specific user to run specific commands
john ALL=(ALL) NOPASSWD: /usr/bin/docker

# Allow group to manage users
%admins ALL=(ALL) /usr/sbin/useradd, /usr/sbin/usermod, /usr/sbin/userdel -> Meaning “Any user who belongs to the group admins can, on any host, run the commands /usr/sbin/useradd, /usr/sbin/usermod, and /usr/sbin/userdel, as any user (including root)” -> Remember, sudoers control what commands can be run as a different user. It does not control all commands that can be run by a user. For example, any user can do “ls” but only those users can do “sudo ls” whose entry is there in the sudoers file

**************

#!/bin/bash
# grant_sudo.sh

USER="$1"
COMMANDS="$2"

SUDOERS_FILE="/etc/sudoers.d/$USER" -> Lets you create files to better manage the config (different teams can create their own files instead of putting everything in the main file) 

# Create sudoers entry
echo "$USER ALL=(ALL) NOPASSWD: $COMMANDS" | sudo tee $SUDOERS_FILE

# Set correct permissions
sudo chmod 0440 $SUDOERS_FILE

# Test syntax
sudo visudo -c

echo "✓ Sudo access granted to $USER"

—————————————————————————————————————————————————


10.
—————————————————————————————————————————————————

ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
~/.ssh/id_rsa - Your private key (keep this secret!)
~/.ssh/id_rsa.pub - Your public key (this goes on the server) -> Copy this is to server   Now if we login, we don’t the private key we usually use (.pem file) 

HW: https://docs.github.com/en/authentication/connecting-to-github-with-ssh

**************  Disable password for auth:  # Edit SSH config
sudo nano /etc/ssh/sshd_config

# Change these settings:
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no

# Restart SSH
sudo systemctl restart sshd
