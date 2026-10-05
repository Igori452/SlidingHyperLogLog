-- Функция накопления
CREATE FUNCTION sliding_hll_accum(internal, timestamptz, bigint, interval)
RETURNS internal
AS 'MODULE_PATHNAME', 'sliding_hll_accum'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION sliding_hll_final(internal)
RETURNS bigint
AS 'MODULE_PATHNAME', 'sliding_hll_final'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE AGGREGATE sliding_count_distinct(timestamptz, bigint, interval) (
    SFUNC = sliding_hll_accum,
    STYPE = internal,
    FINALFUNC = sliding_hll_final,
    PARALLEL = SAFE
);