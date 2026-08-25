# Redis Sharded Helm chart

Helm chart for using redis shards. It is loosely based on [Bitnami Redis Chart](https://github.com/bitnami/charts/tree/master/bitnami/redis) and uses [twemproxy](https://github.com/twitter/twemproxy).

# Why Redis Sharded?

Redis Sharded offers an easy way to use Redis with multiple independent master instances as shards, and optionally a twemproxy in front, so that the client can see it as a single redis instance.

# Quick Start

```bash
helm repo add softonic https://charts.softonic.io
helm install redis-sharded softonic/redis-sharded
```

# Redis version

The Redis image tag defaults to the chart's `appVersion`, so bumping the chart moves Redis with it. Pin a specific version with `image.tag` when you need to stay put:

```yaml
image:
  tag: 8.10.1
```

# Upgrading

**Chart 0.5.0 moves the default from Redis 6.2 to Redis 8.10.** If your release has `persistence.enabled: true`, read this before upgrading.

Redis reads older on-disk data and converts it forward: a legacy single-file AOF is rewritten into the multi-part layout on first start, and any older RDB is loaded normally. **Going backwards does not work** — Redis refuses to load an RDB written by a newer version (`Can't handle RDB format version`), and Redis 6 cannot read a multi-part AOF directory at all.

The RDB format version by release:

| Redis | RDB version |
| --- | --- |
| 6.0 / 6.2 | 9 |
| 7.0 / 7.2 | 10 / 11 |
| 8.0 / 8.2 / 8.4 | 12 |
| 8.6 | 13 |
| 8.8 | 14 |
| 8.10 | 15 |

Note this applies **within Redis 8 too** — rolling 8.10 back to 8.0 fails the same way. So rolling the chart version back is not a recovery path once the data has been written.

If the release holds anything you cannot rebuild from another source, take a dump before upgrading. For a pure cache, no action is needed beyond expecting a cold start.

Each instance is a single pod with no replica, so an upgrade is a short outage for that shard rather than a failover. Stagger the rollout if you run several.
