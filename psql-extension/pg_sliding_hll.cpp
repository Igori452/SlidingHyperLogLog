#include "SlidingHyperLogLog.hpp"

extern "C" {
#include <postgres.h>
#include <fmgr.h>
#include <utils/builtins.h>
#include <utils/memutils.h>
#include <utils/timestamp.h> // Для работы с типом Interval

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(sliding_hll_accum);
PG_FUNCTION_INFO_V1(sliding_hll_final);
}

Datum sliding_hll_accum(PG_FUNCTION_ARGS)
{
    LFPM *state = nullptr;

    // Извлекаем конфигурационные параметры из аргументов SQL
    // Аргумент 0: internal state
    // Аргумент 1: сам элемент (bigint)
    // Аргумент 2: длительность окна (Interval)
    // Аргумент 3: точность/количество бакетов log2m (int32)

    if (PG_ARGISNULL(2) || PG_ARGISNULL(3)) {
        ereport(ERROR, (errmsg("Параметры окна и точности не могут быть NULL")));
    }

    Interval *interval = PG_GETARG_INTERVAL_P(2);
    int32 log2m = PG_GETARG_INT32(3);

    // Конвертируем Interval из Postgres в микросекунды для std::chrono
    // В Postgres Interval хранит микросекунды, дни и месяцы раздельно
    int64 total_microseconds = interval->time + 
                               (interval->day * USECS_PER_DAY) + 
                               (interval->month * DAYS_PER_MONTH * USECS_PER_DAY);
    
    auto window_chrono = std::chrono::microseconds(total_microseconds);

    // Инициализация структуры при первом вызове
    if (PG_ARGISNULL(0)) {
        MemoryContext oldcontext;
        MemoryContext aggcontext;

        if (fcinfo->context && IsA(fcinfo->context, AggState)) {
            aggcontext = AggCheckCallContext(fcinfo, &oldcontext);
        } else {
            aggcontext = TopMemoryContext;
            oldcontext = MemoryContextSwitchTo(aggcontext);
        }

        // Динамически создаем объект, используя переданные пользователем параметры!
        state = new (palloc(sizeof(LFPM))) LFPM(log2m, window_chrono);

        MemoryContextSwitchTo(oldcontext);
    } else {
        state = reinterpret_cast<LFPM *>(PG_GETARG_POINTER(0));
    }

    // Добавляем элемент, если он не NULL
    if (!PG_ARGISNULL(1)) {
        int64 item = PG_GETARG_INT64(1);
        auto now = std::chrono::system_clock::now();
        
        state->add(now, static_cast<uint64_t>(item));
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