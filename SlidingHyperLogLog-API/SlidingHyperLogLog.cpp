#include "SlidingHyperLogLog.hpp"

#include <bit>

LFPM::LFPM(const size_t mDegree_, std::chrono::system_clock::time_point slidingWindow_)
: mDegree(mDegree_), slidingWindow(slidingWindow_) 
{
    lfpm.reserve(1 << mDegree_);
}

size_t LFPM::hashPower(uint64_t hash) const 
{
    return std::countl_zero(hash) + 1;
}

void LFPM::add(std::chrono::system_clock::time_point timestamp, uint64_t hash) 
{
    NodeLFPM node{timestamp, hashPower(hash)};

    
}

size_t LFPM::cardinality() const 
{

}