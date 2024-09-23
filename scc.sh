oc describe svc thanos-querier -n openshift-monitoring
Name:              thanos-querier
Namespace:         openshift-monitoring
Labels:            app.kubernetes.io/component=query-layer
                   app.kubernetes.io/instance=thanos-querier
                   app.kubernetes.io/managed-by=cluster-monitoring-operator
                   app.kubernetes.io/name=thanos-query
                   app.kubernetes.io/part-of=openshift-monitoring
                   app.kubernetes.io/version=0.30.2
Annotations:       service.alpha.openshift.io/serving-cert-signed-by: openshift-service-serving-signer@1707512276
                   service.beta.openshift.io/serving-cert-secret-name: thanos-querier-tls
                   service.beta.openshift.io/serving-cert-signed-by: openshift-service-serving-signer@1707512276
Selector:          app.kubernetes.io/component=query-layer,app.kubernetes.io/instance=thanos-querier,app.kubernetes.io/name=thanos-query,app.kubernetes.io/part-of=openshift-monitoring
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                172.30.3.165
IPs:               172.30.3.165
Port:              web  9091/TCP
TargetPort:        web/TCP
Endpoints:         10.128.8.5:9091,10.130.6.14:9091
Port:              tenancy  9092/TCP
TargetPort:        tenancy/TCP
Endpoints:         10.128.8.5:9092,10.130.6.14:9092
Port:              tenancy-rules  9093/TCP
TargetPort:        tenancy-rules/TCP
Endpoints:         10.128.8.5:9093,10.130.6.14:9093
Port:              metrics  9094/TCP
TargetPort:        metrics/TCP
Endpoints:         10.128.8.5:9094,10.130.6.14:9094
Session Affinity:  None
Events:            <none>
