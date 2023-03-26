# jpm-tasks-view (jptv)

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

With `jptv`, one can do:

```
$ jptv --tags
blue
green
red
yellow
```

```
$ jptv blue
task-a
task-c
```

```
$ jptv green
task-b
```

```
$ jptv --tasks
task-a
task-b
task-c
```

```
$ jptv
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

