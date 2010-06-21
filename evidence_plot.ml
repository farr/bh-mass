open Plplot

let dist_files = 
  [|"exp-cutoff.mcmc.ev";
    "gaussian.mcmc.ev";
    "power-law.mcmc.ev";
    "two-gaussian.mcmc.ev";
    "histogram.mcmc.ev";
    "histogram-1bin.mcmc.ev";
    "histogram-2bin.mcmc.ev";
    "histogram-3bin.mcmc.ev";
    "histogram-4bin.mcmc.ev";
    "histogram-5bin.mcmc.ev"|]

let read_evidences files = 
  let n = Array.length files in 
  let xs = Array.make n 0.0 and 
      ys = Array.make n 0.0 and 
      ymins = Array.make n 0.0 and
      ymaxs = Array.make n 0.0 and
      ysdirect = Array.make n 0.0 in
    for i = 0 to n - 1 do 
      xs.(i) <- float_of_int i;
      let inp = open_in files.(i) in 
        Scanf.fscanf inp " %g %g %g " 
          (fun y ymin ymax ->
            ys.(i) <- y; ymins.(i) <- ymin; ymaxs.(i) <- ymax);
        close_in inp;
        if files.(i) <> "histogram.mcmc.ev" then begin
          let inp = open_in (files.(i) ^ ".direct") in 
            Scanf.fscanf inp " %g " (fun evd -> ysdirect.(i) <- evd);
            close_in inp
        end else begin
          ysdirect.(i) <- 0.0/.0.0
        end
    done;
    (xs, ys, ysdirect, ymins, ymaxs)

let log10 x = 
  (log x) /. (log 10.0)

let plot_name index ymaxs name = 
  plptex (float_of_int index) (log10 (1.1*.ymaxs.(index))) 0.0 1.0 0.0 name

let plot_evidences xs ys ysdirect ymins ymaxs = 
  let xmin = (-1.0) and xmax = float_of_int ((Array.length xs)) and 
      ymax = Array.fold_left max neg_infinity ymaxs and 
      ymin = Array.fold_left min infinity ymins in
    plenv xmin xmax (log10 (ymin /. 3.0)) (log10 (10.0*.ymax)) 0 20;
    plerry xs (Array.map log10 ymins) (Array.map log10 ymaxs);
    Array.iteri (fun i y -> plpoin [|(float_of_int i)|] [|(log10 y)|] 2) ys;
    Array.iteri (fun i y -> plpoin [|(float_of_int i)|] [|(log10 y)|] 3) ysdirect;
    Array.iteri 
      (fun i name -> plot_name i ymaxs name)
      [|"Exp"; "Gaussian"; "Power Law"; "Two Gaussian";
        "Hist (1-5)"; "Hist (1)"; "Hist (2)"; "Hist (3)";
        "Hist (4)"; "Hist (5)"|]

let _ = 
  plparseopts Sys.argv [PL_PARSE_FULL];
  plinit ();
  let (xs,ys, ysdirect, ymins,ymaxs) = read_evidences dist_files in 
    plot_evidences xs ys ysdirect ymins ymaxs;
    pllab "" "p(d)" "";
    plend ()
