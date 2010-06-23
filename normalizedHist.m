function [normns xs] = normalizedHist(data,nbin)

if nargin <= 1
    nbin = 100;
end

[ns xs] = hist(data,nbin);

normns=ns./sum(ns)*nbin/(max(data)-min(data));

bar(xs, normns, 'hist');