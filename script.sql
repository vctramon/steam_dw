CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA dw;

 -- cria a tabela RAW

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

SELECT COUNT(*) FROM raw.steam_games;
SELECT * FROM raw.steam_games;



-- cria a tabela STAGING

