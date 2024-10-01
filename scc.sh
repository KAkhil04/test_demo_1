Today, our Grafana dashboards are protected by oauth and the global dashboards are tied to the ACM clusters. We can't give everyone access to ACM, nor would we want to. But, we want anybody to be able to view the dashboards. I think we can only do this for Grafana, not what's built into the OCP web console.
The end goal is for anyone to be able to view a dashboard, but edit is still protected by oauth and tied to our cluster-admin adom group.

for example, this is our ESX capacity dashboard: https://grafana-route-grafana.apps.tpanpacmj14v.ebiz.verizon.com/d/JSqcRuXSz/cluster-capacity-v3?orgId=1
if our finance people want to see it so they can look for funding to buy more, they should be able to. today we have to send them screenshots.
1:26
how's later today? :slightly_smiling_face:
1:26
otherwise, no.
1:27
however, here is my big picture vision. if the enterprise command center can look at our dashboards to see if a cluster is healthy, it might help prevent us from getting late night calls when app teams want us to fix their application issues that aren't really platform-related.
