-- ============================================================
-- SENTINELA · Global Solution 2026.1 · FIAP
-- Disciplina 03 — Cognitive Data Science
-- Dupla: Rafael & Charles
-- Banco: Sistema espacial de previsão climática (RS)
-- ============================================================

-- ============================================================
-- PARTE 1 — DDL (CREATE TABLE com constraints nomeadas)
-- ============================================================

-- 1. REGIAO
CREATE TABLE REGIAO (
    id_regiao    NUMBER(10)     NOT NULL,
    nome         VARCHAR2(100)  NOT NULL,
    estado       CHAR(2)        NOT NULL,
    latitude     NUMBER(9,6)    NOT NULL,
    longitude    NUMBER(9,6)    NOT NULL,
    area_km2     NUMBER(12,2),
    CONSTRAINT pk_regiao        PRIMARY KEY (id_regiao),
    CONSTRAINT ck_regiao_estado CHECK (estado IN (
        'AC','AL','AP','AM','BA','CE','DF','ES','GO',
        'MA','MT','MS','MG','PA','PB','PR','PE','PI',
        'RJ','RN','RS','RO','RR','SC','SP','SE','TO'))
);

-- 2. ESTACAO
CREATE TABLE ESTACAO (
    id_estacao    NUMBER(10)    NOT NULL,
    id_regiao     NUMBER(10)    NOT NULL,
    codigo        VARCHAR2(20)  NOT NULL,
    latitude      NUMBER(9,6)   NOT NULL,
    longitude     NUMBER(9,6)   NOT NULL,
    altitude_m    NUMBER(7,2),
    ativa         CHAR(1)       DEFAULT 'S' NOT NULL,
    dt_instalacao DATE          NOT NULL,
    CONSTRAINT pk_estacao          PRIMARY KEY (id_estacao),
    CONSTRAINT uk_estacao_codigo   UNIQUE (codigo),
    CONSTRAINT fk_estacao_regiao   FOREIGN KEY (id_regiao)
                                   REFERENCES REGIAO(id_regiao),
    CONSTRAINT ck_estacao_ativa    CHECK (ativa IN ('S','N'))
);

-- 3. LEITURA
CREATE TABLE LEITURA (
    id_leitura           NUMBER(15)  NOT NULL,
    id_estacao           NUMBER(10)  NOT NULL,
    timestamp_leitura    TIMESTAMP WITH TIME ZONE NOT NULL,
    temperatura_c        NUMBER(5,2) NOT NULL,
    umidade_pct          NUMBER(5,2) NOT NULL,
    pressao_hpa          NUMBER(7,2),
    precipitacao_mm      NUMBER(7,2) DEFAULT 0 NOT NULL,
    velocidade_vento_ms  NUMBER(5,2),
    CONSTRAINT pk_leitura            PRIMARY KEY (id_leitura),
    CONSTRAINT fk_leitura_estacao    FOREIGN KEY (id_estacao)
                                     REFERENCES ESTACAO(id_estacao),
    CONSTRAINT ck_leitura_umidade    CHECK (umidade_pct BETWEEN 0 AND 100),
    CONSTRAINT ck_leitura_precip     CHECK (precipitacao_mm >= 0)
);

-- 4. EVENTO_CLIMATICO
CREATE TABLE EVENTO_CLIMATICO (
    id_evento   NUMBER(10)    NOT NULL,
    id_regiao   NUMBER(10)    NOT NULL,
    tipo        VARCHAR2(30)  NOT NULL,
    severidade  VARCHAR2(10)  NOT NULL,
    score_risco NUMBER(5,4),
    dt_inicio   TIMESTAMP WITH TIME ZONE NOT NULL,
    dt_fim      TIMESTAMP WITH TIME ZONE,
    fonte       VARCHAR2(20)  DEFAULT 'SENSOR' NOT NULL,
    CONSTRAINT pk_evento           PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_regiao    FOREIGN KEY (id_regiao)
                                   REFERENCES REGIAO(id_regiao),
    CONSTRAINT ck_evento_tipo      CHECK (tipo IN (
                                   'ENCHENTE','SECA','TEMPESTADE',
                                   'GRANIZO','VENDAVAL')),
    CONSTRAINT ck_evento_sev       CHECK (severidade IN (
                                   'BAIXO','MEDIO','ALTO','CRITICO')),
    CONSTRAINT ck_evento_fonte     CHECK (fonte IN (
                                   'SENSOR','SATELITE','MANUAL','MODELO'))
);

-- 5. ALERTA
CREATE TABLE ALERTA (
    id_alerta   NUMBER(10)    NOT NULL,
    id_evento   NUMBER(10)    NOT NULL,
    nivel       VARCHAR2(10)  NOT NULL,
    mensagem    VARCHAR2(500) NOT NULL,
    canal       VARCHAR2(20)  DEFAULT 'SISTEMA' NOT NULL,
    dt_enviado  TIMESTAMP WITH TIME ZONE NOT NULL,
    confirmado  CHAR(1)       DEFAULT 'N' NOT NULL,
    CONSTRAINT pk_alerta          PRIMARY KEY (id_alerta),
    CONSTRAINT fk_alerta_evento   FOREIGN KEY (id_evento)
                                  REFERENCES EVENTO_CLIMATICO(id_evento),
    CONSTRAINT ck_alerta_nivel    CHECK (nivel IN (
                                  'INFO','ATENCAO','PERIGO','EMERGENCIA')),
    CONSTRAINT ck_alerta_canal    CHECK (canal IN (
                                  'SISTEMA','EMAIL','SMS','API')),
    CONSTRAINT ck_alerta_conf     CHECK (confirmado IN ('S','N'))
);

-- 6. USUARIO
CREATE TABLE USUARIO (
    id_usuario   NUMBER(10)    NOT NULL,
    id_regiao    NUMBER(10)    NOT NULL,
    nome         VARCHAR2(100) NOT NULL,
    email        VARCHAR2(150) NOT NULL,
    papel        VARCHAR2(20)  NOT NULL,
    senha_hash   VARCHAR2(64)  NOT NULL,
    dt_cadastro  DATE          DEFAULT SYSDATE NOT NULL,
    ativo        CHAR(1)       DEFAULT 'S' NOT NULL,
    CONSTRAINT pk_usuario          PRIMARY KEY (id_usuario),
    CONSTRAINT uk_usuario_email    UNIQUE (email),
    CONSTRAINT fk_usuario_regiao   FOREIGN KEY (id_regiao)
                                   REFERENCES REGIAO(id_regiao),
    CONSTRAINT ck_usuario_papel    CHECK (papel IN (
                                   'ADMIN','OPERADOR','ANALISTA',
                                   'VISUALIZADOR')),
    CONSTRAINT ck_usuario_ativo    CHECK (ativo IN ('S','N'))
);

