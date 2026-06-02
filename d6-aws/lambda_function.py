import json
import boto3
import pymysql
import csv
import io
import logging
from datetime import datetime

# ── CONFIGURAÇÃO ─────────────────────────────────────────────────────────────
logger = logging.getLogger()
logger.setLevel(logging.INFO)

DB_HOST     = "sentinela-db.csqzck9hejns.us-east-1.rds.amazonaws.com"
DB_USER     = "admin"
DB_PASSWORD = "Sentinela2026!"
DB_NAME     = "sentinela"
DB_PORT     = 3306

# ID da estação padrão (EST-RS-001 inserida pelo DDL)
ID_ESTACAO_PADRAO = 1

# ── HANDLER PRINCIPAL ─────────────────────────────────────────────────────────
def lambda_handler(event, context):
    """
    Trigger: S3 PutObject na pasta leituras/*.csv
    Fluxo  : S3 → lê CSV → valida → INSERT em leitura → CloudWatch log
    """
    s3 = boto3.client('s3')

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key    = record['s3']['object']['key']

        logger.info(f"[SENTINELA] Arquivo recebido: s3://{bucket}/{key}")

        # Baixa o CSV do S3
        try:
            obj      = s3.get_object(Bucket=bucket, Key=key)
            conteudo = obj['Body'].read().decode('utf-8')
        except Exception as e:
            logger.error(f"[SENTINELA] Erro ao ler S3: {e}")
            raise

        # Processa e insere no RDS
        inseridos, erros = processar_csv(conteudo)

        logger.info(f"[SENTINELA] Processamento concluído: {inseridos} inseridos | {erros} erros")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'mensagem' : 'Pipeline SENTINELA executado com sucesso',
            'inseridos': inseridos,
            'erros'    : erros
        })
    }

# ── PROCESSAMENTO DO CSV ──────────────────────────────────────────────────────
def processar_csv(conteudo):
    """
    Lê CSV do sensor ESP32 (D1) e insere cada linha na tabela leitura.
    Header esperado: timestamp_s,temperatura_c,umidade_pct,pressao_hpa,chuva_mm,status
    """
    inseridos = 0
    erros     = 0

    conn = conectar_rds()
    if not conn:
        return 0, 1

    try:
        cursor = conn.cursor()
        reader = csv.DictReader(io.StringIO(conteudo))

        for i, linha in enumerate(reader):
            try:
                # Valida e converte os campos
                timestamp     = parse_timestamp(linha.get('timestamp_s', ''))
                temperatura   = float_seguro(linha.get('temperatura_c', ''))
                umidade       = float_seguro(linha.get('umidade_pct', ''))
                pressao       = float_seguro(linha.get('pressao_hpa', ''), None)
                precipitacao  = float_seguro(linha.get('chuva_mm', ''), 0.0)
                vento         = float_seguro(linha.get('velocidade_vento_ms', ''), None)

                # Validações físicas (mesmas do D3)
                if umidade is not None and not (0 <= umidade <= 100):
                    raise ValueError(f"umidade fora do range: {umidade}")
                if precipitacao is not None and precipitacao < 0:
                    raise ValueError(f"precipitacao negativa: {precipitacao}")

                sql = """
                    INSERT INTO leitura
                        (id_estacao, timestamp_leitura, temperatura_c,
                         umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                """
                cursor.execute(sql, (
                    ID_ESTACAO_PADRAO,
                    timestamp,
                    temperatura,
                    umidade,
                    pressao,
                    precipitacao,
                    vento
                ))
                inseridos += 1
                logger.info(f"[SENTINELA] Linha {i+1} inserida: ts={timestamp} | temp={temperatura} | precip={precipitacao}mm")

            except Exception as e:
                erros += 1
                logger.warning(f"[SENTINELA] Linha {i+1} ignorada: {e}")

        conn.commit()
        logger.info(f"[SENTINELA] COMMIT realizado — {inseridos} registros gravados no RDS")

    except Exception as e:
        logger.error(f"[SENTINELA] Erro no processamento: {e}")
        conn.rollback()
        erros += 1
    finally:
        conn.close()

    return inseridos, erros

# ── CONEXÃO RDS ───────────────────────────────────────────────────────────────
def conectar_rds():
    try:
        conn = pymysql.connect(
            host     = DB_HOST,
            user     = DB_USER,
            password = DB_PASSWORD,
            database = DB_NAME,
            port     = DB_PORT,
            connect_timeout = 10
        )
        logger.info("[SENTINELA] Conexão RDS estabelecida com sucesso")
        return conn
    except pymysql.MySQLError as e:
        logger.error(f"[SENTINELA] Falha na conexão RDS: {e}")
        return None

# ── UTILITÁRIOS ───────────────────────────────────────────────────────────────
def float_seguro(valor, padrao=None):
    """Converte string para float com segurança."""
    try:
        return float(valor) if valor and valor.strip() else padrao
    except (ValueError, AttributeError):
        return padrao

def parse_timestamp(valor):
    """
    Aceita dois formatos:
    - Unix timestamp em segundos: '1717200000'
    - ISO 8601: '2024-05-01 12:00:00'
    """
    if not valor or not valor.strip():
        return datetime.utcnow()
    try:
        return datetime.utcfromtimestamp(float(valor))
    except (ValueError, OSError):
        pass
    formatos = ['%Y-%m-%d %H:%M:%S', '%Y-%m-%dT%H:%M:%S', '%Y/%m/%d %H:%M:%S']
    for fmt in formatos:
        try:
            return datetime.strptime(valor.strip(), fmt)
        except ValueError:
            continue
    logger.warning(f"[SENTINELA] Timestamp inválido '{valor}' — usando now()")
    return datetime.utcnow()
