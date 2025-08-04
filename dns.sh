#!/bin/bash

header="Authorization: Bearer $token"
base='https://api.cloudflare.com/client/v4'

zone_id=$(curl -s "$base/zones?name=$domain" -H "$header" | jq -r '.result[].id')
echo "Zone ID: $zone_id"

ids=$(curl -s "$base/zones/$zone_id/dns_records?name=$fqdn" -H "$header" | jq -r '.result[].id')

for id in $ids; do
  curl -s -X DELETE "$base/zones/$zone_id/dns_records/$id" -H "$header"
done

IFS="," read -r -a ips <<< $(curl -s 'https://ip.164746.xyz/ipTop')
for ip in "${ips[@]}"; do
  curl -s -X POST "$base/zones/$zone_id/dns_records" -H "$header" \
    -H "Content-Type: application/json" \
    -d '{
          "name": "'"$fqdn"'",
          "type": "A",
          "content": "'"$ip"'"
        }'
  echo "$ip done"
done
