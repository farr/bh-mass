open Printf

module R = Rj_base

type dist = 
  | None
  | Histogram
  | Gaussian
  | Power_law
  | Exponential
  | Two_gaussian
  | Rj

let which_dist = ref None
let filename = ref ""
let outfile = ref ""

let options = 
  [("-histogram", Arg.String (fun s -> which_dist := Histogram; filename := s),
    "use a histogram mcmc output in the given file");
   ("-gaussian", Arg.String (fun s -> which_dist := Gaussian; filename := s),
    "use a gaussian mcmc output in the given file");
   ("-power-law", Arg.String (fun s -> which_dist := Power_law; filename := s),
    "use a power-law mcmc output in the given file");
   ("-exponential", Arg.String (fun s -> which_dist := Exponential; filename := s),
    "use an exponential mcmc output in the given file");
   ("-two-gaussian", Arg.String (fun s -> which_dist := Two_gaussian; filename := s),
    "use the two-gaussian mcmc output in the given file");
   ("-rj", Arg.String (fun s -> which_dist := Rj; filename := s),
    "use the reversible-jump mcmc output in the given file");
   ("-o", Arg.Set_string outfile, "output filename")]

let hist_bounds (bins : float array) = 
  [|bins.(0); bins.(Array.length bins - 1)|]

let gaussian_bounds = function 
  | [|mu; sigma|] -> 
    [|mu -. 2.3263478740408411009*.sigma;
      mu +. 2.3263478740408411009*.sigma|]
  | _ -> raise (Invalid_argument "gaussian_bounds: bad state")

let exponential_bounds = function 
  | [|mmin; msc|] -> 
    [|mmin; mmin +. msc*.(log 100.0)|]
  | _ -> raise (Invalid_argument "exponential_bounds: bad state")

let power_law_bounds = function 
  | [|mmin; mmax; alpha|] -> 
    [|mmin; mmax|]
  | _ -> raise (Invalid_argument "power_law_bounds: bad state")

let solve f x0 = 
  let dx = 
    let rec dx_loop dx = 
      let fxlow = f (x0 -. dx) and 
          fxhigh = f (x0 +. dx) in 
        if fxlow *. fxhigh <= 0.0 then 
          dx
        else
          dx_loop (2.0*.dx) in 
      dx_loop 1.0 in 
  let rec loop x0 x1 fx0 fx1 = 
    if abs_float (x0 -. x1) < 1e-8 then 
      (fx0*.x1 -. fx1*.x0) /. (fx0 -. fx1)
    else
      let xmid = 0.5*.(x0 +. x1) in 
      let fxmid = f xmid in 
        if fx0 *. fxmid <= 0.0 then 
          loop x0 xmid fx0 fxmid
        else
          loop xmid x1 fxmid fx1 in 
  let x0 = x0 -. dx and 
      x1 = x0 +. dx in 
    loop x0 x1 (f x0) (f x1)

let two_gaussian_bounds = function 
  | [|mu1; mu2; sigma1; sigma2; a|] -> 
    let f frac x = 
      0.5*.(1.0 +. a*.(Gsl_sf.erf (0.70710678118654752440 *. (x -. mu1) /. sigma1))
            +. (1.0 -. a)*.(Gsl_sf.erf (0.70710678118654752440 *. (x -. mu2) /. sigma2))) -. frac in 
    let fmin x = f 0.01 x and 
        fmax x = f 0.99 x in 
      [| solve fmin 0.0; solve fmax 0.0|]
  | _ -> raise (Invalid_argument "two_gaussian_bounds: bad state")

let rj_bounds x = 
  match R.array_to_state x with 
    | R.Histogram(x) -> hist_bounds x
    | R.Gaussian(x) -> gaussian_bounds x
    | R.Power_law(x) -> power_law_bounds x
    | R.Two_gaussian(x) -> two_gaussian_bounds x
    | R.Exp_cutoff(x) -> exponential_bounds x

let _ = 
  Arg.parse options (fun _ -> ()) "bounds.{byte,native} OPTIONS ...";
  let get_bounds = 
    match !which_dist with 
      | Gaussian -> gaussian_bounds
      | Exponential -> exponential_bounds
      | Power_law -> power_law_bounds
      | Histogram -> hist_bounds
      | Two_gaussian -> two_gaussian_bounds
      | Rj -> rj_bounds
      | _ -> raise (Failure "You must specify a distribution to read from.") in 
  let inp = open_in !filename in 
  let samples = Read_write.read (fun x -> x) inp in 
    close_in inp;
    let out = open_out !outfile in 
      Array.iter 
        (fun {Mcmc.value = samp} -> 
          match get_bounds samp with 
            | [|low; high|] -> 
              fprintf out "%g %g\n" low high
            | _ -> raise (Failure "bad bounds"))
        samples;
      close_out out
