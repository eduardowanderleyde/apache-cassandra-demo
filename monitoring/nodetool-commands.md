# Nodetool Commands Reference

Nodetool is a command-line interface for managing and monitoring Apache Cassandra clusters. This guide covers the most commonly used commands for cluster administration.

## Basic Cluster Information

### Check Cluster Status
```bash
# Show status of all nodes in the cluster
nodetool status

# Show status with additional details
nodetool status --verbose

# Show status for a specific keyspace
nodetool status <keyspace_name>
```

### Cluster Information
```bash
# Show cluster name
nodetool describecluster

# Show ring information (token distribution)
nodetool ring

# Show network topology
nodetool netstats

# Show cluster information
nodetool info
```

## Node Management

### Node Operations
```bash
# Decommission a node (remove from cluster)
nodetool decommission

# Remove a node from the cluster
nodetool removenode <node_id>

# Rebuild a node from other nodes
nodetool rebuild -- <datacenter_name>

# Move a node to a different token range
nodetool move <new_token>
```

### Node Health
```bash
# Check if a node is responding
nodetool ping

# Show node statistics
nodetool tpstats

# Show thread pool statistics
nodetool tpstats --verbose

# Show garbage collection statistics
nodetool gcstats
```

## Performance Monitoring

### Compaction
```bash
# Show compaction statistics
nodetool compactionstats

# Show compaction history
nodetool compactionhistory

# Trigger manual compaction
nodetool compact <keyspace_name> <table_name>

# Stop all compactions
nodetool stop COMPACTION
```

### Memory and Cache
```bash
# Show memory usage
nodetool info

# Show cache statistics
nodetool cfstats

# Show table statistics
nodetool tablestats <keyspace_name>.<table_name>

# Show column family statistics
nodetool cfhistograms <keyspace_name> <table_name>
```

## Data Management

### Keyspace Operations
```bash
# Show all keyspaces
nodetool describecluster

# Show keyspace details
nodetool describering <keyspace_name>

# Show table details
nodetool describecluster <keyspace_name>.<table_name>
```

### Backup and Repair
```bash
# Trigger repair on a keyspace
nodetool repair <keyspace_name>

# Show repair status
nodetool repair_admin

# Trigger backup
nodetool snapshot <keyspace_name>

# List snapshots
nodetool listsnapshots

# Clear snapshots
nodetool clearsnapshot
```

## Network and Connectivity

### Network Statistics
```bash
# Show network statistics
nodetool netstats

# Show gossip information
nodetool gossipinfo

# Show endpoint information
nodetool endpointsnitch
```

### Connection Management
```bash
# Show client connections
nodetool clientstats

# Show connection pool statistics
nodetool tpstats
```

## Troubleshooting Commands

### Diagnostic Commands
```bash
# Show system logs
nodetool getlogginglevels

# Set logging level
nodetool setlogginglevel <class_name> <level>

# Show system properties
nodetool getcompactionthreshold <keyspace_name> <table_name>

# Set compaction threshold
nodetool setcompactionthreshold <keyspace_name> <table_name> <min_threshold> <max_threshold>
```

### Performance Tuning
```bash
# Show performance statistics
nodetool cfstats

# Show histogram data
nodetool cfhistograms <keyspace_name> <table_name>

# Show table statistics
nodetool tablestats <keyspace_name>.<table_name>
```

## Example Usage Scenarios

### Daily Health Check
```bash
# 1. Check cluster status
nodetool status

# 2. Check node health
nodetool info

# 3. Check performance
nodetool tpstats

# 4. Check compaction
nodetool compactionstats
```

### Before Maintenance
```bash
# 1. Check cluster health
nodetool status

# 2. Check repair status
nodetool repair_admin

# 3. Create backup
nodetool snapshot <keyspace_name>

# 4. Check compaction
nodetool compactionstats
```

### After Issues
```bash
# 1. Check node status
nodetool status

# 2. Check logs
nodetool getlogginglevels

# 3. Check performance
nodetool tpstats

# 4. Check network
nodetool netstats
```

## Tips and Best Practices

1. **Regular Monitoring**: Run status checks daily
2. **Log Levels**: Adjust logging levels for troubleshooting
3. **Performance**: Monitor tpstats and cfstats regularly
4. **Backup**: Create snapshots before major operations
5. **Repair**: Schedule regular repairs for data consistency

## Common Issues and Solutions

### Node Not Responding
```bash
# Check if node is reachable
nodetool ping

# Check network statistics
nodetool netstats

# Check thread pools
nodetool tpstats
```

### Performance Issues
```bash
# Check compaction
nodetool compactionstats

# Check memory usage
nodetool info

# Check table statistics
nodetool cfstats
```

### Data Consistency
```bash
# Check repair status
nodetool repair_admin

# Trigger repair
nodetool repair <keyspace_name>

# Check cluster status
nodetool status
```
