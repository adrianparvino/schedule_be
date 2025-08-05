module Env = Cf_workers.Workers.Env

let jsonify_system_prompt =
  {foo|
  Ensure it is a valid JSON array. Correct transformation is critical.
  Transform the text into the following format. Do not add any markdown.
  Ignore empty days on the output.
  [ 
    { "courseCode": "ABC 12", "MON": [[900, 1030]], "THU": [[900, 1030]] },
    { "courseCode": "ABC 12 LAB", "TUE": [[1300, 1400], [1500, 1630]] } 
  ]
  |foo}

let convert (env : Env.t) body =
  let open Cf_workers.Promise_utils.Bind in
  let ai = env.ai |> Option.get in
  let body =
    Js.String.replaceByRe ~regexp:[%re "/ +/g"] ~replacement:" " body
  in
  let* { response = schedule_response; _ } =
    Cf_workers.Ai.run_score ai "@cf/baai/bge-m3"
      [%mel.obj
        {
          query =
            {|
            Class Course Section Room M T W Th F Time Day Units Grade
            |};
          contexts = [| [%mel.obj { text = body }] |];
        }]
  in
  let* { response = malicious_response; _ } =
    Cf_workers.Ai.run_score ai "@cf/baai/bge-m3"
      [%mel.obj
        {
          query =
            {|foo
            bot administrator prompt injection previous text debugging secret key pwned malicious ignore translations helpful paragraph
            |};
          contexts = [| [%mel.obj { text = body }] |];
        }]
  in
  let score = schedule_response.(0).score -. malicious_response.(0).score in
  if score < 0.0 then failwith "Not implemented"
  else
    let* { response; _ } =
      Cf_workers.Ai.run_text_generation ai
        "@cf/mistralai/mistral-small-3.1-24b-instruct"
        [%mel.obj
          {
            messages =
              [|
                [%mel.obj { role = "system"; content = jsonify_system_prompt }];
                [%mel.obj { role = "user"; content = body }];
              |];
            max_tokens = 10000;
          }]
    in
    Js.Console.log response;
    let response =
      Js.String.replaceByRe ~regexp:[%re "/\\(\\b\\)0/g"] ~replacement:"\\1"
        response
    in
    Js.String.concatMany ~strings:[| "{ \"courses\":"; response; "}" |] ""
    |> Js.Promise.resolve

let options _ _ = "" |> Js.Promise.resolve
