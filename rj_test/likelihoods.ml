let pi = Gsl_math.pi

(** [egg_carton_normalization nosc ndim] gives the multiplicative
    normalizing constant for the egg-carton likelihood with [nosc]
    oscillations in [ndim] dimensions. *)
let egg_carton_normalization nosc ndim = 
  1.0 /. (0.5 *. (float_of_int nosc) *. (float_of_int ndim))

(** [egg_carton_likelihood nosc x] returns the "egg carton" likelihood
    with [nosc] oscillations (i.e. 2x[nosc] peaks) in each dimension
    evaluated at the point [x].  The likelihood is normalized so that
    its total integral over \[0,1\]^n is 1. *)
let egg_carton_likelihood nosc x = 
  let ndim = Array.length x and
      fnosc = float_of_int nosc in
  let norm = egg_carton_normalization nosc ndim in 
  let prod = ref 1.0 in 
    for i = 0 to ndim - 1 do 
      let snx = sin (2.0 *. pi *. fnosc *. x.(i)) in 
        prod := !prod *. snx *. snx
    done;
    !prod *. norm

(** [draw_egg_carton nosc ndim] returns a random point drawn from the
    egg-carton distribution with [nosc] oscillations in each of [ndim]
    dimensions. *)
let draw_egg_carton nosc ndim = 
  let norm = egg_carton_normalization nosc ndim in 
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
