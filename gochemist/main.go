package main

func main() {

}

type ListString []string

func (str ListString) Size() int {
	return len(str)
}

func (str ListString) Last() string {
	return str[len(str)-1]
}

func (str ListString) First() string {
	return str[0]
}
