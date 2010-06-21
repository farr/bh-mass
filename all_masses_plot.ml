open Plplot

let files = 
  [|("masses-a0620.dat", "A0620");
    ("masses-cyg-x1.dat", "Cygnus X-1");
    ("masses-gro-j0422.dat", "GRO J0422");
    ("masses-gro-j1655.dat", "GRO J1655");
    ("masses-grs-1009.dat", "GRS 1009");
    ("masses-grs-1915.dat", "GRS 1915");
    ("masses-gs-1354.dat", "GS 1354");
    ("masses-gs-2000.dat", "GS 2000");
    ("masses-gs-2023.dat", "GS 2023");
    ("masses-m33-x7.dat", "M33 X7");
    ("masses-nova-mus-1991.dat", "Nova Mus 1991");
    ("masses-nova-oph-77.dat", "Nova Mus Oph 77");
    ("masses-u4-1543.dat", "U4 1543");
    ("masses-v4641-sgr.dat", "V4641 Sgr");
    ("masses-xte-j1118.dat", "XTE J1118");
    ("masses-xte-j1550.dat", "XTE J1550");
    ("masses-xte-j1650.dat", "XTE J1650")|]

let read_ms file = 
  let inp = open_in file in 
  let ms = ref [] in 
    (try 
       while true do
         Scanf.fscanf inp " %g "
           (fun m -> ms := m :: !ms)
       done
     with 
       | _ -> close_in inp);
    Array.of_list (List.rev !ms)

let plot_masses ms title = 
  let mmin = Array.fold_left min infinity ms and 
      mmax = min 40.0 (Array.fold_left max neg_infinity ms) in
  let (bds, cts) = Mass_plot.bin_data ms mmin mmax 100 in 
  let  height = Array.fold_left max neg_infinity cts in 
    plenv mmin mmax 0.0 height 0 0;
    plbin bds cts [PL_BIN_NOEXPAND];
    pllab "M" "dN/dM" title

let _ = 
  plparseopts Sys.argv [PL_PARSE_FULL];
  plstar 4 5;
  Array.iter 
    (fun (file, title) -> 
      plot_masses (read_ms file) title)
    files;
  plend ()
    
