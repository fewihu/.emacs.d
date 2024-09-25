package document

import (
	"errors"
	"io"
	"os"

	"gopkg.in/yaml.v3"
)

type documentSupplierImpl struct {
	file      string
	documents *[]yaml.Node
}

type DocumentSupplier interface {
	Get(kind, name string) *yaml.Node
}

func NewDocumentSupplier(file string) DocumentSupplier {
	return &documentSupplierImpl{file: file, documents: nil}
}

func (d *documentSupplierImpl) Get(kind, name string) *yaml.Node {
	//cached supplier magic
	if d.documents == nil {
		docs := readDocuments(d.file)
		d.documents = &docs
	}

	//could be more parallel
	for _, doc := range *d.documents {
		if matchKindAndName(doc, kind, name) {
			return &doc
		}
	}
	return nil
}

func matchKindAndName(document yaml.Node, kind, name string) bool {
	metadata := findField(document, "metadata")
	kindField := findField(document, "kind")
	if metadata == nil || kindField == nil {
		return false
	}
	nameField := findField(*metadata, "name")
	if nameField == nil {
		return false
	}

	if kindField.Value == kind && nameField.Value == name {
		return true
	}
	return false
}

func findField(node yaml.Node, field string) *yaml.Node {
	for i, child := range node.Content {
		if child.Value == field {
			return node.Content[i+1]
		}
	}
	return nil
}

// readDocuments returns all yaml documents it can decode from `path`
// https://stackoverflow.com/a/67607524
func readDocuments(path string) []yaml.Node {
	reader, err := os.Open(path)
	if err != nil {
		panic(err)
	}
	dec := yaml.NewDecoder(reader)
	documents := make([]yaml.Node, 1)

	for i := 0; ; i++ {
		var node yaml.Node
		err := dec.Decode(&node)
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			panic(err)
		}
		documents = append(documents, *node.Content[0])
		//		fmt.Println("Document", node.Content[0].Content[0].Value)
	}
	return documents
}
