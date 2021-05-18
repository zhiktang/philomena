#!/bin/sh

MAX_AGE=${MAX_COMMENT_AGE:-14d};

echo "Anonimizing comments that are older than ${MAX_AGE}"
psql -c "DELETE FROM user_ips where created_at < NOW() - INTERVAL '${MAX_AGE}' RETURNING id" \
&& curl -fsS -m 10 --retry 5 -o /dev/null $HC_GDPR_IP_CLEANER_USER_IPS
