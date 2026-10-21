# Schrödin 🐈

**Seu dinheiro existe. Provavelmente.**

Projeto de aplicação web de gerenciamento financeiro pessoal com **Python, Django e PostgreSQL**, planejado com arquitetura modular e interface responsiva.

O nome combina o experimento mental do gato de Schrödinger com *din-din*.

> **Status:** planejamento e documentação inicial. A aplicação ainda não está implementada.

## Funcionalidades planejadas — MVP
- Autenticação e isolamento dos dados por usuário.
- Múltiplas contas financeiras.
- Receitas e despesas categorizadas.
- Movimentações **pendentes** e **realizadas**, com vencimentos.
- Consulta de saldos realizados e painel consolidado.
- Interface web responsiva.

**Versão 2:** orçamentos por categoria.  
**Futuro:** integração com aplicativo mobile.

## Tecnologias definidas
- **Backend:** Python e Django.
- **Banco de dados:** PostgreSQL.
- **Frontend:** tecnologia ainda a definir, com interface responsiva.
- **Qualidade:** testes automatizados, Git e GitHub.

## Organização atual
```text
schrodin/
├── docs/
│   ├── requirements.md
│   ├── data-model.md
│   └── roadmap.md
├── AGENTS.md
└── README.md
```

Pastas de código e arquivos de configuração serão criados quando a implementação começar.

## Documentação
- [Requisitos e regras de negócio](docs/requirements.md)
- [Modelo de dados preliminar](docs/data-model.md)
- [Roadmap](docs/roadmap.md)

## Desenvolvimento
O próximo passo é validar o DER, inicializar o projeto Django e implementar os modelos e testes com PostgreSQL. Ainda não há comandos de instalação ou execução, pois a aplicação não foi inicializada.

## Segurança
Credenciais e dados financeiros reais não devem ser versionados.

## Licença
A licença ainda não foi definida.
