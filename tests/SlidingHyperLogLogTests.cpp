#include "SlidingHyperLogLog.hpp"

#include <iostream>
#include <cassert>
#include <thread>
#include <chrono>

#include <cmath>
#include <iomanip>

using namespace std::chrono_literals;

// Проверка пустой структуры и работы LinearCounting
void test_empty_and_basic() 
{
    std::cout << "[Test 1] - " << std::flush;
    
    // 2^10 = 1024 бакетов, окно 1 секунда
    LFPM hll(10, 1s); 

    // В пустой структуре оценка должна быть 0
    const auto [card1, err1] {hll.cardinality()};
    assert(card1 == 0);

    auto now = std::chrono::system_clock::now();
    
    // Добавляем 3 уникальных элемента
    hll.add(now, 100ULL);
    hll.add(now, 200ULL);
    hll.add(now, 300ULL);

    const auto [card2, err2] {hll.cardinality()};
    // На таком маленьком количестве элементов работает Linear Counting
    // и ошибка должна быть меньше чем у Sliding HLL
    assert(std::abs(static_cast<double>(card2) - 3.0) <= 3.0 * 3 * err2);
    assert(static_cast<double>(err2) <= 1.04 / std::sqrt(1ULL << 10));

    std::cout << "УСПЕШНО!" << std::endl;
}


// Проверка скользящего окна (вытеснение по времени)
void test_sliding_window_expiration() 
{
    std::cout << "[Test 2] - " << std::flush;

    // Окно всего 200 миллисекунд
    LFPM hll(10, 200ms);
    
    auto t1 = std::chrono::system_clock::now();
    
    // Добавляем элементы в момент времени t1
    hll.add(t1, 1ULL);
    hll.add(t1, 2ULL);
    hll.add(t1, 3ULL);
    
    const auto [card1, err1] {hll.cardinality()};
    assert(std::abs(card1 - 3.0) <= 3.0 * 3 * err1);

    // Ждем 300 мс — это больше, чем наше окно в 200 мс
    std::this_thread::sleep_for(300ms);

    // Теперь элементы должны считаться устаревшими
    const auto [card2, err2] {hll.cardinality()};
    assert(card2 == 0);

    std::cout << "УСПЕШНО!" << std::endl;
}


// Частичное устаревание (старые уходят, новые остаются)
void test_partial_expiration() 
{
    std::cout << "[Test 3] - " << std::flush;

    LFPM hll(10, 400ms);
    
    // Группа 1: добавляем сейчас
    auto now1 = std::chrono::system_clock::now();
    hll.add(now1, 10ULL);
    hll.add(now1, 20ULL);

    // Спим 250 мс
    std::this_thread::sleep_for(250ms);

    const auto [card1, err1] {hll.cardinality()};

    // Группа 2: добавляем новые элементы
    auto now2 = std::chrono::system_clock::now();
    hll.add(now2, 30ULL);
    hll.add(now2, 40ULL);
    hll.add(now2, 50ULL);

    // Спим еще 200 мс. 
    // Итог: с момента Группы 1 прошло 450мс (>400мс -> удалены), 
    // с момента Группы 2 прошло 200мс (<400мс -> активны).
    std::this_thread::sleep_for(200ms);

    const auto [card2, err2] = hll.cardinality();
    
    // Оценка должна уменьшиться, так как первая группа «выпала» из окна
    assert(std::abs(static_cast<double>(card1) - 2.0) <= 2.0 * 3 * err1);
    assert(std::abs(static_cast<double>(card2) - 3.0) <= 3.0 * 3 * err2);

    std::cout << "УСПЕШНО!" << std::endl;
}


// Точность на больших данных (Проверка математики HLL)
void test_hll_accuracy() 
{
    std::cout << "[Test 4] - " << std::flush;

    // 2^11 = 2048 бакетов. Ошибка ~ 1.04 / sqrt(2048) = 2.3%
    LFPM hll(11, 5s);
    auto now = std::chrono::system_clock::now();

    const size_t real_unique_count = 5000;
    for (size_t i = 0; i < real_unique_count; ++i) 
    {
        hll.add(now, i);
    }

    const auto [card1, err1] {hll.cardinality()};
    
    // Считаем относительную погрешность
    double error = std::abs(static_cast<double>(card1) - real_unique_count);

    assert(error < real_unique_count * 3 * err1);
    std::cout << "УСПЕШНО!" << std::endl;
}

int main() 
{
    std::cout << "=== ЗАПУСК ТЕСТОВ SLIDING HYPERLOGLOG ===" << std::endl;
    
    // Проверка на flaky тесты
    for (size_t i {0}; i < 20; ++i) {
        std::cout << "\n========== #" << i << " ==========\n";
        test_empty_and_basic();
        test_sliding_window_expiration();
        test_partial_expiration();
        test_hll_accuracy();
    }

    std::cout << "=========================================" << std::endl;
    std::cout << "ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!" << std::endl;
    
    return 0;
}
