let pi = Gsl_math.pi

(** [egg_carton_normalization nosc ndim] gives the multiplicative
    normalizing constant for the egg-carton likelihood with [nosc]
    oscillations in [ndim] dimensions. *)
let egg_carton_normalization ndim = 
  float_of_int (1 lsl ndim)

(** [egg_carton_likelihood nosc x] returns the "egg carton" likelihood
    with [nosc] oscillations (i.e. 2x[nosc] peaks) in each dimension
    evaluated at the point [x].  The likelihood is normalized so that
    its total integral over \[0,1\]^n is 1. *)
let egg_carton_likelihood nosc x = 
  let ndim = Array.length x and
      fnosc = float_of_int nosc in
  let norm = egg_carton_normalization ndim in 
  let prod = ref 1.0 in 
    for i = 0 to ndim - 1 do 
      let snx = sin (2.0 *. pi *. fnosc *. x.(i)) in 
        prod := !prod *. snx *. snx
    done;
    !prod *. norm

let log_egg_carton_likelihood nosc x = log (egg_carton_likelihood nosc x)

(** [draw_egg_carton nosc ndim] returns a random point drawn from the
    egg-carton distribution with [nosc] oscillations in each of [ndim]
    dimensions. *)
let draw_egg_carton nosc ndim = 
  let norm = egg_carton_normalization ndim in 
  let x = Array.make ndim 0.0 in 
  let rec loop () = 
    for i = 0 to ndim - 1 do 
      x.(i) <- Random.float 1.0 
    done;
    let y = Random.float norm in 
      if y < egg_carton_likelihood nosc x then 
        x
      else
        loop () in 
    loop ()

(** [log_multi_gaussian mu sigma x] returns the (log of the) product
    of gaussians with the given [mu]s, [sigma]s evaluated at the point
    [x]. *)
let log_multi_gaussian mu sigma x = 
  let log_prod = ref 0.0 and 
      n = Array.length x in 
    assert(Array.length mu = n);
    assert(Array.length sigma = n);
    for i = 0 to n - 1 do 
      log_prod := !log_prod +. Stats.log_gaussian mu.(i) sigma.(i) x.(i)
    done;
    !log_prod +. 0.0

let draw_multi_gaussian mu sigma = 
  let n = Array.length mu in 
    assert(Array.length sigma = n);
    let x = Array.make n 0.0 in 
      for i = 0 to n - 1 do 
        x.(i) <- Stats.draw_gaussian mu.(i) sigma.(i)
      done;
      x
