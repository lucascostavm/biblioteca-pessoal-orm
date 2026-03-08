-- =============================================================
-- PROJETO FINAL: BIBLIOTECA PESSOAL DIGITAL
-- Script Unificado (Tabelas, Constraints, Objetos e Dados)
-- Aluno: Antonio Lucas da Costa Pereira
-- =============================================================

-- =====================================================
-- 0. LIMPEZA (DROPS) PARA REEXECUÇÃO
-- =====================================================
DROP VIEW IF EXISTS vw_publicacoes_leitura;
DROP MATERIALIZED VIEW IF EXISTS mv_relatorio_genero;
DROP PROCEDURE IF EXISTS pr_verificar_leituras_antigas;
DROP FUNCTION IF EXISTS fn_validacoes_leitura CASCADE;
DROP FUNCTION IF EXISTS fn_log_conclusao_leitura CASCADE;

DROP TABLE IF EXISTS anotacao CASCADE;
DROP TABLE IF EXISTS leitura CASCADE;
DROP TABLE IF EXISTS publicacao CASCADE;
DROP TABLE IF EXISTS configuracao CASCADE;

-- =====================================================
-- 1. CRIAÇÃO DO BANCO DE DADOS (Tabelas Base)
-- =====================================================

CREATE TABLE configuracao (
    id_configuracao SERIAL PRIMARY KEY,
    genero_favorito VARCHAR(50),
    limite_simultaneas INT DEFAULT 3,
    meta_anual_leituras INT NOT NULL
);

CREATE TABLE publicacao (
    id_publicacao SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(150) NOT NULL,
    ano INT CHECK (ano >= 1500),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('LIVRO', 'REVISTA')),
    genero VARCHAR(50),
    num_paginas INT CHECK (num_paginas > 0),
    data_inclusao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_publicacao_titulo_autor UNIQUE (titulo, autor)
);

CREATE TABLE leitura (
    id_leitura SERIAL PRIMARY KEY,
    id_publicacao INT NOT NULL,
    data_inicio DATE,
    data_fim DATE,
    status VARCHAR(20) DEFAULT 'NAO LIDO' CHECK (status IN ('NAO LIDO', 'LENDO', 'LIDO', 'ABANDONADO')),
    pagina_atual INT DEFAULT 0,
    avaliacao INT CHECK (avaliacao BETWEEN 0 AND 10)
    -- A FK será adicionada na etapa de constraints
);

CREATE TABLE anotacao (
    id_anotacao SERIAL PRIMARY KEY,
    id_publicacao INT NOT NULL,
    texto TEXT NOT NULL,
    trecho TEXT,
    data_anotacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    -- A FK será adicionada na etapa de constraints
);

-- =====================================================
-- 2. APLICAÇÃO DE CONSTRAINTS E REGRAS DE INTEGRIDADE
-- =====================================================

-- CHECK CONSTRAINTS
ALTER TABLE leitura
ADD CONSTRAINT ck_leitura_pagina_nao_negativa
CHECK (pagina_atual >= 0);

ALTER TABLE leitura
ADD CONSTRAINT ck_leitura_datas_validas
CHECK (
    data_fim IS NULL 
    OR data_inicio IS NULL 
    OR data_fim >= data_inicio
);

ALTER TABLE publicacao
ADD CONSTRAINT ck_publicacao_paginas_validas
CHECK (num_paginas > 0);

-- UNIQUE CONSTRAINT
ALTER TABLE configuracao
ADD CONSTRAINT unq_configuracao_genero
UNIQUE (genero_favorito);

-- DEFAULT
ALTER TABLE leitura
ALTER COLUMN status SET DEFAULT 'NAO LIDO';

-- FOREIGN KEYS (REGRAS ON DELETE / ON UPDATE)
ALTER TABLE leitura
ADD CONSTRAINT fk_leitura_publicacao
FOREIGN KEY (id_publicacao)
REFERENCES publicacao(id_publicacao)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE anotacao
ADD CONSTRAINT fk_anotacao_publicacao
FOREIGN KEY (id_publicacao)
REFERENCES publicacao(id_publicacao)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- =====================================================
-- 3. VIEWS, TRIGGERS E PROCEDURE
-- =====================================================

-- VIEW
CREATE OR REPLACE VIEW vw_publicacoes_leitura AS
SELECT 
    p.id_publicacao,
    p.titulo,
    p.autor,
    p.genero,
    p.num_paginas,
    l.status,
    l.pagina_atual,
    l.data_inicio,
    l.data_fim,
    l.avaliacao
FROM publicacao p
LEFT JOIN leitura l 
    ON p.id_publicacao = l.id_publicacao;

-- VIEW MATERIALIZADA
CREATE MATERIALIZED VIEW mv_relatorio_genero AS
SELECT 
    p.genero,
    COUNT(p.id_publicacao) AS total_publicacoes,
    COUNT(l.id_leitura) FILTER (WHERE l.status = 'LIDO') AS total_concluidos,
    ROUND(AVG(l.avaliacao) FILTER (WHERE l.status = 'LIDO'), 2) AS media_avaliacao
