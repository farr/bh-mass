open Printf

type dist = 
  | None
  | Histogram
  | Gaussian
  | Power_law

let which_dist = ref None
let filename = ref ""
let gap_bdy = ref 5.0
let outfile = ref ""

let options = 
  [("-histogram", Arg.String (fun s -> which_dist := Histogram; filename := s),
    "use a histogram mcmc output in the given file");
   ("-gaussian", Arg.String (fun s -> which_dist := Gaussian; filename := s),
    "use a gaussian mcmc output in the given file");
   ("-power-law", Arg.String (fun s -> which_dist := Power_law; filename := s),
    "use a power-law mcmc output in the given file");
   ("-mgap", Arg.Set_float gap_bdy,
    sprintf "maximum mass of the gap region (default %g)" !gap_bdy);
   ("-o", Arg.Set_string outfile, "output filename")]

let hist_gap_overlap bins = 
  let n = Array.length bins in 
  let bvol = 1.0 /. (float_of_int (n-1)) in
  let rec loop i ol = 
    if i >= n - 1 then 
      1.0 
    else
      let low = bins.(i) and 
          high = bins.(i+1) in 
      if high <= !gap_bdy then 
        loop (i+1) (ol +. bvol)
      else if low > !gap_bdy then 
        ol
      else
        let frac = (!gap_bdy -. low)/.(high-.low) in 
          ol +. frac*.bvol in
    loop 0 0.0
        
let gauss_gap_overlap = function 
  | [|mu; sigma|] -> 
    0.5*.(1.0 +. (Gsl_sf.erf ((!gap_bdy -. mu) /. ((sqrt 2.0)*.sigma))))
  | _ -> raise (Invalid_argument "gauss_gap_overlap: bad state")

let power_law_gap_overlap = function 
  | [|mmin; mmax; alpha|] -> 
    if !gap_bdy < mmin then 
      0.0
    else if !gap_bdy > mmax then 
      1.0
    else
      let ap1 = alpha +. 1.0 in 
      let mminap1 = mmin**ap1 in
        ((!gap_bdy)**ap1 -. mminap1) /. (mmax**ap1 -. mminap1)
  | _ -> raise (Failure "power_law_gap_overlap: bad state")

let compare_float (x : float) y = Pervasives.compare x y

let _ = 
  Arg.parse options (fun _ -> ()) "gaptest.{byte,native} OPTIONS ...";
  let inp = open_in !filename in 
  let mcmcs = Read_write.read (fun x -> x) inp in 
    close_in inp;
    let overlaps = 
      match !which_dist with 
        | Histogram -> 
          Array.map (fun {Mcmc.value = x} -> hist_gap_overlap x) mcmcs
        | Gaussian -> 
          Array.map (fun {Mcmc.value = x} -> gauss_gap_overlap x) mcmcs
        | Power_law -> 
          Array.map (fun {Mcmc.value = x} -> power_law_gap_overlap x) mcmcs 
        | _ -> eprintf "You must specify some distribution via a command line argument.\n";
          exit 1 in
    let out = open_out !outfile in 
    let n = Array.length overlaps in 
      Array.iter (fun x -> fprintf out "%g\n" x) overlaps;
      close_out out;
      Array.fast_sort compare_float overlaps;
      eprintf "90%% of overlaps less than %g\n" (overlaps.((n*9)/10))
