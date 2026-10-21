# Schrödin — Requisitos do produto

## Objetivo
Aplicação web responsiva de gestão financeira pessoal, com backend em Python/Django e arquitetura preparada para futura integração com aplicativo mobile.

## Escopo da primeira versão (MVP)
- Cadastro, autenticação e encerramento de sessão de usuários.
- Contas financeiras múltiplas por usuário.
- Categorias de receitas e despesas.
- Movimentações financeiras com valor, tipo, descrição, conta, categoria, data, situação e vencimento opcional.
- Situações: **pendente** e **realizada**.
- Listagem e filtros por conta, categoria, tipo, situação e período.
- Painel com saldos e visão consolidada.

## Regras de negócio
1. Cada usuário só pode acessar suas próprias contas, categorias e movimentações.
2. Valores monetários usam tipo decimal, nunca ponto flutuante binário.
3. Uma movimentação pertence a exatamente uma conta; transferências entre contas deverão ser modeladas como operação própria, preservando rastreabilidade.
4. Movimentações pendentes não afetam o saldo realizado.
5. Movimentações realizadas afetam o saldo realizado da conta: receitas somam, despesas subtraem.
6. Vencimento é opcional e distinto da data de efetivação.
7. Exclusão de conta com movimentações exige regra explícita de proteção ou arquivamento; não apagar histórico em cascata.
8. Alterações de situação devem manter consistência dos saldos e evitar dupla contabilização.
9. Operações e consultas sempre respeitam o proprietário autenticado.

## Versão 2
- Orçamentos por categoria, período e usuário.
- Alertas e relatórios avançados.

## Fora do escopo inicial
- Integração bancária automática.
- Processamento de pagamentos reais.
- Aplicativo mobile nativo (a API será preparada para isso).

## Critérios de qualidade
- Testes de isolamento entre usuários, cálculos, validações e transições de situação.
- Segredos fora do versionamento.
- Documentação e instruções de execução atualizadas.