CREATE SEQUENCE seq_regiao          START WITH 26  INCREMENT BY 1;
CREATE SEQUENCE seq_estacao         START WITH 59  INCREMENT BY 1;
CREATE SEQUENCE seq_leitura         START WITH 61  INCREMENT BY 1;
CREATE SEQUENCE seq_evento_clim     START WITH 51  INCREMENT BY 1;
CREATE SEQUENCE seq_alerta          START WITH 61  INCREMENT BY 1;
CREATE SEQUENCE seq_usuario         START WITH 53  INCREMENT BY 1;


-- ============================================================
-- PARTE 2 — DML (INSERTs com dados reais do RS)
-- ============================================================

-- ============================================================
-- SENTINELA · D3 · INSERTs com dados realistas do RS
-- Ordem respeita integridade referencial (FKs)
-- ============================================================

-- 1. REGIAO
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (1, 'Porto Alegre', 'RS', -30.0346, -51.2177, 496.68);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (2, 'Canoas', 'RS', -29.9178, -51.1836, 131.1);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (3, 'Sao Leopoldo', 'RS', -29.7603, -51.1472, 102.74);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (4, 'Novo Hamburgo', 'RS', -29.6783, -51.1306, 223.82);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (5, 'Lajeado', 'RS', -29.4669, -51.9611, 90.21);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (6, 'Santa Cruz do Sul', 'RS', -29.7175, -52.4258, 733.41);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (7, 'Caxias do Sul', 'RS', -29.1678, -51.1789, 1644.3);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (8, 'Pelotas', 'RS', -31.7654, -52.3376, 1610.08);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (9, 'Rio Grande', 'RS', -32.035, -52.0986, 2709.52);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (10, 'Santa Maria', 'RS', -29.6842, -53.8069, 1788.12);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (11, 'Passo Fundo', 'RS', -28.2628, -52.4067, 783.42);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (12, 'Uruguaiana', 'RS', -29.7547, -57.0883, 5715.76);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (13, 'Bento Goncalves', 'RS', -29.1714, -51.5189, 273.05);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (14, 'Erechim', 'RS', -27.6339, -52.2739, 430.67);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (15, 'Bage', 'RS', -31.3294, -54.1069, 4095.53);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (16, 'Cachoeira do Sul', 'RS', -30.0392, -52.8939, 3735.21);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (17, 'Montenegro', 'RS', -29.6883, -51.4611, 424.01);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (18, 'Taquara', 'RS', -29.6506, -50.7806, 457.86);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (19, 'Estrela', 'RS', -29.5008, -51.9658, 184.18);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (20, 'Venancio Aires', 'RS', -29.6069, -52.1928, 773.45);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (21, 'Gravatai', 'RS', -29.9444, -50.9919, 463.54);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (22, 'Viamao', 'RS', -30.0811, -51.0233, 1497.02);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (23, 'Alvorada', 'RS', -29.9897, -51.0808, 71.31);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (24, 'Sapucaia do Sul', 'RS', -29.8281, -51.145, 58.31);
INSERT INTO REGIAO (id_regiao, nome, estado, latitude, longitude, area_km2) VALUES (25, 'Esteio', 'RS', -29.8606, -51.1786, 27.68);

