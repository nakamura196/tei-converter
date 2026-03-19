#!/bin/sh
[ -f .env ] && . ./.env
rsync -avz docs/ ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH:-~/www/app/tei-tools/}
