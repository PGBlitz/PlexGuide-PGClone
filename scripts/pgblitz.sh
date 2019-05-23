#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705 & PhysK
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################

# Starting Actions
touch /var/plexguide/logs/pgblitz.log

echo "" >> /var/plexguide/logs/pgblitz.log
echo "" >> /var/plexguide/logs/pgblitz.log
echo "----------------------------" >> /var/plexguide/logs/pgblitz.log
echo "PG Blitz Log - First Startup" >> /var/plexguide/logs/pgblitz.log
# chown -R 1000:1000 "{{hdpath}}/downloads"
# chmod -R 755 "{{hdpath}}/downloads"
# chown -R 1000:1000 "{{hdpath}}/move"
# chmod -R 755 "{{hdpath}}/move"

startscript () {
    while read p; do
        
        # Repull excluded folder
        wget -qN https://raw.githubusercontent.com/PGBlitz/PGClone/v8.6/functions/exclude -P /var/plexguide/
        
        cleaner="$(cat /var/plexguide/cloneclean)"
        useragent="$(cat /var/plexguide/uagent)"
        
        let "cyclecount++"
        echo "----------------------------" >> /var/plexguide/logs/pgblitz.log
        echo "PG Blitz Log - Cycle $cyclecount" >> /var/plexguide/logs/pgblitz.log
        echo "" >> /var/plexguide/logs/pgblitz.log
        echo "Utilizing: $p" >> /var/plexguide/logs/pgblitz.log
        
        # find "/mnt/downloads" -mindepth 1 -maxdepth 1 -type d \
        # -name 'sabnzbd' -prune -o \
        # -name 'nzbget' -prune -o \
        # -name 'qbittorrent' -prune -o \
        # -name 'rutorrent' -prune -o \
        # -name 'deluge' -prune -o \
        # -name 'transmission' -prune -o \
        # -name 'makemkv*' -prune -o \
        # -name 'jdownloader*' -prune -o \
        # -name 'handbrake*' -prune -o \
        # -name 'inProgress' -prune -o \
        # -name 'ignore' -prune -o \
        # -exec echo mv '{}' "/mnt/move/" \;

        sudo rclone moveto "/mnt/downloads/" "/mnt/move/" \
        --config /opt/appdata/plexguide/rclone.conf \
        --exclude="**_HIDDEN~" --exclude=".unionfs/**" \
        --exclude='**partial~' --exclude=".unionfs-fuse/**" \
        --exclude=".fuse_hidden**" \
        --exclude="**sabnzbd**" --exclude="**nzbget**" \
        --exclude="**qbittorrent**" --exclude="**rutorrent**" \
        --exclude="**deluge**" --exclude="**transmission**" \
        --exclude="**jdownloader**" --exclude="**makemkv**" \
        --exclude="**handbrake**" --exclude="**bazarr**" \
        --exclude="**ignore**"  --exclude="**inProgress**"
        
        # Set permissions since this script runs as root, any created folders are owned by root.
        chown -R 1000:1000 "{{hdpath}}/move"
        chmod -R 755 "{{hdpath}}/move"
        
        rclone moveto "{{hdpath}}/move" "${p}{{encryptbit}}:/" \
        --config /opt/appdata/plexguide/rclone.conf \
        --log-file=/var/plexguide/logs/pgblitz.log \
        --log-level INFO --stats 5s --stats-file-name-length 0 \
        --tpslimit 12 \
        --checkers=20 \
        --transfers=16 \
        --bwlimit {{bandwidth.stdout}}M \
        --max-size=300G \
        --user-agent="$useragent" \
        --drive-chunk-size={{vfs_dcs}} \
        --exclude="**_HIDDEN~" --exclude=".unionfs/**" \
        --exclude='**partial~' --exclude=".unionfs-fuse/**" \
        --exclude=".fuse_hidden**" \
        --exclude="**sabnzbd**" --exclude="**nzbget**" \
        --exclude="**qbittorrent**" --exclude="**rutorrent**" \
        --exclude="**deluge**" --exclude="**transmission**" \
        --exclude="**jdownloader**" --exclude="**makemkv**" \
        --exclude="**handbrake**" --exclude="**bazarr**" \
        --exclude="**ignore**"  --exclude="**inProgress**"
        
        echo "Cycle $cyclecount - Sleeping for 30 Seconds" >> /var/plexguide/logs/pgblitz.log
        cat /var/plexguide/logs/pgblitz.log | tail -200 > /var/plexguide/logs/pgblitz.log
        #sed -i -e "/Duplicate directory found in destination/d" /var/plexguide/logs/pgblitz.log
        sleep 30
            
        # Remove empty directories
        find "{{hdpath}}/move/" -mindepth 2 -type d -mmin +2 -empty -exec rm -rf {} \;
        
        # Removes garbage | torrent folder excluded        
        find "{{hdpath}}/downloads" -mindepth 2 -type f -cmin +$cleaner $(printf "! -path %s " $(cat /var/plexguide/exclude)) -size -1000M -exec rm -rf {} \;
        find "{{hdpath}}/downloads" -mindepth 2 -type d $(printf "! -path %s " $(cat /var/plexguide/exclude)) -empty -exec rm -rf {} \;

        
    done </var/plexguide/.blitzfinal
}

# keeps the function in a loop
cheeseballs=0
while [[ "$cheeseballs" == "0" ]]; do startscript; done
