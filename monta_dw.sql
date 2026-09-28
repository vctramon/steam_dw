
-------------------------------------
-- cria as DIMENSÕES
-------------------------------------

--------------------------------------------------------------------
--CRIANDO DIMENSÃO jogo
DROP TABLE IF EXISTS dw.dim_jogo;

CREATE TABLE dw.dim_jogo(
	jogo_sk SERIAL PRIMARY KEY,
	appid INTEGER, 
	name VARCHAR(300),
	is_free BOOLEAN
);

SELECT  
	COUNT(*) 
FROM dw.dim_jogo;

--INSERINDO DADOS NA dimensão
INSERT INTO dw.dim_jogo(
	appid,
	name,
	is_free
)
SELECT 
	DISTINCT 
	appid,
	name,
	is_free
FROM staging.steam_games;

SELECT * FROM dw.dim_jogo
--------------------------------------------------------------------

--------------------------------------------------------------------
--CRIANDO DIMENSÃO developer
DROP TABLE IF EXISTS dw.dim_developer;

CREATE TABLE dw.dim_developer(
	developer_sk SERIAL PRIMARY KEY,
	developer VARCHAR(250) UNIQUE
);

SELECT COUNT(*) FROM dw.dim_developer;

--Para descobrir o maior caracter daquela coluna
SELECT
    MAX(LENGTH(developer)) AS maior_tamanho
FROM staging.steam_games;

--INSERINDO DADOS NA dim_developer
INSERT INTO dw.dim_developer(
	developer
)
	SELECT DISTINCT developer
FROM staging.steam_games
WHERE developer IS NOT NULL;

SELECT * FROM dw.dim_developer;
--------------------------------------------------------------------

--------------------------------------------------------------------
--CRIANDO DIMENSÃO dim_publihser
DROP TABLE IF EXISTS dw.dim_publisher;
CREATE TABLE dw.dim_publisher(
	publisher_sk SERIAL PRIMARY KEY,
	publisher VARCHAR(150)UNIQUE
);

SELECT 
	MAX(LENGTH(publisher)) AS maior_tamanho
FROM staging.steam_games;

SELECT COUNT(*) FROM dw.dim_publisher;

--INSERINDO DADOS NA publisher
INSERT INTO dw.dim_publisher(	
	publisher
)
SELECT DISTINCT publisher
FROM staging.steam_games
WHERE publisher IS NOT NULL;

SELECT * FROM dw.dim_publisher;
--------------------------------------------------------------------

--------------------------------------------------------------------
--PARA DESCOBRIR A MENOR E A MAIOR DATA
--PARA USAR O generate_series() QUE VAI GERAR DIA A DIA
SELECT
    MIN(release_date) AS menor_data,
    MAX(release_date) AS maior_data
FROM staging.steam_games
WHERE release_date IS NOT NULL;

--CRIANDO DIMENSÃO date
DROP TABLE IF EXISTS dw.dim_date;

CREATE TABLE dw.dim_date(
    date_sk INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day SMALLINT NOT NULL,
    month SMALLINT NOT NULL,
    month_name VARCHAR(15) NOT NULL,
    quarter SMALLINT NOT NULL,
    year SMALLINT NOT NULL,
    day_of_week VARCHAR(15) NOT NULL,
    is_weekend BOOLEAN NOT NULL
);
--INSERINDO DADOS NA date
INSERT INTO dw.dim_date
SELECT
	CAST(TO_CHAR(d, 'YYYYMMDD')AS INTEGER),
	d::DATE,
	EXTRACT(DAY FROM d)::SMALLINT,
	EXTRACT(MONTH FROM d)::SMALLINT,
	TO_CHAR(d, 'TMMonth'),
	EXTRACT(QUARTER FROM d)::SMALLINT,
	EXTRACT(YEAR FROM d)::SMALLINT,
	TO_CHAR(d, 'TMDay'),
	EXTRACT(DOW FROM d) IN (0, 6)
FROM generate_series(
	DATE '1997-06-30',
	DATE '2026-08-05', 
	INTERVAL '1 day'
)g(d);

SELECT * 
	FROM dw.dim_date
ORDER BY full_date

SELECT COUNT(*) FROM dw.dim_date;





