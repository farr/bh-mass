function [normns xs] = normalizedHist(data,nbin)

[ns xs] = hist(data,nbin);

normns=ns./sum(ns)*nbin/(max(data)-min(data));

bar(xs, normns, 'hist');