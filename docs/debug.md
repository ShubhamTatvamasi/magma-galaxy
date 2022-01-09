# Debug 

Deploy kibana dashboard:
```bash
helm upgrade -i kibana elastic/kibana \
  --set service.type=LoadBalancer
```
> Note: you will need another IP for this.

http://192.168.5.58:5601

