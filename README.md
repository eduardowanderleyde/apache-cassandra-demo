# Apache Cassandra Demo - Configuração de Cluster

Este projeto demonstra como configurar e gerenciar um cluster Apache Cassandra, incluindo configurações básicas, scripts de automação e exemplos práticos.

## 🎯 Objetivos

- Configurar um cluster Cassandra multi-node
- Demonstrar diferentes topologias de cluster
- Fornecer scripts de automação para deploy
- Exemplos de configuração para diferentes cenários

## 📁 Estrutura do Projeto

```
├── docs/                    # Documentação detalhada
├── configs/                 # Arquivos de configuração
├── scripts/                 # Scripts de automação
├── docker/                  # Configurações Docker
├── examples/                # Exemplos práticos
└── monitoring/              # Configurações de monitoramento
```

## 🚀 Início Rápido

1. **Clone o repositório**
   ```bash
   git clone git@github.com:eduardowanderleyde/apache-cassandra-demo.git
   cd apache-cassandra-demo
   ```

2. **Configurar cluster local com Docker**
   ```bash
   cd docker
   docker-compose up -d
   ```

3. **Verificar status do cluster**
   ```bash
   docker exec -it cassandra-node1 cqlsh -e "DESCRIBE CLUSTER"
   ```

## 🔧 Configurações Disponíveis

- **Cluster Single-Node**: Para desenvolvimento e testes
- **Cluster Multi-Node**: Para demonstração de distribuição
- **Cluster com SSL**: Para ambientes de produção
- **Cluster com Autenticação**: Com usuários e permissões

## 📚 Documentação

- [Guia de Configuração Básica](docs/basic-setup.md)
- [Configuração de Cluster Multi-Node](docs/multi-node-cluster.md)
- [Configuração de Segurança](docs/security-setup.md)
- [Monitoramento e Troubleshooting](docs/monitoring.md)

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

## 📄 Licença

Este projeto está sob a licença MIT.
