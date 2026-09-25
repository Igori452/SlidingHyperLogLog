#include "SlidingHyperLogLog.hpp"

#include <iostream>
#include <cassert>
#include <thread>
#include <chrono>

#include <cmath>
#include <iomanip>

using namespace std::chrono_literals;

// Тест 1: Базовая работоспособность и пустая структура
void test_empty_and_basic() 
{
    std::cout << "[Test 1] Инициализация и базовая вставка... " << std::flush;
    
    // 2^10 = 1024 бакетов, окно 1 секунда
    LFPM hll(10, 1s); 

    // В пустой структуре оценка должна быть близка к 0
    const auto [card1, err1] {hll.cardinality()};
    assert(card1 == 0);

    auto now = std::chrono::system_clock::now();
    
    // Добавляем 3 уникальных элемента
    hll.add(now, 100ULL);
    hll.add(now, 200ULL);
    hll.add(now, 300ULL);

    const auto [card2, err2] {hll.cardinality()};
    // На таком маленьком количестве элементов Linear Counting нет,
    // но оценка должна быть строго больше 0
    assert(card2 > 0 && card2 <= 10); 

    std::cout << "УСПЕШНО (Найдено элементов: " << card2 << ")" << std::endl;
}

/*
// Тест 2: Проверка скользящего окна (вытеснение по времени)
void test_sliding_window_expiration() 
{
    std::cout << "[Test 2] Проверка скользящего окна (тайм-аут)... " << std::flush;

    // Окно всего 200 миллисекунд
    LFPM hll(10, 200ms);
    
    auto t1 = std::chrono::system_clock::now();
    
    // Добавляем элементы в момент времени t1
    hll.add(t1, 1ULL);
    hll.add(t1, 2ULL);
    hll.add(t1, 3ULL);
    
    assert(hll.cardinality() > 0);

    // Ждем 300 мс — это больше, чем наше окно в 200 мс
    std::this_thread::sleep_for(300ms);

    // Теперь элементы должны считаться устаревшими
    size_t card_after_expire = hll.cardinality();
    assert(card_after_expire == 0);

    std::cout << "УСПЕШНО (После сдвига окна найдено: " << card_after_expire << ")" << std::endl;
}

// Тест 3: Частичное устаревание (старые уходят, новые остаются)
void test_partial_expiration() 
{
    std::cout << "[Test 3] Частичное вытеснение данных... " << std::flush;

    LFPM hll(10, 400ms);
    
    // Группа 1: добавляем сейчас
    auto now1 = std::chrono::system_clock::now();
    hll.add(now1, 10ULL);
    hll.add(now1, 20ULL);
    
    size_t initial_card = hll.cardinality();

    // Спим 250 мс
    std::this_thread::sleep_for(250ms);

    // Группа 2: добавляем новые элементы
    auto now2 = std::chrono::system_clock::now();
    hll.add(now2, 30ULL);
    hll.add(now2, 40ULL);
    hll.add(now2, 50ULL);

    // Спим еще 200 мс. 
    // Итог: с момента Группы 1 прошло 450мс (>400мс -> удалены), 
    // с момента Группы 2 прошло 200мс (<400мс -> активны).
    std::this_thread::sleep_for(200ms);

    size_t final_card = hll.cardinality();
    
    // Оценка должна уменьшиться, так как первая группа «выпала» из окна
    assert(final_card < initial_card + 3);
    assert(final_card > 0);

    std::cout << "УСПЕШНО" << std::endl;
}

// Тест 4: Точность на больших данных (Проверка математики HLL)
void test_hll_accuracy() 
{
    std::cout << "[Test 4] Проверка точности на 5000 уникальных элементах... " << std::flush;

    // 2^11 = 2048 бакетов. Ошибка ~ 1.04 / sqrt(2048) = 2.3%
    LFPM hll(11, 5s);
    auto now = std::chrono::system_clock::now();

    const size_t real_unique_count = 5000;
    for (size_t i = 0; i < real_unique_count; ++i) 
    {
        hll.add(now, i);
    }

    size_t estimated_card = hll.cardinality();
    
    // Считаем относительную погрешность
    double error = std::abs(static_cast<double>(estimated_card) - real_unique_count) / real_unique_count;

    // Для HLL нормальное отклонение в пределах 3-5 стандартных ошибок (возьмем с запасом 15%, 
    // так как у нас нет Linear Counting для коррекции крайних значений)
    assert(error < 0.15);

    std::cout << "УСПЕШНО (Оценка: " << estimated_card << ", Погрешность: " << (error * 100.0) << "%)" << std::endl;
}
*/
// ТОЧКА ВХОДА ДЛЯ ОБЪЕКТНОГО ФАЙЛА ТЕСТОВ
int main() 
{
    std::cout << "=== ЗАПУСК ТЕСТОВ SLIDING HYPERLOGLOG ===" << std::endl;
    
    test_empty_and_basic();
    //test_sliding_window_expiration();
    //test_partial_expiration();
    //test_hll_accuracy();

    std::cout << "=========================================" << std::endl;
    std::cout << "ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!" << std::endl;
    
    return 0;
}
