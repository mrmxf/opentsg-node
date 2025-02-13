package main

import (
	"embed"
	//"flag"
	"fmt"
	"log/slog"
	"path/filepath"
	"time"

	gonanoid "github.com/matoous/go-nanoid"
	"github.com/mrmxf/opentsg-node/src/semver"

	"github.com/mrmxf/opentsg-modules/opentsg-core/tsg"
	opentsgwidgets "github.com/mrmxf/opentsg-modules/opentsg-widgets"

	flag "github.com/spf13/pflag"
)

//go:embed releases.yaml
var vFs embed.FS

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
	// err := versionstr.ParseLinkerData(LDos, LDcpu, LDcommit, LDdate, LDappname, LDsuffix)
	// if err != nil {
	// 	panic(err)
	// }

	// bring in the input file

	configfile := flag.StringP("config", "c", "", "the config file location") //flag.String("c", "", "config file location") // default values as nothing
	debug := flag.BoolP("debug", "d", false, "Debug mode on or off")          // default values as false
	profile := flag.StringP("profile", "p", "", "aws profile to be used")
	jid := flag.StringP("jobid", "j", gonanoid.MustID(16), "the opentsg job id")
	outputuri := flag.StringP("output", "o", "", "folder/uri prefix added to all files to be saved")
	doVersion := flag.BoolP("version", "v", false, "return the version information and exit")
	doNote := flag.BoolP("note", "n", false, "report this version's deployment note")
	doShortVersion := flag.BoolP("sversion", "s", false, "return the short version information and exit")
	keys := flag.StringArray("key", []string{}, "the API keys ofr openTSG to use to access secrets etc")

	// flag.Var(&myFlags, "key", "keys for accessing the intended web pages of content")

	// if the version istrue
	flag.Parse()
	if *doVersion {
		fmt.Printf(LDappname+" version %s\n", semver.Info.Long)
		return
	}
	if *doNote {
		fmt.Println(semver.Info.Note)
		return
	}
	if *doShortVersion {
		fmt.Println(semver.Info.Short)
		return
	}

	if *configfile == "" {
		panic("no input file provided, please use the --c flag")
	}

	commandInputs := *configfile
	// Import the file to generate open tpg
	otsg, configErr := tsg.BuildOpenTSG(commandInputs, *profile, *debug, &tsg.RunnerConfiguration{RunnerCount: 1, ProfilerEnabled: true}, *keys...)

	// return the config error or start the program
	if configErr != nil {
		// Show the version of this build
		panic("F_CONFIG_OPENTSG_" + configErr.Error()) // always make true for config errors

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

func init() {
	//initialise the linker data parsed version numbers
	semver.Initialise(vFs, "releases.yaml")
}
