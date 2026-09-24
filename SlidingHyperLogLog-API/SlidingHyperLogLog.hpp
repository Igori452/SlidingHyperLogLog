#pragma once

#include <vector>
#include <chrono>

struct NodeLFPM 
{
    std::chrono::system_clock::time_point timestamp;
    size_t value;
};

class LFPM 
{
    private:
        const size_t mDegree;
        const std::chrono::system_clock::time_point slidingWindow;

        std::vector<std::vector<NodeLFPM>> lfpm;

        size_t hashPower(uint64_t hash) const;
    public:
        LFPM() = delete;
        LFPM(const size_t mDegree_, std::chrono::system_clock::time_point slidingWindow_);
        
        template <typename T>
        void add(std::chrono::system_clock::time_point timestamp, T val);
        void add (std::chrono::system_clock::time_point timestamp, uint64_t hash);

        size_t cardinality() const;
};

template <typename T>
void LFPM::add(std::chrono::system_clock::time_point timestamp, T val) 
{
    uint64_t hash {Hashes::quickBashHash(val) >> (Hashes::hashDegree - mDegree)};

    lfpm.add(timestamp, hash);
}

class Hashes 
{
    public:
        const size_t hashDegree {64}; 

        static inline uint64_t quickBashHash(uint64_t input);
};

uint64_t Hashes::quickBashHash(uint64_t input)
{
    uint64_t w0 = input;
    uint64_t w1 = 0x5555555555555555ULL; 
    uint64_t w2 = 0xAAAAAAAAAAAAAAAAULL;

    const int m1 = 8;
    const int n1 = 19;
    const int m2 = 29;
    const int n2 = 37;

    w1 ^= ((w0 >> m1) | (w0 << (64 - m1)));
    w2 ^= ((w1 >> n1) | (w1 << (64 - n1)));
    w0 ^= ((w2 >> m2) | (w2 << (64 - m2)));
    w1 ^= ((w0 >> n2) | (w0 << (64 - n2)));

    return w0 ^ w1 ^ w2;
}