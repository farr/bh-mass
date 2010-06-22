let _ = 
  let inp = open_in "power-law.mcmc" in 
  let samples = Read_write.read (fun x -> x) inp in 
    close_in inp;
    let out = open_out "power-law.mcmc.tmp" in 
      for i = 0 to Array.length samples - 1 do 
        if i mod 3 <> 0 then 
          Read_write.write_sample (fun x -> x) out samples.(i)
      done;
      close_out out
