#include "SlidingHyperLogLog.hpp"

#include <iostream>
#include <cassert>
#include <chrono>
#include <cmath>
#include <iomanip>

using namespace std::chrono_literals;

// [Тест 1] Проверка пустой структуры и работы LinearCounting
void test_empty_and_basic() 
{
    std::cout << "[Test 1] - " << std::flush;
    
    const auto t_end = std::chrono::system_clock::now();
    // 2^10 = 1024 бакетов, окно 1 секунда
    LFPM hll(10, t_end, 1s); 

    // В пустой структуре оценка должна быть ровно 0
    const auto [card1, err1] {hll.cardinality()};
    assert(card1 == 0);

    // Добавляем элементы СТРОГО внутри окна (на 100 мс раньше, чем t_end)
    auto t_valid = t_end - 100ms;
    
    hll.add(t_valid, 100ULL);
    hll.add(t_valid, 200ULL);
    hll.add(t_valid, 300ULL);

    const auto [card2, err2] {hll.cardinality()};
    // На таком маленьком количестве элементов работает Linear Counting
    assert(std::abs(card2 - 3.0) <= 3.0 * 3 * err2);
    assert(err2 <= 1.04 / std::sqrt(1ULL << 10));

    std::cout << "УСПЕШНО!" << std::endl;
}


// [Тест 2] Проверка жестких границ (элементы полностью вне диапазона)
void test_sliding_window_expiration() 
{
    std::cout << "[Test 2] - Границы окна - " << std::flush;

    const auto t_end = std::chrono::system_clock::now();
    // Окно всего 200 миллисекунд: диапазон [t_end - 200ms, t_end]
    LFPM hll(10, t_end, 200ms);
    
    // Пытаемся добавить элементы, которые "опоздали" (из будущего относительно t_end)
    auto t_future = t_end + 10ms;
    hll.add(t_future, 1ULL);
    hll.add(t_future, 2ULL);

    // Пытаемся добавить элементы, которые "устарели" (на 300 мс раньше t_end)
    auto t_too_old = t_end - 300ms;
    hll.add(t_too_old, 3ULL);
    hll.add(t_too_old, 4ULL);
    
    // Проверяем: так как все элементы были вне диапазона, кардинальность обязана остаться 0
    const auto [card, err] {hll.cardinality()};
    assert(card == 0);

    std::cout << "УСПЕШНО!" << std::endl;
}


// [Тест 3] Частичное попадание (одни элементы внутри окна, другие снаружи)
void test_partial_expiration() 
{
    std::cout << "[Test 3] - Частичное попадание - " << std::flush;

    const auto t_end = std::chrono::system_clock::now();
    // Окно 400 миллисекунд: диапазон [t_end - 400ms, t_end]
    LFPM hll(10, t_end, 400ms);
    
    // Группа 1: Слишком старая (на 450 мс раньше t_end). Должна отброситься.
    auto t_group1 = t_end - 450ms;
    hll.add(t_group1, 10ULL);
    hll.add(t_group1, 20ULL);

    // Группа 2: Валидная (на 200 мс раньше t_end). Должна записаться.
    auto t_group2 = t_end - 200ms;
    hll.add(t_group2, 30ULL);
    hll.add(t_group2, 40ULL);
    hll.add(t_group2, 50ULL);

    const auto [card, err] = hll.cardinality();
    
    // В структуре должны быть учтены ТОЛЬКО 3 элемента из Группы 2
    assert(std::abs(card - 3.0) <= 3.0 * 3 * err);

    std::cout << "УСПЕШНО!" << std::endl;
}


// [Тест 4] Точность на больших данных (Проверка математики HLL)
void test_hll_accuracy() 
{
    std::cout << "[Test 4] - " << std::flush;

    const auto t_end = std::chrono::system_clock::now();
    LFPM hll(11, t_end, 5s);
    
    // Элементы гарантированно внутри окна
    auto now = t_end - 1s;

    const size_t real_unique_count = 5000;
    for (size_t i = 0; i < real_unique_count; ++i) 
    {
        hll.add(now, i);
    }

    const auto [card1, err1] {hll.cardinality()};
    
    // Проверяем, что погрешность укладывается в рамки правила 3-х сигм (3 * err)
    double error = std::abs(card1 - static_cast<double>(real_unique_count));
    assert(error < real_unique_count * 3 * err1);
    
    std::cout << "УСПЕШНО!" << std::endl;
}

// [Тест 5] Нагрузочный тест (остался без изменений, он уже адаптирован)
void test_sliding_stream_high_load() 
{
    std::cout << "[Test 5] - " << std::flush;

    const auto t_end = std::chrono::system_clock::now();
    const auto window_duration = 500ms;
    
    LFPM hll(10, t_end, window_duration);

    auto t_past = t_end - 400ms; 
    const size_t past_bulk_size = 8000; 

    for (size_t i = 0; i < past_bulk_size; ++i) 
    {
        hll.add(t_past, i);
    }

    const auto [card_past, err_past] = hll.cardinality();
    assert(card_past > 3000); 
    assert(std::abs(card_past - static_cast<double>(past_bulk_size)) <= past_bulk_size * 3 * err_past);

    auto t_present = t_end - 50ms; 
    const size_t present_bulk_size = 6000;

    for (size_t i = 0; i < present_bulk_size; ++i) 
    {
        hll.add(t_present, i + 100000ULL); 
    }

    const size_t total_combined = past_bulk_size + present_bulk_size;
    const auto [card_combined, err_combined] = hll.cardinality();
    assert(std::abs(card_combined - static_cast<double>(total_combined)) <= total_combined * 3 * err_combined);

    auto t_outside_future = t_end + 10ms;
    hll.add(t_outside_future, 999999ULL);

    auto t_outside_past = t_end - 600ms;
    hll.add(t_outside_past, 888888ULL);

    const auto [card_after_outside, _] = hll.cardinality();
    assert(card_after_outside == card_combined);

    std::cout << "УСПЕШНО!" << std::endl;
}


int main() 
{
    std::cout << "=== ЗАПУСК ТЕСТОВ STATIC WINDOW HYPERLOGLOG ===" << std::endl;
    
    test_sliding_stream_high_load();

    // Проверка на flaky тесты (запуск по кругу)
    for (size_t i {0}; i < 20; ++i) {
        std::cout << "\n========== Итерация #" << i << " ==========\n";
        test_empty_and_basic();
        test_sliding_window_expiration();
        test_partial_expiration();
        test_hll_accuracy();
    }
    
    std::cout << "\n=========================================" << std::endl;
    std::cout << "ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!" << std::endl;
    
    return 0;
}
