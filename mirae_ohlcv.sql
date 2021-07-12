-- SELECT create_hypertable('mirae_ohlcv', 'ts');
	
-- CREATE UNIQUE INDEX mirae_ohlcv_ts_symbol_idx ON mirae_ohlcv (ts, symbol);

-- CREATE OR REPLACE PROCEDURE public.resample_mirae(
-- 	)
-- LANGUAGE 'plpgsql'

-- AS $BODY$	begin
-- 		INSERT INTO mirae_ohlcv(ts, symbol, open, high, low, close, volume, insert_ts, executed_on)
-- 	SELECT time_bucket('1 min', ts - interval '7 Hour') as new_ts, 
-- 			code as symbol, 
-- 		   first(matchprice, ts) as open,
-- 		   max(matchprice) as high,
-- 		   min(matchprice) as low,
-- 		   last(matchprice, ts) as close,
-- 		   sum(matchqtty) as volume,
-- 		   NOW() as insert_ts,
-- 		   time_bucket('1 min', ts - interval '7 Hour')::date as executed_on
-- 			FROM all_sources_order_matching
-- 			WHERE ts::date = NOW()::date and source = 'MAS'
-- 			GROUP BY new_ts, symbol
-- ON CONFLICT (ts, symbol) DO UPDATE SET open=excluded.open, high=excluded.high, low=excluded.low, close=excluded.close, volume=excluded.volume, insert_ts=excluded.insert_ts, executed_on=excluded.executed_on;
-- end;
-- $BODY$;

call resample_mirae()


