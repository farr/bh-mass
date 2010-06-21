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

let options = 
  [("-i", Arg.String (fun s -> have_input_file := true; input_file := s),
    "input from the given file (default stdin)");
   ("-o", Arg.String (fun s -> have_output_file := true; output_file := s),
    "output to the given file (default stdout)");
   ("-nbstrap", Arg.Set_int nbstrap,
    sprintf "number of bootstrap samples for 10%%, 90%% values (default %d)" !nbstrap)]

let compare_float (x : float) y = Pervasives.compare x y

let _ = 
  Random.self_init ();
  Arg.parse options (fun _ -> ()) "direct_evidence.{byte,native} OPTIONS ...";
  let inp = if !have_input_file then open_in !input_file else stdin in 
  let samples = Read_write.read (fun x -> x) inp in 
  let bsamples = Array.copy samples in 
  let nsamp = Array.length bsamples in 
    if !have_input_file then close_in inp;
    let ev = Ev.evidence_direct samples in
    let evs = Array.make !nbstrap 0.0 in 
      for i = 0 to !nbstrap - 1 do 
        for i = 0 to nsamp - 1 do 
          bsamples.(i) <- samples.(Random.int nsamp)
        done;
        evs.(i) <- Ev.evidence_direct bsamples
      done;
      Array.fast_sort compare_float evs;
      let out = if !have_output_file then open_out !output_file else stdout in 
        fprintf out "%g %g %g\n"
          ev evs.(!nbstrap/10) evs.((!nbstrap*9)/10);
        if !have_output_file then close_out out
