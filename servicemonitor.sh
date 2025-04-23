#!/bin/bash

# Prompt for OCP credentials
read -p "OCP User: " OU
read -s -p "OCP Pass: " OP
echo ""

# Check if input.txt exists
if [[ ! -f input.txt ]]; then
    echo "Error: input.txt not found"
    exit 1
fi

# Check if PJ variable is set
if [[ -z "$PJ" ]]; then
    read -p "Enter project name: " PJ
fi

while IFS= read -r c; do
    # Skip empty lines
    [[ -z "$c" ]] && continue

    # Attempt OCP login
    if ! oc login "https://api.$c.verizon.com:6443" -u "$OU" -p "$OP" --insecure-skip-tls-verify; then
        echo "Failed to login to cluster $c"
        continue
    fi

    # Set project
    if ! oc project "$PJ" >/dev/null 2>&1; then
        echo "Failed to set project $PJ in cluster $c"
        continue
    fi

    # Create ServiceMonitor YAML
    cat << EOF > servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: blackbox-exporter
  namespace: blackbox-exporter
  labels:
    k8s-app: blackbox-exporter
spec:
  endpoints:
    - interval: 30s
      params:
        module:
          - http_2xx_ssl
        target:
          - https://api.$c.verizon.com:6443
      path: /probe
      port: http
      relabelings:
        - action: replace
          sourceLabels:
            - __param_target
          targetLabel: instance
      scheme: http
      targetPort: 9115
    - interval: 30s
      params:
        module:
          - http_2xx_ssl
        target:
          - https://j14v.apps.$c.verizon.com:443
      path: /probe
      port: http
      relabelings:
        - action: replace
          sourceLabels:
            - __param_target
          targetLabel: instance
      scheme: http
      targetPort: 9115
  selector:
    matchLabels:
      app: blackbox-exporter
EOF

    # Apply ServiceMonitor
    if ! oc apply -f servicemonitor.yaml -n blackbox-exporter; then
        echo "Failed to apply ServiceMonitor in cluster $c"
        continue
    fi

    echo "Successfully processed cluster $c"
done < input.txt

# Clean up
rm -f servicemonitor.yaml
echo "Done."