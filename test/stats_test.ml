open OUnit
open Stats
open Asserts

let test_mean () = 
  let xs = [|1.0; 2.0; 3.0; 4.0|] in 
  let mu = mean xs in 
    assert_equal_float 2.5 mu

let test_sigma () = 
  let xs = [|1.0; 2.0; 3.0; 4.0|] in 
  let mu = mean xs in 
  let s_mu = std ~mu:mu xs and 
      s = std xs in 
    assert_equal_float ~msg:"with and without ~mu argument" s s_mu;
    assert_equal_float (sqrt (5.0/.3.0)) s

let tests = "stats.ml tests" >:::
  ["mean test" >:: test_mean;
   "std test" >:: test_sigma]
