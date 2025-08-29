# Basic Cassandra Cluster Setup

This guide will walk you through setting up a basic 3-node Cassandra cluster using Docker.

## Prerequisites

- Docker installed and running
- Docker Compose installed
- At least 4GB of available RAM
- At least 10GB of available disk space

## Quick Start

1. **Clone the repository**
   ```bash
   git clone git@github.com:eduardowanderleyde/apache-cassandra-demo.git
   cd apache-cassandra-demo
   ```

2. **Start the cluster**
   ```bash
   ./scripts/start-cluster.sh start
   ```

3. **Check cluster status**
   ```bash
   ./scripts/start-cluster.sh status
   ```

4. **Connect to the cluster**
   ```bash
   docker exec -it cassandra-node1 cqlsh
   ```

## Cluster Architecture

The demo cluster consists of 3 nodes:

- **cassandra-node1**: Primary node (ports: 9042, 7000, 7001, 9160)
- **cassandra-node2**: Secondary node (ports: 9043, 7002, 7003, 9161)
- **cassandra-node3**: Tertiary node (ports: 9044, 7004, 7005, 9162)

## Port Mapping

| Service | Node 1 | Node 2 | Node 3 |
|---------|---------|---------|---------|
| CQL (Client) | 9042 | 9043 | 9044 |
| Inter-node | 7000 | 7002 | 7004 |
| SSL Inter-node | 7001 | 7003 | 7005 |
| Thrift | 9160 | 9161 | 9162 |

## Configuration Details

### Cluster Settings
- **Cluster Name**: CassandraDemoCluster
- **Data Center**: datacenter1
- **Rack**: rack1
- **Partitioner**: Murmur3Partitioner
- **Snitch**: SimpleSnitch

### Performance Settings
- **Concurrent Reads**: 32
- **Concurrent Writes**: 32
- **Memtable Heap Space**: 2048MB
- **Compaction Throughput**: 16MB/s

## Verification Commands

Once the cluster is running, you can verify it with these CQL commands:

```sql
-- Check cluster information
DESCRIBE CLUSTER;

-- Check keyspaces
DESCRIBE KEYSPACES;

-- Check nodes
SELECT * FROM system.peers;

-- Check local node
SELECT * FROM system.local;
```

## Troubleshooting

### Common Issues

1. **Nodes not joining cluster**
   - Check if all containers are running: `docker ps`
   - Verify network connectivity: `docker network ls`
   - Check logs: `./scripts/start-cluster.sh logs`

2. **Port conflicts**
   - Ensure ports 9042-9044, 7000-7005, 9160-9162 are available
   - Stop any existing Cassandra instances

3. **Memory issues**
   - Increase Docker memory limit to at least 4GB
   - Check system memory usage

### Useful Commands

```bash
# View all container logs
docker-compose -f docker/docker-compose.yml logs

# Restart a specific node
docker restart cassandra-node1

# Check cluster health
nodetool status

# View cluster topology
nodetool ring
```

## Next Steps

After basic setup, you can:
- [Configure Security](security-setup.md)
- [Set up Monitoring](monitoring.md)
- [Create Sample Data](examples/)
- [Scale the Cluster](multi-node-cluster.md)

## Support

If you encounter issues:
1. Check the logs first
2. Verify Docker and Docker Compose versions
3. Ensure sufficient system resources
4. Check network connectivity between containers
