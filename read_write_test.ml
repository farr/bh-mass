let _ = 
  let samples = Read_write.read (fun x -> x) stdin in 
  let sum = ref 0.0 in 
    for i = 0 to Array.length samples - 1 do 
      let {Mcmc.like_prior = {Mcmc.log_likelihood = ll;
                              log_prior = lp}} = samples.(i) in 
      sum := !sum +. (exp (ll +. lp))
    done;
    Printf.printf "Average posterior = %g\n" (!sum /. (float_of_int (Array.length samples)))
