open OUnit
open Asserts
open Skew_gaussian_base

let test_skew_gaussian () = 
  let xi = 0.929896 and 
      omega = 0.847341 and 
      alpha = -0.6990723686704698 and 
      x = 0.820419 in
  let sg = skew_gaussian xi omega alpha x in 
    assert_equal_float 0.5005053061799335917 sg

let quad f a b h = 
  let n = int_of_float (floor ((b-.a)/.h +. 0.5)) in 
  let h = (b-.a)/.(float_of_int n) in 
  let rec sum = ref (0.5*.h*.((f a) +. (f b))) in 
    for i = 1 to n - 1 do 
      sum := !sum +. h*.(f (a +. (float_of_int i)*.h))
    done;
    !sum +. 0.0

let test_mean_conversion () =
  let mu = Random.float 1.0 -. 0.5 and 
      sigma = Random.float 1.0 +. 1.0 and 
      alpha = Random.float 1.0 -. 0.5 in 
    match mu_sigma_to_xi_omega [|mu; sigma; alpha|] with
      | [|xi; omega|] -> 
        let mean = quad (fun x -> x*.(skew_gaussian xi omega alpha x)) (-10.0) 10.0 0.01 in 
        let std = sqrt (quad (fun x -> let dx = x -. mean in dx*.dx*.(skew_gaussian xi omega alpha x)) (-10.0) 10.0 0.01) in 
          assert_equal_float ~epsabs:1e-3 ~epsrel:1e-3 mu mean;
          assert_equal_float ~epsabs:1e-3 ~epsrel:1e-3 std sigma
      | _ -> raise (Failure "test_mean_conversion: bad state")

let tests = "skew_gaussian_base.ml tests" >::: 
  ["skew Gaussian PDF" >:: test_skew_gaussian;
   "test of re-parameterization in terms of mean and std" >:: test_mean_conversion]
