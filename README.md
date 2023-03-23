# jpm-tasks-view (jtv)

Suppose the content of a `project.janet` is:

```janet
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
```

With `jtv`, one can do:

```
$ jtv --tags
blue
green
red
yellow
```

```
$ jtv blue
task-a
task-c
```

```
$ jtv green
task-b
```

```
$ jtv --tasks
task-a
task-b
task-c
```

```
$ jtv
blue
  task-c
  task-a

green
  task-b

red
  task-c

yellow
  task-b
```

