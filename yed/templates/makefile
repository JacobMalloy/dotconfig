CXX=        g++
CC=         gcc
CXXFLAGS=   -Wall -std=gnu++11
CCFLAGS=    -Wall
SHELL=      bash
OPTO=       -g -O0
#OPTO=       -O3 -march=native -mtune=native


all:main

main:main.cpp
	$(CXX) $(CXXFLAGS) $(OPTO) $^ -o $@

clean:
	rm -f *.o

test:     all
	echo "put gradescript here"

test-memory: all
	valgrind --leak-check=full --show-reachable=yes ./main
