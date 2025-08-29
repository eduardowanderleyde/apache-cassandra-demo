# Multi-Node Cassandra Cluster Configuration

This guide covers advanced configuration for multi-node Cassandra clusters, including scaling, load balancing, and high availability.

## Cluster Topology

### Basic 3-Node Cluster
```
                    [Client Applications]
                           |
                    [Load Balancer]
                           |
        ┌──────────┬──────────┬──────────┐
        │          │          │          │
    [Node 1]   [Node 2]   [Node 3]   [Node N]
        │          │          │          │
    [DC1/R1]  [DC1/R1]  [DC1/R1]  [DC1/R1]
```

### Multi-Datacenter Cluster
```
                    [Client Applications]
                           |
                    [Load Balancer]
                           |
        ┌─────────────────┬─────────────────┐
        │                 │                 │
    [Datacenter 1]   [Datacenter 2]   [Datacenter 3]
        │                 │                 │
    [Node 1,2,3]     [Node 4,5,6]     [Node 7,8,9]
    [Rack 1,2,3]     [Rack 1,2,3]     [Rack 1,2,3]
```

## Configuration Files

### cassandra.yaml - Key Settings

```yaml
# Cluster Configuration
cluster_name: 'MultiNodeCluster'
num_tokens: 256
initial_token:

# Network Configuration
listen_address: ${CASSANDRA_LISTEN_ADDRESS}
rpc_address: ${CASSANDRA_RPC_ADDRESS}
rpc_port: 9160

# Gossip and Seeds
endpoint_snitch: GossipingPropertyFileSnitch
seeds: "192.168.1.10,192.168.1.11,192.168.1.12"

# Data Storage
data_file_directories:
    - /var/lib/cassandra/data
commitlog_directory: /var/lib/cassandra/commitlog

# Performance Tuning
concurrent_reads: 32
concurrent_writes: 32
memtable_heap_space_in_mb: 2048
memtable_offheap_space_in_mb: 0

# Compaction
compaction_throughput_mb_per_sec: 16
compaction_large_partition_warning_threshold_mb: 100
```

### cassandra-rackdc.properties

```properties
# Datacenter and Rack Configuration
dc=datacenter1
rack=rack1

# Additional datacenter configurations
# dc2=datacenter2
# rack2=rack2
```

### cassandra-topology.properties

```properties
# Network Topology Configuration
# IP=Data Center:Rack
192.168.1.10=DC1:RAC1
192.168.1.11=DC1:RAC1
192.168.1.12=DC1:RAC2
192.168.1.13=DC1:RAC2
192.168.1.14=DC2:RAC1
192.168.1.15=DC2:RAC1
```

## Deployment Strategies

### 1. Single Datacenter, Multiple Racks

```yaml
# docker-compose.yml for single DC, multiple racks
version: '3.8'
services:
  cassandra-node1:
    environment:
      - CASSANDRA_DC=datacenter1
      - CASSANDRA_RACK=rack1
      - CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch
      - CASSANDRA_SEEDS=cassandra-node1,cassandra-node2,cassandra-node3

  cassandra-node2:
    environment:
      - CASSANDRA_DC=datacenter1
      - CASSANDRA_RACK=rack2
      - CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch
      - CASSANDRA_SEEDS=cassandra-node1,cassandra-node2,cassandra-node3

  cassandra-node3:
    environment:
      - CASSANDRA_DC=datacenter1
      - CASSANDRA_RACK=rack3
      - CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch
      - CASSANDRA_SEEDS=cassandra-node1,cassandra-node2,cassandra-node3
```

### 2. Multi-Datacenter Setup

```yaml
# docker-compose.yml for multi-DC
version: '3.8'
services:
  # Datacenter 1
  cassandra-dc1-node1:
    environment:
      - CASSANDRA_DC=datacenter1
      - CASSANDRA_RACK=rack1
      - CASSANDRA_SEEDS=cassandra-dc1-node1,cassandra-dc2-node1

  cassandra-dc1-node2:
    environment:
      - CASSANDRA_DC=datacenter1
      - CASSANDRA_RACK=rack2
      - CASSANDRA_SEEDS=cassandra-dc1-node1,cassandra-dc2-node1

  # Datacenter 2
  cassandra-dc2-node1:
    environment:
      - CASSANDRA_DC=datacenter2
      - CASSANDRA_RACK=rack1
      - CASSANDRA_SEEDS=cassandra-dc1-node1,cassandra-dc2-node1

  cassandra-dc2-node2:
    environment:
      - CASSANDRA_DC=datacenter2
      - CASSANDRA_RACK=rack2
      - CASSANDRA_SEEDS=cassandra-dc1-node1,cassandra-dc2-node1
```

## Scaling Operations

### Adding New Nodes

1. **Prepare the new node**
   ```bash
   # Copy configuration files
   cp configs/cassandra.yaml /etc/cassandra/
   cp configs/cassandra-rackdc.properties /etc/cassandra/
   
   # Set node-specific settings
   sed -i 's/listen_address: localhost/listen_address: NEW_NODE_IP/' /etc/cassandra/cassandra.yaml
   sed -i 's/rpc_address: localhost/rpc_address: NEW_NODE_IP/' /etc/cassandra/cassandra.yaml
   ```

