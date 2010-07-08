open Printf

let nsamp = ref 1000
let outfile = ref "masses.dat"
let high_m = ref false

let options = 
  [("-nsamp", Arg.Set_int nsamp,
    sprintf "number of samples of each objects' mass PDF (default %d)" !nsamp);
   ("-seed", Arg.Int (fun s -> Random.init s), "initialize RNG with given seed");
   ("-o", Arg.Set_string outfile, 
    sprintf "output to given file name (default %s)" !outfile);
   ("-high-mass", Arg.Set high_m,
    "include high-mass objects in sample")]

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "mass_hist.{byte,native} OPTIONS ...";
  let samples = Masses.generate_samples !high_m !nsamp in 
  let out = open_out !outfile in 
    List.iter 
      (fun samps -> Array.iter (fun m -> fprintf out "%g\n" m) samps)
      samples;
    close_out out;
    List.iter2
      (fun name samps -> 
        let fname = "masses-" ^ name ^ ".dat" in 
        let out = open_out fname in 
          Array.iter (fun m -> fprintf out "%g\n" m) samps;
          close_out out)
      Masses.names samples
          
