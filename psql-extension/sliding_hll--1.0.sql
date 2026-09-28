-- Функция накопления
CREATE FUNCTION sliding_hll_accum(internal, bigint, interval, integer DEFAULT 11)
RETURNS internal
AS 'MODULE_PATHNAME', 'sliding_hll_accum'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION sliding_hll_final(internal)
RETURNS bigint
AS 'MODULE_PATHNAME', 'sliding_hll_final'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

-- Регистрируем агрегат; последнее значение выбрано оптимально
CREATE AGGREGATE sliding_count_distinct(bigint, interval, integer DEFAULT 11) (
    SFUNC = sliding_hll_accum,
    STYPE = internal,
    FINALFUNC = sliding_hll_final,
    PARALLEL = SAFE
);
