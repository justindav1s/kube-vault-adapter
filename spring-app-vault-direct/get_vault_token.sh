#!/usr/bin/env bash

APPDOMAIN=ola
APPNAME=spring-vault-demo
ENV=dev
PROJECT=${APPDOMAIN}-${ENV}

oc project ${APPDOMAIN}-${ENV}

export VAULT_ADDR=https://`oc get route -n vault | grep -m1 vault | awk '{print $2}'`
echo VAULT_ADDR $VAULT_ADDR

default_account_token=$(oc serviceaccounts get-token default -n ${PROJECT})

#Using REST API
AUTH_RESPONSE=$(curl -s \
    --request POST \
    --data "{\"jwt\": \"${default_account_token}\", \"role\": \"${APPDOMAIN}-${ENV}-admin\"}" \
    ${VAULT_ADDR}/v1/auth/kubernetes/login)

export VAULT_TOKEN=$(echo $AUTH_RESPONSE | jq -r .auth.client_token)

echo VAULT_TOKEN = $VAULT_TOKEN


#Using CLI
VAULT_TOKEN=$(vault write -tls-skip-verify \
            auth/kubernetes/login role=${PROJECT}-admin \
            jwt=${default_account_token} \
            | grep '^token ' \
            | awk '{print $2}')

echo VAULT_TOKEN = $VAULT_TOKEN


