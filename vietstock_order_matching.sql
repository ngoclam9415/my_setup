CREATE TABLE vietstock_order_matching(insert_ts timestamp without time zone,"Package" numeric,"Vol" numeric,"TotalVal" numeric,"TotalVol" numeric,"IsBuy" character varying,"Price" numeric,"PerChange" numeric,"Stockcode" character varying,"Change" numeric,"TradingDate" timestamp without time zone NOT NULL);

SELECT create_hypertable('vietstock_order_matching', 'TradingDate', migrate_data => true)

CREATE INDEX ON vietstock_order_matching ("TradingDate");

CREATE UNIQUE INDEX date_code_vietstock_order_matching
ON vietstock_order_matching("TradingDate", "Stockcode");