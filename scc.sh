oc get scaledobject -n nt4v-dev-ntls
NAME                      SCALETARGETKIND   SCALETARGETNAME   MIN   MAX   TRIGGERS     AUTHENTICATION           READY   ACTIVE   FALLBACK   PAUSED   AGE
poc-dev-customscale                         poc-dev           2     6     prometheus   keda-trigger-auth-nt4v                                        40m
prometheus-scaledobject                     poc-dev           2     6     prometheus   keda-prom-creds                                               2m8s
