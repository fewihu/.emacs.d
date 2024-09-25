package linter

import (
	"os/exec"
)

type Linter interface {
	Exec(file string, c chan<- string) bool
}

type parser interface {
	apply(output, file string) []string
}

func execLinter(cmd []string, file string, p parser, c chan<- string) bool {
	cmd = append(cmd, file)
	stdout, err := exec.Command(cmd[0], cmd[1:]...).Output()

	for _, info := range p.apply(string(stdout), file) {
		c <- info
	}
	close(c)

	if err != nil {
		return false
	}
	return true
}
