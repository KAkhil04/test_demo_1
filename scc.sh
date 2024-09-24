apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app_domain: infrastructure
    app_name: poc
    project.app: poc-dev
    project.lob: nts
    project.name: poc
    project.vsad: nt4v
  name: poc-dev
  namespace: nt4v-dev-ntls
spec:
  progressDeadlineSeconds: 600
  replicas: 2
  selector:
    matchLabels:
      project.app: poc-dev
      project.name: poc
  template:
    metadata:
      annotations:
        elastic.co/namespace: nsit_np_nt4v
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/actuator/prometheus"
      labels:
        app_domain: infrastructure
        app_name: poc
        project.app: poc-dev
        project.lob: nts
        project.name: poc
        project.vsad: nt4v
    spec:
      containers:
      - env:
        - name: APP_DEPLOYED_TIME
          value: 2024-09-09.01-48-10
        - name: MIN_TIMEOUT
          value: "1"
        - name: MAX_TIMEOUT
          value: "1"
        envFrom:
        image: nt4v-docker-dev.oneartifactoryci.verizon.com/nts/nt4v/poc:1.0.5-SNAPSHOT-1234
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 2
          httpGet:
            path: /actuator/health/liveness
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 5
          periodSeconds: 1
          successThreshold: 1
          timeoutSeconds: 2
        name: poc
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
        readinessProbe:
          failureThreshold: 2
          httpGet:
            path: /actuator/health/readiness
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 5
          periodSeconds: 1
          successThreshold: 1
          timeoutSeconds: 2
        resources:
          limits:
            cpu: 500m
            memory: 1Gi
          requests:
            cpu: 200m
            memory: 500Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsGroup: 1000
          runAsUser: 1000
        startupProbe:
          failureThreshold: 20
          httpGet:
            path: /actuator/health/liveness
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 5
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 2
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /tmp
          name: empty-volume
      dnsConfig:
        options:
        - name: ndots
          value: "3"
        - name: single-request-reopen
      imagePullSecrets:
      - name: nautilusregistrypullsecret
      restartPolicy: Always
      securityContext:
        runAsUser: 1000
        supplementalGroups:
        - 1000
      terminationGracePeriodSeconds: 60
      volumes:
      - emptyDir: {}
        name: empty-volume
---
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
  namespace: openshift-monitoring
spec:
  selector:
    matchLabels:
      app_name: poc
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
  namespace: nt4v-dev-ntls
spec:
  selector:
    matchLabels:
      app_name: poc
  podMetricsEndpoints:
  - path: /actuator/prometheus
    interval: 10s
    port: http
  namespaceSelector:
    matchNames:
    - nt4v-dev-ntls
---
apiVersion: v1
kind: Secret
metadata:
  name: keda-prom-secret
  namespace: nt4v-dev-ntls
data:
  bearerToken: "BEARER_TOKEN"
---
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: keda-prom-creds
  namespace: nt4v-dev-ntls
spec:
  secretTargetRef:
  - parameter: bearerToken
    name: keda-prom-secret
    key: bearerToken
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: prometheus-scaledobject
  namespace: nt4v-dev-ntls
  labels:
    deploymentName: dummy
spec:
  maxReplicaCount: 12
  scaleTargetRef:
    name: dummy
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://<prometheus-host>:9090
      metricName: http_requests_total # DEPRECATED: This parameter is deprecated as of KEDA v2.10 and will be removed in version 2.12
      threshold: '100'
      query: sum(rate(http_requests_total{deployment="my-deployment"}[2m]))
      authModes: "bearer"
    authenticationRef:
      name: keda-prom-creds
