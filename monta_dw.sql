
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
	is_free BOOLEAN,
	required_age INTEGER
);

SELECT  
	COUNT(*) 
FROM dw.dim_jogo;

SELECT * FROM dw.dim_jogo;

--INSERINDO DADOS NA dimensão
INSERT INTO dw.dim_jogo(
	appid,
	name,
	is_free,
	required_age
)
SELECT 
	DISTINCT 
	appid,
	name,
	is_free,
	required_age
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

--VERIFICAR O MAIOR CARACTER DA TABELA
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
--------------------------------------------------------------------

--------------------------------------------------------------------
--CRIANDO A TABELA FATO
DROP TABLE IF EXISTS dw.fact_steam;

CREATE TABLE dw.fact_steam(
	jogo_sk INTEGER PRIMARY KEY REFERENCES dw.dim_jogo(jogo_sk),
	developer_sk INTEGER REFERENCES dw.dim_developer(developer_sk),
	publisher_sk INTEGER REFERENCES dw.dim_publisher(publisher_sk),
	date_sk INTEGER REFERENCES dw.dim_date(date_sk),

	positive INTEGER,
    negative INTEGER,
    owners_min INTEGER,
    owners_max INTEGER,
    price NUMERIC(10,2),
    ccu INTEGER,

	average_forever INTEGER,
	average_2weeks INTEGER,
	median_forever INTEGER,
	median_2weeks INTEGER,
	initialprice NUMERIC(10,2),
	discount INTEGER,
	metacritic_score INTEGER, 
	recommendations INTEGER,
	achievements INTEGER
);

SELECT * FROM dw.fact_steam;
--obs: os dados vem da staging e não das dim
INSERT INTO dw.fact_steam(
	jogo_sk,
	developer_sk ,
	publisher_sk ,
	date_sk ,

	positive ,
    negative ,
    owners_min ,
    owners_max ,
    price,
    ccu,

	average_forever,
	average_2weeks,
	median_forever,
	median_2weeks,
	initialprice,
	discount,
	metacritic_score, 
	recommendations,
	achievements
	
)
SELECT 
	j.jogo_sk,
	dv.developer_sk,
	p.publisher_sk,
	d.date_sk,
	s.positive,
	s.negative,
	s.owners_min,
	s.owners_max,
	s.price,
    s.ccu,

	s.average_forever,
	s.average_2weeks,
	s.median_forever,
	s.median_2weeks,
	s.initialprice,
	s.discount,
	s.metacritic_score, 
	s.recommendations,
	s.achievements
FROM staging.steam_games s
JOIN dw.dim_jogo j
	ON j.appid = s.appid
LEFT JOIN dw.dim_developer dv
	ON dv.developer = s.developer
LEFT JOIN dw.dim_publisher p
	ON p.publisher = s.publisher
LEFT JOIN dw.dim_date d
	ON d.full_date = s.release_date
;
	
SELECT * FROM dw.fact_steam;


SELECT COUNT(*) FROM staging.steam_games;
SELECT COUNT(*) FROM dw.fact_steam;


--Testando alguns JOINS (puxando da fato)
SELECT
    j.name,
    dv.developer,
    p.publisher,
    d.full_date AS release_date,
    f.negative
FROM dw.fact_steam f

JOIN dw.dim_jogo j
    ON j.jogo_sk = f.jogo_sk

LEFT JOIN dw.dim_developer dv
    ON dv.developer_sk = f.developer_sk

LEFT JOIN dw.dim_publisher p
    ON p.publisher_sk = f.publisher_sk

LEFT JOIN dw.dim_date d
    ON d.date_sk = f.date_sk
ORDER BY negative DESC;
LIMIT 10;

--------------------------------------------------------------------