-- 2. ESTACAO
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (1, 1, 'EST-RS-001', -30.073467, -51.193545, 199.69, 'S', TO_DATE('2022-04-15', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (2, 1, 'EST-RS-002', -30.01693, -51.178482, 74.12, 'S', TO_DATE('2022-01-31', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (3, 1, 'EST-RS-003', -30.07523, -51.244434, 483.6, 'S', TO_DATE('2023-07-13', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (4, 2, 'EST-RS-004', -29.945756, -51.174673, 648.5, 'N', TO_DATE('2022-06-13', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (5, 2, 'EST-RS-005', -29.897986, -51.199575, 128.61, 'S', TO_DATE('2022-12-11', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (6, 3, 'EST-RS-006', -29.801025, -51.187528, 678.76, 'S', TO_DATE('2022-02-14', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (7, 3, 'EST-RS-007', -29.737327, -51.143577, 778.63, 'S', TO_DATE('2023-07-20', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (8, 4, 'EST-RS-008', -29.64536, -51.118748, 690.06, 'S', TO_DATE('2022-03-13', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (9, 4, 'EST-RS-009', -29.723718, -51.15781, 235.06, 'N', TO_DATE('2022-08-27', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (10, 5, 'EST-RS-010', -29.478887, -51.965759, 668.12, 'S', TO_DATE('2022-12-30', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (11, 5, 'EST-RS-011', -29.495949, -51.984402, 749.64, 'S', TO_DATE('2022-06-25', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (12, 6, 'EST-RS-012', -29.694587, -52.45946, 306.67, 'S', TO_DATE('2023-07-25', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (13, 6, 'EST-RS-013', -29.745538, -52.443372, 615.81, 'N', TO_DATE('2022-02-02', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (14, 6, 'EST-RS-014', -29.686995, -52.435684, 57.62, 'S', TO_DATE('2023-08-04', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (15, 7, 'EST-RS-015', -29.186332, -51.163356, 319.53, 'S', TO_DATE('2023-04-15', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (16, 7, 'EST-RS-016', -29.203513, -51.214937, 597.27, 'S', TO_DATE('2023-08-22', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (17, 7, 'EST-RS-017', -29.174957, -51.170547, 292.79, 'S', TO_DATE('2022-05-22', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (18, 8, 'EST-RS-018', -31.766048, -52.312022, 689.58, 'S', TO_DATE('2022-06-13', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (19, 8, 'EST-RS-019', -31.736192, -52.345384, 55.5, 'S', TO_DATE('2023-04-25', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (20, 8, 'EST-RS-020', -31.762489, -52.290492, 689.32, 'N', TO_DATE('2022-04-28', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (21, 9, 'EST-RS-021', -31.996521, -52.073512, 616.04, 'S', TO_DATE('2022-10-28', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (22, 9, 'EST-RS-022', -32.041523, -52.103228, 763.28, 'S', TO_DATE('2022-09-27', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (23, 9, 'EST-RS-023', -31.987811, -52.072404, 408.61, 'S', TO_DATE('2022-11-02', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (24, 10, 'EST-RS-024', -29.683434, -53.837009, 302.26, 'S', TO_DATE('2023-06-28', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (25, 10, 'EST-RS-025', -29.642351, -53.797006, 393.44, 'S', TO_DATE('2023-01-07', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (26, 10, 'EST-RS-026', -29.646328, -53.773733, 249.47, 'N', TO_DATE('2023-08-04', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (27, 11, 'EST-RS-027', -28.304235, -52.408101, 60.02, 'S', TO_DATE('2022-05-09', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (28, 11, 'EST-RS-028', -28.299961, -52.409172, 442.09, 'S', TO_DATE('2023-03-10', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (29, 12, 'EST-RS-029', -29.711809, -57.062773, 553.44, 'S', TO_DATE('2023-02-13', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (30, 12, 'EST-RS-030', -29.705185, -57.073312, 353.29, 'S', TO_DATE('2022-05-04', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (31, 13, 'EST-RS-031', -29.19893, -51.535091, 472.71, 'S', TO_DATE('2022-08-14', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (32, 13, 'EST-RS-032', -29.220681, -51.498116, 51.8, 'N', TO_DATE('2022-02-02', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (33, 14, 'EST-RS-033', -27.676814, -52.3001, 536.84, 'S', TO_DATE('2022-05-16', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (34, 14, 'EST-RS-034', -27.611565, -52.235662, 463.09, 'S', TO_DATE('2023-04-30', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (35, 15, 'EST-RS-035', -31.360359, -54.147207, 347.69, 'S', TO_DATE('2023-04-24', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (36, 15, 'EST-RS-036', -31.293016, -54.151483, 524.5, 'S', TO_DATE('2022-03-04', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (37, 16, 'EST-RS-037', -30.016379, -52.863841, 91.87, 'S', TO_DATE('2023-07-04', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (38, 16, 'EST-RS-038', -30.044339, -52.901712, 226.44, 'S', TO_DATE('2022-03-19', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (39, 17, 'EST-RS-039', -29.657498, -51.425503, 82.84, 'S', TO_DATE('2023-07-08', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (40, 17, 'EST-RS-040', -29.654697, -51.4142, 741.46, 'S', TO_DATE('2022-06-20', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (41, 18, 'EST-RS-041', -29.652036, -50.809225, 323.83, 'N', TO_DATE('2023-01-24', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (42, 18, 'EST-RS-042', -29.700384, -50.791558, 741.58, 'S', TO_DATE('2022-10-20', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (43, 19, 'EST-RS-043', -29.481141, -51.942749, 627.77, 'S', TO_DATE('2023-05-14', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (44, 19, 'EST-RS-044', -29.53532, -51.986129, 775.12, 'S', TO_DATE('2023-07-10', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (45, 20, 'EST-RS-045', -29.582102, -52.237083, 469.42, 'S', TO_DATE('2023-06-28', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (46, 20, 'EST-RS-046', -29.641157, -52.146722, 68.69, 'S', TO_DATE('2022-03-11', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (47, 21, 'EST-RS-047', -29.908218, -51.001522, 753.57, 'S', TO_DATE('2023-08-16', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (48, 21, 'EST-RS-048', -29.934948, -50.979962, 338.28, 'S', TO_DATE('2023-06-20', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (49, 21, 'EST-RS-049', -29.962763, -51.015823, 537.43, 'S', TO_DATE('2022-09-29', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (50, 22, 'EST-RS-050', -30.118012, -51.00875, 368.49, 'S', TO_DATE('2022-03-16', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (51, 22, 'EST-RS-051', -30.130168, -51.011184, 452.58, 'N', TO_DATE('2023-07-05', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (52, 23, 'EST-RS-052', -29.989112, -51.117554, 282.46, 'N', TO_DATE('2022-09-08', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (53, 23, 'EST-RS-053', -30.002747, -51.115025, 667.83, 'S', TO_DATE('2023-06-26', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (54, 24, 'EST-RS-054', -29.811314, -51.13954, 745.75, 'S', TO_DATE('2022-05-18', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (55, 24, 'EST-RS-055', -29.851653, -51.106029, 595.22, 'S', TO_DATE('2022-10-16', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (56, 25, 'EST-RS-056', -29.889537, -51.194312, 551.56, 'S', TO_DATE('2023-06-02', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (57, 25, 'EST-RS-057', -29.861747, -51.138066, 677.65, 'N', TO_DATE('2023-03-10', 'YYYY-MM-DD'));
INSERT INTO ESTACAO (id_estacao, id_regiao, codigo, latitude, longitude, altitude_m, ativa, dt_instalacao) VALUES (58, 25, 'EST-RS-058', -29.827665, -51.224191, 270.18, 'S', TO_DATE('2022-09-26', 'YYYY-MM-DD'));

-- total estacoes: 58

-- 3. USUARIO
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (1, 6, 'Ana Silva', 'ana.silva@sentinela.gov.br', 'VISUALIZADOR', '4283fefc63f0cd0e873a0000c6d07ef7b77e90d3593ad699fc1f7cd5bb2e35cb', TO_DATE('2023-03-14', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (2, 16, 'Bruno Costa', 'bruno.costa@sentinela.gov.br', 'VISUALIZADOR', '122b598615dcbe810beacd557705a54b5edbbbe5ce7f8fbeebef7a58f99d96fb', TO_DATE('2022-11-12', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (3, 22, 'Carla Souza', 'carla.souza@sentinela.gov.br', 'ANALISTA', '74bf20f876ffc474c0251908fcdce4b314f68d9dcbd7a085a368932ff2b2d409', TO_DATE('2022-12-16', 'YYYY-MM-DD'), 'N');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (4, 14, 'Diego Lima', 'diego.lima@sentinela.gov.br', 'VISUALIZADOR', '793cf4220c917b853860886599b2ac757f8290996dd9de5798121e8fa462d6e8', TO_DATE('2022-02-15', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (5, 6, 'Elaine Rocha', 'elaine.rocha@sentinela.gov.br', 'OPERADOR', '8b0e7153bf7c3706d85c524e440066559a6656c90bd5482a90a29b9fa5ff5180', TO_DATE('2022-11-25', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (6, 24, 'Felipe Alves', 'felipe.alves@sentinela.gov.br', 'OPERADOR', '2f8104fba08f6d3682da2bd8e369316bf60b7d9b3263896cf7460650a9bcc94f', TO_DATE('2023-07-17', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (7, 2, 'Gabriela Dias', 'gabriela.dias@sentinela.gov.br', 'OPERADOR', 'a4c123b1612dd272d1371c17149d439536b3216fdaeeb975729fae923d5a4fd1', TO_DATE('2023-02-12', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (8, 22, 'Henrique Melo', 'henrique.melo@sentinela.gov.br', 'ADMIN', '7bc4612476c0efecf6c2f708dfc3832cc31a72f6421f64ee9bd453abf694b927', TO_DATE('2022-11-18', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (9, 12, 'Isabela Nunes', 'isabela.nunes@sentinela.gov.br', 'OPERADOR', 'eb8450ae2a1c5ed5571342c3967d286c8a160d1cf407d30366a02402f6d2c624', TO_DATE('2022-12-18', 'YYYY-MM-DD'), 'N');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (10, 6, 'Joao Pereira', 'joao.pereira@sentinela.gov.br', 'VISUALIZADOR', '1df06ef851fa27b1d4bcd98e59b4e7ec107469b7aedf2a57d711f9224cb433e5', TO_DATE('2022-02-12', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (11, 7, 'Karina Mota', 'karina.mota@sentinela.gov.br', 'VISUALIZADOR', 'eee65f53e9421ce50211670eae679f02e8d28a79023c39c200661fccd268a29a', TO_DATE('2023-03-01', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (12, 1, 'Lucas Ramos', 'lucas.ramos@sentinela.gov.br', 'VISUALIZADOR', 'f8b4c0bf8e704eb5a6162ac20172de3d4a5152cdffc0268bbc9387abb50cd107', TO_DATE('2022-05-01', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (13, 22, 'Mariana Pinto', 'mariana.pinto@sentinela.gov.br', 'ANALISTA', '895747542690d408428ed48b7fdbda3b8e4ee5965b8be88c4f776b42dec0d174', TO_DATE('2024-03-01', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (14, 16, 'Nelson Castro', 'nelson.castro@sentinela.gov.br', 'VISUALIZADOR', '378892e9ecc387ab8b4585023a0286cce33b53f68e6f9833288305d32df5ce9f', TO_DATE('2023-10-17', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (15, 15, 'Olivia Freitas', 'olivia.freitas@sentinela.gov.br', 'ANALISTA', '60157014b73aeb8c8b76ba79d7edf2ebeaec2f064509f433c12e9c75b27995ac', TO_DATE('2022-04-08', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (16, 16, 'Paulo Teixeira', 'paulo.teixeira@sentinela.gov.br', 'OPERADOR', 'bff9d7e0d877099a49078040ee979b8d2bfd591920b7f499aee25f0ef0f3e2f0', TO_DATE('2022-03-17', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (17, 5, 'Quenia Barros', 'quenia.barros@sentinela.gov.br', 'VISUALIZADOR', 'd9b958307cd8ac414646a329d2f4da0db1b1fb0c7367b18286489ba5a38a01b0', TO_DATE('2023-01-14', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (18, 15, 'Rafael Gomes', 'rafael.gomes@sentinela.gov.br', 'VISUALIZADOR', '53ea76ff5f9e8683a57576b6f6980ac7cb88939f4f566d4df368af2f4f4f272b', TO_DATE('2022-02-25', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (19, 7, 'Sandra Vieira', 'sandra.vieira@sentinela.gov.br', 'VISUALIZADOR', '136cb94838da83a906263ec23d03dce95d736c644f3e0ef3ffbd50720ece384f', TO_DATE('2023-02-07', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (20, 10, 'Tiago Moraes', 'tiago.moraes@sentinela.gov.br', 'ANALISTA', '483a50dd234afed66aaad2fc267163268998530877710984ae48d55c34db7316', TO_DATE('2022-06-25', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (21, 14, 'Ursula Campos', 'ursula.campos@sentinela.gov.br', 'OPERADOR', '5dd9f6f5700bd24771dde1af3b04230e5acf451f726623fc6a4d9becafc8025f', TO_DATE('2022-03-24', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (22, 1, 'Vitor Cardoso', 'vitor.cardoso@sentinela.gov.br', 'ANALISTA', '470e53b2781a5d1089d6531aa85c94885d1a1d89dc59bc09dd22eb3dc167c03e', TO_DATE('2024-02-06', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (23, 7, 'Wanda Reis', 'wanda.reis@sentinela.gov.br', 'OPERADOR', '9209dcb468e07e032fd0db161b56bb9a2f5fe555a6323d188a3b99e68433f7a4', TO_DATE('2022-12-24', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (24, 24, 'Xavier Lopes', 'xavier.lopes@sentinela.gov.br', 'ANALISTA', 'c565652490ee305fe9f285a92b16aa29374f98862f44af64f877248a7c69c2fb', TO_DATE('2022-06-21', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (25, 11, 'Yara Fonseca', 'yara.fonseca@sentinela.gov.br', 'OPERADOR', 'c069f1819d336a5bf33bdb65e22c241527dedffe1f951dce0f7db243275474b6', TO_DATE('2023-08-12', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (26, 6, 'Zeca Martins', 'zeca.martins@sentinela.gov.br', 'ANALISTA', '66d14f15d7d607446fcb7009310eaadd6186cd4132411d6b2a3d1de21b37248b', TO_DATE('2023-07-08', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (27, 25, 'Aline Duarte', 'aline.duarte@sentinela.gov.br', 'ANALISTA', 'f896228a8bc577f22dd1eb0f84a743c9125e48150e4bd29eeb0b585fb1756f2a', TO_DATE('2023-11-30', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (28, 11, 'Bento Farias', 'bento.farias@sentinela.gov.br', 'VISUALIZADOR', '34574ed664c54660d723da4587e46098283d56b21dfb5c8c57596d0761abc3f4', TO_DATE('2023-10-14', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (29, 24, 'Celia Tavares', 'celia.tavares@sentinela.gov.br', 'ANALISTA', '2b92bcd013e7b2fad6e57dd6d987df499fc3b484a2c5dde94a6800cd4d490119', TO_DATE('2023-04-05', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (30, 4, 'Davi Antunes', 'davi.antunes@sentinela.gov.br', 'ADMIN', '90681cc42e07025cb2c078d383f94998247a30d955faeaa203ff8f885559d76f', TO_DATE('2022-03-01', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (31, 12, 'Eva Macedo', 'eva.macedo@sentinela.gov.br', 'VISUALIZADOR', '0f3c41437441147ed6230ca66acb766d115b464c02e66db6a7f18a9acfa63959', TO_DATE('2023-09-27', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (32, 3, 'Fabio Cunha', 'fabio.cunha@sentinela.gov.br', 'OPERADOR', '26497f013aa1fb040f696e2a3135e0d11b75e9f5921979a27c9d2f05e5214819', TO_DATE('2023-09-08', 'YYYY-MM-DD'), 'N');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (33, 5, 'Gisele Borges', 'gisele.borges@sentinela.gov.br', 'ANALISTA', '578f5afe929d9f1d8a731a962b3a78a0b9cc531b32423a01d8b66cefbe9f20fc', TO_DATE('2022-02-07', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (34, 13, 'Hugo Pacheco', 'hugo.pacheco@sentinela.gov.br', 'VISUALIZADOR', 'b070cb2d9a3438b0421b81c599ca66e54cd7732e8d3965cae2fdeb4e84759929', TO_DATE('2023-11-15', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (35, 17, 'Ines Bittencourt', 'ines.bittencourt@sentinela.gov.br', 'OPERADOR', 'a4a49d818b3b003fb0af107a25a52fb29524efacc18e13af32cc6ec087750233', TO_DATE('2023-02-21', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (36, 23, 'Julio Cesar', 'julio.cesar@sentinela.gov.br', 'OPERADOR', 'a10920578db82dfcbc7c53f695fa50cf46db6f817e9e27965527bd0cbf5823e6', TO_DATE('2023-05-13', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (37, 8, 'Kelly Andrade', 'kelly.andrade@sentinela.gov.br', 'VISUALIZADOR', '21be3e9cde412d29bdb16d200b270ab50069791986f4681ee30872e4ab034257', TO_DATE('2022-06-01', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (38, 17, 'Leandro Prado', 'leandro.prado@sentinela.gov.br', 'OPERADOR', 'dd32beb15ba8a9fc72f4d70cb04f3834e23c95bedf985d85b277904d7b20b17c', TO_DATE('2022-07-04', 'YYYY-MM-DD'), 'N');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (39, 5, 'Marta Siqueira', 'marta.siqueira@sentinela.gov.br', 'VISUALIZADOR', '68c067c08b5092b03dbd3c982ed8a016fca9cbf4d259973cf2d10d0c473e6774', TO_DATE('2022-03-08', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (40, 18, 'Nadia Coelho', 'nadia.coelho@sentinela.gov.br', 'ADMIN', 'e17964b8e0416e15a38a43d1aa749599e56fd25602e9367ee3fae97214c5e3d6', TO_DATE('2022-12-05', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (41, 19, 'Otavio Brito', 'otavio.brito@sentinela.gov.br', 'ADMIN', 'ca75c98c070e44a58131d962bf40334518a705d19c432d0fc70242ecd800ea54', TO_DATE('2022-09-04', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (42, 3, 'Patricia Maia', 'patricia.maia@sentinela.gov.br', 'VISUALIZADOR', '30877432d1026706d7e805da846a32c3bb81e3c29b62179273c8eb5bb682575e', TO_DATE('2023-11-30', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (43, 13, 'Quintino Reis', 'quintino.reis@sentinela.gov.br', 'OPERADOR', '194eb3ef0dbdc5133c435f4c85c211515982313eaae542a18b5239fbd1fd2b42', TO_DATE('2023-12-06', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (44, 22, 'Renata Furtado', 'renata.furtado@sentinela.gov.br', 'VISUALIZADOR', 'd35c790730359ccab2a953238a391bc3ff6648711d1abfe47feb1850709b6c3b', TO_DATE('2022-11-11', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (45, 11, 'Sergio Maciel', 'sergio.maciel@sentinela.gov.br', 'OPERADOR', '8df829a02f03939124846d2d4115a8ba3d20aac81fb6b407fd96dcc4e2c109a9', TO_DATE('2024-01-04', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (46, 6, 'Tania Bastos', 'tania.bastos@sentinela.gov.br', 'OPERADOR', '2c174102a1049a2cfb4fe2e3d7ae843b2aec5c9b637a293b5b562c3a5059c016', TO_DATE('2022-02-20', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (47, 25, 'Ulisses Neto', 'ulisses.neto@sentinela.gov.br', 'OPERADOR', 'b2dea8cc1d0308f0ad77be71bba6714a3bc837a6f3db978b1f9c8736cf84e052', TO_DATE('2022-03-19', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (48, 3, 'Vera Lucia', 'vera.lucia@sentinela.gov.br', 'OPERADOR', 'a496d543f764f602d24f5419aa3788094bd56c80b399f3374afad30bdda0cfd8', TO_DATE('2023-07-14', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (49, 5, 'Wagner Pires', 'wagner.pires@sentinela.gov.br', 'VISUALIZADOR', '2bd3a1184e179bc0743dcab8c1d628a4f7a8dffc804062921b1da2f6d9f58ea3', TO_DATE('2023-08-01', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (50, 4, 'Ximena Cruz', 'ximena.cruz@sentinela.gov.br', 'VISUALIZADOR', 'f8b7fa2a724b3ba762ad22ad07a8d36e8e4863d3fd4f92b40b0df75348c7a112', TO_DATE('2023-04-13', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (51, 21, 'Yuri Salgado', 'yuri.salgado@sentinela.gov.br', 'OPERADOR', '75778ceabc8c03081f5b9be60e5f01335e0dd6b3f5bef3e0d1f39e0ad2d87ff6', TO_DATE('2023-06-26', 'YYYY-MM-DD'), 'S');
INSERT INTO USUARIO (id_usuario, id_regiao, nome, email, papel, senha_hash, dt_cadastro, ativo) VALUES (52, 18, 'Zilda Aguiar', 'zilda.aguiar@sentinela.gov.br', 'ADMIN', '81fbd145d5be01ce07255f78ffd31c2cb44c582a5dd0606fe453524696d25647', TO_DATE('2023-07-03', 'YYYY-MM-DD'), 'S');

-- total usuarios: 52

-- 4. LEITURA
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (1, 21, TO_TIMESTAMP_TZ('2024-05-01 10:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 24.92, 48.91, 1005.97, 108.58, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (2, 28, TO_TIMESTAMP_TZ('2024-05-12 20:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 14.26, 74.76, NULL, 23.69, 12.83);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (3, 4, TO_TIMESTAMP_TZ('2024-05-19 14:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 9.29, 56.94, 999.0, 13.52, 12.33);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (4, 44, TO_TIMESTAMP_TZ('2024-05-02 17:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 23.12, 79.5, 1011.43, 43.64, 14.97);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (5, 28, TO_TIMESTAMP_TZ('2024-05-08 09:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 23.22, 69.47, 1018.83, 6.1, 11.55);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (6, 57, TO_TIMESTAMP_TZ('2024-05-09 15:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 15.49, 97.93, NULL, 18.93, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (7, 32, TO_TIMESTAMP_TZ('2024-05-12 23:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 33.01, 49.19, 1018.67, 8.5, 10.93);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (8, 52, TO_TIMESTAMP_TZ('2024-05-14 11:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 29.84, 96.01, 1014.92, 136.72, 21.85);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (9, 53, TO_TIMESTAMP_TZ('2024-05-14 00:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 26.63, 92.9, 1023.22, 15.27, 4.8);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (10, 19, TO_TIMESTAMP_TZ('2024-04-30 12:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 18.35, 94.51, 999.99, 6.95, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (11, 28, TO_TIMESTAMP_TZ('2024-05-18 11:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 26.37, 98.27, 1006.41, 47.03, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (12, 43, TO_TIMESTAMP_TZ('2024-05-04 22:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 20.61, 76.81, 995.12, 9.23, 20.97);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (13, 45, TO_TIMESTAMP_TZ('2024-05-16 23:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 19.87, 92.03, 1015.42, 9.95, 10.59);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (14, 26, TO_TIMESTAMP_TZ('2024-04-27 15:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 9.75, 56.27, 1005.2, 35.03, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (15, 7, TO_TIMESTAMP_TZ('2024-05-10 12:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 9.83, 56.23, 1014.03, 15.06, 2.54);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (16, 32, TO_TIMESTAMP_TZ('2024-05-14 21:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 20.58, 49.64, NULL, 6.62, 3.55);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (17, 2, TO_TIMESTAMP_TZ('2024-05-03 18:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 11.81, 74.33, NULL, 24.46, 15.32);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (18, 17, TO_TIMESTAMP_TZ('2024-05-17 02:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 31.61, 64.21, 1011.25, 15.91, 17.34);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (19, 49, TO_TIMESTAMP_TZ('2024-05-03 07:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 29.28, 84.95, 1010.53, 0.72, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (20, 18, TO_TIMESTAMP_TZ('2024-05-15 03:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 13.03, 77.68, 1019.26, 8.74, 1.77);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (21, 7, TO_TIMESTAMP_TZ('2024-05-04 16:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 13.11, 56.04, 1022.01, 11.99, 17.59);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (22, 6, TO_TIMESTAMP_TZ('2024-05-23 04:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 31.65, 87.24, 1009.34, 149.42, 17.62);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (23, 47, TO_TIMESTAMP_TZ('2024-05-11 21:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 18.44, 96.13, 1000.1, 56.92, 17.74);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (24, 10, TO_TIMESTAMP_TZ('2024-05-21 02:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 25.09, 63.92, 998.93, 175.78, 11.58);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (25, 9, TO_TIMESTAMP_TZ('2024-05-13 12:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 29.48, 56.4, 1003.79, 120.03, 9.22);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (26, 9, TO_TIMESTAMP_TZ('2024-04-27 14:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 31.34, 80.77, 1010.5, 21.95, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (27, 10, TO_TIMESTAMP_TZ('2024-05-17 08:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 30.69, 86.93, 1018.28, 55.53, 2.65);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (28, 4, TO_TIMESTAMP_TZ('2024-05-08 21:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 28.39, 50.73, 1002.45, 146.98, 12.36);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (29, 49, TO_TIMESTAMP_TZ('2024-04-27 16:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 16.47, 97.56, 1000.98, 108.68, 11.17);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (30, 16, TO_TIMESTAMP_TZ('2024-05-24 19:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 31.99, 93.21, 1008.43, 9.81, 14.77);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (31, 28, TO_TIMESTAMP_TZ('2024-04-28 02:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 25.41, 87.33, 999.63, 16.51, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (32, 57, TO_TIMESTAMP_TZ('2024-04-30 20:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 13.71, 96.44, 1009.62, 20.81, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (33, 28, TO_TIMESTAMP_TZ('2024-05-16 23:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 16.82, 55.57, 1016.66, 115.34, 0.4);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (34, 22, TO_TIMESTAMP_TZ('2024-05-17 01:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 21.32, 48.47, 1018.65, 2.62, 0.87);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (35, 50, TO_TIMESTAMP_TZ('2024-05-02 17:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 27.65, 89.27, 1015.28, 10.15, 11.33);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (36, 32, TO_TIMESTAMP_TZ('2024-05-24 21:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 10.33, 48.11, 1007.76, 171.06, 17.64);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (37, 6, TO_TIMESTAMP_TZ('2024-05-20 22:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 9.73, 91.59, 1005.17, 23.17, 2.84);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (38, 34, TO_TIMESTAMP_TZ('2024-05-05 04:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 33.2, 59.14, 1022.97, 13.28, 9.81);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (39, 44, TO_TIMESTAMP_TZ('2024-05-02 14:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 17.02, 45.98, 995.46, 13.78, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (40, 31, TO_TIMESTAMP_TZ('2024-05-05 11:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 10.76, 89.22, 1009.85, 9.83, 15.13);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (41, 15, TO_TIMESTAMP_TZ('2024-05-09 14:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 29.64, 83.16, 1007.14, 1.36, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (42, 5, TO_TIMESTAMP_TZ('2024-05-21 16:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 19.2, 47.99, 1006.43, 24.27, 15.24);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (43, 3, TO_TIMESTAMP_TZ('2024-05-14 14:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 12.1, 69.07, 1023.85, 13.68, 21.24);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (44, 20, TO_TIMESTAMP_TZ('2024-05-04 07:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 12.76, 63.11, NULL, 130.12, 17.08);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (45, 6, TO_TIMESTAMP_TZ('2024-05-06 06:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 11.74, 76.69, 1003.99, 2.11, 18.77);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (46, 10, TO_TIMESTAMP_TZ('2024-05-23 01:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 27.87, 83.92, 1003.53, 3.62, 15.73);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (47, 33, TO_TIMESTAMP_TZ('2024-05-21 18:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 27.08, 88.86, NULL, 12.61, 17.7);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (48, 53, TO_TIMESTAMP_TZ('2024-05-24 06:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 10.21, 47.26, 1023.79, 11.28, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (49, 2, TO_TIMESTAMP_TZ('2024-05-21 17:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 20.72, 45.18, 1017.45, 13.38, 1.45);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (50, 48, TO_TIMESTAMP_TZ('2024-05-15 05:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 29.04, 90.69, 1017.69, 129.24, 18.6);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (51, 5, TO_TIMESTAMP_TZ('2024-05-15 10:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 27.94, 78.32, 997.32, 71.82, 6.7);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (52, 37, TO_TIMESTAMP_TZ('2024-04-30 16:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 20.54, 71.23, 997.99, 105.99, 6.28);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (53, 30, TO_TIMESTAMP_TZ('2024-05-14 21:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 33.83, 74.65, 997.58, 7.24, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (54, 33, TO_TIMESTAMP_TZ('2024-05-14 04:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 18.06, 94.49, 997.24, 143.39, 7.91);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (55, 39, TO_TIMESTAMP_TZ('2024-05-21 22:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 31.06, 82.98, 1021.93, 0.62, NULL);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (56, 32, TO_TIMESTAMP_TZ('2024-05-24 01:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 18.54, 84.27, 1006.28, 83.04, 7.44);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (57, 26, TO_TIMESTAMP_TZ('2024-04-30 02:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 26.54, 93.68, 1006.17, 24.97, 7.94);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (58, 28, TO_TIMESTAMP_TZ('2024-05-06 17:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 15.3, 47.79, 1014.05, 175.8, 6.94);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (59, 50, TO_TIMESTAMP_TZ('2024-05-10 22:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 30.99, 88.85, 1022.4, 13.73, 1.09);
INSERT INTO LEITURA (id_leitura, id_estacao, timestamp_leitura, temperatura_c, umidade_pct, pressao_hpa, precipitacao_mm, velocidade_vento_ms) VALUES (60, 47, TO_TIMESTAMP_TZ('2024-05-12 12:45:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 23.99, 52.48, 1009.57, 13.75, NULL);

-- total leituras: 60

-- 5. EVENTO_CLIMATICO
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (1, 15, 'VENDAVAL', 'ALTO', 0.7843, TO_TIMESTAMP_TZ('2024-05-23 16:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-24 19:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (2, 17, 'TEMPESTADE', 'MEDIO', 0.225, TO_TIMESTAMP_TZ('2024-05-23 09:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (3, 23, 'TEMPESTADE', 'MEDIO', 0.4224, TO_TIMESTAMP_TZ('2024-05-23 20:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-27 10:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (4, 1, 'GRANIZO', 'BAIXO', 0.0835, TO_TIMESTAMP_TZ('2024-05-10 19:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (5, 15, 'TEMPESTADE', 'BAIXO', 0.2696, TO_TIMESTAMP_TZ('2024-05-13 15:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (6, 21, 'ENCHENTE', 'CRITICO', 0.986, TO_TIMESTAMP_TZ('2024-04-30 22:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-02 06:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (7, 1, 'ENCHENTE', 'ALTO', 0.4264, TO_TIMESTAMP_TZ('2024-05-13 12:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (8, 22, 'ENCHENTE', 'BAIXO', 0.9057, TO_TIMESTAMP_TZ('2024-05-25 12:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-27 17:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (9, 19, 'TEMPESTADE', 'ALTO', 0.3036, TO_TIMESTAMP_TZ('2024-04-30 09:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-02 16:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MODELO');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (10, 4, 'ENCHENTE', 'ALTO', 0.0603, TO_TIMESTAMP_TZ('2024-05-24 15:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (11, 15, 'TEMPESTADE', 'CRITICO', 0.7734, TO_TIMESTAMP_TZ('2024-05-21 20:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-24 01:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (12, 7, 'ENCHENTE', 'ALTO', 0.9664, TO_TIMESTAMP_TZ('2024-06-01 09:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-06-01 14:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (13, 13, 'VENDAVAL', 'MEDIO', 0.5923, TO_TIMESTAMP_TZ('2024-04-27 04:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (14, 25, 'TEMPESTADE', 'ALTO', 0.413, TO_TIMESTAMP_TZ('2024-04-29 02:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'MANUAL');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (15, 1, 'TEMPESTADE', 'MEDIO', 0.476, TO_TIMESTAMP_TZ('2024-06-01 15:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-06-02 11:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MODELO');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (16, 6, 'TEMPESTADE', 'BAIXO', 0.2647, TO_TIMESTAMP_TZ('2024-06-03 07:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-06-04 06:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MODELO');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (17, 18, 'ENCHENTE', 'CRITICO', 0.8793, TO_TIMESTAMP_TZ('2024-06-02 02:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-06-02 18:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (18, 17, 'VENDAVAL', 'BAIXO', 0.7123, TO_TIMESTAMP_TZ('2024-05-11 13:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-14 20:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (19, 17, 'ENCHENTE', 'ALTO', 0.1146, TO_TIMESTAMP_TZ('2024-05-09 15:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-13 00:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (20, 9, 'ENCHENTE', 'CRITICO', 0.754, TO_TIMESTAMP_TZ('2024-04-29 08:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-04-30 18:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (21, 6, 'ENCHENTE', 'MEDIO', 0.9647, TO_TIMESTAMP_TZ('2024-04-30 11:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (22, 11, 'TEMPESTADE', 'ALTO', 0.5994, TO_TIMESTAMP_TZ('2024-05-03 18:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (23, 12, 'GRANIZO', 'CRITICO', 0.9412, TO_TIMESTAMP_TZ('2024-06-04 02:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-06-08 02:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (24, 5, 'VENDAVAL', 'BAIXO', 0.5633, TO_TIMESTAMP_TZ('2024-04-27 23:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-04-28 18:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MODELO');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (25, 11, 'SECA', 'ALTO', 0.8968, TO_TIMESTAMP_TZ('2024-05-21 00:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-24 04:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (26, 22, 'SECA', 'MEDIO', 0.6223, TO_TIMESTAMP_TZ('2024-04-30 02:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-01 13:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MODELO');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (27, 24, 'SECA', 'CRITICO', 0.7025, TO_TIMESTAMP_TZ('2024-05-24 14:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-27 14:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (28, 25, 'TEMPESTADE', 'BAIXO', 0.1325, TO_TIMESTAMP_TZ('2024-04-26 07:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-04-27 00:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (29, 20, 'TEMPESTADE', 'MEDIO', 0.8926, TO_TIMESTAMP_TZ('2024-05-18 09:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (30, 17, 'ENCHENTE', 'CRITICO', 0.8156, TO_TIMESTAMP_TZ('2024-05-23 15:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-25 11:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (31, 9, 'ENCHENTE', 'MEDIO', 0.8076, TO_TIMESTAMP_TZ('2024-05-07 06:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-10 11:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MODELO');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (32, 7, 'ENCHENTE', 'MEDIO', 0.8369, TO_TIMESTAMP_TZ('2024-04-27 22:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'MODELO');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (33, 6, 'ENCHENTE', 'MEDIO', 0.9202, TO_TIMESTAMP_TZ('2024-05-21 12:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-24 06:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MANUAL');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (34, 23, 'GRANIZO', 'CRITICO', 0.7689, TO_TIMESTAMP_TZ('2024-04-29 01:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-02 09:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (35, 23, 'ENCHENTE', 'MEDIO', 0.6603, TO_TIMESTAMP_TZ('2024-05-31 00:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-06-02 06:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (36, 1, 'GRANIZO', 'BAIXO', 0.7825, TO_TIMESTAMP_TZ('2024-04-28 20:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (37, 18, 'TEMPESTADE', 'ALTO', 0.951, TO_TIMESTAMP_TZ('2024-05-07 06:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-08 17:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (38, 1, 'GRANIZO', 'MEDIO', 0.084, TO_TIMESTAMP_TZ('2024-05-09 08:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-12 08:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MANUAL');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (39, 17, 'TEMPESTADE', 'CRITICO', 0.8834, TO_TIMESTAMP_TZ('2024-05-09 02:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-13 01:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (40, 15, 'SECA', 'MEDIO', 0.9054, TO_TIMESTAMP_TZ('2024-05-19 17:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-22 12:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MODELO');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (41, 11, 'TEMPESTADE', 'MEDIO', 0.2426, TO_TIMESTAMP_TZ('2024-05-02 06:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (42, 3, 'VENDAVAL', 'MEDIO', 0.7933, TO_TIMESTAMP_TZ('2024-05-15 08:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-15 13:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (43, 3, 'ENCHENTE', 'MEDIO', 0.4461, TO_TIMESTAMP_TZ('2024-05-12 15:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-13 21:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MODELO');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (44, 3, 'SECA', 'BAIXO', 0.5511, TO_TIMESTAMP_TZ('2024-05-03 15:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (45, 24, 'TEMPESTADE', 'ALTO', 0.4638, TO_TIMESTAMP_TZ('2024-05-26 18:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-27 08:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MODELO');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (46, 15, 'TEMPESTADE', 'BAIXO', 0.7351, TO_TIMESTAMP_TZ('2024-06-04 05:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-06-07 07:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (47, 22, 'SECA', 'ALTO', 0.8965, TO_TIMESTAMP_TZ('2024-05-08 09:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-05-11 09:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'SATELITE');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (48, 19, 'TEMPESTADE', 'MEDIO', 0.1574, TO_TIMESTAMP_TZ('2024-04-25 19:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), TO_TIMESTAMP_TZ('2024-04-28 18:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'MODELO');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (49, 17, 'VENDAVAL', 'MEDIO', 0.98, TO_TIMESTAMP_TZ('2024-05-02 15:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SENSOR');
INSERT INTO EVENTO_CLIMATICO (id_evento, id_regiao, tipo, severidade, score_risco, dt_inicio, dt_fim, fonte) VALUES (50, 18, 'SECA', 'CRITICO', 0.8024, TO_TIMESTAMP_TZ('2024-05-20 08:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), NULL, 'SATELITE');

-- total eventos: 50

-- 6. ALERTA
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (1, 17, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-06 20:10:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (2, 15, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-05-03 02:40:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (3, 48, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-04-26 13:10:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (4, 39, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'SISTEMA', TO_TIMESTAMP_TZ('2024-05-12 04:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (5, 17, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-22 04:20:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (6, 15, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-30 18:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (7, 28, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-02 11:40:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (8, 17, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-30 19:50:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (9, 29, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-29 05:20:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (10, 34, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-11 11:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (11, 18, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-03 18:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (12, 37, 'PERIGO', 'Risco ALTO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-05-07 22:20:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (13, 28, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-19 00:50:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (14, 3, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-05-04 15:50:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (15, 41, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-05 23:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (16, 17, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-07 22:50:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (17, 46, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-06-02 07:50:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (18, 40, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SISTEMA', TO_TIMESTAMP_TZ('2024-06-01 22:40:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (19, 38, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-06 09:10:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (20, 44, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'SISTEMA', TO_TIMESTAMP_TZ('2024-05-09 05:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (21, 39, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'SISTEMA', TO_TIMESTAMP_TZ('2024-05-23 10:50:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (22, 1, 'PERIGO', 'Risco ALTO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-05-14 03:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (23, 18, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'SISTEMA', TO_TIMESTAMP_TZ('2024-05-25 16:20:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (24, 3, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SISTEMA', TO_TIMESTAMP_TZ('2024-05-15 10:10:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (25, 35, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-09 21:10:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (26, 3, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-27 22:10:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (27, 17, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-08 08:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (28, 23, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-06-01 09:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (29, 23, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-30 10:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (30, 5, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'SISTEMA', TO_TIMESTAMP_TZ('2024-06-02 00:50:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (31, 13, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-25 17:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (32, 19, 'PERIGO', 'Risco ALTO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-03 04:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (33, 11, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-05-14 09:40:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (34, 3, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-03 03:20:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (35, 38, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-04-27 11:40:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (36, 4, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-05 17:50:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (37, 1, 'PERIGO', 'Risco ALTO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-05-04 02:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (38, 5, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-11 06:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (39, 43, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-05-28 14:10:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (40, 40, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SISTEMA', TO_TIMESTAMP_TZ('2024-05-30 01:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (41, 35, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-29 12:20:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (42, 35, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-11 02:20:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (43, 2, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-04-25 03:40:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (44, 6, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-06-04 13:10:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (45, 44, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-04-27 03:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (46, 25, 'PERIGO', 'Risco ALTO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-19 08:10:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (47, 29, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-04-25 16:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (48, 18, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-09 07:20:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (49, 49, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-21 08:10:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (50, 35, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-07 12:50:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (51, 13, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SISTEMA', TO_TIMESTAMP_TZ('2024-05-31 01:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (52, 12, 'PERIGO', 'Risco ALTO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-05-01 00:40:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (53, 6, 'EMERGENCIA', 'Risco CRITICO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-31 16:50:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (54, 14, 'PERIGO', 'Risco ALTO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-04-26 17:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (55, 44, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-05-14 19:10:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (56, 47, 'PERIGO', 'Risco ALTO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-11 07:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (57, 7, 'PERIGO', 'Risco ALTO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-05-15 16:40:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (58, 29, 'ATENCAO', 'Risco MEDIO detectado - acao recomendada conforme protocolo SENTINELA', 'SMS', TO_TIMESTAMP_TZ('2024-05-09 19:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'S');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (59, 28, 'INFO', 'Risco BAIXO detectado - acao recomendada conforme protocolo SENTINELA', 'EMAIL', TO_TIMESTAMP_TZ('2024-05-27 23:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');
INSERT INTO ALERTA (id_alerta, id_evento, nivel, mensagem, canal, dt_enviado, confirmado) VALUES (60, 10, 'PERIGO', 'Risco ALTO detectado - acao recomendada conforme protocolo SENTINELA', 'API', TO_TIMESTAMP_TZ('2024-05-17 04:50:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 'N');

-- total alertas: 60
-- Alerta 29: estava em abril, evento começa em junho
UPDATE ALERTA
SET dt_enviado = TO_TIMESTAMP_TZ('2024-06-05 10:30:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM')
WHERE id_alerta = 29;

-- Alerta 28: estava 3 dias antes do evento
UPDATE ALERTA
SET dt_enviado = TO_TIMESTAMP_TZ('2024-06-04 06:15:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM')
WHERE id_alerta = 28;

-- Evento 8: severidade BAIXO mas score 0.9057 (absurdo)
UPDATE EVENTO_CLIMATICO SET score_risco = 0.1842 WHERE id_evento = 8;

-- Evento 10: severidade ALTO mas score 0.0603
UPDATE EVENTO_CLIMATICO SET score_risco = 0.7619 WHERE id_evento = 10;

-- Evento 23: severidade CRITICO mas score 0.07
UPDATE EVENTO_CLIMATICO SET score_risco = 0.9134 WHERE id_evento = 23;

COMMIT;
