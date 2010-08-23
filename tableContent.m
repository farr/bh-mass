function tableContent = tableContent( data )
% TABLECONTENT: produces a table entry for the given MCMC output.

dataSize=size(data);
nparams=dataSize(2) - 2;

quants=[0.05 0.15 0.5 0.85 0.95];

tableContent=' ';

for i = 1:nparams
    qs = quantile(data(:,i), quants);
    tableContent=sprintf('%s\n\\hline\n & & %g & %g & %g & %g & %g \\\\', tableContent, qs(1),qs(2),qs(3),qs(4),qs(5));
end

end

