#!/bin/sh

echo "What should be the MariaDB Root Password?"
read dbrootpass

echo "What should be the MariaDB Database Name?"
read dbname

echo "What should be the MariaDB Username?"
read dbuser

echo "What should be the MariaDB User Password?"
read dbuserpass

echo "What should be the WordPress Table Prefix? (e.g. wp_)"
read wpdbprefix

mkdir wpinstance
mkdir ${PWD}'/wpinstance/nginx'
mkdir ${PWD}'/wpinstance/web'
mkdir ${PWD}'/wpinstance/mysql'

cat <<'EOF' > ${PWD}'/wpinstance/nginx/'nginx.conf
server {
listen 80;
listen [::]:80;
access_log off;
root /var/www/html;
index index.php;
server_name localhost;
server_tokens off;
location / {
    # First attempt to serve request as file, then
    # as directory, then fall back to displaying a 404.
    try_files $uri $uri/ /index.php?$args;
}
# pass the PHP scripts to FastCGI server listening on wordpress:9000
location ~ \.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass wordpress:9000;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param SCRIPT_NAME $fastcgi_script_name;
}
}
EOF

DB_ROOT_PASS=$dbrootpass DB_NAME=$dbname DB_USER=$dbuser DB_USER_PASS=$dbuserpass WP_PREFIX=$wpdbprefix LOCAL_PATH=${PWD}/wpinstance docker-compose up -d

for (( i=30; i>0; i--)); do
  sleep 1 &
  printf "Preparing the nginx Server: $i Second(s) left... \r"
  wait
done

cat << "EOF"
  ____        _      _      _____             _              __          _______     _____                          
 / __ \      (_)    | |    |  __ \           | |             \ \        / /  __ \   / ____|                         
| |  | |_   _ _  ___| | __ | |  | | ___   ___| | _____ _ __   \ \  /\  / /| |__) | | (___   ___ _ ____   _____ _ __ 
| |  | | | | | |/ __| |/ / | |  | |/ _ \ / __| |/ / _ \ '__|   \ \/  \/ / |  ___/   \___ \ / _ \ '__\ \ / / _ \ '__|
| |__| | |_| | | (__|   <  | |__| | (_) | (__|   <  __/ |       \  /\  /  | |       ____) |  __/ |   \ V /  __/ |   
 \___\_\\__,_|_|\___|_|\_\ |_____/ \___/ \___|_|\_\___|_|        \/  \/   |_|      |_____/ \___|_|    \_/ \___|_|   
EOF

echo "Ready for launch!"
echo "Visit: http://localhost:8080"