(** Useful statistical functions. *)

(** Mean. *)
val mean : float array -> float

(** Standard deviation; optionally, takes the mean as argument to
    avoid redundant computation.  Note the different opinions about
    normalization in the literature: some use 1/(N-1), where N is the
    number of data points, while others use 1/N to normalize the
    variance (std = sqrt(variance).  This function uses 1/N. *)
val std : ?mu : float -> float array -> float
