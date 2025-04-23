#!/bin/bash

read -p "OCP User: " OU; read -s -p "OCP Pass: " OP; echo ""

for c in $(<input.txt); do
    oc login "https://api.$c.verizon.com:6443" -u "$OU" -p "$OP" || continue
    oc project $PJ
    << apiVersion: monitoring.coreos.com/v1
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
          - 'https://api.$c.verizon.com:6443'
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
          - 'https://j14v.apps.$c.verizon.com:443'
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
>> servicemonitor.yaml
   oc apply -f servicemonitor.yaml -n blackbox-exporter
done

echo "Done."
