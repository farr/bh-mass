open Printf

let nbinmax = ref 5
let fixedbin = ref false
let nbin = ref 1
let mmin = ref 0.0
let mmax = ref 40.0
let nmsamp = ref 1000
let outfile = ref "histogram.mcmc"
let nmcmc = ref 30000
let nburnin = ref 10000
let nskip = ref 100
let overwrite = ref false
let high_m = ref false

let options = 
  [("-nbinmax", Arg.Set_int nbinmax,
    sprintf "maximum number of bins to allow (default %d)" !nbinmax);
   ("-fixedbin", Arg.Set fixedbin,
    sprintf "fix the number of bins to the value of the nbin argument");
   ("-nbin", Arg.Set_int nbin,
    sprintf "number of bins to use when in fixedbin mode (default %d)" !nbin);
   ("-mmin", Arg.Set_float mmin,
    sprintf "minimum BH mass (default %g)" !mmin);
   ("-mmax", Arg.Set_float mmax,
    sprintf "maximum BH mass (default %g)" !mmax);
   ("-seed", Arg.Int (fun s -> Random.init s),
    "seed the RNG");
   ("-nmsamp", Arg.Set_int nmsamp,
    sprintf "number of samples to use from each system's mass distribution (default %d)" !nmsamp);
   ("-o", Arg.Set_string outfile,
    sprintf "output file name (default %s)" !outfile);
   ("-nmcmc", Arg.Set_int nmcmc,
    sprintf "number of MCMC samples to record (default %d)" !nmcmc);
   ("-nskip", Arg.Set_int nskip,
    sprintf "number of samples to skip between recording (default %d)" !nskip);
   ("-nburnin", Arg.Set_int nburnin,
    sprintf "number of initial 'burn in' samples to discard (default %d)" !nburnin);
   ("-overwrite", Arg.Set overwrite,
    "overwrite the output file instead of appending to it");
   ("-high-mass", Arg.Set high_m,
    "use high-mass objects in sample")]

let compare_float (x : float) y = Pervasives.compare x y

let log_likelihood msamples = 
  let msamples = 
    List.map 
      (fun msamp -> 
        let msamp = Array.copy msamp in 
          Array.fast_sort compare_float msamp;
          msamp)
      msamples in 
    fun bins -> 
      List.fold_left
        (fun ll msamp -> 
          let nm = Array.length msamp and 
              nb = Array.length bins in
          let rec overlap_loop im ib ol = 
            if im >= nm then 
              ol /. (float_of_int nm)
            else if ib >= nb - 1 then 
              ol /. (float_of_int nm)
            else
              let m = msamp.(im) and 
                  low = bins.(ib) and 
                  high = bins.(ib+1) in
                if m < low then 
                  overlap_loop (im+1) ib ol
                else if m >= high then 
                  overlap_loop im (ib+1) ol
                else
                  overlap_loop (im+1) ib (ol +. 1.0 /. ((float_of_int (nb-1))*.(high-.low))) in 
          let overlap = overlap_loop 0 0 0.0 in 
            ll +. (log overlap))
        0.0
        msamples

let log_factorial n = 
  let sum = ref 0.0 in 
    for i = 2 to n do 
      sum := !sum +. (log (float_of_int i))
    done;
    !sum

let log_prior bins = 
  let log_bin_factor = if !fixedbin then 0.0 else ~-.(log (float_of_int !nbinmax)) in
  let n = Array.length bins in 
    (log_factorial n) +. log_bin_factor -. (float_of_int n)*.(log (!mmax -. !mmin))

let decrease_bins bins = 
  let n = Array.length bins in 
    if n <= 2 then 
      bins
    else begin
      let iomit = Random.int n in 
      let new_bins = Array.make (n-1) 0.0 in 
        Array.blit bins 0 new_bins 0 iomit;
        Array.blit bins (iomit+1) new_bins iomit (n-1-iomit);
        new_bins
    end

