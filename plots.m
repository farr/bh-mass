curFig=1;
% Mass histogram.
figure(curFig);
colordef white;
massData=importdata('masses.dat');
normalizedHist(massData, 1000);
blackHistogram();
axis([0 30 0 inf])
xlabel('M')
ylabel('dN/dM')
print -deps '../../Paper/plots/masses.eps'

% High masses
curFig=curFig+1;
figure(curFig);
colordef white;
massData=importdata('high-mass/masses.dat');
normalizedHist(massData, 1000);
blackHistogram();
axis([0 40 -inf inf]);
xlabel('M');
ylabel('dN/dM');
print -deps '../../Paper/plots/masses-high.eps'

% Harmonic and Direct Evidence.
curFig=curFig+1;
figure(curFig);
colordef white;
xs = 0:9;
harmEvData=[importdata('power-law.mcmc.ev');
            importdata('exp-cutoff.mcmc.ev');
            importdata('gaussian.mcmc.ev');
            importdata('two-gaussian.mcmc.ev');
            importdata('log-normal.mcmc.ev');
            importdata('histogram-1bin.mcmc.ev');
            importdata('histogram-2bin.mcmc.ev');
            importdata('histogram-3bin.mcmc.ev');
            importdata('histogram-4bin.mcmc.ev');
            importdata('histogram-5bin.mcmc.ev')];
errorbar(xs, harmEvData(:,1), harmEvData(:,1)-harmEvData(:,2), harmEvData(:,3)-harmEvData(:,1), '+k')
axis([-0.5 9.5 -inf inf])
set(gca, 'XTickLabel', {'PL', 'E', 'G', 'TG', 'LN', 'H1', 'H2', 'H3', 'H4', 'H5'});
ylabel('p(M_i|d)')
print -deps '../../Paper/plots/evidence.eps'

% Reverse Jump Evidence
curFig = curFig + 1;
figure(curFig);
colordef white;
rjData=importdata('reversible-jump.dat');
xs=0:(length(rjData)-1);
errorbar(xs, rjData(:,1), rjData(:,1)-rjData(:,2), rjData(:,3)-rjData(:,1),'+k')
axis([-0.5 9.5 -inf inf]);
set(gca, 'XTickLabel', {'PL', 'E', 'G', 'TG', 'LN', 'H1', 'H2', 'H3', 'H4', 'H5'});
ylabel('Relative Probability');
print -deps '../../Paper/plots/rj.eps'

% Parameteric Distributions
curFig = curFig + 1;
figure(curFig);
nx=2;
ny=3;
mmin=2;
mmax=15;
ymin=0;
ymax=0.7;
subplot(nx,ny,1);
data=importdata('power-law.mcmc.dist');
errorbar(data(:,1), data(:,2), data(:,2)-data(:,3), data(:,4)-data(:,2), '-k')
axis([mmin mmax ymin ymax])
title('Power Law')
xlabel('M')
ylabel('dN/dM')
subplot(nx,ny,2)
data=importdata('exp-cutoff.mcmc.dist');
errorbar(data(:,1), data(:,2), data(:,2)-data(:,3), data(:,4)-data(:,2), '-k')
axis([mmin mmax ymin ymax])
title('Exponential')
xlabel('M')
ylabel('dN/dM')
subplot(nx,ny,3)
data=importdata('gaussian.mcmc.dist');
errorbar(data(:,1), data(:,2), data(:,2)-data(:,3), data(:,4)-data(:,2), '-k')
axis([mmin mmax ymin ymax])
title('Gaussian')
xlabel('M')
ylabel('dN/dM')
subplot(nx,ny,4)
data=importdata('two-gaussian.mcmc.dist');
errorbar(data(:,1), data(:,2), data(:,2)-data(:,3), data(:,4)-data(:,2), '-k')
axis([mmin mmax ymin ymax])
title('Two Gaussians')
xlabel('M')
ylabel('dN/dM')
subplot(nx,ny,5)
data=importdata('log-normal.mcmc.dist');
errorbar(data(:,1), data(:,2), data(:,2)-data(:,3), data(:,4)-data(:,2), '-k')
axis([mmin mmax ymin ymax]);
title('Log Normal');
xlabel('M')
ylabel('dN/dM')
print -deps '../../Paper/plots/dist-parameteric.eps'

