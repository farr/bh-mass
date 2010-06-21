open Plplot

let dists = 
  [|("exp-cutoff.mcmc.dist", "Exponential With Cutoff");
    ("gaussian.mcmc.dist", "Gaussian");
    ("power-law.mcmc.dist", "Power Law");
    ("two-gaussian.mcmc.dist", "Two Gaussians");
    ("histogram.mcmc.dist", "Histogram (1-5 Bins)");
    ("histogram-1bin.mcmc.dist", "Histogram (1 Bin)");
    ("histogram-2bin.mcmc.dist", "Histogram (2 Bins)");
    ("histogram-3bin.mcmc.dist", "Histogram (3 Bins)");
    ("histogram-4bin.mcmc.dist", "Histogram (4 Bins)");
    ("histogram-5bin.mcmc.dist", "Histogram (5 Bins)")|]

let read_dist file = 
  let inp = open_in file in 
  let dist_pts = ref [] in 
    (try 
       while true do 
         Scanf.fscanf inp " %g %g %g %g "
           (fun x y ymin ymax -> 
             dist_pts := [|x; y; ymin; ymax|] :: !dist_pts)
       done
     with 
      | End_of_file -> ());
    close_in inp;
    Array.of_list (List.rev !dist_pts)

let plot_dist pts title = 
  let xs = Array.map (fun pt -> pt.(0)) pts and 
      ys = Array.map (fun pt -> pt.(1)) pts and
      ymins = Array.map (fun pt -> pt.(2)) pts and 
      ymaxs = Array.map (fun pt -> pt.(3)) pts in 
    plenv 2.0 15.0 0.0 0.6 0 0;
    plerry xs ymins ymaxs;
    plline xs ys;
    pllab "M" "dN/dM" title

let _ = 
  plparseopts Sys.argv [PL_PARSE_FULL];
  plstar 2 5;
  Array.iter (fun (file, title) -> 
    let pts = read_dist file in 
      plot_dist pts title)
    dists;
  plend ()
