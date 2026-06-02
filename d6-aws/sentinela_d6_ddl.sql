-- ============================================================
-- SENTINELA · D6 — Plataformas e Serviços Cognitivos AWS
-- DDL MySQL — RDS sentinela-db
-- Endpoint: sentinela-db.csqzck9hejns.us-east-1.rds.amazonaws.com
-- ============================================================

-- Cria e seleciona o banco
CREATE DATABASE IF NOT EXISTS sentinela;
USE sentinela;

-- 1. REGIAO
CREATE TABLE IF NOT EXISTS regiao (
    id_regiao   INT            NOT NULL AUTO_INCREMENT,
    nome        VARCHAR(100)   NOT NULL,
    estado      CHAR(2)        NOT NULL,
    latitude    DECIMAL(9,6)   NOT NULL,
    longitude   DECIMAL(9,6)   NOT NULL,
    area_km2    DECIMAL(12,2),
    CONSTRAINT pk_regiao PRIMARY KEY (id_regiao)
);

-- 2. ESTACAO
CREATE TABLE IF NOT EXISTS estacao (
    id_estacao    INT          NOT NULL AUTO_INCREMENT,
    id_regiao     INT          NOT NULL,
    codigo        VARCHAR(20)  NOT NULL,
    latitude      DECIMAL(9,6) NOT NULL,
    longitude     DECIMAL(9,6) NOT NULL,
    altitude_m    DECIMAL(7,2),
    ativa         CHAR(1)      NOT NULL DEFAULT 'S',
    dt_instalacao DATE         NOT NULL,
    CONSTRAINT pk_estacao        PRIMARY KEY (id_estacao),
    CONSTRAINT uk_estacao_codigo UNIQUE (codigo),
    CONSTRAINT fk_estacao_regiao FOREIGN KEY (id_regiao)
                                 REFERENCES regiao(id_regiao)
);

-- 3. LEITURA (tabela principal do pipeline S3 → Lambda → RDS)
CREATE TABLE IF NOT EXISTS leitura (
    id_leitura          INT            NOT NULL AUTO_INCREMENT,
    id_estacao          INT            NOT NULL,
    timestamp_leitura   DATETIME       NOT NULL,
    temperatura_c       DECIMAL(5,2)   NOT NULL,
    umidade_pct         DECIMAL(5,2)   NOT NULL,
    pressao_hpa         DECIMAL(7,2),
    precipitacao_mm     DECIMAL(7,2)   NOT NULL DEFAULT 0,
    velocidade_vento_ms DECIMAL(5,2),
    CONSTRAINT pk_leitura          PRIMARY KEY (id_leitura),
    CONSTRAINT fk_leitura_estacao  FOREIGN KEY (id_estacao)
                                   REFERENCES estacao(id_estacao),
    CONSTRAINT ck_leitura_umidade  CHECK (umidade_pct BETWEEN 0 AND 100),
    CONSTRAINT ck_leitura_precip   CHECK (precipitacao_mm >= 0)
);

-- 4. EVENTO_CLIMATICO
CREATE TABLE IF NOT EXISTS evento_climatico (
    id_evento   INT           NOT NULL AUTO_INCREMENT,
    id_regiao   INT           NOT NULL,
    tipo        VARCHAR(30)   NOT NULL,
    severidade  VARCHAR(10)   NOT NULL,
    score_risco DECIMAL(5,4),
    dt_inicio   DATETIME      NOT NULL,
    dt_fim      DATETIME,
    fonte       VARCHAR(20)   NOT NULL DEFAULT 'SENSOR',
    CONSTRAINT pk_evento        PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_regiao FOREIGN KEY (id_regiao)
                                REFERENCES regiao(id_regiao)
);

-- 5. ALERTA
CREATE TABLE IF NOT EXISTS alerta (
    id_alerta   INT           NOT NULL AUTO_INCREMENT,
    id_evento   INT           NOT NULL,
    nivel       VARCHAR(10)   NOT NULL,
    mensagem    VARCHAR(500)  NOT NULL,
    canal       VARCHAR(20)   NOT NULL DEFAULT 'SISTEMA',
    dt_enviado  DATETIME      NOT NULL,
    confirmado  CHAR(1)       NOT NULL DEFAULT 'N',
    CONSTRAINT pk_alerta        PRIMARY KEY (id_alerta),
    CONSTRAINT fk_alerta_evento FOREIGN KEY (id_evento)
                                REFERENCES evento_climatico(id_evento)
);

-- 6. USUARIO
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario  INT           NOT NULL AUTO_INCREMENT,
    id_regiao   INT           NOT NULL,
    nome        VARCHAR(100)  NOT NULL,
    email       VARCHAR(150)  NOT NULL,
    papel       VARCHAR(20)   NOT NULL,
    senha_hash  VARCHAR(64)   NOT NULL,
    dt_cadastro DATE          NOT NULL DEFAULT (CURDATE()),
    ativo       CHAR(1)       NOT NULL DEFAULT 'S',
    CONSTRAINT pk_usuario        PRIMARY KEY (id_usuario),
    CONSTRAINT uk_usuario_email  UNIQUE (email),
    CONSTRAINT fk_usuario_regiao FOREIGN KEY (id_regiao)
                                 REFERENCES regiao(id_regiao)
);

-- ============================================================
-- Inserts iniciais de teste (1 regiao + 1 estacao)
-- ============================================================
INSERT INTO regiao (nome, estado, latitude, longitude, area_km2)
VALUES ('Porto Alegre', 'RS', -30.0346, -51.2177, 496.68);

INSERT INTO estacao (id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao)
VALUES (1, 'EST-RS-001', -30.0374, -51.1935, 41.18, 'S', '2024-01-15');

-- Verificação final
SELECT 'regiao'           AS tabela, COUNT(*) AS registros FROM regiao
UNION ALL
SELECT 'estacao',           COUNT(*) FROM estacao
UNION ALL
SELECT 'leitura',           COUNT(*) FROM leitura
UNION ALL
SELECT 'evento_climatico',  COUNT(*) FROM evento_climatico
UNION ALL
SELECT 'alerta',            COUNT(*) FROM alerta
UNION ALL
SELECT 'usuario',           COUNT(*) FROM usuario;

USE sentinela;
SELECT * FROM leitura;

USE sentinela;
SELECT 'regiao' AS tabela, COUNT(*) AS registros FROM regiao
UNION ALL SELECT 'estacao', COUNT(*) FROM estacao
UNION ALL SELECT 'leitura', COUNT(*) FROM leitura;