% Non-Parameteric Distributions
curFig = curFig + 1;
figure(curFig);
nx=2;
ny=3;
mmin=2;
mmax=15;
ymin=0;
ymax=0.6;
subplot(nx,ny,1);
data=importdata('histogram-1bin.mcmc.dist');
errorbar(data(:,1),data(:,2),data(:,2)-data(:,3),data(:,4)-data(:,2), '-k');
axis([mmin mmax ymin ymax]);
title('Histogram (1 Bin)');
xlabel('M');
ylabel('dN/dM');
subplot(nx,ny,2);
data=importdata('histogram-2bin.mcmc.dist');
errorbar(data(:,1),data(:,2),data(:,2)-data(:,3),data(:,4)-data(:,2), '-k');
axis([mmin mmax ymin ymax]);
title('Histogram (2 Bin)');
xlabel('M');
ylabel('dN/dM');
subplot(nx,ny,3);
data=importdata('histogram-3bin.mcmc.dist');
errorbar(data(:,1),data(:,2),data(:,2)-data(:,3),data(:,4)-data(:,2), '-k');
axis([mmin mmax ymin ymax]);
title('Histogram (3 Bin)');
xlabel('M');
ylabel('dN/dM');
subplot(nx,ny,4);
data=importdata('histogram-4bin.mcmc.dist');
errorbar(data(:,1),data(:,2),data(:,2)-data(:,3),data(:,4)-data(:,2), '-k');
axis([mmin mmax ymin ymax]);
title('Histogram (4 Bin)');
xlabel('M');
ylabel('dN/dM');
subplot(nx,ny,5);
data=importdata('histogram-5bin.mcmc.dist');
errorbar(data(:,1),data(:,2),data(:,2)-data(:,3),data(:,4)-data(:,2), '-k');
axis([mmin mmax ymin ymax]);
title('Histogram (5 Bin)');
xlabel('M');
ylabel('dN/dM');
print -deps '../../Paper/plots/dist-non-parameteric.eps'

% Mass Plots
curFig = curFig + 1;
figure(curFig);
nx=5;
ny=3;
filenames={'masses-a0620.dat'; 
           'masses-nova-mus-1991.dat'; 'masses-gro-j0422.dat';
           'masses-nova-oph-77.dat'; 'masses-gro-j1655.dat';
           'masses-u4-1543.dat'; 'masses-grs-1009.dat';
           'masses-v4641-sgr.dat'; 'masses-grs-1915.dat';
           'masses-xte-j1118.dat'; 'masses-gs-1354.dat';
           'masses-xte-j1550.dat'; 'masses-gs-2000.dat';
           'masses-xte-j1650.dat'; 'masses-gs-2023.dat'};
names={'A0620'; 'Nova Mus 1991';
       'GRO J0422'; 'Nova Oph 77';
       'GRO J1655'; 'U4 1543'; 'GRS 1009';
       'V4641 Sgr'; 'GRS 1915'; 'XTE J1118'; 'GS 1354';
       'XTE J1550'; 'GS 2000'; 'XTE J1650'; 'GS 2023'};
for i = 1:length(filenames)
    subplot(nx,ny,i);
    data=importdata(filenames{i});
    normalizedHist(data);
    blackHistogram();   
    axis([0 30 -inf inf]);
    xlabel('M')
    ylabel('dN/dM')
    title(names{i})
end
print -deps '../../Paper/plots/all-masses.eps'

% High mass plots
curFig=curFig+1;
figure(curFig);
nx=3; ny=2;
filenames={'high-mass/masses-cyg-x1.dat';
           'high-mass/masses-m33-x7.dat';
           'high-mass/masses-ic10-x1.dat';
           'high-mass/masses-ngc300-x1.dat';
           'high-mass/masses-lmc-x1.dat'};
names={'Cyg X1'; 'M33 X7'; 'IC10 X1'; 'NGC300 X1'; 'LMC X1'};
for i = 1:length(filenames)
    subplot(nx,ny,i);
    data=importdata(filenames{i});
    normalizedHist(data);
    blackHistogram();
    axis([0 80 -inf inf]);
    xlabel('M');
    ylabel('dN/dM');
    title(names{i})
end
print -deps '../../Paper/plots/high-masses.eps'

