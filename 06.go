package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func main() {
	bytes, e := ioutil.ReadFile("06.txt")
	if e != nil {
		panic(e)
	}

	strArr := strings.Split(string(bytes), "\t")
	banks := make([]int, len(strArr))

	for i, val := range strArr {
		banks[i], e = strconv.Atoi(strings.Trim(val, "\n"))
		if e != nil {
			panic(e)
		}
	}

	run(banks)
}

func indexOfMax(banks []int) int {
	maxIndex := 0
	for i, val := range banks {
		if val > banks[maxIndex] {
			maxIndex = i
		}
	}
	return maxIndex
}

func run(banks []int) {
	memo := make(map[string]bool) // lol go doesnt have sets
	steps := 0
	for {
		key := keyFor(banks)
		_, found := memo[key]
		if found {
			fmt.Println("Found a repeat on step ", steps)
		}
		fmt.Println(banks)
		rebalance(banks)
		memo[key] = true
		steps += 1
	}
}

// Could be done in one pass
func rebalance(banks []int) {
	maxIndex := indexOfMax(banks)
	maxVal := banks[maxIndex]
	banks[maxIndex] = 0
	cur := 0
	length := len(banks)

	for i := 1; i <= maxVal; i++ {
		cur = (maxIndex + i) % length
		banks[cur] += 1
	}
}

func keyFor(banks []int) string {
	buf := new(bytes.Buffer)
	for _, v := range banks {
		buf.WriteString(strconv.Itoa(v))
		buf.WriteString("_")
	}
	return buf.String()
}
