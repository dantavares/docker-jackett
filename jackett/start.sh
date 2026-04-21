#! /bin/sh

./etc/jackett/updateJackett.sh

chown -R jackett:jackett /config /opt/jackett

echo "STARTING JACKETT"
#sudo -u jackett /opt/jackett/jackett_launcher.sh
exec su-exec jackett:jackett /opt/jackett/jackett --NoRestart --DataFolder=/config/Jackett