% Power-law Plots
curFig = curFig + 1;
figure(curFig);
data=importdata('power_law-long.mcmc');
subplot(2,2,1);
normalizedHist(data(:,1),200);
blackHistogram();
xlabel('M_{min}');
ylabel('dN/dM_{min}');
subplot(2,2,2);
normalizedHist(data(:,2),200);
blackHistogram();
xlabel('M_{max}');
ylabel('dN/dM_{max}');
subplot(2,2,[3 4]);
normalizedHist(data(:,3),200);
blackHistogram();
xlabel('\alpha');
ylabel('dN/d\alpha');
print -deps '../../Paper/plots/power-law.eps'

% Power-law 2D correlations
curFig=curFig+1;
figure(curFig);
data=importdata('power_law-long.mcmc');
subplot(2,1,1);
scatter(data(:,1), data(:,3), '.k', 'SizeData', 1);
xlabel('M_{min}');
ylabel('\alpha');
subplot(2,1,2);
scatter(data(:,2), data(:,3), '.k', 'SizeData', 1);
xlabel('M_{max}');
ylabel('\alpha');
print -deps '../../Paper/plots/power-law-2D.eps'

% Parameteric Mmin plots
curFig = curFig + 1;
figure(curFig);
files={'power-law.mcmc.bds'; 'exp-cutoff.mcmc.bds'; 
       'gaussian.mcmc.bds'; 'two-gaussian.mcmc.bds'; 'log-normal.mcmc.bds'};
names={'Power Law'; 'Exponential'; 'Gaussian'; 'Two Gaussians'; 'Log Normal'};
nx=2;
ny=3;
for i = 1:length(files)
    subplot(nx,ny,i);
    data=importdata(files{i});
    normalizedHist(data(:,1),1000);
    axis([max(0,min(data(:,1))) inf -inf inf]);
    blackHistogram();
    title(names{i});
    xlabel('M_{min}');
    ylabel('dN/dM_{min}');
end
print -deps '../../Paper/plots/mmin-parameteric.eps'

% Nonparameteric Mmin plots
curFig = curFig + 1;
nx = 2;
ny = 3;
figure(curFig);
files={'histogram-1bin.mcmc.bds'; 'histogram-2bin.mcmc.bds';
       'histogram-3bin.mcmc.bds'; 'histogram-4bin.mcmc.bds';
       'histogram-5bin.mcmc.bds'};
titles={'Histogram (1 Bin)'; 'Histogram (2 Bin)';
        'Histogram (3 Bin)'; 'Histogram (4 Bin)';
        'Histogram (5 Bin)'};
for i = 1:length(files)
    subplot(nx,ny,i);
    data=importdata(files{i});
    normalizedHist(data(:,1),1000);
    blackHistogram();
    title(titles{i});
    xlabel('M_{min}');
    ylabel('dN/dM_{min}');
end
print -deps '../../Paper/plots/mmin-non-parameteric.eps'

% Exponential M_0 plots
curFig=curFig+1;
figure(curFig);
data=importdata('exp-cutoff.mcmc');
subplot(2,1,1);
normalizedHist(data(:,1),250);
blackHistogram();
xlabel('M_{min}');
ylabel('dN/dM_{min}');
axis([4 8 -inf inf]);
subplot(2,1,2);
normalizedHist(data(:,2),500);
blackHistogram();
xlabel('M_0');
ylabel('dN/dM_0');
axis([0 5 -inf inf]);
print -deps '../../Paper/plots/exp-cutoff.eps'

% 2D Exponential Plots
curFig=curFig+1;
figure(curFig);
nskip=20;
data=importdata('exp-cutoff.mcmc');
scatter(data(1:nskip:end,1), data(1:nskip:end,2), '.k', 'SizeData', 1);
xlabel('M_{min}');
ylabel('M_0');
print -deps '../../Paper/plots/exp-cutoff-2d.eps'

% High-Mass Exponential M_0 plots
curFig=curFig+1;
figure(curFig);
data=importdata('high-mass/exp-cutoff.mcmc');
subplot(2,1,1);
normalizedHist(data(:,1),100);
blackHistogram();
xlabel('M_{min}');
ylabel('dN/dM_{min}');
subplot(2,1,2);
normalizedHist(data(:,2),100);
blackHistogram();
xlabel('M_0');
ylabel('dN/dM_0');
print -deps '../../Paper/plots/exp-cutoff-high.eps'

