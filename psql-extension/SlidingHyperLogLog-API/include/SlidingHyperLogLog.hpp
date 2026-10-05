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
