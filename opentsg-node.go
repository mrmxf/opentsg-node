package main

import (
	"flag"
	"fmt"
	"log/slog"
	"path/filepath"
	"time"

	gonanoid "github.com/matoous/go-nanoid"
	"github.com/mrmxf/opentsg-node/versionstr"

	errhandle "github.com/mrmxf/opentsg-modules/opentsg-core/errHandle"

	"github.com/mrmxf/opentsg-modules/opentsg-core/tsg"
	opentsgwidgets "github.com/mrmxf/opentsg-modules/opentsg-widgets"
)

// dummy data to be overriden by linker injection for production
var LDos = "?os"
var LDcpu = "?cpu"
var LDcommit = "0123456789|- dummy-||- data -||-----xxxx"
var LDdate = "noDate"
var LDsuffix = ""
var LDappname = "opentsg"

// or change this all into the core repo?
func main() {
	start := time.Now()
	err := versionstr.ParseLinkerData(LDos, LDcpu, LDcommit, LDdate, LDappname, LDsuffix)
	if err != nil {
		panic(err)
	}

	// bring in the input file
	configfile := flag.String("c", "", "config file location") // default values as nothing
	debug := flag.Bool("debug", false, "Debug mode on or off") // default values as false
	profile := flag.String("profile", "", "aws profile to be used")
	jid := flag.String("jobid", gonanoid.MustID(16), "the opentsg job id")
	outputuri := flag.String("output", "", "folder/uri prefix added to all files to be saved")
	outputLog := flag.String("log", "", "the output destination of the log")
	doVersion := flag.Bool("version", false, "return the version information and exit")
	doNote := flag.Bool("note", false, "report this version's deployment note")
	doShortVersion := flag.Bool("v", false, "return the short version information and exit")

	flag.Var(&myFlags, "key", "keys for accessing the intended web pages of content")

	// if the version istrue
	flag.Parse()
	if *doVersion {
		fmt.Printf(LDappname+" version %s\n", versionstr.Info.Long)
		return
	}
	if *doNote {
		fmt.Println(versionstr.Info.Note)
		return
	}
	if *doShortVersion {
		fmt.Println(versionstr.Info.Short)
		return
	}

	if *configfile == "" {
		panic("no input file provided, please use the --c flag")
	}

	commandInputs := *configfile

	// Import the file to generate open tpg
	otsg, configErr := tsg.BuildOpenTSG(commandInputs, *profile, *debug, &tsg.RunnerConfiguration{RunnerCount: 1, ProfilerEnabled: true}, myFlags...)

	logs := errhandle.LogInit(*outputLog, *outputuri)
	// return the config error or start the program
	if configErr != nil {
		// Show the version of this build
		logs.PrintErrorMessage("F_CONFIG_OPENTSG_", configErr, true) // always make true for config errors
		logs.LogFlush()
	} else {

		// run opentsg
		opentsgwidgets.AddBuiltinWidgets(otsg)
		tsg.AddBaseEncoders(otsg)
		jobLog := filepath.Join(*outputuri, "./_logs/")
		tsg.LogToFile(otsg, slog.HandlerOptions{Level: slog.LevelDebug}, jobLog, *jid)

		otsg.Run(*outputuri)
	}
	elapsed := time.Since(start)
	fmt.Printf("tsg took %s to run\n", elapsed)

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