% Gaussian Mean, Sigma Plots.
curFig=curFig+1;
figure(curFig);
data=importdata('gaussian.mcmc');
nx=2; ny = 1;
subplot(nx,ny,1);
normalizedHist(data(:,1), 1000);
blackHistogram();
xlabel('\mu');
ylabel('dN/d\mu');
axis([5 10 -inf inf]);
subplot(nx,ny,2);
normalizedHist(data(:,2), 1000);
blackHistogram();
xlabel('\sigma');
ylabel('dN/d\sigma');
print -deps '../../Paper/plots/gaussian.eps'

% Log Normal
curFig=curFig+1;
figure(curFig);
data=importdata('log-normal.mcmc');
nx=2;ny=1;
subplot(nx,ny,1);
normalizedHist(data(:,1),1000);
blackHistogram();
xlabel('<M>');
ylabel('dN/d<M>');
axis([4 10 -inf inf]);
subplot(nx,ny,2);
normalizedHist(data(:,2),1000);
blackHistogram();
xlabel('\sigma_M');
ylabel('dN/d\sigma_M');
axis([0 4 -inf inf]);
print -deps '../../Paper/plots/log-normal.eps'

% Two Gaussian
curFig=curFig+1;
figure(curFig);
data=importdata('two-gaussian.mcmc');
nx=3;ny=2;
subplot(nx,ny,1);
normalizedHist(data(:,1),100);
blackHistogram();
xlabel('\mu_1');
ylabel('dN/d\mu_1');
subplot(nx,ny,2);
normalizedHist(data(:,3),100);
blackHistogram();
xlabel('\sigma_1');
ylabel('dN/d\sigma_1');
subplot(nx,ny,3);
normalizedHist(data(:,2),100);
blackHistogram();
xlabel('\mu_2');
ylabel('dN/d\mu_2');
subplot(nx,ny,4);
normalizedHist(data(:,4),100);
blackHistogram();
xlabel('\sigma_2');
ylabel('dN/d\sigma_2');
subplot(nx,ny,[5 6]);
normalizedHist(data(:,5),100);
blackHistogram();
xlabel('\alpha');
ylabel('dN/d\alpha');
print -deps '../../Paper/plots/two-gaussian.eps'

% High-mass Reverse Jump Evidence
curFig = curFig + 1;
figure(curFig);
colordef white;
rjData=importdata('high-mass/reversible-jump.dat');
xs=0:(length(rjData)-1);
errorbar(xs, rjData(:,1), rjData(:,1)-rjData(:,2), rjData(:,3)-rjData(:,1),'+k')
axis([-0.5 9.5 -inf inf]);
set(gca, 'XTickLabel', {'PL', 'E', 'G', 'TG', 'LN', 'H1', 'H2', 'H3', 'H4', 'H5'});
ylabel('Relative Probability');
print -deps '../../Paper/plots/rj-high.eps'

% High-mass Parameteric Distributions
curFig = curFig + 1;
figure(curFig);
nx=2;
ny=3;
mmin=2;
mmax=25;
ymin=0;
ymax=0.7;
subplot(nx,ny,1);
data=importdata('high-mass/power-law.mcmc.dist');
errorbar(data(:,1), data(:,2), data(:,2)-data(:,3), data(:,4)-data(:,2), '-k')
axis([mmin mmax ymin ymax])
title('Power Law')
xlabel('M')
ylabel('dN/dM')
subplot(nx,ny,2)
data=importdata('high-mass/exp-cutoff.mcmc.dist');
errorbar(data(:,1), data(:,2), data(:,2)-data(:,3), data(:,4)-data(:,2), '-k')
axis([mmin mmax ymin ymax])
title('Exponential')
xlabel('M')
ylabel('dN/dM')
subplot(nx,ny,3)
data=importdata('high-mass/gaussian.mcmc.dist');
errorbar(data(:,1), data(:,2), data(:,2)-data(:,3), data(:,4)-data(:,2), '-k')
axis([mmin mmax ymin ymax])
title('Gaussian')
xlabel('M')
ylabel('dN/dM')
subplot(nx,ny,4)
data=importdata('high-mass/two-gaussian.mcmc.dist');
errorbar(data(:,1), data(:,2), data(:,2)-data(:,3), data(:,4)-data(:,2), '-k')
axis([mmin mmax ymin ymax])
title('Two Gaussians')
xlabel('M')
ylabel('dN/dM')
subplot(nx,ny,5)
data=importdata('high-mass/log-normal.mcmc.dist');
errorbar(data(:,1), data(:,2), data(:,2)-data(:,3), data(:,4)-data(:,2), '-k')
axis([mmin mmax ymin ymax]);
title('Log Normal');
xlabel('M')
ylabel('dN/dM')
print -deps '../../Paper/plots/dist-parameteric-high.eps'

