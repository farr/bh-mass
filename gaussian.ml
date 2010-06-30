open Printf
open Stats

let mmin = ref 0.0
let mmax = ref 40.0
let nmsamp = ref 1000
let nmcmc = ref 30000
let nskip = ref 100
let nbin = ref 10000
let outfile = ref "gaussian.mcmc"
let overwrite = ref false

let options = 
  [("-mmin", Arg.Set_float mmin, 
    sprintf "minimum mass (default %g)" !mmin);
   ("-mmax", Arg.Set_float mmax,
    sprintf "maximum mass (default %g)" !mmax);
   ("-nmsamp", Arg.Set_int nmsamp,
    sprintf "number of samples to take from mass distributions (default %d)" !nmsamp);
   ("-nmcmc", Arg.Set_int nmcmc,
    sprintf "number of MCMC samples to output (default %d)" !nmcmc);
   ("-nskip", Arg.Set_int nskip,
    sprintf "number of MCMC samples to skip between outputs (default %d)" !nskip);
   ("-nbin", Arg.Set_int nbin,
    sprintf "number of burn-in samples (default %d)" !nbin);
   ("-seed", Arg.Int (fun s -> Random.init s), "initialize RNG with given seed");
   ("-o", Arg.Set_string outfile, 
    sprintf "output file for the mcmc (default %s)" !outfile);
   ("-overwrite", Arg.Set overwrite,
    "overwrite the pre-existing MCMC samples in output file")]

let gaussian mu sigma x = 
  let d = mu -. x in 
  (exp ~-.((d*.d)/.(2.0*.sigma*.sigma))) /. (2.5066282746310005024 *. sigma)

let log_likelihood msamples = function 
  | [|mu; sigma|] -> 
    List.fold_left
      (fun ll msamples -> 
        let overlap = ref 0.0 and
            nsamples = Array.length msamples in
          for i = 0 to nsamples - 1 do
            let m = msamples.(i) in 
              overlap := !overlap +. gaussian mu sigma m
          done;
          ll +. (log (!overlap /. (float_of_int nsamples))))
      0.0
      msamples
  | _ -> raise (Invalid_argument "log_likelihood: bad state")

let log_prior = function 
  | [|mu; sigma|] -> 
    if mu >= !mmin && mu <= !mmax && sigma >= 0.0 && 
      mu +. 2.0*.sigma <= !mmax && mu -. 2.0*.sigma >= !mmin then 
      2.0794415416798359283 -. 2.0*.(log (!mmax -. !mmin))
    else
      neg_infinity
  | _ -> raise (Failure "log_prior: bad state")

let jump_proposal = function 
  | [|mu; sigma|] -> 
    [|Mcmc.uniform_wrapping !mmin !mmax 1.0 mu;
      Mcmc.uniform_wrapping 0.0 (!mmax -. !mmin) 1.0 sigma|]
  | _ -> raise (Invalid_argument "jump_proposal: bad state")

let log_jump_prob _ _ = 0.0

let _ = 
  Random.self_init ();
  Arg.parse options (fun _ -> ()) "gaussian.{byte,native} OPTIONS ...";
  let msamples = Masses.generate_samples !nmsamp in
  let log_likelihood musig = log_likelihood msamples musig in
  let next = Mcmc.make_mcmc_sampler log_likelihood log_prior jump_proposal log_jump_prob in
  let s0 = [|8.0; 2.0|] in 
  let current = ref {Mcmc.like_prior = {Mcmc.log_likelihood = log_likelihood s0;
                                        Mcmc.log_prior = log_prior s0};
                     value = s0} in
    for i = 1 to !nbin do 
      current := next !current
    done;
    let flags = (if !overwrite then Open_trunc else Open_append) :: [Open_wronly; Open_creat; Open_text] in
    let out = open_out_gen flags 0o644 !outfile in
      for i = 1 to !nmcmc do
        for j = 1 to !nskip do
          current := next !current
        done;
        Read_write.write_sample (fun x -> x) out !current
      done;
      close_out out
