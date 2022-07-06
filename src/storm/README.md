## Storm
[Apache Storm](http://storm.apache.org/) is a free and open source distributed realtime computation system. Storm makes it easy to reliably process unbounded streams of data, doing for realtime processing what Hadoop did for batch processing. Storm is simple, can be used with any programming language, and is a lot of fun to use!

### Prerequisites

This example assumes you have a Kubernetes cluster installed and
running, and that you have installed the ```kubectl``` command line
tool somewhere in your path. Please see the [getting
started](https://kubernetes.io/docs/tutorials/kubernetes-basics/) for installation
instructions for your platform.

### Installing the Chart

To install the chart with the release name `my-storm`:

```bash
$ helm repo add gresearch https://g-research.github.io/charts
$ helm install my-storm gresearch/storm
```

## Configuration

The following table lists the configurable parameters of the Storm chart and their default values.

### Global
| Parameter                         | Description                      | Default             |
| --------------------------------- | ---------------------------      | ------------------- |
| `nameOverride`                    | Override to expand name of chart | ""                  |
| `fullnameOverride`                | Override App Name                | ""                  |
| `enabled`                         | Enable chart                     | true                |
| `namespace`                       | Override namespace               | ""                  |

### Nimbus
| Parameter                         | Description                 | Default             |
| --------------------------------- | --------------------------- | ------------------- |
| `nimbus.replicaCount`             | Number of replicas          | 1                   |
| `nimbus.image.repository`         | Container image name        | storm               |
| `nimbus.image.tag`                | Container image version     | 2.4.0               |
| `nimbus.image.pullPolicy`         | The default pull policy     | IfNotPresent        |
| `nimbus.service.name`             | Service name                | nimbus              |
| `nimbus.service.type`             | Service Type                | ClusterIP           |
| `nimbus.service.port`             | Service Port                | 6627                |
| `nimbus.resources.limits.cpu`     | Compute resources           | 100m                |

### Supervisor
| Parameter                              | Description                    | Default             |
| ---------------------------------      | ---------------------------    | ------------------- |
| `supervisor.replicaCount`              | Number of replicas             | 2                   |
| `supervisor.image.repository`          | Container image name           | storm               |
| `supervisor.image.tag`                 | Container image version        | 2.4.0               |
| `supervisor.image.pullPolicy`          | The default pull policy        | IfNotPresent        |
| `supervisor.service.name`              | Service Name                   | supervisor          |
| `supervisor.service.type`              | Service Type                   | ClusterIP           |
| `supervisor.slots`                     | Slots/Workers (one port each)  | 4                   |
| `supervisor.resources.requests.memory` | Compute Resouces               | 512Mi               | 
| `supervisor.resources.requests.cpu`    | Compute Resouces               | 1                   |
| `supervisor.resources.limits.memory`   | Compute Resouces               | 1024Mi              | 
| `supervisor.resources.limits.cpu`      | Compute Resouces               | 2                   |
| `supervisor.extraVolumes`              | Optionally specify extra list of additional volumes  | []            |
| `supervisor.extraVolumeMounts`         | Optionally specify extra list of additional volumeMounts | []         |

### User Interface   
| Parameter                         | Description                 | Default             |
| --------------------------------- | --------------------------- | ------------------- |                      
| `ui.enabled`                      | Enable the UI               | true                |
| `ui.replicaCount`                 | Number of replicas          | 1                   |
| `ui.image.repository`             | Container image name        | storm               |
| `ui.image.tag`                    | UI image version            | 2.4.0               |
| `ui.image.pullPolicy`             | The default pull policy     | IfNotPresent        |
| `ui.service.type`                 | UI Service Type             | ClusterIP           |
| `ui.service.name`                 | UI service name             | ui                  |
| `ui.service.port`                 | UI service port             | 8080                |
| `ui.resources.limits.cpu`         | Compute resources           | 100m                |
| `ui.header.bufferbytes`           | Max size of headers         | 8192kB              |

### Zookeeper
| Parameter                         | Description                 | Default             |
| --------------------------------- | --------------------------- | ------------------- |
| `zookeeper.enabled`               | Enable Zookeeper            | true                |
| `zookeeper.service.name`          | Service name                | zookeeper           |


### Store
| Parameter                         | Description                 | Default             |
| --------------------------------- | --------------------------- | ------------------- |
| `store.localdatadir`              | Data dir location           | /data               |
| `store.logdir`                    | Logs dir location           | /logs               |
| `store.log4j2conf`                | Log4j2 dir location         | /log4j2             |
| `store.config`                    | Config dir location         | /conf               |
| `store.metricsdb`                 | Metrics db dir location     | /storm_rocks        |

### Security
| Parameter                         | Description                 | Default             |
| --------------------------------- | --------------------------- | ------------------- |
| `security.userid`                 | Run as user                 | 1000                |
| `security.groupid`                | Group ID                    | 2000                |

### Topology
| Parameter                             | Description                  | Default             |
| ---------------------------------     | ---------------------------  | ------------------- |
| `topology.javaserialization`          | Set Java Serialization       | true                |
| `topology.loadaware.disablemessaging` | Disable loadaware messaging  | true                |

### JMX
| Parameter                         | Description                            | Default             |
| --------------------------------- | ---------------------------            | ------------------- |
| `jmx.enabled`                     | Enable JMX exporter metrics service    | false                |
| `jmx.config`                      | Storm metrics to export                | .*                  |

### Exporters
| Parameter                         | Description                            | Default             |
| --------------------------------- | ---------------------------            | ------------------- |
| `exporter.prometheus.enabled`     | Enable Prometheus exporter             | true                |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml incubator/storm
```

> **Tip**: You can use the default [values.yaml](values.yaml)
