# Schrödin 🐈

**Seu dinheiro existe. Provavelmente.**

Aplicação web de gerenciamento financeiro pessoal desenvolvida com **Python e Django**, planejada com arquitetura modular, persistência de dados e interface responsiva.

O nome combina o experimento mental do gato de Schrödinger com *din-din*: seu saldo não precisa continuar sendo um mistério.

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

## Tecnologias previstas
- **Backend:** Python, Django.
- **Banco de dados:** definido na etapa de implementação (SQLite pode ser usado localmente).
- **Frontend:** tecnologia a definir, com design responsivo.
- **Qualidade:** testes automatizados, Git e GitHub.

## Organização
```text
schrodin/
├── docs/
│   ├── requirements.md
│   ├── data-model.md
│   └── roadmap.md
├── AGENTS.md
├── .env.example
├── .gitignore
└── README.md
```
As pastas de código serão criadas quando a stack de interface e a estrutura Django forem inicializadas.

## Documentação
- [Requisitos e regras de negócio](docs/requirements.md)
- [Modelo de dados preliminar](docs/data-model.md)
- [Roadmap](docs/roadmap.md)

## Desenvolvimento
O primeiro passo técnico será validar o diagrama entidade-relacionamento (DER), criar o projeto Django e implementar os modelos e testes. **Ainda não há comandos de instalação ou execução**, pois a aplicação não foi inicializada.

## Segurança
Nunca versionar credenciais ou dados financeiros reais. O arquivo `.env.example` contém apenas valores ilustrativos.

## Licença
A licença ainda não foi definida.
