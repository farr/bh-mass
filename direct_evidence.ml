open Printf

module Ev = Evidence.Make(struct
  type params = float array
  let to_coords (x : params) = x
end)

let have_input_file = ref false
let input_file = ref ""
let have_output_file = ref false
let output_file = ref ""
let nbstrap = ref 1000
let ngroup = ref 64

let options = 
  [("-i", Arg.String (fun s -> have_input_file := true; input_file := s),
    "input from the given file (default stdin)");
   ("-o", Arg.String (fun s -> have_output_file := true; output_file := s),
    "output to the given file (default stdout)");
   ("-nbstrap", Arg.Set_int nbstrap,
    sprintf "number of bootstrap samples for 10%%, 90%% values (default %d)" !nbstrap);
   ("-ngroup", Arg.Set_int ngroup,
    sprintf "number of points in single intgeration group (default %d)" !ngroup)]

let compare_float (x : float) y = Pervasives.compare x y

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "direct_evidence.{byte,native} OPTIONS ...";
  let inp = if !have_input_file then open_in !input_file else stdin in 
  let samples = Read_write.read (fun x -> x) inp in 
    if !have_input_file then close_in inp;
    let out = if !have_output_file then open_out !output_file else stdout in 
      fprintf out "%g\n" (Ev.evidence_direct ~n:(!ngroup) samples);
      if !have_output_file then close_out out
