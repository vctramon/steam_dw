CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA dw;

 
------------------------------------------
-- cria a tabela RAW
------------------------------------------
-- DROP TABLE IF EXISTS raw.steam_games;

CREATE TABLE raw.steam_games(

	appid TEXT,
	name TEXT,
	developer TEXT,
	publisher TEXT,

	positive TEXT,
	negative TEXT,
	owners TEXT,

	average_forever TEXT,
	average_2weeks TEXT,
	median_forever TEXT,
	median_2weeks TEXT,

	price TEXT,
	initialprice TEXT,
	discount TEXT,
	ccu TEXT,
	
	release_data TEXT,
	required_age TEXT,
	is_free TEXT,

	short_description TEXT,
	supported_languages TEXT,

	plataforms_windows TEXT,
	plataforms_mac TEXT,
	plataforms_linux TEXT,

	metacritic_score TEXT,
	recommendations TEXT,
	achievements TEXT,

	genres TEXT,
	categories TEXT,
	
	extra_1 TEXT,
    extra_2 TEXT,
    extra_3 TEXT,
    extra_4 TEXT
);

--Traz todas as colunas da tabelas
SELECT * FROM raw.steam_games;

--Traz a contagem de todas as linhas dessa tabela
SELECT COUNT(*) FROM raw.steam_games;

--
SELECT DISTINCT release_date
FROM raw.steam_games
WHERE release_date IS NOT NULL
LIMIT 30;

--
SELECT 
	appid,
	COUNT (appid) AS quantidade
FROM raw.steam_games
GROUP BY appid;

--
SELECT 
	appid,
	count(*) AS quantidade
from raw.steam_games
GROUP BY appid
HAVING COUNT(*) > 1;

-- PARA DESCOBRIR O TOTAL DE VALORES NULL E VAZIOS
SELECT 
	COUNT (appid) AS quantidade_null
FROM raw.steam_games
WHERE appid IS NULL OR appid = '';

-- PARA SABER A QUANTIDADE TOTAL DE DUPLICADOS
SELECT COUNT(*) AS quantidade_appids_duplicados
FROM (
    SELECT appid
    FROM raw.steam_games
    GROUP BY appid
    HAVING COUNT(*) > 1
) AS duplicados;

--PARA DESCOBRIR O TOTAL DE LINHAS DUPLICAS DISTINTAS
SELECT COUNT(*) AS linhas_unicas
FROM (
    SELECT DISTINCT *
    FROM raw.steam_games
) AS dados_unicos;--

-- INVESTIGANDO appid
SELECT *
FROM raw.steam_games
WHERE appid = '1083310';

--Ve o total de dados distintos maiores que 1
SELECT
    appid,
    COUNT(*) AS quantidade
FROM (
    SELECT DISTINCT *
    FROM raw.steam_games
) AS dados_unicos
GROUP BY appid
HAVING COUNT(*) > 1;

-------------------------------------
-- cria a tabela STAGING
-------------------------------------
DROP TABLE IF EXISTS staging.steam_games;
CREATE TABLE staging.steam_games(
	appid INTEGER PRIMARY KEY,
	name VARCHAR(300) NOT NULL,
	developer TEXT,
	publisher TEXT,

	positive INTEGER,
	negative INTEGER,

	owners_min INTEGER,
	owners_max INTEGER,

	average_forever INTEGER,
	average_2weeks INTEGER,
	median_forever INTEGER,
	median_2weeks INTEGER,

	price NUMERIC(10,2) NOT NULL,
	initialprice NUMERIC(10,2) NOT NULL,
	discount INTEGER,
	ccu INTEGER,

	release_date DATE,
	required_age INTEGER,
	is_free BOOLEAN,

	metacritic_score INTEGER,
	recommendations INTEGER,
	achievements INTEGER,

	genres TEXT,
	categories TEXT
);

--Inserindo dados na tabela STAGING
INSERT INTO staging.steam_games(
	appid,
	name,
	developer,
	publisher,
	positive,
	negative,
	owners_min,
    owners_max,
    average_forever,
    average_2weeks,
    median_forever,
    median_2weeks,
    price,
    initialprice,
    discount,
    ccu,
    release_date,
    required_age,
    is_free,
    metacritic_score,
    recommendations,
    achievements,
    genres,
    categories
)
SELECT DISTINCT
	appid::INTEGER,
	name,
	developer,
	publisher,
	
	NULLIF(TRIM(positive),'')::INTEGER,
	NULLIF(TRIM(negative),'')::INTEGER,
	
	NULLIF(
		REPLACE(TRIM(SPLIT_PART(owners,'..', 1)),',',''),
		''
	)::INTEGER,
	
	NULLIF(
		REPLACE(TRIM(SPLIT_PART(owners,'..', 2)),',', ''),
		''
	)::INTEGER,

	NULLIF(TRIM(average_forever),'')::INTEGER,
	NULLIF(TRIM(average_2weeks),'')::INTEGER,
	NULLIF(TRIM(median_forever),'')::INTEGER,
	NULLIF(TRIM(median_2weeks),'')::INTEGER,

	NULLIF(TRIM(price),'')::NUMERIC(10,2),
	NULLIF(TRIM(initialprice),'')::NUMERIC(10,2),
	NULLIF(TRIM(discount), '')::INTEGER,
	NULLIF(TRIM(ccu),'')::INTEGER,
	CASE
		WHEN NULLIF(TRIM(release_date),'') IS NULL THEN NULL
		WHEN release_date LIKE '%/%'
			THEN TO_DATE(TRIM(release_date), 'DD/Mon/YY')
		ELSE
			TO_DATE(TRIM(release_date),'DD Mon, YYYY')
	END,

	NULLIF(TRIM(required_age),'')::NUMERIC::INTEGER,
	NULLIF(TRIM(is_free),'')::BOOLEAN,

	NULLIF(TRIM(metacritic_score), '')::NUMERIC::INTEGER,
	NULLIF(TRIM(recommendations), '')::NUMERIC::INTEGER,
	NULLIF(TRIM(achievements),'')::NUMERIC::INTEGER,

	genres,
	categories
FROM raw.steam_games
WHERE appid ~ '^[0-9]+$'
	AND owners LIKE '%..%'
	AND NULLIF(TRIM(name), '') IS NOT NULL;

--Traz todas as colunas dessa tabela
SELECT * FROM staging.steam_games;

--Traz a contagem de todas as linhas dessa tabela
SELECT 
	COUNT(*) AS Total
FROM staging.steam_games;

