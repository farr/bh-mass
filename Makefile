# Makefile to run all the MCMC's available.  Run with -j <n-processors> for parallel speedup. 

MCMCS = exp-cutoff gaussian histogram histogram-fixed power-law two-gaussian

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
		echo "  Running $${i}-bin histogram..."; \
		_build/histogram.native -fixedbin -nbin $$i -o histogram-$${i}bin.mcmc; \
	done;

.PHONY: power-law
power-law:
	_build/power_law.native 

.PHONY: two-gaussian
two-gaussian:
	_build/two_gaussian.native