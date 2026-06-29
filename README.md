# SENTINELA — Previsão de Eventos Climáticos Extremos

> Sistema IoT + IA para previsão de eventos climáticos extremos com antecedência,
> inspirado nas enchentes de Porto Alegre (RS) em 2024.

📹 [Pitch de apresentação](https://youtu.be/UleuMJZ3Sb0)

Global Solution 2026.1 — FIAP
Rafael Gonçalves (RM 569461) + Charles Augusto (RM 571908)

---

## O problema

As enchentes de 2024 no RS afetaram 2,3 milhões de pessoas.
Os sistemas de alerta atuais são reativos: o desastre começa antes do aviso chegar.
O SENTINELA propõe inverter essa lógica — prever eventos extremos antes que aconteçam,
combinando sensores ESP32 no campo com modelos de ML treinados em 11 anos de dados do INMET.

## Arquitetura
sensor ESP32 (D1) → AWS S3 + Lambda (D6) → RDS MySQL (D3)
→ análise estatística (D8) → ML clássico (D5) → MLP/DL (D7)
→ app + alertas (D4) · cybersec (D2)

## Disciplinas neste repositório (frente Rafael)

| Pasta | Disciplina | O que tem |
|---|---|---|
| `d1-sensores/` | AI Computer Systems & Sensors | ESP32 + sensor de umidade/temp, simulação Wokwi |
| `d5-ml/` | Machine Learning & Modelling | Random Forest, feature engineering, avaliação |
| `d7-neural/` | Redes Neurais e Deep Learning | MLP com Keras, curvas de treino, matriz de confusão |

As disciplinas D2, D3, D6, D8 e D4 foram desenvolvidas por Charles Augusto.

## Dataset

INMET histórico · Porto Alegre · 2014–2025
11 anos de dados meteorológicos diários com feature engineering de séries temporais
(lags, médias móveis 7 dias, deltas de pressão).

## Resultados — Random Forest (D5)

Target: classificação binária de `evento_extremo`

| Métrica | Valor |
|---|---|
| Precision | 100% |
| Recall | 16,7% |
| F1-score | 0,29 |

> O modelo não emite falsos alarmes (precision 1.0) — toda predição positiva é um
> evento real. O recall baixo reflete a raridade dos eventos extremos na série histórica.
> Próximo passo: ajuste de threshold e integração da telemetria em tempo real do ESP32.

## Resultados — MLP / Deep Learning (D7)

[Preenche com os valores do notebook após rodar]

## Como rodar

```bash
pip install pandas scikit-learn keras tensorflow matplotlib seaborn
jupyter notebook
```

Abrir em ordem: `d5-ml/` → `d7-neural/`
