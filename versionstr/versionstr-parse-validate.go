//This simple package manages the version number and name.
//
// versionstr.Info struct is exported for use in an application
//
// The ParseLinkerJson() function initialises the Info struct

package versionstr

import (
	_ "embed"
	"errors"
	"fmt"

	"gopkg.in/yaml.v2"
)

// read the history and return the latest version string
func getEmbeddedHistoryData() error {
	path := "releases.yml"
	yamlBytes, err := vFs.ReadFile(path)
	if err != nil {
		e := fmt.Sprintf("Cannot read History source %s", path)
		return errors.New(e)
	}

	err = yaml.Unmarshal(yamlBytes, &Info.History)
	if err != nil {
		e := fmt.Sprintf("Cannot parse embedded history %v\n%v\n", path, err)
		return errors.New(e)
	}
	return nil
}

// read the history and return the latest version string
func cleanLinkerData(LDos string, LDcpu string, LDcommit string, LDdate string, LDappname string) error {
	if len(LDos) == 0 {
		return errors.New("ldflags build OS string is empty - what OS are you bulding for?")
	}

	if len(LDcpu) == 0 {
		return errors.New("ldflags build CPU string is empty - what CPU are you bulding for?")
	}

	if len(LDcommit) == 0 {
		return errors.New("ldflags build commit id string is empty - use git rev-list -1 HEAD")
	}

	if len(LDcommit) < 40 {
		return errors.New("ldflags build commit id string should be 40 chars - use git rev-list -1 HEAD")
	}

	if len(LDdate) == 0 {
		return errors.New("ldflags build date string is empty - use and ISO 8601 format")
	}

	if len(LDappname) == 0 {
		return errors.New("ldflags build appname string is empty - program cannot run")
	}

	Info.CPU = LDcpu
	Info.OS = LDos
	Info.Date = LDdate
	Info.CommitId = LDcommit

	return nil
}
