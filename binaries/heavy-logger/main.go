package main

import (
	"flag"
	"fmt"
	"math/rand"
	"os"
	"os/signal"
)

const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func randString(n int) string {
	b := make([]byte, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}

func main() {
	flag.Parse()

	done := make(chan struct{}, 1)

	c := make(chan os.Signal, 1)
	signal.Notify(c)

	go func() {
		for {
			select {
			case s := <-c:
				fmt.Printf("caught signal: %d (%s)\n", s, s.String())
				done <- struct{}{}
			default:
				sLen := rand.Intn(50 * 1024)
				s := randString(sLen)
				fmt.Printf("random log (%d): %s\n", sLen, s)
			}
		}
	}()

	fmt.Println("waiting for signal...")
	<-done
}
