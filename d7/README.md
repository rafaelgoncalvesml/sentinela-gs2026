# D7 — Redes Neurais (MLP) · SENTINELA GS 2026.1

## Objetivo
MLP para classificação de eventos climáticos extremos (chuva > 30mm/24h).
Mesmo dataset e split do D5 — comparação direta entre ML clássico e rede neural.

## Arquitetura
Dense(64, relu) → Dropout(0.2) → Dense(32, relu) → Dense(1, sigmoid)

## Arquivos
- `sentinela_d7_mlp.ipynb` — notebook completo
- `sentinela_mlp_d7.keras` — modelo treinado
- `sentinela_scaler_d7.pkl` — scaler (fit no treino)
- `sentinela_imputer_d7.pkl` — imputer (fit no treino)
