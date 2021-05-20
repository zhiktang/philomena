#!/bin/sh

MAX_AGE=${MAX_REPORT_AGE:-14d};

echo "Anonimizing reports that are older than ${MAX_AGE}"
psql -c "UPDATE reports SET ip = '0.0.0.0', fingerprint = '', user_agent = '' where created_at < NOW() - INTERVAL '${MAX_AGE}' and IP != '0.0.0.0' RETURNING id" \
&& curl -fsS -m 10 --retry 5 -o /dev/null $HC_GDPR_IP_CLEANER_REPORTS
