open Plplot

let xmin = -8.0
let xmax = 8.0
let nbin = 100

let data = 
  let inp = open_in "power-law.mcmc" in 
  let samples = Read_write.read (fun x -> x) inp in
    close_in inp;
    Array.map (fun {Mcmc.value = x} -> x.(2)) samples

let _ = 
  let (bins, cts) = Mass_plot.bin_data data xmin xmax nbin in
    plparseopts Sys.argv [PL_PARSE_FULL];
    plinit ();
    plfontld 1;
    plenv xmin xmax 0.0 (1.1*.(Array.fold_left max neg_infinity cts)) 0 0;
    plbin bins cts [PL_BIN_NOEXPAND];
    pllab "#ga" "dN/d#ga" "";
    plend ()
    
