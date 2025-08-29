#!/bin/bash

# Cassandra Cluster Management Script
# This script helps manage a multi-node Cassandra cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="CassandraDemoCluster"
NODE_COUNT=3
DOCKER_COMPOSE_FILE="docker/docker-compose.yml"

echo -e "${GREEN}🚀 Starting Cassandra Cluster...${NC}"

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
        exit 1
    fi
}

# Function to check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose is not installed. Please install it first.${NC}"
        exit 1
    fi
}

# Function to start the cluster
start_cluster() {
    echo -e "${YELLOW}📦 Starting Cassandra nodes...${NC}"
    cd "$(dirname "$0")/.."
    docker-compose -f $DOCKER_COMPOSE_FILE up -d
    
    echo -e "${YELLOW}⏳ Waiting for nodes to be ready...${NC}"
    sleep 30
    
    echo -e "${YELLOW}🔍 Checking cluster status...${NC}"
    check_cluster_status
}

# Function to check cluster status
check_cluster_status() {
    echo -e "${YELLOW}📊 Cluster Status:${NC}"
    
    # Check if nodes are running
    for i in {1..3}; do
        container_name="cassandra-node$i"
        if docker ps | grep -q $container_name; then
            echo -e "${GREEN}✅ $container_name is running${NC}"
        else
            echo -e "${RED}❌ $container_name is not running${NC}"
        fi
    done
    
    # Check cluster information
    echo -e "${YELLOW}🔍 Cluster Information:${NC}"
    docker exec -it cassandra-node1 cqlsh -e "DESCRIBE CLUSTER" 2>/dev/null || echo "Cluster not ready yet"
}

# Function to stop the cluster
stop_cluster() {
    echo -e "${YELLOW}🛑 Stopping Cassandra cluster...${NC}"
    cd "$(dirname "$0")/.."
    docker-compose -f $DOCKER_COMPOSE_FILE down
    echo -e "${GREEN}✅ Cluster stopped${NC}"
}

# Function to show logs
show_logs() {
    echo -e "${YELLOW}📋 Showing logs for all nodes...${NC}"
    cd "$(dirname "$0")/.."
    docker-compose -f $DOCKER_COMPOSE_FILE logs -f
}

# Function to show help
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start     Start the Cassandra cluster"
    echo "  stop      Stop the Cassandra cluster"
    echo "  status    Check cluster status"
    echo "  logs      Show cluster logs"
    echo "  help      Show this help message"
    echo ""
}

# Main script logic
case "${1:-start}" in
    start)
        check_docker
        check_docker_compose
        start_cluster
        ;;
    stop)
        check_docker
        check_docker_compose
        stop_cluster
        ;;
    status)
        check_docker
        check_docker_compose
        check_cluster_status
        ;;
    logs)
        check_docker
        check_docker_compose
        show_logs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac
