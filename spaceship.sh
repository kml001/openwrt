#!/bin/ash

PREFIX="PREFIX"
DOMAIN="MYTLD"
DDNS="$PREFIX.$DOMAIN"

APIKEY='KEY'
APISECRET='SECRET'

MYDNS="launch1.spaceship.net"

# let's get the current IP we're on
IP4=`curl -s 4.ipquail.com/ip`

# let's get the DNS IP
DNSIP=`dig +short @$MYDNS $DDNS`

if [ -z "$DNSIP" ]; then
  echo "can't resolve or we're offline"
  exit 1
fi

echo "Current IP is:  $IP4   $DDNS currently resolves to $DNSIP"

if [ "$IP4" == "$DNSIP" ]; then
        echo "they match, do nothing"
        exit 0
else
# delete the existing record first
generate_del_data()
{
  cat <<EOF
[
  {
    "type": "A",
    "address": "$DNSIP",
    "name": "$PREFIX"
  }
]
EOF
}

echo -n "update needed, deleting existing record..."
curl --request DELETE \
     --url https://spaceship.dev/api/v1/dns/records/$DOMAIN \
     --header "X-API-Key: $APIKEY" \
     --header "X-API-Secret: $APISECRET" \
     --header 'content-type: application/json' \
     --data "$(generate_del_data)"
echo -n "done..."


echo -n "creating new record..."
generate_new_data()
{
  cat <<EOF
{
  "force": true,
  "items": [
    {
      "type": "A",
      "name": "$PREFIX",
      "address": "$IP4",
      "ttl": 3600
    }
  ]
}


EOF
}

curl --request PUT \
     --url https://spaceship.dev/api/v1/dns/records/$DOMAIN \
     --header "X-API-Key: $APIKEY" \
     --header "X-API-Secret: $APISECRET" \
     --header 'content-type: application/json' \
     --data "$(generate_new_data)"

fi
echo "done"
