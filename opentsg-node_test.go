package main

// go test -bench=. -benchtime=40s
/*
func BenchmarkNRGBA64(b *testing.B) {
	// this section is to remove the stdout clogging up the bench output
	_, w, err := os.Pipe()
	if err != nil {
		log.Fatal(err)
	}
	// origStdout := os.Stdout
	os.Stdout = w
	opentsg, _ := tsg.FileImport("./ebu/loadergrid.json", "", true)
	// cont, framenumber, _ := core.FileImport("./ebu/loadergrid.json", "", true)
	// run the Fib function b.N times
	for n := 0; n < b.N; n++ {
		opentsg.Draw(false, "", "")
	}
}

func BenchmarkACES(b *testing.B) {
	// this section is to remove the stdout clogging up the bench output
	_, w, err := os.Pipe()
	if err != nil {
		log.Fatal(err)
	}
	// origStdout := os.Stdout
	os.Stdout = w
	opentsg, _ := tsg.FileImport("./ebu/loaderaces.json", "", true)
	// cont, framenumber, _ := core.FileImport("./ebu/loaderaces.json", "", true)
	// run the Fib function b.N times
	for n := 0; n < b.N; n++ {
		opentsg.Draw(false, "", "")
		// framedraw.Draw(cont, framenumber, false, "", "")
	}
}

/*
first run of 40s
BenchmarkNRGBA64-16           12        3749180936 ns/op
BenchmarkACES-16               7        5911287002 ns/op

run of 100s
BenchmarkNRGBA64-16           40        3104468548 ns/op
BenchmarkACES-16              19        5952576454 ns/op
*/
