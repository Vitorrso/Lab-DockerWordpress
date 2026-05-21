#!/bin/bash

set -e


WP_DIR="/srv/www/wordpress"
WP_CONFIG="$WP_DIR/wp-config.php"

WORDPRESS_TABLE_PREFIX="${WORDPRESS_TABLE_PREFIX:-wp_}"

echo "Ajustando permissões..."
chown -R www-data:www-data /srv/www

if [ ! -f "$WP_CONFIG" ]; then
    echo "Criando wp-config.php..."

    runuser -u www-data -- cp "$WP_DIR/wp-config-sample.php" "$WP_CONFIG"

    runuser -u www-data -- sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" "$WP_CONFIG"
    runuser -u www-data -- sed -i "s/username_here/${WORDPRESS_DB_USER}/" "$WP_CONFIG"
    runuser -u www-data -- sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" "$WP_CONFIG"
    runuser -u www-data -- sed -i "s/localhost/${WORDPRESS_DB_HOST}/" "$WP_CONFIG"

    runuser -u www-data -- sed -i "s|\$table_prefix = 'wp_';|\$table_prefix = '${WORDPRESS_TABLE_PREFIX}';|" "$WP_CONFIG"

    echo "Gerando salts locais..."

    AUTH_KEY=$(openssl rand -hex 64)
    SECURE_AUTH_KEY=$(openssl rand -hex 64)
    LOGGED_IN_KEY=$(openssl rand -hex 64)
    NONCE_KEY=$(openssl rand -hex 64)
    AUTH_SALT=$(openssl rand -hex 64)
    SECURE_AUTH_SALT=$(openssl rand -hex 64)
    LOGGED_IN_SALT=$(openssl rand -hex 64)
    NONCE_SALT=$(openssl rand -hex 64)

    perl -0777 -i -pe "s#define\\( 'AUTH_KEY'.*?define\\( 'NONCE_SALT'.*?;\\n#define( 'AUTH_KEY',         '$AUTH_KEY' );\ndefine( 'SECURE_AUTH_KEY',  '$SECURE_AUTH_KEY' );\ndefine( 'LOGGED_IN_KEY',    '$LOGGED_IN_KEY' );\ndefine( 'NONCE_KEY',        '$NONCE_KEY' );\ndefine( 'AUTH_SALT',        '$AUTH_SALT' );\ndefine( 'SECURE_AUTH_SALT', '$SECURE_AUTH_SALT' );\ndefine( 'LOGGED_IN_SALT',   '$LOGGED_IN_SALT' );\ndefine( 'NONCE_SALT',       '$NONCE_SALT' );\n#s" "$WP_CONFIG"

    chown www-data:www-data "$WP_CONFIG"
fi

echo "Subindo Apache..."
exec apache2ctl -D FOREGROUND