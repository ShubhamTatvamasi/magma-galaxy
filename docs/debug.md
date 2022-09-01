# Debug 

Deploy kibana dashboard:
```bash
helm upgrade -i kibana elastic/kibana \
  --set service.type=LoadBalancer
```
> Note: you will need another IP for this.

http://192.168.5.58:5601

Request for getting event and log counts:
```bash
curl http://elasticsearch-master:9200//_count; echo
curl http://elasticsearch-master:9200/eventd%2A/_count; echo
curl http://elasticsearch-master:9200/magma%2A/_count; echo
```

Keep deleting prometheus-cache pod if you have limited storage:
```bash
kubectl delete pod -l app.kubernetes.io/component=prometheus-cache
```
