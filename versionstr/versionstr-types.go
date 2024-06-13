package versionstr

import (
	"embed"
	"time"
)

// When a release build is created, the linker injects variables:
// ID=$(git rev-list -1 HEAD)
// DT=$(date +%F)
// OS='windows'
// CPU='amd64'
// APP=myExecutableName

// build the executable like this:
// GOOS=$OS GOARCH=$CPU go build -ldflags "-X main.LDos=$OS -X main.LDcpu=$CPU  -X main.LDcommit=$ID -X main.LDdate=$DT -X main.LDappname=$APP"  -o tmp/exefile

//to use in your code:
// ```
//	package main
//
// // dummy data to be overriden by linker injection for production
// var LDos = "?os"
// var LDcpu = "?cpu"
// var LDcommit = "0123456789|- dummy-||- data -||-----xxxx"
// var LDdate = "noDate"
//  ...
//  versionStr.ParseLinkerData(LDos, LDcpu, LDcommit, LDdate, LDAppname)
//  config.InitConfig(versionStr.Info)
//  ...
//  fmt.Printf("version=%s on %S for %s", config.VER, config.OS, config.CPU)
// ```

// this struct is exported
type VersionInfo struct {
	CommitId string `json:"id"`
	Date     string `json:"date"`
	OS       string `json:"os"`
	CPU      string `json:"cpu"`
	Suffix   string `json:"semverSuffix"`
	Short    string
	Long     string
	Note     string
	History  []ReleaseHistory
}

// JSON & YAML field names are the same
type ReleaseHistory struct {
	Appname  string    `json:"appname"`
	Version  string    `json:"version"`
	Date     time.Time `json:"date"`
	CodeName string    `json:"codename"`
	Note     string    `json:"note"`
}

//go:embed *.yml
var vFs embed.FS

var Info VersionInfo
