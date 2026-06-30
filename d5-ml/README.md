# SENTINELA · D5 — Machine Learning & Modelling

## Objetivo
Classificação binária de eventos climáticos extremos (precipitação > 30mm/24h)
a partir de dados históricos do INMET — Porto Alegre, 2014–2025.

## Dataset
- Fonte: INMET (portal.inmet.gov.br/dadoshistoricos)
- Período: 2014-01-05 a 2025-12-31
- Amostras: 4.379 dias | 25 features
- Desbalanceamento: 97.2% sem evento · 2.8% evento extremo

## Features utilizadas
Dados meteorológicos do dia anterior e histórico recente:
pressao_hpa, temperatura_c, temp_max_c, temp_min_c, umidade_pct,
chuva_lag1, chuva_lag2, pressao_lag1, chuva_mm7d, temp_mm7d,
umid_mm7d, pressao_delta + dummies de mês (mes_1 a mes_12)

Nota: chuva_mm_dia excluída das features — é a base do target,
incluí-la seria data leakage.

## Split temporal
80/20 sem shuffle — treino até 2023-08-08, teste de 2023-08-09 em diante.
Ordem cronológica preservada para evitar vazamento de dados futuros.

## Modelos e métricas

| Modelo           | Accuracy | Precision | Recall | F1     |
|------------------|----------|-----------|--------|--------|
| Random Forest    | 0.9943   | 1.0000    | 0.1667 | 0.2857 |
| XGBoost (tuned)  | 0.9897   | 0.2000    | 0.1667 | 0.1818 |

**Vencedor: Random Forest (F1 = 0.2857)**

Interpretação: precision 1.0 significa zero falsos alarmes —
quando o modelo dispara, o evento é real. Recall de 16.7% indica
que ainda perde a maioria dos eventos, problema a ser atacado
pelo D7 (rede neural MLP) usando a mesma base comparativa.

## XGBoost — melhores hiperparâmetros (GridSearchCV temporal)
- learning_rate: 0.1
- max_depth: 5
- n_estimators: 200
- subsample: 0.8
- scale_pos_weight: 29.2 (compensa desbalanceamento)

## Feature importance (RF)
Top 3: umidade_pct · pressao_hpa · temp_max_c
Lags e médias móveis contribuem — confirmam que o histórico
recente tem poder preditivo.

## Arquivos gerados
- modelo_chuva.pkl       → importado pelo D4 (app Python)
- modelo_meta.json       → metadados de features e métricas
- matrizes_confusao.png  → visualização dos resultados
- feature_importance.png → top 15 variáveis

## Conexão SENTINELA
D8 (estatística histórica) → D5 (modelo treinado) → D4 (alertas) + D7 (baseline MLP)
