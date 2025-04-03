#!/bin/bash

read -p "OCP User: " OU; read -s -p "OCP Pass: " OP; echo ""
read -p "Registry: " RS; read -p "User: " RU; read -s -p "Pass: " RP; echo ""
read -p "Email (default@example.com): " RE; RE=${RE:-"default@example.com"}

[[ -z "$OU$OP$RS$RU$RP" || ! -f input.txt ]] && { echo "Error: Missing input or input.txt not found"; exit 1; }
for c in $(<input.txt); do
    oc login "https://api.$c.ebiz.xyz.com:6443" -u "$OU" -p "$OP" --insecure-skip-tls-verify || continue
    oc delete sealedsecret my-pull-secret --ignore-not-found
    oc create secret docker-registry my-pull-secret --docker-server="$RS" --docker-username="$RU" --docker-password="$RP" --docker-email="$RE" --dry-run=client -o yaml | \
    kubeseal --controller-namespace bitnami-sealed-secrets --controller-name bitnami-sealed-secrets --format yaml | oc apply -f -
done

echo "Done."