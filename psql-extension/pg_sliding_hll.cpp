#include "SlidingHyperLogLog.hpp"

extern "C" {
#include <postgres.h>
#include <fmgr.h>
#include <utils/builtins.h>
#include <utils/memutils.h>
#include <utils/timestamp.h> // Для работы с типом Interval
#include <cmath>

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(sliding_hll_accum);
PG_FUNCTION_INFO_V1(sliding_hll_final);
}

Datum sliding_hll_accum(PG_FUNCTION_ARGS)
{
    LFPM *state = nullptr;

    // Аргументы: 0=state, 1=timestamp, 2=value, 3=interval
    if (PG_ARGISNULL(3)) {
        ereport(ERROR, (errmsg("sliding_hll: window cannot be NULL")));
    }
    Interval *interval = PG_GETARG_INTERVAL_P(3);

    int64 total_microseconds = interval->time
                             + interval->day  * USECS_PER_DAY
                             + interval->month * DAYS_PER_MONTH * USECS_PER_DAY;
    auto window_chrono = std::chrono::microseconds(total_microseconds);

    if (PG_ARGISNULL(0)) {
        MemoryContext oldcontext;
        MemoryContext aggcontext;
        if (!AggCheckCallContext(fcinfo, &aggcontext))
            elog(ERROR, "sliding_hll: not in aggregate context");

        oldcontext = MemoryContextSwitchTo(aggcontext);
        state = new (palloc(sizeof(LFPM))) LFPM(11, window_chrono);
        MemoryContextSwitchTo(oldcontext);
    } else {
        state = reinterpret_cast<LFPM *>(PG_GETARG_POINTER(0));
    }

    if (!PG_ARGISNULL(1) && !PG_ARGISNULL(2)) {
        TimestampTz tstz = PG_GETARG_TIMESTAMPTZ(1);
        int64       item = PG_GETARG_INT64(2);

        // Postgres epoch = 2000-01-01, Unix epoch = 1970-01-01
        // Разница = 946684800 секунд
        constexpr int64 PG_EPOCH_OFFSET_US = 946684800LL * 1000000LL;
        int64 unix_us = tstz + PG_EPOCH_OFFSET_US;

        auto event_time = std::chrono::system_clock::time_point{
            std::chrono::microseconds{unix_us}
        };

        state->add(event_time, static_cast<uint64_t>(item));
    }

    PG_RETURN_POINTER(state);
}

Datum sliding_hll_final(PG_FUNCTION_ARGS)
{
    if (PG_ARGISNULL(0)) {
        PG_RETURN_INT64(0);
    }

    LFPM *state = reinterpret_cast<LFPM *>(PG_GETARG_POINTER(0));
    const auto [cardinality, err] = state->cardinality();

    PG_RETURN_INT64(static_cast<int64>(std::round(cardinality)));
}