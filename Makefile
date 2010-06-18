# Makefile to run all the MCMC's available.

MCMCS = exp-cutoff gaussian histogram histogram-fixed power-law power-law-neg two-gaussian

.PHONY: all
all: $(MCMCS)

.PHONY: exp-cutoff
exp-cutoff:
	_build/exp_cutoff.native

.PHONY: gaussian
gaussian:
	_build/gaussian.native

.PHONY: histogram
histogram:
	_build/histogram.native

.PHONY: histogram-fixed
histogram-fixed:
	for i in {1..5}; do \
		echo "Running with $$i bins..." \
		_build/histogram.native -fixedbin -nbin $$i -o histogram-$${i}bin.mcmc \
	done

.PHONY: power-law
power-law:
	_build/power_law.native 

.PHONY: power-law-neg
power-law-neg:
	_build/power_law.native -alphamin -6.0 -alphamax -1.2 -o power-law-neg.mcmc

.PHONY: two-gaussian
two-gaussian:
	_build/two_gaussian.native