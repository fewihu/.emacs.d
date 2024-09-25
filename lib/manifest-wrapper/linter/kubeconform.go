package linter

import (
	"encoding/json"
	"fmt"
	"manifest-wrapper/document"
	"os"
	"strconv"
	"strings"

	"gopkg.in/yaml.v3"
)

type kubeconformLinter struct {
	cmd []string
	p   parser
}

func NewKubeconformLinter() Linter {
	return &kubeconformLinter{
		cmd: []string{"kubeconform", "--strict", "--output", "json"},
		p:   &kubeconformParser{},
	}
}

func (k *kubeconformLinter) Exec(file string, c chan<- string) bool {
	return execLinter(k.cmd, file, k.p, c)
}

type kubeconformParser struct {
}

func (k *kubeconformParser) apply(output, file string) []string {
	doc := document.NewDocumentSupplier(file)
	var infos []string
	for _, finding := range decodeKubeconformOutput(output).Resources {
		node := doc.Get(finding.Kind, finding.Name)
		if node == nil {
			fmt.Println("Could not find", finding.Kind, finding.Name, "in file:", file)
			continue
		}

		for _, msg := range finding.Errors {
			info := handleKubeconformFinding(msg.Path, msg.Msg, *node)
			if info != nil {
				infos = append(infos, *info)
			}
		}
	}
	return infos
}

type resources struct {
	Resources []resource `json:"resources"`
}

type resource struct {
	Filename string  `json:"filename"`
	Kind     string  `json:"kind"`
	Name     string  `json:"name"`
	Version  string  `json:"version"`
	Status   string  `json:"status"`
	Msg      string  `json:"msg"`
	Errors   []error `json:"validationErrors"`
}

type error struct {
	Path string `json:"path"`
	Msg  string `json:"msg"`
}

func decodeKubeconformOutput(output string) resources {
	var findings resources
	err := json.Unmarshal([]byte(output), &findings)
	if err != nil {
		fmt.Println("could not unmarshal kubeconform output", err)
		os.Exit(1)
	}
	return findings
}

func handleKubeconformFinding(path, msg string, node yaml.Node) *string {
	target := iteratePaths(pathToKeyList(path), node)
	var info *string = nil
	if target != nil {
		//TODO conform to agreed pattern
		ret := fmt.Sprintf("%d:%d error %s", target.Line, target.Column, msg)
		info = &ret
	}
	return info
}

// iteratePaths tries to find a node with alias equal to the first
// element of paths, proceeds to search the next element of paths in
// the components of the matching node and so on, until the path is
// consumed. It does it by trying to interpret the elements of paths
// as an index (parseIndex) or as a sort of map key (parsePath) and
// chooses whichever works.
// iteratePaths returns the node matching the last element of paths if
// all paths got matched to an alias of a node or nil otherwise.
func iteratePaths(paths []string, node yaml.Node) *yaml.Node {
	n := &node
	for _, path := range paths {
		// if we only had either monad :(
		n1 := parsePath(path, *n)
		n2 := parseIndex(path, *n)
		if n1 != nil {
			n = n1
		} else if n2 != nil {
			n = n2
		} else {
			return nil
		}
	}
	return n
}

func parseIndex(index string, node yaml.Node) *yaml.Node {
	i, err := strconv.Atoi(index)
	if node.Kind == yaml.SequenceNode && err == nil {
		return node.Content[i]
	}
	return nil
}

func parsePath(path string, node yaml.Node) *yaml.Node {
	for i, child := range node.Content {
		if path == child.Value {
			return node.Content[i+1]
		}
	}
	return nil
}

func pathToKeyList(path string) []string {
	return strings.Split(path, "/")[1:]
}
