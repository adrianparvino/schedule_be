module Response = struct
  type t = Js.Json.t

  let render x = Js.Json.stringify x
end

module Env = struct
  type t = { ai : Jsoo_hello.Ai.t }
end

let jsonify_system_prompt =
  {foo|
   You will be presented unstructured text containing a class schedule and you must return structured output.
   If it is a laboratory class, append it to the course code.
   Just output the raw JSON. Correct output is critical.
   Some classes may have appear multiple times. Output each entry as a separate object.
   Output it as a stream of one-liner JSON objects.

   A sample output is as follows:
   { "courseCode": "ABC-12", "MON": [[900, 1030]], "THU": [[900, 1030]] },
   { "courseCode": "ABC-12", "TUE": [[1300, 1400], [1500, 1630]] }
   |foo}

let head _ _ = failwith "Not implemented"
let get _ _ = failwith "Not implemented"

let post _ (env : Env.t) body =
  let open Jsoo_hello.Promise_utils.Bind in
  let ai = env.ai in
  let* { response; _ } =
    Jsoo_hello.Ai.run_text_generation ai
      "@cf/meta/llama-3.3-70b-instruct-fp8-fast"
      [%mel.obj
        {
          messages =
            [|
              [%mel.obj { role = "system"; content = jsonify_system_prompt }];
              [%mel.obj
                {
                  role = "user";
                  content =
                    Js.String.replaceByRe ~regexp:[%re "/ +/g"] ~replacement:" "
                      body;
                }];
            |];
          max_tokens = 10000;
        }]
  in
  let response =
    Js.String.concatMany ~strings:[| "{ \"courses\": ["; response; "]}" |] ""
    |> Js.Json.parseExn
  in
  Js.Promise.resolve response

let put _ _ _ = failwith "Not implemented"
let delete _ _ = failwith "Not implemented"
