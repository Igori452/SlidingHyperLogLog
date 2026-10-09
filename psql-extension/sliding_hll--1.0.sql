-- SFUNC: state + timestamp + value + interval + refTime
CREATE FUNCTION sliding_hll_accum(internal, timestamptz, bigint, interval, timestamptz)
RETURNS internal
AS 'MODULE_PATHNAME', 'sliding_hll_accum'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

-- FINALFUNC: state + timestamp + value + interval + refTime
CREATE FUNCTION sliding_hll_final(internal, timestamptz, bigint, interval, timestamptz)
RETURNS bigint
AS 'MODULE_PATHNAME', 'sliding_hll_final'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE AGGREGATE sliding_count_distinct(timestamptz, bigint, interval, timestamptz) (
    SFUNC = sliding_hll_accum,
    STYPE = internal,
    FINALFUNC = sliding_hll_final,
    FINALFUNC_EXTRA,
    PARALLEL = SAFE
);