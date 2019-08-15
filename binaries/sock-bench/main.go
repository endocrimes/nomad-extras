package main

import (
	"flag"
	"fmt"
	"net"
	"time"
)

var (
	startPort int
	endPort   int
)

func init() {
	flag.IntVar(&startPort, "start", 14000, "port to start search")
	flag.IntVar(&endPort, "end", 14512, "port to end search")
	flag.Parse()
}

func bench(desc string, op func() error) error {
	start := time.Now()
	err := op()
	end := time.Now()
	diff := end.Sub(start)
	fmt.Printf("Operation: %s, duration: %s, success?: %v\n", desc, diff, err == nil)
	return err
}

func linearPortSearch(start, end int) int {
	freeCount := 0

	bench("overall", func() error {
		for port := start; port <= end; port++ {
			address := fmt.Sprintf("127.0.0.1:%d", port)
			err := bench(address, func() error {
				listener, err := net.Listen("tcp", address)
				if listener != nil {
					listener.Close()
				}
				return err
			})

			if err == nil {
				freeCount++
			}
		}
		return nil
	})

	return freeCount
}

func main() {
	freePorts := linearPortSearch(startPort, endPort)
	fmt.Printf("Found %d ports\n", freePorts)
}
