function [normns xs] = normalizedHist(data,nbin)
% normalizedHist : Produce histograms that are properly normalized as
% probability densities.
%
% normalizedHist(data, nbin) : Plots a histogram of the given data, binned
% into nbin bins.
%
% normalizedHist(data) : Equivalent to normalizedHist(data,100).
%
% [heights xs] = normalizedHist(...) : Returns the bin x-locations and
% heights in addition to plotting the histogram; see hist(...).
if nargin <= 1
    nbin = 100;
end

[ns xs] = hist(data,nbin);

normns=ns./sum(ns)*nbin/(max(data)-min(data));

bar(xs, normns, 'hist');