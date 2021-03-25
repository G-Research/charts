## Install

```
git clone https://github.com/G-Research/siembol.git
cd src/siembol
helm dep up
helm install -f values.yaml siembol  .
```

## Known Issues

1. It doesn't quite work yet...
2. #1 is because kafka expects zookeeper to be named zookeeper-0, zookeeper-1, etc.. Because we're using Storm's zookeeper, the naming convention is storm-zookeeper.  We can either:
   1. Override the name of the storm zookeeper.  Probably easy to do, but this zookeeper may not be the most robust in terms of configurable options -- the helm charts in the kafka and incubator charts look more fully-featured.
   2. Disable both the kafka and storm zookeeper dependencies and then try and use the incubator/zookeeper helm chart
   2. Somehow make it work where the Storm zookeeper is disabled and the Kafka zookeeper is enabled.  We'd need to. figure out how to point Storm at zookeeeper-[0-n], in that case (the reverse problem of now)