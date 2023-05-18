(def usage
  ``
  Usage: jptv [options]
         jptv <tag>
  View jpm tasks by tag.

    --help    show this output
    --tags    show all tags
    --tasks   show all tasks

  With no arguments, shows all tags with all associated tasks.

  Invoke in a directory that contains a project.janet file.
  ``)

(comment

  (def sample-src
    ``
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
    ``)

  (def tweaked-src
    (string "[" sample-src "]"))

  (def pj
    (parse tweaked-src))

  pj
  # =>
  '[(declare-project
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
      (os/execute ["ps"] :p))]

  (def pj-tasks
    (filter |(and (tuple? $)
                  (= 'task (first $)))
            pj))

  pj-tasks
  # =>
  '@[(task "task-a" []
      :tags [:blue]
      (os/execute ["ls"] :p))

    (task "task-b" []
      :tags [:green :yellow]
      (os/execute ["df"] :p))

    (task "task-c" []
      :tags [:red :blue]
      (os/execute ["ps"] :p))]

  (def task-names-and-tags
    (->> pj-tasks
         (map |[(get $ 1)
                # XXX: look for :tags and take next thing
                #      is this good enough?
                (let [marker (get $ 3)
                      after (get $ 4)]
                  (when (= :tags marker)
                    after))])
         from-pairs))

  task-names-and-tags
  # =>
  @{"task-a" [:blue]
    "task-b" [:green :yellow]
    "task-c" [:red :blue]}

  )

(defn has-project-janet?
  []
  (os/stat "project.janet"))

(defn find-all-tags
  [task-names-and-tags]
  (->> (values task-names-and-tags)
               flatten
               distinct
               sort))

(defn print-tasks
  [task-names-and-tags tag]
  (def tag-kwd
    (when tag
      (keyword tag)))

  (each name (sort (keys task-names-and-tags))
    (def tags
      (get task-names-and-tags name))

    (when (or (nil? tag)
              (and tags
                   (find |(= tag-kwd $) tags)))
      (print name))))

# XXX: not used yet
(defn print-tasks-with-doc
  [task-names-and-tags tag]
  (def longest-name-length
    (->> (keys task-names-and-tags)
         (map length)
         splice
         max))

  (def min-spaces 3)

  (def tag-kwd
    (when tag
      (keyword tag)))

  (each name (sort (keys task-names-and-tags))
    (def tags
      (get task-names-and-tags name))

    (when (or (nil? tag)
              (and tags
                   (find |(= tag-kwd $) tags)))
      (def name-len
        (length name))
      # XXX
      (def doc-str "")
      (def spacer
        (string/repeat " "
                       (- (+ longest-name-length min-spaces)
                          name-len)))
      (printf "%s%s%s" name spacer doc-str))))

(defn main
  [& argv]

  # XXX: improve args handling
  (when (or (not (has-project-janet?))
            (when-let [arg (get argv 1)]
              (= "--help" arg)))
    (print usage)
    (os/exit 0))

  (def show-tags
    (when (> (length argv) 1)
      (= "--tags" (get argv 1))))

  (def show-tasks
    (when (> (length argv) 1)
      (= "--tasks" (get argv 1))))

  # XXX: only one tag at a time for the moment
  (def tag
    (when (> (length argv) 1)
      (let [cand (get argv 1)]
        (if (or (= "--tags" cand)
                (= "--tasks" cand))
          nil
          cand))))

  (def project-janet
    (slurp "project.janet"))

  (def tweaked-pj
    (string "[" project-janet "]"))

  (def pj
    (try
      (parse tweaked-pj)
      ([_]
        (eprint "Failed to parse project.janet")
        (os/exit 1))))

  (def pj-tasks
    (filter |(and (tuple? $)
                  (= 'task (first $)))
            pj))

  (def task-names-and-tags
    (->> pj-tasks
         (map |[(get $ 1)
                # XXX: look for :tags and take next thing
                #      is this good enough?
                (let [marker (get $ 3)
                      after (get $ 4)]
                  (when (= :tags marker)
                    after))])
         from-pairs))

  (cond
    show-tasks
    (each name (keys task-names-and-tags)
      (print name))
    #
    show-tags
    (each a-tag (find-all-tags task-names-and-tags)
      (print a-tag))
    #
    tag
    (print-tasks task-names-and-tags tag)
    #
    (each a-tag (find-all-tags task-names-and-tags)
      (print a-tag)
      (each task (keys task-names-and-tags)
        (when (find |(= a-tag $)
                    (get task-names-and-tags task))
          (print "  " task)))
      (print))))

