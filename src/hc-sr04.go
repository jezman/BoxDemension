package main

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/stianeikeland/go-rpio"
)

func checkRange(Trig, Echo, DefaultRange uint8) float64 {
	// Open and map memory to access gpio, check for errors
	if err := rpio.Open(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	// Unmap gpio memory when done
	defer rpio.Close()

	trig := rpio.Pin(Trig)
	echo := rpio.Pin(Echo)

	trig.Output()
	echo.Input()

	trig.Write(rpio.Low)
	time.Sleep(time.Duration(50) * time.Microsecond)

	trig.Write(rpio.High)
	time.Sleep(time.Duration(10) * time.Microsecond)
	trig.Write(rpio.Low)

	var now time.Time
	var dist float64

	for echo.Read() == rpio.Low {
		now = time.Now()
	}
	for echo.Read() == rpio.High {
		dist = float64(DefaultRange) - float64(time.Since(now).Seconds()*17150)
	}
	return dist
}

func results(w http.ResponseWriter, r *http.Request) {
	// X, Y, Z
	Trig := [3]uint8{18, 17, 23}
	Echo := [3]uint8{22, 27, 24}
	DefaultRange := [3]uint8{103, 104, 119}

	x := checkRange(Trig[0], Echo[0], DefaultRange[0])
	y := checkRange(Trig[1], Echo[1], DefaultRange[1])
	z := checkRange(Trig[2], Echo[2], DefaultRange[2])

	fmt.Fprintf(w, "%.2f\n%.2f\n%.f", x, y, z)
}

func main() {

	http.HandleFunc("/", results)
	http.ListenAndServe(":3000", nil)
}
