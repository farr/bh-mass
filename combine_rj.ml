let filenames : string list ref = ref []

let read_file file = 
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
    Array.of_list (List.map (fun line -> Scanf.sscanf line "%d " (fun count -> float_of_int count)) lines)

let probs_and_stddev files = 
  let counts = Array.of_list (List.map read_file files) in 
  let mu = Stats.multi_mean counts and 
      sigma = Stats.multi_std counts in 
  let total = Array.fold_left (+.) 0.0 mu and 
      n = Array.length counts in 
  (Array.map (fun m -> m /. total) mu,
   Array.map (fun s -> s /. (total*.(sqrt (float_of_int n)))) sigma)    

let _ = 
  Arg.parse [] (fun s -> filenames := s :: !filenames) "combine_rj.{byte,native} FILE ...";
  filenames := List.rev !filenames;
  let (mu, sigma) = probs_and_stddev !filenames in
  let nmodels = Array.length mu in
  let names = [|"Power Law"; "Exp With Cutoff"; "Gaussian"; "Two Gaussians"; "Log Normal"; "Skew Gaussian";
              "Histogram 1"; "Histogram 2"; "Histogram 3"; "Histogram 4"; 
              "Histogram 5"|] in 
    for i = 0 to nmodels - 1 do 
      Printf.printf "%g %g %% %s\n" mu.(i) sigma.(i) names.(i)
    done
