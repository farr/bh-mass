open Plplot

let bounds = 
  [|("exp-cutoff.mcmc.bds", "Exponential With Cutoff");
    ("gaussian.mcmc.bds", "Gaussian");
    ("power-law.mcmc.bds", "Power Law");
    ("two-gaussian.mcmc.bds", "Two Gaussians");
    ("histogram.mcmc.bds", "Histogram (1-5 Bins)");
    ("histogram-1bin.mcmc.bds", "Histogram (1 Bin)");
    ("histogram-2bin.mcmc.bds", "Histogram (2 Bins)");
    ("histogram-3bin.mcmc.bds", "Histogram (3 Bins)");
    ("histogram-4bin.mcmc.bds", "Histogram (4 Bins)");
    ("histogram-5bin.mcmc.bds", "Histogram (5 Bins)")|]

let read_bounds file = 
  let inp = open_in file in 
  let bds = ref [] in 
    (try
       while true do 
         Scanf.fscanf inp " %g %g "
           (fun low high -> bds := [|low; high|] :: !bds)
       done
     with 
       | _ -> close_in inp);
    Array.of_list (List.rev !bds)

let plot_bounds bds title = 
  let lowbds = Array.map (fun bds -> bds.(0)) bds in 
  let minbd = max 0.0 (Array.fold_left min infinity lowbds) and 
      maxbd = min 10.0 (Array.fold_left max neg_infinity lowbds) in 
  let (boxes, counts) = Mass_plot.bin_data lowbds minbd maxbd 100 in
  let high = Array.fold_left max neg_infinity counts in 
    plenv 0.0 10.0 0.0 (1.1*.high) 0 0;
    plbin boxes counts [PL_BIN_NOEXPAND];
    pllab "M" "dN/dM" title
    

let _ = 
  plparseopts Sys.argv [PL_PARSE_FULL];
  plstar 2 5;
  Array.iter 
    (fun (file, title) -> 
      plot_bounds (read_bounds file) title)
    bounds;
  plend ()
