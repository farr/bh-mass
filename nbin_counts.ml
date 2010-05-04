let bin_file = ref "binned.dat"

let opts = 
  [("-bfile", Arg.Set_string bin_file,
    Printf.sprintf "filename for binned MCMC output (default %s)" !bin_file)]

let _ = 
  Arg.parse opts (fun _ -> ()) "nbin_counts.{byte,native} OPTIONS ...";
  let inp = open_in !bin_file in 
  let samples = Read_write.read (fun pt -> pt) inp in 
    close_in inp;
  let counts = Hashtbl.create 10 in 
    Array.iter 
      (fun {Mcmc.value = v} -> 
         let nbins = Array.length v - 1 in 
           if Hashtbl.mem counts nbins then 
             Hashtbl.replace counts nbins (1 + Hashtbl.find counts nbins)
           else
             Hashtbl.add counts nbins 1)
      samples;
    Printf.printf "nbins counts\n";
    let nbin_count = 
      Hashtbl.fold
        (fun nbin count ncs -> (nbin, count) :: ncs)
        counts
        [] in
      List.iter 
        (fun (nbin, ct) -> Printf.printf "%d %d\n" nbin ct)
        (List.fast_sort (fun (nbin1,_) (nbin2,_) -> Pervasives.compare nbin1 nbin2) nbin_count)
