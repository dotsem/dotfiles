// Package task holds the in-memory task list.
package task

// Task is a single to-do item.
type Task struct {
	ID    int
	Title string
	Done  bool
}

// Service manages tasks in memory.
type Service struct {
	tasks  []Task
	nextID int
}

// NewService returns an empty Service.
func NewService() *Service {
	return &Service{nextID: 1}
}

// Add appends a task and returns it.
func (s *Service) Add(title string) Task {
	t := Task{ID: s.nextID, Title: title}
	s.nextID++
	s.tasks = append(s.tasks, t)
	return t
}

// List returns all tasks.
func (s *Service) List() []Task {
	return s.tasks
}
