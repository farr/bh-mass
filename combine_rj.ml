let filenames : string list ref = ref []

let raw_read_filename file = 
  let inp = open_in file in 
  let lines = ref [] in 
  let lines = 
    try 
      while true do 
        lines := (input_line inp) :: !lines
      done;
      List.rev !lines
    with 
      | End_of_file -> List.rev !lines in 
    close_in inp;
    List.map (fun line -> Scanf.sscanf line "%d " (fun count -> count)) lines

let normalize_counts cts = 
  let total = List.fold_left ( + ) 0 cts in 
    List.map (fun ct -> (float_of_int ct) /. (float_of_int total)) cts

let read_file file = 
  normalize_counts (raw_read_filename file)

let compare_dim (dim : int) (a : float array) (b : float array) = 
  Pervasives.compare a.(dim) b.(dim)

let round f = 
  if f >= 0.0 then 
    int_of_float (f +. 0.5)
  else
    int_of_float (f -. 0.5)

let med_5_95 ?(lowf = 0.05) ?(highf = 0.95) dim probs = 
  let nrj = Array.length probs in 
  let comp a b = compare_dim dim a b in
  let medi = round (0.5*.(float_of_int nrj)) and 
      lowi = round (lowf*.(float_of_int nrj)) and 
      highi = round (highf*.(float_of_int nrj)) in
    if highi >= nrj then 
      raise (Failure (Printf.sprintf "combine_rj: you need more samples to explore the %g-th percentile" highf));
    let med = (Stats.find_nthf ~copy:false comp medi probs).(dim) and 
        low = (Stats.find_nthf ~copy:false comp lowi probs).(dim) and 
        high = (Stats.find_nthf ~copy:false comp highi probs).(dim) in 
      (med, low, high)

let _ = 
  Arg.parse [] (fun s -> filenames := s :: !filenames) "combine_rj.{byte,native} FILE ...";
  filenames := List.rev !filenames;
  let probs = Array.of_list (List.map (fun f -> Array.of_list (read_file f)) !filenames) in 
  let nmodels = Array.length probs.(0) in 
    for i = 0 to nmodels - 1 do 
      let (med,low,high) = med_5_95 i probs in 
        Printf.printf "%g %g %g\n" med low high
    done
