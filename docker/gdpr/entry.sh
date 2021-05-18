#!/bin/sh

#set environment
export PGHOST=$POSTGRES_HOST
export PGPORT=$POSTGRES_PORT
export PGDATABASE=$POSTGRES_DB
export PGUSER=$POSTGRES_USER
export PGPASSWORD=$POSTGRES_PASSWORD

echo "Starting all scripts once during startup"
/scripts/anonymize_comments.sh
/scripts/anonymize_images.sh
/scripts/anonymize_posts.sh
/scripts/anonymize_reports.sh
/scripts/anonymize_source_changes.sh
/scripts/anonymize_tag_changes.sh
/scripts/anonymize_user_ips.sh

# start cron
echo "Starting cron"
/usr/sbin/crond -f -l 8
