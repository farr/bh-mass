open Printf

module Ev = Evidence.Make(struct
  type params = float array
  let to_coords (x : float array) = x
end)

let outfile = ref ""
let to_file = ref false
let infile = ref ""
let from_file = ref false
let nsamp = ref 10000

let options = 
  [("-i", Arg.String (fun s -> from_file := true; infile := s),
    "input from file (default stdin)");
   ("-o", Arg.String (fun s -> to_file := true; outfile := s),
    "output to file (default stdout)");
   ("-n", Arg.Set_int nsamp, 
    sprintf "the number of bootstrap samples for error output (default %d)" !nsamp)]

let _ = 
  Random.self_init ();
  Arg.parse options (fun _ -> ()) "harmonic_evidence.{byte,native} OPTIONS ...";
  let inp = if !from_file then open_in !infile else stdin in 
  let samples = Read_write.read (fun x -> x) inp in 
  let n = Array.length samples in 
    if !from_file then close_in inp;
    let ev = Ev.evidence_harmonic_mean samples in 
    let bsamples = Array.copy samples in 
    let evs = 
      Array.init !nsamp 
        (fun _ -> 
          for i = 0 to n - 1 do 
            bsamples.(i) <- samples.(Random.int n)
          done;
            Ev.evidence_harmonic_mean bsamples) in 
      Array.fast_sort (fun (x : float) y -> Pervasives.compare x y) evs;
      let ind910 = int_of_float ((float_of_int !nsamp) *. 0.9) and
          ind10 = int_of_float ((float_of_int !nsamp) *. 0.1) in
      let output = if !to_file then open_out !outfile else stdout in 
      let deltap = (evs.(ind910) -. ev) and 
          deltam = (ev -. (evs.(ind10))) in
        fprintf output "%g %g %g\n" ev deltap deltam;
        if !to_file then close_out output
      
