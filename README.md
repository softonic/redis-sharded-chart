# Redis Sharded Helm chart

Helm chart for using redis shards. It is loosely based on [Bitnami Redis Chart](https://github.com/bitnami/charts/tree/master/bitnami/redis) and uses [twemproxy](https://github.com/twitter/twemproxy).

# Why Redis Sharded?

Redis Sharded offers an easy way to use Redis with multiple independent master instances as shards, and optionally a twemproxy in front, so that the client can see it as a single redis instance.

# Quick Start

```bash
helm repo add softonic https://charts.softonic.io
helm install redis-sharded softonic/redis-sharded
```
