apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: prom-scaledobject
  namespace: my-namespace
spec:
# ...
  triggers:
  - type: prometheus 
    metadata:
      serverAddress: https://thanos-querier.openshift-monitoring.svc.cluster.local:9092 
      namespace: kedatest 
      metricName: http_requests_total 
      threshold: '5' 
      query: sum(rate(http_requests_total{job="test-app"}[1m])) 
      authModes: basic 
      cortexOrgID: my-org 
      ignoreNullValues: "false" 
      unsafeSsl: "false" 
