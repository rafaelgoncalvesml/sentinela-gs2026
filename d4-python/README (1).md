# SENTINELA · D4 — Computational Thinking with Python

**Global Solution 2026.1 · FIAP**
**Dupla:** Rafael & Charles

## Sobre

Aplicativo de linha de comando (CLI) para monitoramento de eventos
climáticos do sistema SENTINELA. Cadastra leituras de estações, classifica
automaticamente o risco de desastre, gera alertas e produz relatórios para
apoio à tomada de decisão da defesa civil.

## Como executar

```bash
python sentinela_app.py
```

Requer apenas Python 3.x (sem bibliotecas externas — usa só a biblioteca padrão).

## Funcionalidades

| Opção | Função |
|---|---|
| 1 | Cadastrar evento climático (com classificação automática de risco) |
| 2 | Listar todos os eventos |
| 3 | Atualizar precipitação de um evento (reclassifica o risco) |
| 4 | Confirmar alerta (governança — operador reconhece) |
| 5 | Deletar evento |
| 6 | Ver indicadores agregados |
| 7 | Gerar relatório em arquivo .txt |
| 0 | Sair |

## Classificação de risco

A classificação é feita pela precipitação em mm (alinhada ao threshold
meteorológico usado em todo o SENTINELA):

| Faixa | Risco | Nível de alerta |
|---|---|---|
| < 10mm | BAIXO | INFO |
| 10–30mm | MEDIO | ATENCAO |
| 30–60mm | ALTO | PERIGO |
| > 60mm | CRITICO | EMERGENCIA |

## Conceitos da disciplina aplicados

- **Variáveis e tipos**: dados dos eventos
- **Condicionais**: classificação de risco por thresholds
- **Repetições**: menu while loop, iteração sobre eventos
- **Listas e dicionários**: estrutura de eventos (lista de dicionários)
- **Funções**: CRUD, classificação, relatório (modularização)
- **Manipulação de arquivos**: persistência JSON + relatório TXT (UTF-8)
- **Tratamento de erros**: try/except em I/O e conversões numéricas

## Arquivos

- `sentinela_app.py` — código principal
- `eventos_sentinela.json` — banco de dados local (gerado na execução)
- `relatorio_sentinela.txt` — relatório (gerado pela opção 7)

## Conexão SENTINELA

Este app é a camada de usuário do sistema. Consome o esquema de dados
modelado no D3 (mesmos campos: região, tipo, precipitação, risco) e os
dados ingeridos pelo pipeline AWS do D6. A classificação de risco usa o
mesmo threshold de 30mm que orienta os modelos de ML do D5 e D7 e a análise
estatística do D8.
