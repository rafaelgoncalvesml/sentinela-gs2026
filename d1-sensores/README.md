# D1 — Sensores IoT (ESP32) · SENTINELA GS 2026.1

## Objetivo
Estação meteorológica simulada no Wokwi que capta dados ambientais
e dispara alertas locais quando detecta condições de evento extremo.

## Componentes
- DHT22 → temperatura_c, umidade_pct (GPIO15)
- Potenciômetro A → precipitacao_mm (GPIO34)
- Potenciômetro B → velocidade_vento_ms (GPIO35)
- Potenciômetro C → pressao_hpa, faixa 980–1030 hPa (GPIO32)
- LED vermelho → alerta visual (GPIO2)
- Buzzer → alerta sonoro, 2 kHz (GPIO4)

## Thresholds de alerta
| Sensor | Limite |
|:-------|-------:|
| Chuva | > 30 mm/h |
| Umidade | > 90% |
| Vento | > 20 m/s |

## Output serial (CSV)

timestamp_leitura,temperatura_c,umidade_pct,pressao_hpa,precipitacao_mm,velocidade_vento_ms

Campos alinhados com a tabela LEITURA do D3 (MER Charles).

## Simulação
[Abrir no Wokwi](https://wokwi.com/projects/465300118520840193)

## Arquivos
- `sketch.ino` — código Arduino completo
- `diagram.json` — circuito Wokwi
