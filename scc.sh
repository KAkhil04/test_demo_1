oc logs custom-metrics-autoscaler-operator-74f89bc4f4-w4mt8
2024-08-14T15:44:53Z    INFO    setup   Using watch namespace 'openshift-keda' from service account namespace specified in /var/run/secrets/kubernetes.io/serviceaccount/namespace
2024-08-14T15:44:53Z    INFO    setup   Using watch namespace 'openshift-keda' from service account namespace specified in /var/run/secrets/kubernetes.io/serviceaccount/namespace
2024-08-14T15:44:58Z    ERROR   controllers.ConfigMap   Unable to query {"gvk": "route.openshift.io/v1, Kind=route", "error": "failed to get API group resources: unable to retrieve the complete list of server APIs: route.openshift.io/v1: the server is currently unable to handle the request"}
github.com/kedacore/keda-olm-operator/controllers/keda/util.isGvkPresent
        /remote-source/cma-operator/app/controllers/keda/util/util.go:119
github.com/kedacore/keda-olm-operator/controllers/keda/util.RunningOnOpenshift
        /remote-source/cma-operator/app/controllers/keda/util/util.go:74
github.com/kedacore/keda-olm-operator/controllers/keda.(*ConfigMapReconciler).SetupWithManager
        /remote-source/cma-operator/app/controllers/keda/configmap_controller.go:74
main.main
        /remote-source/cma-operator/app/main.go:114
runtime.main
        /usr/lib/golang/src/runtime/proc.go:250
2024-08-14T15:45:28Z    ERROR   controllers.Secret      Unable to query {"gvk": "route.openshift.io/v1, Kind=route", "error": "the server is currently unable to handle the request (get routes.route.openshift.io)"}
github.com/kedacore/keda-olm-operator/controllers/keda/util.isGvkPresent
        /remote-source/cma-operator/app/controllers/keda/util/util.go:119
github.com/kedacore/keda-olm-operator/controllers/keda/util.RunningOnOpenshift
        /remote-source/cma-operator/app/controllers/keda/util/util.go:74
github.com/kedacore/keda-olm-operator/controllers/keda.(*SecretReconciler).SetupWithManager
        /remote-source/cma-operator/app/controllers/keda/secret_controller.go:74
main.main
        /remote-source/cma-operator/app/main.go:122
runtime.main
        /usr/lib/golang/src/runtime/proc.go:250
2024-08-14T15:45:28Z    INFO    setup   starting manager
2024-08-14T15:45:28Z    INFO    setup   KEDA Version: 2.11.2
2024-08-14T15:45:28Z    INFO    setup   Git Commit: 48ea55165fd9a4e53324d3aef5c851e0788c2a9d
2024-08-14T15:45:28Z    INFO    setup   Go Version: go1.20.10
2024-08-14T15:45:28Z    INFO    setup   Go OS/Arch: linux/amd64
2024-08-14T15:45:28Z    INFO    controller-runtime.metrics      Starting metrics server
2024-08-14T15:45:28Z    INFO    starting server {"kind": "health probe", "addr": "[::]:8081"}
2024-08-14T15:45:28Z    INFO    controller-runtime.metrics      Serving metrics server  {"bindAddress": ":8080", "secure": false}
I0814 15:45:28.302817       1 leaderelection.go:250] attempting to acquire leader lease openshift-keda/olm-operator.keda.sh...
I0814 15:45:45.564965       1 leaderelection.go:260] successfully acquired lease openshift-keda/olm-operator.keda.sh
2024-08-14T15:45:45Z    INFO    Starting EventSource    {"controller": "kedacontroller", "controllerGroup": "keda.sh", "controllerKind": "KedaController", "source": "kind source: *v1alpha1.KedaController"}
2024-08-14T15:45:45Z    INFO    Starting EventSource    {"controller": "kedacontroller", "controllerGroup": "keda.sh", "controllerKind": "KedaController", "source": "kind source: *v1.Deployment"}
2024-08-14T15:45:45Z    INFO    Starting Controller     {"controller": "kedacontroller", "controllerGroup": "keda.sh", "controllerKind": "KedaController"}
2024-08-14T15:45:45Z    INFO    Starting workers        {"controller": "kedacontroller", "controllerGroup": "keda.sh", "controllerKind": "KedaController", "worker count": 1}
