function blackHistogram()
% blackHistogram: blacken a previously-plotted histogram.

h = findobj(gca,'Type','patch');
set(h,{'FaceColor'},{'black'},{'EdgeColor'},{'black'})