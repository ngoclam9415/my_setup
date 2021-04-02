CREATE TABLE public.sts_foreign_MO
(
    ts timestamp without time zone NOT NULL,
    symbol character varying(7) COLLATE pg_catalog."default",
    total_room numeric,
    owned_ratio numeric,
    curr_room numeric,
    remain_room numeric,
    buy_vol numeric,
    per_buy_vol numeric,
	buy_val numeric,
	per_buy_val numeric,
	sell_vol numeric,
	per_sell_vol numeric,
	sell_val numeric,
	per_sell_val numeric,
	diff_buy_sell_vol numeric,
	diff_buy_sell_val numeric,
	buy_put_vol numeric,
	per_buy_put_vol numeric,
	buy_put_val numeric,
	per_buy_put_val numeric,
	sell_put_vol numeric,
	per_sell_put_vol numeric,
	sell_put_val numeric,
	per_sell_put_val numeric,
	diff_buy_sell_put_vol numeric,
	diff_buy_sell_put_val numeric,
	row numeric
)



-- FUNCTION: public.f_ohlcv_vndirect(text, text, text, text, boolean)

DROP FUNCTION public.f_ohlcv_vndirect(text, text, text, boolean);

CREATE OR REPLACE FUNCTION public.f_ohlcv_vndirect(
	groupinterval text,
	from_date text DEFAULT NULL::text,
	to_date text DEFAULT NULL::text,
	_round boolean DEFAULT false)
    RETURNS TABLE(bucket timestamp without time zone, code character varying, open numeric, high numeric, low numeric, close numeric, volume numeric) 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$
DECLARE
	_groupinterval TEXT;
	_from_date TIMESTAMP := (NOW()::DATE - INTERVAL '7 day')::TEXT;
	_to_date TIMESTAMP := (NOW()::DATE + INTERVAL '1 day')::TEXT;
