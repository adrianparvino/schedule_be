module type Handler = sig
  module Response : sig
    type t

    val render : t -> Js.String.t
  end

  module Env : sig
    type t
  end

  val head : Headers.t -> Env.t -> Response.t Js.Promise.t
  val get : Headers.t -> Env.t -> Response.t Js.Promise.t
  val post : Headers.t -> Env.t -> Js.String.t -> Response.t Js.Promise.t
  val put : Headers.t -> Env.t -> Js.String.t -> Response.t Js.Promise.t
  val delete : Headers.t -> Env.t -> Response.t Js.Promise.t
end

module Response = struct
  type t
  type options = { headers : Headers.t } [@@warning "-69"]

  external make : 'a -> options -> t = "Response" [@@mel.new]

  let create response =
    let headers = Headers.empty () in
    headers |> Headers.set "content-type" "application/json";
    make response { headers }
end

module Workers_request = struct
  type t = { _method : String.t; [@mel.as "method"] headers : Headers.t }

  external text : unit -> String.t Js.Promise.t = "text" [@@mel.send.pipe: t]
  external json : unit -> 'a Js.t Js.Promise.t = "json" [@@mel.send.pipe: t]
end

module Make (Handler : Handler) = struct
  let handle request env () =
    let open Workers_request in
    let open Promise_utils.Bind in
    let headers = request.headers in
    let+ r =
      let open Promise_utils.Bind in
      match request._method with
      | "HEAD" -> Handler.head headers env
      | "GET" -> Handler.get headers env
      | "POST" ->
          let* body = request |> Workers_request.text () in
          let _ = Js.Console.log body in
          Handler.post headers env body
      | "PUT" ->
          let* body = request |> Workers_request.text () in
          Handler.put headers env body
      | "DELETE" -> Handler.delete headers env
      | _ -> failwith "method not supported"
    in

    r |> Handler.Response.render |> Response.create
end
