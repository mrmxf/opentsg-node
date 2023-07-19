package main

import (
	"flag"
	"fmt"
	"opentpg/versionstr"
	"time"

	"gitlab.com/mmTristan/tpg-core/tpg"

	errhandle "gitlab.com/mmTristan/tpg-core/errHandle"
)

var UseLinkerOverrides string

// or change this all into the core repo?
func main() {
	start := time.Now()
	doOverride := len(UseLinkerOverrides) > 1

	//bring in the input file
	configfile := flag.String("c", "", "config file location")                  //default values as nothing
	debug := flag.Bool("debug", false, "Debug mode on or off for saving files") //default values as false
	profile := flag.String("profile", "", "aws profile to be used")
	outputmnt := flag.String("output", "", "extensions to all files to be saved")
	outputLog := flag.String("log", "", "the type of log to be used")
	doVersion := flag.Bool("version", false, "return the version information and exit")

	flag.Var(&myFlags, "key", "keys for accessing the intended web pages of content")

	// if the version istrue
	flag.Parse()
	if *doVersion {
		fmt.Printf("openTPG version %s\n", versionstr.Long(doOverride))
		return
	}

	if *configfile == "" {
		panic("no input file provided, please use the --c flag")
	}

	commandInputs := *configfile

	// Import the file to generate open tpg
	tpg, configErr := tpg.FileImport(commandInputs, *profile, *debug, myFlags...)

	logs := errhandle.LogInit(*outputLog, *outputmnt)
	// return the config error or start the program
	if configErr != nil {
		// Show the version of this build
		logs.PrintErrorMessage("F_CONFIG_OPENTPG_", configErr, true) // always make true for config errors
		logs.LogFlush()
	} else {
		// run opentpg
		tpg.Draw(*debug, *outputmnt, *outputLog)
	}
	elapsed := time.Since(start)
	fmt.Printf("tpg took %s to run\n", elapsed)

}

// Custom slice for flags of https
type flagStrings []string

func (i *flagStrings) String() string {
	return fmt.Sprintf("%v", *i)
}

func (i *flagStrings) Set(value string) error {
	*i = append(*i, value)
	return nil
}

var myFlags flagStrings
