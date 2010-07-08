open Printf

let nbin = ref 5
let nhist = ref 10000

let mmin = 0.0
let mmax = 40.0

let options = 
  [("-nbin", Arg.Set_int nbin, 
    sprintf "number of bins to generate (default %d)" !nbin);
   ("-nhist", Arg.Set_int nhist,
    sprintf "number of histograms to generate (default %d)" !nhist)]

let print_array (x : float array) = 
  let n = Array.length x in 
    for i = 0 to n - 2 do
      printf "%g " x.(i)
    done;
    printf "%g 0.0 0.0\n" x.(n-1) (* Last two zeros are for MCMC-style output. *)

let compare_float (a : float) b = 
  Pervasives.compare a b

let random_hist arr = 
  for i = 0 to Array.length arr - 1 do 
    arr.(i) <- mmin +. (mmax-.mmin)*.(Random.float 1.0)
  done;
  Array.fast_sort compare_float arr

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "random_histogram.{byte,native} OPTIONS ...";
  let hist = Array.make (!nbin + 1) 0.0 in 
    for i = 0 to !nhist - 1 do 
      random_hist hist;
      print_array hist
    done
