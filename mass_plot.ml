open Plplot

let read_masses file = 
  let inp = open_in file in 
  let ms = ref [] in 
    (try
       while true do 
         Scanf.fscanf inp " %g " (fun m -> ms := m :: !ms)
       done
     with 
       | _ -> close_in inp);
    Array.of_list (List.rev !ms)

let bin_data data xmin xmax nbins = 
  let dx = (xmax -. xmin) /. (float_of_int nbins) in 
  let bins = Array.init nbins (fun i -> (float_of_int i) *. dx +. xmin) and
      counts = Array.make nbins 0 in 
  let accumulate x = 
    if x < xmin || x > xmax then 
      () 
    else if x > bins.(nbins - 1) then 
      counts.(nbins-1) <- counts.(nbins-1) + 1
    else
      let rec bin_loop ilow ihigh = 
        if ihigh - ilow <= 1 then 
          counts.(ilow) <- counts.(ilow) + 1
        else
          let imid = (ilow + ihigh) / 2 in 
          let xmid = bins.(imid) in 
            if x < xmid then 
              bin_loop ilow imid
            else
              bin_loop imid ihigh in 
        bin_loop 0 (nbins-1) in 
    for i = 0 to Array.length data - 1 do 
      accumulate data.(i)
    done;
    let ndata = Array.length data in 
      (bins, Array.map (fun ct -> (float_of_int ct) /. (float_of_int ndata) /. dx) counts)

let _ = 
  let plotmmin = 0.0 and 
      plotmmax = 20.0 and 
      nbins = 100 in
  plparseopts Sys.argv [PL_PARSE_FULL];
  let ms = read_masses "masses.dat" in 
  let (bins, heights) = bin_data ms plotmmin plotmmax nbins in
    plinit ();
    plenv plotmmin plotmmax 0.0 0.24 0 0;
    plbin bins heights [PL_BIN_NOEXPAND];
    pllab "M" "dN/dM" "";
    plend ()
  
    