FROM publicacao p
LEFT JOIN leitura l 
    ON p.id_publicacao = l.id_publicacao
GROUP BY p.genero;

-- TRIGGER BEFORE: Validações de leitura
CREATE OR REPLACE FUNCTION fn_validacoes_leitura()
RETURNS TRIGGER AS $$
DECLARE
    total_paginas INT;
BEGIN
    -- Validação de página atual
    SELECT num_paginas INTO total_paginas
    FROM publicacao
    WHERE id_publicacao = NEW.id_publicacao;

    IF NEW.pagina_atual > total_paginas THEN
        RAISE EXCEPTION 
        'A página atual (%) não pode exceder o total de páginas (%).',
        NEW.pagina_atual, total_paginas;
    END IF;

    -- Definição automática de data_fim
    IF NEW.status = 'LIDO' AND NEW.data_fim IS NULL THEN
        NEW.data_fim := CURRENT_DATE;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validacoes_leitura
BEFORE INSERT OR UPDATE ON leitura
FOR EACH ROW
EXECUTE FUNCTION fn_validacoes_leitura();

-- TRIGGER AFTER: Log de conclusão
CREATE OR REPLACE FUNCTION fn_log_conclusao_leitura()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'LIDO' AND OLD.status <> 'LIDO' THEN
        RAISE NOTICE 
        'Leitura concluída para publicação ID % em %.',
        NEW.id_publicacao, CURRENT_DATE;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_conclusao_leitura
AFTER UPDATE ON leitura
FOR EACH ROW
EXECUTE FUNCTION fn_log_conclusao_leitura();

-- PROCEDURE: Verificar leituras antigas
CREATE OR REPLACE PROCEDURE pr_verificar_leituras_antigas()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE leitura
    SET status = 'ABANDONADO'
    WHERE status = 'LENDO'
      AND data_inicio < CURRENT_DATE - INTERVAL '60 days'
      AND data_fim IS NULL;
END;
$$;

-- =====================================================
-- 4. CARGA DE DADOS (INSERTs)
-- =====================================================

INSERT INTO configuracao (genero_favorito, limite_simultaneas, meta_anual_leituras)
VALUES ('Fantasia', 5, 12);

INSERT INTO publicacao (titulo, autor, ano, tipo, genero, num_paginas) VALUES
('O Pequeno Príncipe', 'Antoine de Saint-Exupéry', 1943, 'LIVRO', 'Infantil', 96),
('O Caso Evandro', 'Ivan Mizanzuk', 2021, 'LIVRO', 'True Crime', 448),
('1984', 'George Orwell', 1949, 'LIVRO', 'Distopia', 336),
('As Crônicas de Gelo e Fogo', 'George R. R. Martin', 1996, 'LIVRO', 'Fantasia', 600);

INSERT INTO leitura (id_publicacao, data_inicio, data_fim, status, pagina_atual, avaliacao)
VALUES (1, '2024-01-10', '2024-01-15', 'LIDO', 96, 10);

INSERT INTO leitura (id_publicacao, data_inicio, status, pagina_atual)
VALUES (2, '2024-02-01', 'LENDO', 215);

INSERT INTO leitura (id_publicacao, data_inicio, data_fim, status, pagina_atual, avaliacao)
VALUES (3, '2023-11-05', '2023-11-20', 'LIDO', 336, 9);

INSERT INTO anotacao (id_publicacao, texto, trecho) VALUES
(1, 'Reflexão profunda sobre a responsabilidade afetiva.', 'Tu te tornas eternamente responsável por aquilo que cativas.'),
(2, 'A complexidade da investigação é impressionante.', 'O inquérito policial é a base de tudo, mas também a fonte dos maiores erros.'),
(3, 'Assustadoramente atual sobre vigilância e controle.', 'O Grande Irmão está de olho em você.');

-- Inserção em massa gerada automaticamente
INSERT INTO publicacao (
    titulo,
    autor,
    ano,
    tipo,
    genero,
    num_paginas
)
SELECT
    'Publicacao ' || gs AS titulo,
    'Autor ' || (gs % 500) AS autor,
    1950 + (random() * 75)::int AS ano,
    CASE 
        WHEN random() < 0.7 THEN 'LIVRO'
        ELSE 'REVISTA'
    END AS tipo,
    CASE 
        WHEN random() < 0.2 THEN 'Fantasia'
        WHEN random() < 0.4 THEN 'Distopia'
        WHEN random() < 0.6 THEN 'True Crime'
        WHEN random() < 0.8 THEN 'Infantil'
        ELSE 'Romance'
    END AS genero,
    50 + (random() * 950)::int AS num_paginas
FROM generate_series(1, 20000) AS gs;

-- Para testar os objetos programáveis criados:
-- REFRESH MATERIALIZED VIEW mv_relatorio_genero;
-- CALL pr_verificar_leituras_antigas();