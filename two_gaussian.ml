open Printf

let mmin = ref 0.0
let mmax = ref 40.0
let nmsamp = ref 1000
let outfile = ref "two-gaussian.mcmc"
let overwrite = ref false
let nbin = ref 10000
let nmcmc = ref 10000
let nskip = ref 100

let options = 
  [("-mmin", Arg.Set_float mmin,
    sprintf "minimum mass (default %g)" !mmin);
   ("-mmax", Arg.Set_float mmax,
    sprintf "maximum mass (default %g)" !mmax);
   ("-nmsamp", Arg.Set_int nmsamp,
    sprintf "number of samples for each mass measurement (default %d)" !nmsamp);
   ("-o", Arg.Set_string outfile,
    sprintf "output filename (default %s)" !outfile);
   ("-overwrite", Arg.Set overwrite,
    "overwrite output file with new MCMC");
   ("-nmcmc", Arg.Set_int nmcmc,
    sprintf "number of MCMC samples to output (default %d)" !nmcmc);
   ("-nbin", Arg.Set_int nbin,
    sprintf "number of MCMC samples to discard initially (default %d)" !nbin);
   ("-nskip", Arg.Set_int nskip,
    sprintf "number of MCMC samples to discard between each output (default %d)" !nskip)]

let gaussian mu sigma x = 
  let d = mu -. x in 
  (exp ~-.((d*.d)/.(2.0*.sigma*.sigma))) /. (2.5066282746310005024 *. sigma)

let log_likelihood msamples = function 
  | [|mu1; mu2; sigma1; sigma2; a|] -> 
    List.fold_left 
      (fun ll msamp -> 
        let n = Array.length msamp in 
        let ol = ref 0.0 in 
          for i = 0 to n - 1 do 
            let m = msamp.(i) in 
              ol := !ol +. a*.(gaussian mu1 sigma1 m);
              ol := !ol +. (1.0 -. a)*.(gaussian mu2 sigma2 m)
          done;
          ll +. (log (!ol /. (float_of_int n))))
      0.0
      msamples
  | _ -> raise (Invalid_argument "log_likelihood: bad state")

let log_prior = function 
  | [|mu1; mu2; sigma1; sigma2; a|] -> 
    if mu1 > mu2 then 
      neg_infinity
    else
      -0.69314718055994530942 -. 4.0*.(log (!mmax -. !mmin)) (* First factor is log(1/2). *)
  | _ -> raise (Invalid_argument "log_prior: bad state")

let jump_proposal = function 
  | [|mu1; mu2; sigma1; sigma2; a|] -> 
    [|Mcmc.uniform_wrapping !mmin !mmax 1.0 mu1;
      Mcmc.uniform_wrapping !mmin !mmax 1.0 mu2;
      Mcmc.uniform_wrapping !mmin !mmax 1.0 sigma1;
      Mcmc.uniform_wrapping !mmin !mmax 1.0 sigma2;
      Mcmc.uniform_wrapping 0.0 1.0 0.1 a|]
  | _ -> raise (Invalid_argument "jump_proposal: bad state")

let log_jump_probability _ _ = 0.0

let _ = 
  Random.self_init ();
  Arg.parse options (fun _ -> ()) "two_gaussian.{byte,native} OPTIONS ...";
  let msamples = Masses.generate_samples !nmsamp in 
  let s0 = [|8.0; 8.0; 2.0; 2.0; 0.5|] in
  let log_likelihood x = log_likelihood msamples x in
  let current = ref {Mcmc.value = s0;
                     like_prior = {Mcmc.log_likelihood = log_likelihood s0;
                                   log_prior = log_prior s0}} in
  let next = Mcmc.make_mcmc_sampler log_likelihood log_prior jump_proposal log_jump_probability in
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
