# Schrödin 🐈

**Seu dinheiro existe. Provavelmente.**

Projeto de aplicação web de gerenciamento financeiro pessoal com **Python, Django e PostgreSQL**, planejado com arquitetura modular e interface responsiva.

O nome combina o experimento mental do gato de Schrödinger com *dinheiro*.

> **Status:** projeto Django inicializado com PostgreSQL. As funcionalidades ainda não estão implementadas.

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
├── backend/
│   ├── apps/
│   │   ├── core/        modelo base e rotas comuns
│   │   └── users/       usuário com fuso horário
│   ├── config/          settings e urls do Django
│   ├── manage.py
│   └── pyproject.toml
├── docs/
├── docker-compose.yml
├── .env.example
├── AGENTS.md
└── README.md
```

## Documentação
- [Requisitos e regras de negócio](docs/requirements.md)
- [Modelo de dados preliminar](docs/data-model.md)
- [Roadmap](docs/roadmap.md)

## Desenvolvimento
Pré-requisitos: Python 3.14, [uv](https://docs.astral.sh/uv/) e Docker.

```bash
cp .env.example .env
docker compose up -d db
cd backend
uv sync
uv run python manage.py migrate
uv run python manage.py runserver
```

`GET http://localhost:8000/health` consulta o banco: responde `200 {"status": "ok", "database": "ok"}`, ou `503` se o Postgres estiver fora do ar.

## Segurança
Credenciais e dados financeiros reais não devem ser versionados.

## Licença
A licença ainda não foi definida.
