//This simple package manages the version number and name.
//
// versionstr.Info struct is exported for use in an application
//
// The ParseLinkerJson() function initialises the Info struct

package versionstr

import (
	_ "embed"
	"fmt"
)

// logic to valid the loading of the Info struct & linker data
func ParseLinkerData(LDos string, LDcpu string, LDcommit string, LDdate string, LDappname string) error {

	if err := getEmbeddedHistoryData(); err != nil {
		return err
	}

	if err := cleanLinkerData(LDos, LDcpu, LDcommit, LDdate, LDappname); err != nil {
		return err
	}

	Info.Short = Info.History[0].Version
	Info.Note = Info.History[0].Note
	Info.Long = fmt.Sprintf("%s-%s (%s:%s:%s:%s:%s)",
		Info.Short,
		Info.CommitId[36:],
		Info.History[0].CodeName,
		Info.History[0].Date.Format("2006-01-02"),
		Info.OS,
		Info.CPU,
		"\""+Info.History[0].Note+"\"")
	return nil
}
