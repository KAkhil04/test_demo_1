apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "80"
    prometheus.io/path: "/actuator/prometheus"
  labels:
    app_domain: infrastructure
    app_name: poc
    project.app: poc-dev
    project.lob: nts
    project.name: poc
    project.vsad: nt4v
  name: poc
  namespace: nt4v-dev-ntls
spec:
  ports:
  - name: portdetails
    port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    project.app: poc-dev
    project.name: poc
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: poc-service-monitor
  namespace: openshift-user-workload-monitoring
  labels:
    app_domain: infrastructure
    app_name: poc
    project.app: poc-dev
    project.lob: nts
    project.name: poc
    project.vsad: nt4v
spec:
  selector:
    matchLabels:
      project.app: poc-dev
      project.name: poc
  endpoints:
  - port: portdetails
    path: /actuator/prometheus
    interval: 5s
  namespaceSelector:
    matchNames:
    - nt4v-dev-ntls
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: poc-pod-monitor
  namespace: openshift-user-workload-monitoring
  labels:
    app_domain: infrastructure
    app_name: poc
    project.app: poc-dev
    project.lob: nts
    project.name: poc
    project.vsad: nt4v
spec:
  selector:
    matchLabels:
      project.app: poc-dev
      project.name: poc
  podMetricsEndpoints:
  - path: /actuator/prometheus
    interval: 10s
    port: http
  namespaceSelector:
    matchNames:
    - nt4v-dev-ntls
