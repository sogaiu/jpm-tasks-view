(declare-project
  :name "nice-project"
  :description "A nice project in Janet")

(task "task-a" []
  :tags [:blue]
  (os/execute ["ls"] :p))

(task "task-b" []
  :tags [:green :yellow]
  (os/execute ["df"] :p))

(task "task-c" []
  :tags [:red :blue]
  (os/execute ["ps"] :p))
