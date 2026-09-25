#pragma once

#include <vector>
#include <tuple>

#include <chrono>
#include <algorithm>

struct NodeLFPM 
{
    std::chrono::system_clock::time_point timestamp;
    size_t value;
};

class Hashes 
{
    public:
        static constexpr size_t hashDegree {64}; 

        static inline uint64_t quickBashHash(uint64_t input)
        {
            /*
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
            */

            // Классический финальный миксер из MurmurHash3 (64-битный)
            uint64_t x = input;
            x ^= x >> 33;
            x *= 0xff51afd7ed558ccdULL;
            x ^= x >> 33;
            x *= 0xc4ceb9fe1a85ec53ULL;
            x ^= x >> 33;
            return x;
        }
};

class LFPM 
{
    private:
        const size_t mDegree;
        const size_t mBuckets;
        const double alpha;
        
        const std::chrono::nanoseconds slidingWindow; 

        std::vector<std::vector<NodeLFPM>> lfpm;

        size_t hashPower(uint64_t hash) const;
        double calculateAlpha() const;
    public:
        LFPM() = delete;
        LFPM(const size_t mDegree_, std::chrono::nanoseconds slidingWindow_);
        
        template <typename T>
        void add(std::chrono::system_clock::time_point timestamp, T val);

        std::tuple<double, double> cardinality() const;
};

template <typename T>
void LFPM::add(std::chrono::system_clock::time_point timestamp, T val) 
{
    uint64_t hashVal {Hashes::quickBashHash(static_cast<uint64_t>(val))};
    uint64_t hashKey {hashVal >> (Hashes::hashDegree - mDegree)};

    NodeLFPM node {timestamp, hashPower(hashVal)};

    std::erase_if(lfpm[hashKey], [&](const NodeLFPM& item) {
        return (item.timestamp + slidingWindow < node.timestamp) || (item.value < node.value);
    });

    lfpm[hashKey].push_back(node);
}
