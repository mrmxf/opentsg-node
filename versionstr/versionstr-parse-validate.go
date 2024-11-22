// This simple package manages the version number and name.
//
// versionstr.Info struct is exported for use in an application
//
// The ParseLinkerJson() function initialises the Info struct

package versionstr

import (
	_ "embed"
	"errors"
	"fmt"

	"gopkg.in/yaml.v3"
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
func cleanLinkerData(lDos string, lDcpu string, lDcommit string, lDdate string, lDappname string, lDsuffix string) error {
	if len(lDos) == 0 {
		return errors.New("ldflags build OS string is empty - what OS are you bulding for?")
	}

	if len(lDcpu) == 0 {
		return errors.New("ldflags build CPU string is empty - what CPU are you bulding for?")
	}

	if len(lDcommit) == 0 {
		return errors.New("ldflags build commit id string is empty - use git rev-list -1 HEAD")
	}

	if len(lDcommit) < 40 {
		return errors.New("ldflags build commit id string should be 40 chars - use git rev-list -1 HEAD")
	}

	if len(lDdate) == 0 {
		return errors.New("ldflags build date string is empty - use and ISO 8601 format")
	}

	if len(lDappname) == 0 {
		return errors.New("ldflags build appname string is empty - program cannot run")
	}

	Info.CPU = lDcpu
	Info.OS = lDos
	Info.Date = lDdate
	Info.CommitId = lDcommit
	// semver suffix is v1.2.3+4fe2 or v1.2.3-rc.4fe2
	Info.Suffix = "+" + Info.CommitId[:4]
	if len(lDsuffix) > 0 {
		Info.Suffix = "-" + lDsuffix + "." + Info.CommitId[:4]
	}
	return nil
}
