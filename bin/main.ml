let default =
  let open Jsoo_hello.Workers.Make (Handler) in
  [%mel.obj { fetch = (fun x y z -> handle x y z) }]
