open Printf

let mmin = ref 0.0
let mmax = ref 40.0
let nmcmc = ref 1000000
let nmsamp = ref 1000
let nskip = ref 100
let nbin = ref 1000000
let high_m = ref false

let base_opts = 
  [("-mmin", Arg.Set_float mmin, 
    sprintf "mm minimum mass (default %g)" !mmin);
   ("-mmax", Arg.Set_float mmax,
    sprintf "mm maximum mass (default %g)" !mmax);
   ("-nmsamp", Arg.Set_int nmsamp,
    sprintf "nms number of samples to take from mass distributions (default %d)" !nmsamp);
   ("-nmcmc", Arg.Set_int nmcmc,
    sprintf "nmc number of MCMC samples to output (default %d)" !nmcmc);
   ("-nskip", Arg.Set_int nskip,
    sprintf "nsk number of MCMC samples to skip between outputs (default %d)" !nskip);
   ("-nbin", Arg.Set_int nbin,
    sprintf "nb number of burn-in samples (default %d)" !nbin);
   ("-seed", Arg.Int (fun s -> Random.init s), "s initialize RNG with given seed");
   ("-high-mass", Arg.Set high_m,
    "use high-mass objects in sample")]
