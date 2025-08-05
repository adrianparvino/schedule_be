let default =
  let open Cf_workers.Workers.Make (struct
    let default_headers env =
      let headers = Cf_workers.Headers.empty () in
      if Cf_workers.Workers.Env.get env "DISABLE_CORS" = Some "true" then (
        headers |> Cf_workers.Headers.set "access-control-allow-origin" "*";
        headers
        |> Cf_workers.Headers.set "access-control-allow-credentials" "true";
        headers |> Cf_workers.Headers.set "access-control-allow-headers" "*";
        headers |> Cf_workers.Headers.set "access-control-allow-methods" "*");
      headers

    let respond ?headers env body =
      let headers =
        match headers with None -> default_headers env | Some header -> header
      in
      Cf_workers.Workers.Response.create ~headers body |> Js.Promise.resolve

    let handle req =
      let open Cf_workers.Promise_utils.Bind in
      match req with
      | Cf_workers.Workers.Request.Post { env; body; _ } ->
          let* body = body () in
          let* response = Handler.convert env body in
          respond env response
      | Cf_workers.Workers.Request.Options { env; _ } -> respond env ""
      | _ -> failwith "Not implemented"
  end) in
  [%mel.obj { fetch = (fun [@u] x y z -> handle x y z) }]
