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


DROP FUNCTION f_get_ohlcv(text[],timestamp without time zone,timestamp without time zone,text,interval);

CREATE OR REPLACE FUNCTION public.f_get_ohlcv(
    _codes text[],
    _from_date timestamp without time zone,
    _to_date timestamp without time zone,
    _source text default 'VND',
    _bucket interval default '1 min'
)
RETURNS TABLE(
    "Date" timestamp without time zone,
	symbol character varying(11),
    open numeric,
    high numeric,
    low numeric,
    close numeric,
    volume numeric
)
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
ROWS 1000

AS $BODY$
begin 
    return query
	SELECT time_bucket(_bucket, ts - interval '7 Hours') as bucket,
		   code as symbol,
		   first(matchprice, ts) as open,
		   max(matchprice) as high,
		   min(matchprice) as low,
		   last(matchprice, ts) as close,
		   case
		       when last(accumulatedvol, ts) is null then sum(matchqtty)
			   else last(accumulatedvol, ts) - first(accumulatedvol, ts) + first(matchqtty, ts)
			END as volume
	FROM all_sources_order_matching
	WHERE (
		ts >= _from_date + interval '7 Hours'
		and ts < _to_date + interval '7 Hours'
		and source = _source
		and code = any(_codes)
	)
	group by bucket, code
	order by bucket;
END;
$BODY$;
	