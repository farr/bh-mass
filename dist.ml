open Printf

type dist = 
  | No_dist
  | Gaussian
  | Histogram
  | Exponential
  | Power_law
  | Two_gaussian
  | Log_normal
  | Skew_gaussian

let mmin = ref 0.0
let mmax = ref 40.0 
let dm = ref 0.5
let infile = ref ""
let outfile = ref ""
let dist = ref No_dist

let options = 
  Arg.align 
    ([("-gaussian", Arg.String (fun s -> dist := Gaussian; infile := s),
       "file use gaussian MCMC output in given file");
      ("-histogram", Arg.String (fun s -> dist := Histogram; infile := s),
       "file use histogram MCMC output in given file");
      ("-exponential", Arg.String (fun s -> dist := Exponential; infile := s),
       "file use cutoff exponential MCMC output in given file");
      ("-power-law", Arg.String (fun s -> dist := Power_law; infile := s),
       "file use power-law MCMC output in given file");
      ("-two-gaussian", Arg.String (fun s -> dist := Two_gaussian; infile := s),
       "file use two-gaussian MCMC output in given file");
      ("-log-normal", Arg.String (fun s -> dist := Log_normal; infile := s),
       "file use log-normal MCMC output in given file");
      ("-skew-gaussian", Arg.String (fun s -> dist := Skew_gaussian; infile := s),
       "file use skew-gaussian MCMC output in given file");
      ("-o", Arg.Set_string outfile, "file output to given file");
      ("-mmin", Arg.Set_float mmin, 
       sprintf "mm minimum mass to plot (default %g)" !mmin);
      ("-mmax", Arg.Set_float mmax,
       sprintf "mm maximum mass to plot (default %g)" !mmax);
      ("-dm", Arg.Set_float dm,
       sprintf "d mass step for output (default %g)" !dm)])

let eval_gaussian params x = 
  match params with 
    | [|mu; sigma|] -> exp (Stats.log_gaussian mu sigma x)
    | _ -> raise (Invalid_argument "eval_gaussian: bad state")

let find_bin_bds bins x = 
  let n = Array.length bins in
  if x < bins.(0) || x >= bins.(n-1) then 
    None
  else
    let rec loop ilow ihigh = 
      if ihigh - ilow <= 1 then 
        Some((bins.(ilow), bins.(ihigh)))
      else
        let imid = ilow + (ihigh - ilow)/2 in 
        let mid = bins.(imid) in 
          if x < mid then 
            loop ilow imid
          else
            loop imid ihigh in 
      loop 0 (n-1)

let eval_histogram bins x = 
  match find_bin_bds bins x with 
    | None -> 0.0
    | Some((low,high)) -> 
      let nb = Array.length bins - 1 in 
        1.0 /. ((float_of_int nb) *. (high -. low))

let eval_exponential params x = 
  match params with 
    | [|mc; m0|] -> 
      if mc <= x then 
        let norm = (exp (mc /. m0)) /. m0 in
          norm *. (exp ~-.(x /. m0))
      else
        0.0
    | _ -> raise (Invalid_argument "eval_exponential: bad state")
      
let eval_power_law params x = 
  match params with 
    | [|mmin; mmax; alpha|] -> 
      if x < mmin || x > mmax then 
        0.0 
      else
        let ap1 = alpha +. 1.0 in 
        let norm = ap1 /. (mmax**ap1 -. mmin**ap1) in
          norm*.x**alpha
    | _ -> raise (Invalid_argument "eval_power_law: bad state")

let eval_two_gaussian params x = 
  match params with 
    | [|mu1; mu2; sigma1; sigma2; a|] -> 
      a*.(eval_gaussian [|mu1; sigma1|] x) +. (1.0-.a)*.(eval_gaussian [|mu2; sigma2|] x)
    | _ -> raise (Invalid_argument "eval_two_gaussian: bad state")

let eval_log_normal params x = 
  match Logn_base.msigma_to_musigma params with 
    | [|mu; sigma|] -> 
      exp (Stats.log_lognormal mu sigma x)
    | _ -> raise (Invalid_argument "eval_log_normal: bad state")

let eval_skew_gaussian params x = 
  match Skew_gaussian_base.mu_sigma_to_xi_omega params with 
    | [|xi; omega|] -> 
      let alpha = params.(2) in 
        Skew_gaussian_base.skew_gaussian xi omega alpha x
    | _ -> raise (Invalid_argument "eval_skew_gaussian: bad state")

let _ = 
  Arg.parse options (fun _ -> ()) "plot_dist.{byte,native} OPTIONS ...";
  let nb = int_of_float ((!mmax -. !mmin) /. !dm +. 0.5) in 
  let xs = Array.init (nb+1) (fun i -> !mmin +. (float_of_int i) *. !dm) in
  let inp = open_in !infile in 
  let samples = Read_write.read (fun x -> x) inp in 
  let ev = match !dist with 
    | Gaussian -> eval_gaussian
    | Histogram -> eval_histogram
    | Exponential -> eval_exponential
    | Power_law -> eval_power_law
    | Two_gaussian -> eval_two_gaussian 
    | Log_normal -> eval_log_normal
    | Skew_gaussian -> eval_skew_gaussian
    | _ -> raise (Failure "un-recognized distribution") in
  let pts = 
    Array.map 
      (fun {Mcmc.value = params} -> 
        Array.map
          (fun x -> ev params x)
          xs)
      samples in 
  let out = open_out !outfile in 
    for i = 0 to Array.length xs - 1 do 
      Array.fast_sort
        (fun (pt1 : float array) pt2 -> Pervasives.compare pt1.(i) pt2.(i))
        pts;
      let n = Array.length pts in
      let y = pts.(n/2).(i) and 
          ymin = pts.(n/10).(i) and 
          ymax = pts.((n*9)/10).(i) in 
        fprintf out "%g %g %g %g\n" xs.(i) y ymin ymax
    done;
    close_out out