2. **Start the new node**
   ```bash
   # Start Cassandra service
   systemctl start cassandra
   
   # Check if node joins cluster
   nodetool status
   ```

3. **Rebalance the cluster**
   ```bash
   # Rebalance tokens across all nodes
   nodetool rebalance
   
   # Check token distribution
   nodetool ring
   ```

### Removing Nodes

1. **Decommission a node**
   ```bash
   # Gracefully remove node from cluster
   nodetool decommission
   
   # Wait for completion
   nodetool status
   ```

2. **Remove failed nodes**
   ```bash
   # Remove a failed node
   nodetool removenode <node_id>
   
   # Verify removal
   nodetool status
   ```

## Load Balancing

### Client-Side Load Balancing

```java
// Java driver example
Cluster cluster = Cluster.builder()
    .addContactPoint("192.168.1.10")
    .addContactPoint("192.168.1.11")
    .addContactPoint("192.168.1.12")
    .withLoadBalancingPolicy(new TokenAwarePolicy(DCAwareRoundRobinPolicy.builder().build()))
    .build();
```

### Application-Level Load Balancing

```python
# Python driver example
from cassandra.cluster import Cluster
from cassandra.policies import TokenAwarePolicy, DCAwareRoundRobinPolicy

cluster = Cluster(
    contact_points=['192.168.1.10', '192.168.1.11', '192.168.1.12'],
    load_balancing_policy=TokenAwarePolicy(DCAwareRoundRobinPolicy())
)
```

## High Availability

### Replication Strategy

```sql
-- NetworkTopologyStrategy for multi-DC
CREATE KEYSPACE demo_keyspace 
WITH replication = {
    'class': 'NetworkTopologyStrategy',
    'datacenter1': 3,
    'datacenter2': 2
};

-- SimpleStrategy for single DC
CREATE KEYSPACE demo_keyspace 
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 3
};
```

### Consistency Levels

```sql
-- Strong consistency
INSERT INTO users (user_id, username) VALUES (uuid(), 'john') USING CONSISTENCY ALL;

-- Eventual consistency
INSERT INTO users (user_id, username) VALUES (uuid(), 'john') USING CONSISTENCY ONE;

-- Read consistency
SELECT * FROM users USING CONSISTENCY QUORUM;
```

## Monitoring and Maintenance

### Health Checks

```bash
# Daily health check script
#!/bin/bash
echo "=== Cluster Health Check ==="
echo "1. Cluster Status:"
nodetool status

echo "2. Node Health:"
nodetool info

echo "3. Performance:"
nodetool tpstats

echo "4. Compaction:"
nodetool compactionstats
```

### Backup Strategy

```bash
# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/cassandra/$DATE"

mkdir -p $BACKUP_DIR

# Create snapshots for all keyspaces
nodetool snapshot --all

# Copy snapshots to backup directory
cp -r /var/lib/cassandra/data/*/snapshots/* $BACKUP_DIR/

# Clean up old snapshots
nodetool clearsnapshot
```

## Performance Tuning

### JVM Settings

```bash
# cassandra-env.sh
export CASSANDRA_HEAP_NEWSIZE="800M"
export CASSANDRA_MAX_HEAP_SIZE="4G"
export CASSANDRA_HEAPDUMP_DIR="/var/log/cassandra"

# GC tuning
export JVM_OPTS="$JVM_OPTS -XX:+UseG1GC"
export JVM_OPTS="$JVM_OPTS -XX:MaxGCPauseMillis=200"
export JVM_OPTS="$JVM_OPTS -XX:InitiatingHeapOccupancyPercent=45"
```

### System Tuning

```bash
# /etc/sysctl.conf
vm.max_map_count=1048575
vm.dirty_background_ratio=15
vm.dirty_ratio=80

# /etc/security/limits.conf
cassandra soft nofile 65536
cassandra hard nofile 65536
cassandra soft nproc 32768
cassandra hard nproc 32768
```

## Troubleshooting

### Common Issues

1. **Node not joining cluster**
   - Check network connectivity
   - Verify seed configuration
   - Check firewall settings

2. **Performance degradation**
   - Monitor compaction
   - Check memory usage
   - Review JVM settings

3. **Data inconsistency**
   - Run repairs regularly
   - Check replication factor
   - Monitor consistency levels

### Diagnostic Commands

```bash
# Check cluster health
nodetool status

# Check network
nodetool netstats

# Check performance
nodetool tpstats

# Check compaction
nodetool compactionstats

# Check repair status
nodetool repair_admin
```

## Best Practices

1. **Planning**
   - Plan cluster size based on data volume
   - Consider future growth
   - Design for failure

2. **Deployment**
   - Use consistent configuration across nodes
   - Test in staging environment
   - Document all changes

3. **Maintenance**
   - Regular health checks
   - Scheduled backups
   - Proactive monitoring

4. **Security**
   - Use authentication and authorization
   - Encrypt sensitive data
   - Regular security updates
