let default =
  let open Cf_workers.Workers.Make (struct
    (* let head headers env = Handler.head env headers
    let get headers env = Handler.get env headers
    let post headers env body = Handler.post headers env body
    let put headers env body = Handler.put headers env body
    let delete headers env = Handler.delete env headers
    let options headers env = Handler.options env headers *)

    let handle req =
      let open Cf_workers.Promise_utils.Bind in
      match req with
      | Cf_workers.Workers.Request.Post { headers; env; body; _ } ->
          let* body = body () in
          Handler.post headers env body
      | _ -> failwith "Not implemented"
  end) in
  [%mel.obj { fetch = (fun x y z -> handle x y z) }]