BEGIN
	_groupinterval = groupinterval;

	IF from_date IS NOT NULL THEN
		_from_date = from_date;
	END IF;

	IF to_date IS NOT NULL THEN
		_to_date = to_date;
	END IF;
	if _round then 
		RETURN QUERY EXECUTE FORMAT('
		WITH cte AS (
			SELECT
				CASE
					WHEN new_table.time::TIME >= ''11:30:00''::TIME AND new_table.time::TIME < ''12:00:00''::TIME THEN new_table.time::DATE + ''11:29:59.999999''::TIME
					WHEN new_table.time::TIME >= ''14:30:00''::TIME AND new_table.time::TIME < ''14:45:00''::TIME THEN new_table.time::DATE + ''14:29:59.999999''::TIME
					WHEN new_table.time::TIME >= ''14:45:00''::TIME AND new_table.time::TIME < ''14:50:00''::TIME THEN new_table.time::DATE + ''14:45:01''::TIME
					ELSE new_table.time
				END AS round_ts,
				new_table.ts,
				new_table.matchprice,
				new_table.matchqtty,
				new_table.accumulatedvol,
				new_table.code,
				new_table.lagaccumulatedvol,
				new_table.lagts
			FROM (
				SELECT
				    futures_order_book.ts,
				    futures_order_book.ts::DATE + futures_order_book.time::TIME as time,
					futures_order_book.matchprice,
					futures_order_book.matchqtty,
					futures_order_book.accumulatedvol,
					futures_order_book.standard_code AS code,
					lag(futures_order_book.accumulatedvol) OVER (PARTITION BY futures_order_book.code ORDER BY futures_order_book.ts) AS lagaccumulatedvol,
					lag(futures_order_book.ts) OVER (PARTITION BY futures_order_book.code ORDER BY futures_order_book.ts) AS lagts
				FROM futures_order_book
				WHERE (
					ts BETWEEN ''%s''::DATE AND ''%s''::DATE + INTERVAL ''1 day''
					and futures_order_book.matchqtty IS NOT NULL
				)
				UNION ALL
				SELECT
				    equity_order_book.ts as time,
				    equity_order_book.ts,
					equity_order_book.matchprice,
					equity_order_book.matchqtty,
					equity_order_book.accumulatedvol,
					equity_order_book.code,
					lag(equity_order_book.accumulatedvol) OVER (PARTITION BY equity_order_book.code ORDER BY equity_order_book.ts) AS lagaccumulatedvol,
					lag(equity_order_book.ts) OVER (PARTITION BY equity_order_book.code ORDER BY equity_order_book.ts) AS lagts
				FROM equity_order_book
				WHERE (
					ts BETWEEN ''%s''::DATE AND ''%s''::DATE + INTERVAL ''1 day''
					and equity_order_book.matchqtty IS NOT NULL
				)
			) new_table
			WHERE (
				new_table.accumulatedvol <> new_table.lagaccumulatedvol
				-- and new_table.matchqtty IS NOT NULL
			)
			UNION ALL
	        (
	            SELECT
	                NOW()::timestamp AS round_ts,
	                NULL AS ts,
	                NULL AS matchprice,
	                NULL AS matchqtty,
	                NULL AS accumulatedvol,
	                ''KIM'' AS code,
	                NULL AS lagaccumulatedvol,
	                NULL AS lagts
	        )
	
		)
		-- select from cte
		--
		SELECT time_bucket(''%s'', cte.round_ts) AS bucket,
			cte.code AS code,
			first(cte.matchprice, cte.ts) AS open,
			max(cte.matchprice) AS high,
			min(cte.matchprice) AS low,
			last(cte.matchprice, cte.ts) AS close,
			(
				CASE
					WHEN first(cte.lagaccumulatedvol, cte.ts) IS NULL THEN max(cte.accumulatedvol)
					WHEN last(cte.ts, cte.ts)::date = first(cte.lagts, cte.ts)::date THEN max(cte.accumulatedvol) - min(cte.lagaccumulatedvol)
					ELSE max(cte.accumulatedvol)
				END
			) AS volume
		FROM cte
		WHERE time_bucket(''%s'', cte.round_ts) BETWEEN ''%s'' AND ''%s''
		GROUP BY code, time_bucket(''%s'', cte.round_ts)
		HAVING max(cte.matchprice) IS NOT NULL;
		', _from_date, _to_date,
		 _from_date, _to_date,
		 _groupinterval,
		 _groupinterval, _from_date, _to_date,
		 _groupinterval);
	else
		RETURN QUERY EXECUTE FORMAT('
		WITH cte AS (
			SELECT
				new_table.time as round_ts,
				new_table.ts,
				new_table.matchprice,
				new_table.matchqtty,
				new_table.accumulatedvol,
				new_table.code,
				new_table.lagaccumulatedvol,
				new_table.lagts
			FROM (
				SELECT
				    futures_order_book.ts,
				    futures_order_book.ts::DATE + futures_order_book.time::TIME as time,
					futures_order_book.matchprice,
					futures_order_book.matchqtty,
					futures_order_book.accumulatedvol,
					futures_order_book.standard_code AS code,
					lag(futures_order_book.accumulatedvol) OVER (PARTITION BY futures_order_book.code ORDER BY futures_order_book.ts) AS lagaccumulatedvol,
					lag(futures_order_book.ts) OVER (PARTITION BY futures_order_book.code ORDER BY futures_order_book.ts) AS lagts
				FROM futures_order_book
				WHERE (
					ts BETWEEN ''%s''::DATE AND ''%s''::DATE + INTERVAL ''1 day''
					and futures_order_book.matchqtty IS NOT NULL
				)
				UNION ALL
				SELECT
				    equity_order_book.ts as time,
				    equity_order_book.ts,
					equity_order_book.matchprice,
					equity_order_book.matchqtty,
					equity_order_book.accumulatedvol,
					equity_order_book.code,
					lag(equity_order_book.accumulatedvol) OVER (PARTITION BY equity_order_book.code ORDER BY equity_order_book.ts) AS lagaccumulatedvol,
					lag(equity_order_book.ts) OVER (PARTITION BY equity_order_book.code ORDER BY equity_order_book.ts) AS lagts
				FROM equity_order_book
				WHERE (
					ts BETWEEN ''%s''::DATE AND ''%s''::DATE + INTERVAL ''1 day''
					and equity_order_book.matchqtty IS NOT NULL
				)
			) new_table
			WHERE (
				new_table.accumulatedvol <> new_table.lagaccumulatedvol
				-- and new_table.matchqtty IS NOT NULL
			)
			UNION ALL
	        (
	            SELECT
	                NOW()::timestamp AS round_ts,
	                NULL AS ts,
	                NULL AS matchprice,
	                NULL AS matchqtty,
	                NULL AS accumulatedvol,
	                ''KIM'' AS code,
	                NULL AS lagaccumulatedvol,
	                NULL AS lagts
	        )
	
		)
		-- select from cte
		--
		SELECT time_bucket(''%s'', cte.round_ts) AS bucket,
			cte.code as code,
			first(cte.matchprice, cte.ts) AS open,
			max(cte.matchprice) AS high,
			min(cte.matchprice) AS low,
			last(cte.matchprice, cte.ts) AS close,
			(
				CASE
					WHEN first(cte.lagaccumulatedvol, cte.ts) IS NULL THEN max(cte.accumulatedvol)
					WHEN last(cte.ts, cte.ts)::date = first(cte.lagts, cte.ts)::date THEN max(cte.accumulatedvol) - min(cte.lagaccumulatedvol)
					ELSE max(cte.accumulatedvol)
				END
			) AS volume
		FROM cte
		WHERE time_bucket(''%s'', cte.round_ts) BETWEEN ''%s'' AND ''%s''
		GROUP BY code, time_bucket(''%s'', cte.round_ts)
		HAVING max(cte.matchprice) IS NOT NULL;
		', _from_date, _to_date,
		 _from_date, _to_date,
		 _groupinterval,
		 _groupinterval, _from_date, _to_date,
		 _groupinterval);
	end if;
END;
$BODY$;

ALTER FUNCTION public.f_ohlcv_vndirect(text, text, text, boolean)
    OWNER TO admin;