let log_decrease_bins_jp x y = 
  let n = Array.length x in 
    if n <= 2 && x == y then 
      0.0 
    else if Array.length y = n - 1 then 
      ~-.(log (float_of_int n))
    else
      neg_infinity

let increase_bins bins = 
  let n = Array.length bins in 
    if (n-1) >= !nbinmax then 
      bins
    else begin
      let new_bins = Array.make (n+1) 0.0 in 
        Array.blit bins 0 new_bins 0 n;
        new_bins.(n) <- !mmin +. (Random.float (!mmax -. !mmin));
        Array.fast_sort compare_float new_bins;
        new_bins
    end

let log_increase_bins_jp x y = 
  let n = Array.length x in 
    if (n-1) >= !nbinmax && x == y then 
      0.0
    else if Array.length y = n + 1 then 
      ~-.(log (!mmax -. !mmin))
    else
      neg_infinity

let move_one_boundary bins = 
  let n = Array.length bins and 
      new_bins = Array.copy bins in
  let imove = Random.int n in 
    if imove = 0 then begin
      new_bins.(0) <- !mmin +. (Random.float (bins.(1) -. !mmin));
      new_bins
    end else if imove = n - 1 then begin
      new_bins.(n-1) <- bins.(n-2) +. (Random.float (!mmax -. bins.(n-2)));
      new_bins
    end else begin
      new_bins.(imove) <- bins.(imove-1) +. (Random.float (bins.(imove+1) -. bins.(imove-1)));
      new_bins
    end

let first_differ_index a b = 
  let n = Array.length a in 
    assert((Array.length b) = n);
    let rec loop i = 
      if i >= n then 
        None
      else
        let x : float = a.(i) and 
            y = b.(i) in 
          if x <> y then 
            Some(i)
          else
            loop (i+1) in 
      loop 0

let log_move_one_boundary_jp x y = 
  let n = Array.length x in 
    if Array.length y <> n then 
      neg_infinity
    else
      let log_index_factor = ~-.(log (float_of_int n)) in 
        match first_differ_index x y with 
          | None -> neg_infinity
          | Some(ichange) -> 
            if ichange = 0 then 
              log_index_factor -. (log (x.(1) -. !mmin))
            else if ichange = n - 1 then 
              log_index_factor -. (log (!mmax -. x.(n-2)))
            else
              log_index_factor -. (log (x.(ichange+1) -. x.(ichange-1)))

let _ = 
  Random.self_init ();
  Arg.parse options (fun _ -> ()) "histogram.{byte,native} OPTIONS ...";
  let (jump_propose, log_jump_prob) = 
    if !fixedbin then (move_one_boundary, log_move_one_boundary_jp) else 
      Mcmc.combine_jump_proposals 
        [(0.1, decrease_bins, log_decrease_bins_jp);
         (0.1, increase_bins, log_increase_bins_jp);
         (0.8, move_one_boundary, log_move_one_boundary_jp)] in
  let samples = Masses.generate_samples !high_m !nmsamp in
  let log_likelihood = log_likelihood samples in 
  let next = Mcmc.make_mcmc_sampler log_likelihood log_prior jump_propose log_jump_prob in 
  let s0 = 
    if !fixedbin then 
      Array.init (!nbin + 1) 
        (fun i -> 
          if i = 0 then !mmin else if i = 1 then !mmax else Stats.draw_uniform !mmin !mmax) 
    else
      [|!mmin; !mmax|] in
    Array.fast_sort compare_float s0;
  let current = ref {Mcmc.value = s0;
                     like_prior = {Mcmc.log_likelihood = log_likelihood s0;
                                   Mcmc.log_prior = log_prior s0}} in 
    for i = 1 to !nburnin do 
      current := next !current
    done;
    let flags = [Open_wronly; Open_creat; Open_text] in 
    let flags = if !overwrite then Open_trunc :: flags else Open_append :: flags in 
    let out = open_out_gen flags 0o644 !outfile in
      for i = 1 to !nmcmc do 
        for j = 1 to !nskip do 
          current := next !current
        done;
        Read_write.write_sample (fun x -> x) out !current
      done;
      close_out out
