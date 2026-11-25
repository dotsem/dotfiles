package main

import (
	"fmt"

	"example.com/tasks/internal/task"
)

func main() {
	svc := task.NewService()
	svc.Add("write spec")
	fmt.Println(svc.List())
}
