#!/bin/bash
DB_FILE=db/init.sql

echo "\\n🛠  Installing services..."
docker-compose up -d

echo "\\n💣 Initializing Wordpress..."
sleep 40
echo "✅ Ready!\\n"

echo "\\n🧨 Initializing database..."
until  docker-compose run --rm wpcli wp db create --dbuser=root --dbpass=docker
do
    echo "\\n🔄 Re-initializing database..."
    sleep 10
done

if [ -f "$DB_FILE" ]
then
    echo "\\n🧨 Migrating database..."

    until  docker-compose run --rm wpcli wp db import "$DB_FILE"
    do
        echo "\\n🔄 Retrying migrating database..."
        sleep 10
    done
else
    docker-compose run --rm wpcli wp core install \
    --url=localhost \
    --title="Weber CMS" \
    --admin_user=admin \
    --admin_password=password \
    --admin_email=noreply@email.com
fi

echo "\\n🧽 Cleaning up..."
docker-compose run --rm wpcli wp plugin delete akismet
docker-compose run --rm wpcli wp plugin delete hello

echo "\\n🔌 Installing plugins..."
docker-compose run --rm wpcli wp plugin install polylang --activate

echo "\\n\\n🎉 All done!! \\n"
echo " ---------------------------------------\\n"
echo "| wordpress: http://localhost/wp-admin  |\\n"
echo "| phpmyadmin: http://localhost:8080     |\\n"
echo "| mailhog: http://localhost:8025        |\\n"
echo " ---------------------------------------\\n"