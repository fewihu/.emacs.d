package linter

import (
	"strings"
)

type yamllintParser struct {
}

func (y *yamllintParser) apply(output, _ string) []string {
	// TODO conform to agreed pattern
	var infos []string
	parts := strings.Split(output, "\n")
	for _, part := range parts {
		if strings.Contains(part, "error") || strings.Contains(part, "warning") {
			infos = append(infos, strings.Join(strings.Fields(part), " "))
		}
	}
	return infos
}

type yamllintLinter struct {
	cmd []string
	p   parser
}

func NewYamllintLinter() Linter {
	return &yamllintLinter{
		cmd: []string{"yamllint", "--strict"},
		p:   &yamllintParser{},
	}
}

func (y *yamllintLinter) Exec(file string, c chan<- string) bool {
	return execLinter(y.cmd, file, y.p, c)
}
