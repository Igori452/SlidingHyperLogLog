cmake_minimum_required(VERSION 3.15)

project(SlidingHLLForPSQL)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(SlidingHyperLogLog-API)

add_executable(${PROJECT_NAME} 
    tests/SlidingHyperLogLogTests.cpp)

target_link_libraries(${PROJECT_NAME} 
    PRIVATE SlidingHLL-API)