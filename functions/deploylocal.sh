#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################
# NOTES
# Variable recall comes from /functions/variables.sh
################################################################################
executelocal () {

# Reset Front Display
rm -rf plexguide/deployed.version

# Call Variables
pgclonevars

# to remove all service running prior to ensure a clean launch
ansible-playbook /opt/pgclone/ymls/remove.yml

# deploy union
ansible-playbook /opt/pgclone/ymls/local.yml -e "multihds=$multihds hdpath=$hdpath"

# display edition final
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💪 DEPLOYED: PG Local Edition
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

read -rp '↘️  Acknowledge Info | Press [ENTER] ' typed < /dev/tty

}
