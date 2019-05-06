package main

import (
	"flag"
	"fmt"
	"os"
	"os/signal"
)

var ignore bool

func init() {
	flag.BoolVar(&ignore, "ignore", false, "ignore signals")
}

func main() {
	flag.Parse()

	done := make(chan struct{}, 1)

	c := make(chan os.Signal, 1)
	signal.Notify(c)

	go func() {
		for {
			s := <-c
			fmt.Printf("caught signal: %d (%s)\n", s, s.String())
			if !ignore {
				done <- struct{}{}
			} else {
				fmt.Println("-ignore flag passed, ignoring signals")
			}
		}
	}()

	fmt.Println("Hello World!")

	fmt.Println("waiting for signal...")
	<-done
}
