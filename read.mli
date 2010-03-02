(** Utility code to read from channels sets of measured masses and the
    associated standard deviations. *)

(** [call_with_input_file file f] calls the function [f] with the
    result of [open_in file], but makes sure to close the file upon
    the return of [f], {b or} when an exception is thrown. *)
val call_with_input_file : string -> (in_channel -> 'a) -> 'a

(** Read from the given channel [m,sigma] pairs.  Reading stops when
    the [End_of_file] exception is encountered. *)
val read_msigmas : in_channel -> (float array) * (float array)

(** [read_mcmc_output ndim chan]: read in parameters and
    log-likelihood/log-prior values from a given channel.  We assume
    that there are [ndim] floating-point parameters, and [ndim + 2]
    values on each line of channel; the last two values are the
    log-likelihood and log-prior for the given parameters. *)
val read_mcmc_output : int -> in_channel -> (float array) Mcmc.mcmc_sample list
