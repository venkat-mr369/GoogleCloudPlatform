#! /bin/bash
apt-get update
apt-get install -y apache2 php wget
cd /var/www/html
rm index.html -f
rm index.php -f
wget https://raw.githubusercontent.com/yvsc369/GoogleCloudPlatform/master/LoadBalancer/version1/index.php
META_REGION_STRING=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
REGION=`echo "$META_REGION_STRING" | awk -F/ '{print $4}'`
sed -i "s|region-here|$REGION|" index.php
