(lang dune 3.13)

(using melange 0.1)

(name schedule_be)

(generate_opam_files true)

(source
 (github adrianparvino/schedule_be))

(authors "Adrian Parvin Ouano")

(maintainers "Adrian Parvin Ouano")

(license LICENSE)

(documentation https://github.com/adrianparvino/schedule_be)

(package
 (allow_empty)
 (name schedule_be)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
  ocaml
  (melange
   (>= 5.1))
  (dune
   (>= 3.13))
  cf_workers
  ppx_deriving
  odoc
  melange-webapi)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
