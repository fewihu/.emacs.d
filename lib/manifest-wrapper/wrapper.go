package main

import (
	"flag"
	"fmt"
	"manifest-wrapper/linter"
)

// TODO sanity check if yamllint, kubeconform and manifest are actually there

// kubeconform --strict (in case ignore network errors)
// yamllint --strict
// check file ending (yaml/yml)
func main() {
	var manifest string
	flag.StringVar(&manifest,
		"file",
		"/dev/null",
		"path to the manifest file")
	flag.Parse()

	fmt.Println("file: " + manifest)

	yamllintFindings := make(chan string)
	kubeconformFindings := make(chan string)

	yamllint := linter.NewYamllintLinter()

	kubeconform := linter.NewKubeconformLinter()

	go yamllint.Exec(manifest, yamllintFindings)
	go kubeconform.Exec(manifest, kubeconformFindings)
	// if yamllint.Exec(manifest, yamllintFindings) {
	// 	go kubeconform.Exec(manifest, kubeconformFindings)
	// }
	printFindings(yamllintFindings)
	printFindings(kubeconformFindings)
}

func printFindings(c <-chan string) {
	ok := true
	var finding string
	for {
		finding, ok = <-c
		if !ok {
			break
		}
		fmt.Println(finding)
	}
}
