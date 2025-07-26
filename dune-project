(lang dune 3.13)

(using melange 0.1)

(name schedule_be)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (allow_empty)
 (name schedule_be)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
  ocaml
  (melange
   (>= 3.0.0))
  (dune
   (>= 3.13))
  hex
  ppx_jsobject_conv
  ppx_deriving
  odoc
  melange-webapi)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
