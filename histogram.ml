open Printf
open Dist_base
open Histogram_base

(* let nbinmax = ref 5 *) (* Comes from base. *)
(* let fixedbin = ref false *) 
let numbin = ref 1
let outfile = ref "histogram.mcmc"
let overwrite = ref false

let options = 
  Arg.align
    (base_opts @ [("-nbinmax", Arg.Set_int nbinmax,
                   sprintf "maximum number of bins to allow (default %d)" !nbinmax);
                  ("-fixedbin", Arg.Set fixedbin,
                   sprintf "fix the number of bins to the value of the nbin argument");
                  ("-numbin", Arg.Set_int numbin,
                   sprintf "number of bins to use when in fixedbin mode (default %d)" !numbin);
                  ("-o", Arg.Set_string outfile,
                   sprintf "output file name (default %s)" !outfile);
                  ("-overwrite", Arg.Set overwrite,
                   "overwrite the output file instead of appending to it")])

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
  Randomize.randomize ();
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
      Array.init (!numbin + 1) 
        (fun i -> 
          if i = 0 then !mmin else if i = 1 then !mmax else Stats.draw_uniform !mmin !mmax) 
    else
      [|!mmin; !mmax|] in
    Array.fast_sort compare_float s0;
  let current = ref {Mcmc.value = s0;
                     like_prior = {Mcmc.log_likelihood = log_likelihood s0;
                                   Mcmc.log_prior = log_prior s0}} in 
    for i = 1 to !nbin do 
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
