let split_mss mss = 
  let ms = Array.map fst mss and 
      sigmas = Array.map snd mss in 
    (ms,sigmas)

let call_with_input_file file f = 
  let inp = open_in file in 
    try
      let result = f inp in 
        close_in inp;
        result
    with 
      | x -> 
          close_in inp;
          raise x

let read_msigmas chan = 
  let mss = ref [] in 
    try
      while true do 
        let m = Scanf.fscanf chan " %g " (fun x -> x) and
            sigma = Scanf.fscanf chan " %g " (fun x -> x) in 
          mss := (m,sigma) :: !mss
      done;
      split_mss (Array.of_list (List.rev !mss))
    with 
      | End_of_file -> split_mss (Array.of_list (List.rev !mss))
