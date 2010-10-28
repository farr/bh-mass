open Printf

type dist = 
  | None
  | Histogram
  | Gaussian
  | Power_law
  | Exponential
  | Two_gaussian
  | Log_normal
  | Skew_gaussian

let which_dist = ref None
let filename = ref ""
let outfile = ref ""
let low_quantile = ref 0.01
let high_quantile = ref 0.99

let options = 
  Arg.align
    ([("-histogram", Arg.String (fun s -> which_dist := Histogram; filename := s),
       "file use a histogram mcmc output in the given file");
      ("-gaussian", Arg.String (fun s -> which_dist := Gaussian; filename := s),
       "file use a gaussian mcmc output in the given file");
      ("-power-law", Arg.String (fun s -> which_dist := Power_law; filename := s),
       "file use a power-law mcmc output in the given file");
      ("-exponential", Arg.String (fun s -> which_dist := Exponential; filename := s),
       "file use an exponential mcmc output in the given file");
      ("-two-gaussian", Arg.String (fun s -> which_dist := Two_gaussian; filename := s),
       "file use the two-gaussian mcmc output in the given file");
      ("-log-normal", Arg.String (fun s -> which_dist := Log_normal; filename := s),
       "file use the log-normal mcmc output in the given file");
      ("-skew-gaussian", Arg.String (fun s -> which_dist := Skew_gaussian; filename := s),
       "file use the skew-gaussian MCMC output in the given file");
      ("-o", Arg.Set_string outfile, "file output filename")])

let hist_bounds (bins : float array) = 
  let nbins = Array.length bins - 1 in 
  let nbinsf = float_of_int nbins in 
  let bin_weight = 1.0 /. nbinsf in 
  let ilow = int_of_float (!low_quantile /. bin_weight) and 
      ihigh = int_of_float (!high_quantile /. bin_weight) in 
  let low_width = bins.(ilow+1) -. bins.(ilow) and 
      high_width = bins.(ihigh+1) -. bins.(ihigh) in 
  let low_extra = mod_float !low_quantile bin_weight and 
      high_extra = mod_float !high_quantile bin_weight in 
    [|bins.(ilow) +. (low_extra /. bin_weight)*.low_width;
      bins.(ihigh) +. (high_extra /. bin_weight)*.high_width|]

let gaussian_bounds = function 
  | [|mu; sigma|] -> 
    [|mu -. 2.3263478740408411009*.sigma;
      mu +. 2.3263478740408411009*.sigma|]
  | _ -> raise (Invalid_argument "gaussian_bounds: bad state")

let exponential_bounds = function 
  | [|mmin; msc|] -> 
    [|mmin +. msc*.(log (100.0/.99.0));
      mmin +. msc*.(log 100.0)|]
  | _ -> raise (Invalid_argument "exponential_bounds: bad state")

let power_law_bounds = function 
  | [|mmin; mmax; alpha|] -> 
    let ap1 = alpha +. 1.0 in 
    let rap1 = 1.0 /. ap1 in 
      [|((mmax**ap1 +. 99.0*.mmin**ap1)/.100.0)**rap1;
        ((99.0*.mmax**ap1 +. mmin**ap1)/.100.0)**rap1|]
  | _ -> raise (Invalid_argument "power_law_bounds: bad state")

let solve f = 
  let dx = 
    let rec dx_loop dx = 
      let fxlow = f (~-.dx) and 
          fxhigh = f dx in 
        if fxlow *. fxhigh <= 0.0 then 
          dx
        else
          dx_loop (2.0*.dx) in 
      dx_loop 1.0 in 
  let solver = Gsl_root.Bracket.make Gsl_root.Bracket.BRENT f (~-.dx) dx in 
  let rec loop () = 
    Gsl_root.Bracket.iterate solver;
    let (low, high) = Gsl_root.Bracket.interval solver in 
      if Gsl_root.test_interval ~lo:low ~up:high ~epsabs:1e-3 ~epsrel:0.0 then 
        Gsl_root.Bracket.root solver
      else
        loop () in 
    loop ()

let two_gaussian_bounds = function 
  | [|mu1; mu2; sigma1; sigma2; a|] -> 
    let f frac x = 
      0.5*.(1.0 +. a*.(Gsl_sf.erf (0.70710678118654752440 *. (x -. mu1) /. sigma1))
            +. (1.0 -. a)*.(Gsl_sf.erf (0.70710678118654752440 *. (x -. mu2) /. sigma2))) -. frac in 
    let fmin x = f 0.01 x and 
        fmax x = f 0.99 x in 
      [| solve fmin; solve fmax|]
  | _ -> raise (Invalid_argument "two_gaussian_bounds: bad state")

let log_normal_bounds state = 
  match Logn_base.msigma_to_musigma state with 
    | [|mu; sigma|] -> 
      let logxmin = mu -. 2.3263478740408411009*.sigma and 
          logxmax = mu +. 2.3263478740408411009*.sigma in 
        [|exp logxmin; exp logxmax|]
    | _ -> raise (Invalid_argument "log_normal_bounds: bad state")

let skew_gaussian_bounds state = 
  match Skew_gaussian_base.mu_sigma_to_xi_omega state with 
    | [|xi; omega|] -> 
      let alpha = state.(2) in 
      let f frac x = 
        Skew_gaussian_base.skew_gaussian_cdf xi omega alpha x -. frac in 
      let fmin x = f 0.01 x and 
          fmax x = f 0.99 x in 
        [| solve fmin; solve fmax|]
    | _ -> raise (Invalid_argument "skew_gaussian_bounds: bad state")

let _ = 
  Arg.parse options (fun _ -> ()) "bounds.{byte,native} OPTIONS ...";
  let get_bounds = 
    match !which_dist with 
      | Gaussian -> gaussian_bounds
      | Exponential -> exponential_bounds
      | Power_law -> power_law_bounds
      | Histogram -> hist_bounds
      | Two_gaussian -> two_gaussian_bounds
      | Log_normal -> log_normal_bounds
      | Skew_gaussian -> skew_gaussian_bounds
      | None -> raise (Failure "You must specify a distribution to read from.") in 
  let inp = open_in !filename in 
  let out = open_out !outfile in 
    try 
      while true do 
        let sample = Read_write.read_sample (fun x -> x) inp in 
          match get_bounds sample.Mcmc.value with 
            | [|low; high|] -> fprintf out "%g %g\n" low high
            | _ -> raise (Failure "bad bounds")
      done              
    with
      | End_of_file -> 
        close_in inp;
        close_out out;
