#include "SlidingHyperLogLog.hpp"
#include <bit>
#include <cmath>

LFPM::LFPM(const size_t mDegree_, std::chrono::nanoseconds slidingWindow_)
: mDegree(mDegree_), 
  mBuckets(1ULL << mDegree_),
  alpha(mBuckets == 16 ? 0.673 : (mBuckets == 32 ? 0.697 : (mBuckets == 64 ? 0.709 : 0.7213 / (1.0 + 1.079 / mBuckets)))),
  slidingWindow(slidingWindow_),
  lfpm(1ULL << mDegree_)
{}

size_t LFPM::hashPower(uint64_t hash) const 
{
    uint64_t remainingHash = hash << mDegree;
    if (remainingHash == 0) return Hashes::hashDegree - mDegree + 1;
    return std::countl_zero(remainingHash) + 1;
}

std::tuple<double, double> LFPM::cardinality() const 
{
    const auto nowTime {std::chrono::system_clock::now()};
    
    std::chrono::system_clock::time_point tp {nowTime - slidingWindow};
        
    double sm {0.0};
    size_t emptyBuckets {0};

    for (const auto& reg : lfpm) 
    {
        size_t maxVal {0};
        bool emptyBucket {false};

        for (auto it {std::rbegin(reg)}; it != std::rend(reg); ++it) 
        {
            if (it->timestamp < tp)
            {
                break;
            }
         
            maxVal = std::max(maxVal, it->value);
            emptyBucket = true;
        }

        emptyBuckets += !emptyBucket;
        sm += 1.0 / (1ULL << maxVal);
    }

    double rawEstimate {alpha * mBuckets * mBuckets * (1.0 / sm)};
    double error {1.04 / std::sqrt(mBuckets)};

    if (emptyBuckets > 0 && rawEstimate <= 2.5 * mBuckets) 
    {
        // Linear Counting: m * ln(m / V)
        rawEstimate = static_cast<double>(mBuckets) * std::log(static_cast<double>(mBuckets) / emptyBuckets);
        
        if (rawEstimate > 0.0) 
        {
            double t = rawEstimate / mBuckets;
            error = std::sqrt(std::exp(t) - t - 1.0) / (t *  std::sqrt(static_cast<double>(mBuckets)));
        }
        else 
        {
            error = 0.0;
        }
    }

    return {static_cast<size_t>(rawEstimate), error};
}