% Non-Parameteric High-mass Distributions
curFig = curFig + 1;
figure(curFig);
nx=2;
ny=3;
mmin=2;
mmax=25;
ymin=0;
ymax=0.6;
subplot(nx,ny,1);
data=importdata('high-mass/histogram-1bin.mcmc.dist');
errorbar(data(:,1),data(:,2),data(:,2)-data(:,3),data(:,4)-data(:,2), '-k');
axis([mmin mmax ymin ymax]);
title('Histogram (1 Bin)');
xlabel('M');
ylabel('dN/dM');
subplot(nx,ny,2);
data=importdata('high-mass/histogram-2bin.mcmc.dist');
errorbar(data(:,1),data(:,2),data(:,2)-data(:,3),data(:,4)-data(:,2), '-k');
axis([mmin mmax ymin ymax]);
title('Histogram (2 Bin)');
xlabel('M');
ylabel('dN/dM');
subplot(nx,ny,3);
data=importdata('high-mass/histogram-3bin.mcmc.dist');
errorbar(data(:,1),data(:,2),data(:,2)-data(:,3),data(:,4)-data(:,2), '-k');
axis([mmin mmax ymin ymax]);
title('Histogram (3 Bin)');
xlabel('M');
ylabel('dN/dM');
subplot(nx,ny,4);
data=importdata('high-mass/histogram-4bin.mcmc.dist');
errorbar(data(:,1),data(:,2),data(:,2)-data(:,3),data(:,4)-data(:,2), '-k');
axis([mmin mmax ymin ymax]);
title('Histogram (4 Bin)');
xlabel('M');
ylabel('dN/dM');
subplot(nx,ny,5);
data=importdata('high-mass/histogram-5bin.mcmc.dist');
errorbar(data(:,1),data(:,2),data(:,2)-data(:,3),data(:,4)-data(:,2), '-k');
axis([mmin mmax ymin ymax]);
title('Histogram (5 Bin)');
xlabel('M');
ylabel('dN/dM');
print -deps '../../Paper/plots/dist-non-parameteric-high.eps'

% High-mass Harmonic and Direct Evidence.
curFig=curFig+1;
figure(curFig);
colordef white;
xs = 0:9;
harmEvData=[importdata('high-mass/power-law.mcmc.ev');
            importdata('high-mass/exp-cutoff.mcmc.ev');
            importdata('high-mass/gaussian.mcmc.ev');
            importdata('high-mass/two-gaussian.mcmc.ev');
            importdata('high-mass/log-normal.mcmc.ev');
            importdata('high-mass/histogram-1bin.mcmc.ev');
            importdata('high-mass/histogram-2bin.mcmc.ev');
            importdata('high-mass/histogram-3bin.mcmc.ev');
            importdata('high-mass/histogram-4bin.mcmc.ev');
            importdata('high-mass/histogram-5bin.mcmc.ev')];
dirEvData=[importdata('high-mass/power-law.mcmc.ev.direct');
           importdata('high-mass/exp-cutoff.mcmc.ev.direct');
           importdata('high-mass/gaussian.mcmc.ev.direct');
           importdata('high-mass/two-gaussian.mcmc.ev.direct');
           importdata('high-mass/log-normal.mcmc.ev.direct');
           importdata('high-mass/histogram-1bin.mcmc.ev.direct');
           importdata('high-mass/histogram-2bin.mcmc.ev.direct');
           importdata('high-mass/histogram-3bin.mcmc.ev.direct');
           importdata('high-mass/histogram-4bin.mcmc.ev.direct');
           importdata('high-mass/histogram-5bin.mcmc.ev.direct')];
semilogy(xs,dirEvData, 'xk');
hold on;
errorbar(xs, harmEvData(:,1), harmEvData(:,1)-harmEvData(:,2), harmEvData(:,3)-harmEvData(:,1), '+k')
axis([-0.5 9.5 -inf inf])
set(gca, 'XTickLabel', {'PL', 'E', 'G', 'TG', 'LN', 'H1', 'H2', 'H3', 'H4', 'H5'});
ylabel('p(d|M_i)')
legend('Direct Integration Evidence','Harmonic Mean Evidence')
print -deps '../../Paper/plots/evidence-high.eps'
hold off