# Makefile to run all the MCMC's available.  Run with -j <n-processors> for parallel speedup. 

MCMCS = exp-cutoff gaussian histogram histogram-fixed power-law two-gaussian
POST_MCMCS = $(patsubst %,post-%,$(MCMCS))

.PHONY: all
all: 
	ocamlbuild all.otarget

.PHONY: runs
runs: $(MCMCS)

.PHONY: clean
clean:
	ocamlbuild -clean

.PHONY: post-processing
post-processing: $(POST_MCMCS)

.PHONY: plots
plots: all
	_build/mass_plot.native -dev ps -o masses.ps
	ps2pdf masses.ps
	_build/all_masses_plot.native -dev ps -o all-masses.ps
	ps2pdf all-masses.ps
	_build/evidence_plot.native -dev ps -o evidence.ps
	ps2pdf evidence.ps
	_build/dist_plot.native -dev ps -o dist.ps
	ps2pdf dist.ps
	_build/bounds_plot.native -dev ps -o bounds.ps
	ps2pdf bounds.ps

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

.PHONY: post-exp-cutoff
post-exp-cutoff:
	_build/harmonic_evidence.native -i exp-cutoff.mcmc -o exp-cutoff.mcmc.ev
	_build/dist.native -exponential exp-cutoff.mcmc -o exp-cutoff.mcmc.dist
	_build/bounds.native -exponential exp-cutoff.mcmc -o exp-cutoff.mcmc.bds

.PHONY: post-gaussian
post-gaussian:
	_build/harmonic_evidence.native -i gaussian.mcmc -o gaussian.mcmc.ev
	_build/dist.native -gaussian gaussian.mcmc -o gaussian.mcmc.dist
	_build/bounds.native -gaussian gaussian.mcmc -o gaussian.mcmc.bds

.PHONY: post-histogram
post-histogram:
	_build/harmonic_evidence.native -i histogram.mcmc -o histogram.mcmc.ev
	_build/dist.native -histogram histogram.mcmc -o histogram.mcmc.dist
	_build/bounds.native -histogram histogram.mcmc -o histogram.mcmc.bds

.PHONY: post-histogram-fixed
post-histogram-fixed:
	for i in {1..5}; do \
		_build/harmonic_evidence.native -i histogram-$${i}bin.mcmc -o histogram-$${i}bin.mcmc.ev; \
		_build/dist.native -histogram histogram-$${i}bin.mcmc -o histogram-$${i}bin.mcmc.dist; \
		_build/bounds.native -histogram histogram-$${i}bin.mcmc -o histogram-$${i}bin.mcmc.bds; \
	done;

.PHONY: post-power-law
post-power-law:
	_build/harmonic_evidence.native -i power-law.mcmc -o power-law.mcmc.ev
	_build/dist.native -power-law power-law.mcmc -o power-law.mcmc.dist
	_build/bounds.native -power-law power-law.mcmc -o power-law.mcmc.bds

.PHONY: post-two-gaussian
post-two-gaussian:
	_build/harmonic_evidence.native -i two-gaussian.mcmc -o two-gaussian.mcmc.ev
	_build/dist.native -two-gaussian two-gaussian.mcmc -o two-gaussian.mcmc.dist
	_build/bounds.native -two-gaussian two-gaussian.mcmc -o two-gaussian.mcmc.bds