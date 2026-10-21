# Modelo de dados preliminar

> Proposta de arquitetura; nenhum modelo Django ou tabela foi implementado ainda.

## Entidades
- **User**: usuário autenticado (modelo configurável do Django).
- **Account**: id (PK), user_id (FK), name, type, opening_balance (decimal), active, created_at.
- **Category**: id (PK), user_id (FK), name, kind (income/expense), created_at.
- **Transaction**: id (PK), user_id (FK), account_id (FK), category_id (FK opcional), kind (income/expense), amount (decimal positivo), description, status (pending/completed), due_date (opcional), effective_date (opcional), created_at, updated_at.

## Cardinalidades
- User 1:N Account
- User 1:N Category
- User 1:N Transaction
- Account 1:N Transaction
- Category 1:N Transaction (categoria opcional)

## Restrições propostas
- amount > 0.
- effective_date obrigatória quando status = completed.
- Account, Category e Transaction devem pertencer ao mesmo usuário.
- Category.kind compatível com Transaction.kind.
- Índices para user + status + due_date e account + effective_date.

## Saldo realizado
Saldo realizado da conta = opening_balance + soma(receitas realizadas) - soma(despesas realizadas).

## Próxima etapa
Validar as decisões acima, desenhar o DER e implementar modelos, migrações e testes Django com PostgreSQL. Transferências exigirão modelagem específica antes da implementação.
