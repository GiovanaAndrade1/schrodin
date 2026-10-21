# Instruções para agentes de código (Codex)

Este repositório contém o projeto Schrödin, um gerenciador financeiro pessoal. A documentação em `docs/` define o escopo atual.

## Diretrizes
- Antes de alterar arquivos, leia `README.md` e `docs/requirements.md`.
- Trabalhe em pequenas etapas, explique as mudanças e liste os testes executados.
- Não declare funcionalidades como implementadas se ainda estiverem apenas planejadas.
- Use Python/Django no backend; mantenha separação entre regras de domínio, persistência e interface.
- Projete endpoints e autenticação com possibilidade de cliente mobile no futuro.
- Proteja dados entre usuários; teste autorização e isolamento de recursos.
- Use Decimal para dinheiro e transações atômicas para operações relacionadas.
- Nunca adicione credenciais, tokens, segredos ou arquivos .env reais ao Git.
- Não apague histórico financeiro em cascata sem aprovação explícita.
- Não acrescente dependências sem justificar.
- Não realize deploy nem altere infraestrutura externa sem autorização.
