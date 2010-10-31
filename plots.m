curFig=1;

% Distributions
curFig = curFig + 1;
figure(curFig);
nx=4;
ny=3;
mmin=2;
mmax=15;
ymin=-inf;
ymax=inf;
subplot(nx,ny,1);
data=importdata('power-law.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax])
title('Power Law')
%xlabel('M (Solar Mass)')
set(gca, 'ytick', []);
subplot(nx,ny,2)
data=importdata('exp-cutoff.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax])
title('Exponential')
%xlabel('M (Solar Mass)')
set(gca, 'ytick', []);
subplot(nx,ny,3)
data=importdata('gaussian.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax])
title('Gaussian')
%xlabel('M (Solar Mass)')
set(gca, 'ytick', []);
subplot(nx,ny,4)
data=importdata('two-gaussian.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax])
title('Two Gaussians')
%xlabel('M (Solar Mass)')
set(gca, 'ytick', []);
subplot(nx,ny,5)
data=importdata('log-normal.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Log Normal');
%xlabel('M (Solar Mass)')
set(gca, 'ytick', []);
subplot(nx,ny,6);
data=importdata('histogram-1bin.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Histogram (1 Bin)');
%xlabel('M (Solar Mass)');
set(gca, 'ytick', []);
subplot(nx,ny,7);
data=importdata('histogram-2bin.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Histogram (2 Bin)');
%xlabel('M (Solar Mass)');
set(gca, 'ytick', []);
subplot(nx,ny,8);
data=importdata('histogram-3bin.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Histogram (3 Bin)');
xlabel('M (Solar Mass)');
set(gca, 'ytick', []);
subplot(nx,ny,9);
data=importdata('histogram-4bin.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Histogram (4 Bin)');
xlabel('M (Solar Mass)');
set(gca, 'ytick', []);
subplot(nx,ny,10);
data=importdata('histogram-5bin.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Histogram (5 Bin)');
xlabel('M (Solar Mass)');
set(gca, 'ytick', []);
print -deps '../../Paper/plots/dist.eps'

% High-mass Distributions
curFig = curFig + 1;
figure(curFig);
nx=4;
ny=3;
mmin=2;
mmax=30;
ymin=-inf;
ymax=inf;
subplot(nx,ny,1);
data=importdata('high-mass/power-law.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax])
title('Power Law')
set(gca, 'ytick', []);
subplot(nx,ny,2)
data=importdata('high-mass/exp-cutoff.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax])
title('Exponential')
set(gca, 'ytick', []);
subplot(nx,ny,3)
data=importdata('high-mass/gaussian.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax])
title('Gaussian')
set(gca, 'ytick', []);
subplot(nx,ny,4)
data=importdata('high-mass/two-gaussian.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax])
title('Two Gaussians')
set(gca, 'ytick', []);
subplot(nx,ny,5)
data=importdata('high-mass/log-normal.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Log Normal');
set(gca, 'ytick', []);
subplot(nx,ny,6);
data=importdata('high-mass/histogram-1bin.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Histogram (1 Bin)');
set(gca, 'ytick', []);
subplot(nx,ny,7);
data=importdata('high-mass/histogram-2bin.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Histogram (2 Bin)');
set(gca, 'ytick', []);
subplot(nx,ny,8);
data=importdata('high-mass/histogram-3bin.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Histogram (3 Bin)');
xlabel('M (Solar Mass)');
set(gca, 'ytick', []);
subplot(nx,ny,9);
data=importdata('high-mass/histogram-4bin.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Histogram (4 Bin)');
xlabel('M (Solar Mass)');
set(gca, 'ytick', []);
subplot(nx,ny,10);
data=importdata('high-mass/histogram-5bin.mcmc.dist');
plot(data(:,1),data(:,2),'-k', data(:,1), data(:,3), '--k', data(:,1), data(:,4), '--k');
axis([mmin mmax ymin ymax]);
title('Histogram (5 Bin)');
xlabel('M (Solar Mass)');
set(gca, 'ytick', []);
print -deps '../../Paper/plots/dist-high.eps'

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
    h=subplot(nx,ny,i);
    data=importdata(filenames{i});
    hist(data,100);
    set(findobj(gca, 'Type', 'patch'), {'FaceColor'}, {'black'}, {'EdgeColor'}, {'black'});
    axis([0 30 -inf inf]);
    set(gca, 'YTickLabel', []);
    if i <= 12 
        set(gca, 'XTickLabel', []);
    end
    if i > 12
        xlabel('M (Solar Mass)')
    end
    title(names{i});
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
    if i > 3
        xlabel('M (Solar Mass)');
    end
    set(gca, 'YTickLabel', []);
    if i <= 3
        set(gca, 'XTickLabel', []);
    end
    title(names{i});
end
print -deps '../../Paper/plots/high-masses.eps'

% Power-law Plots
curFig = curFig + 1;
figure(curFig);
data=importdata('power-law.mcmc');
subplot(2,1,1);
hist(data(:,1),50);
set(findobj(gca,'Type','patch'), 'FaceColor', 'none', 'EdgeColor', 'black', 'LineStyle', '--');
hold on
hist(data(:,2),200);
hold off
set(findobj(gca,'Type','patch'), 'FaceColor', 'none', 'EdgeColor', 'black');
xlabel('M (Solar Mass)');
set(gca, 'YTickLabel', []);
axis([0 15 -inf inf]);
legend('M_{min}', 'M_{max}');
subplot(2,1,2);
hist(data(:,3),100);
set(findobj(gca,'Type', 'patch'), 'FaceColor', 'none', 'EdgeColor', 'black');
xlabel('\alpha');
set(gca, 'YTickLabel', []);
print -deps '../../Paper/plots/power-law.eps'

% Power-law Plots (high-mass)
curFig = curFig + 1;
figure(curFig);
data=importdata('high-mass/power-law.mcmc');
subplot(2,1,1);
hist(data(:,1),30);
set(findobj(gca,'Type','patch'), 'FaceColor', 'none', 'EdgeColor', 'black', 'LineStyle', '--');
xlabel('M (Solar Mass)');
hold on
hist(data(:,2),100);
hold off
set(findobj(gca,'Type','patch'), 'FaceColor', 'none', 'EdgeColor', 'black');
set(gca, 'YTickLabel', []);
legend('M_{min}', 'M_{max}');
subplot(2,1,2);
hist(data(:,3),200);
set(findobj(gca,'Type','patch'), 'FaceColor', 'none', 'EdgeColor', 'black');
xlabel('\alpha');
set(gca, 'YTickLabel', []);
print -deps '../../Paper/plots/power-law-high.eps'

% Power-law 2D correlations
curFig=curFig+1;
figure(curFig);
data=importdata('power-law.mcmc');
nskip=30;
subplot(2,1,1);
scatter(data(1:nskip:end,1), data(1:nskip:end,3), '.k', 'SizeData', 1);
xlabel('M_{min} (Solar Mass)');
ylabel('\alpha');
subplot(2,1,2);
scatter(data(1:nskip:end,2), data(1:nskip:end,3), '.k', 'SizeData', 1);
xlabel('M_{max} (Solar Mass)');
ylabel('\alpha');
print -deps '../../Paper/plots/power-law-2D.eps'

% Parametric Mmin plots
curFig = curFig + 1;
figure(curFig);
files={'power-law.mcmc.bds'; 'exp-cutoff.mcmc.bds'; 
       'gaussian.mcmc.bds'; 'two-gaussian.mcmc.bds'; 'log-normal.mcmc.bds'; 
       'histogram-1bin.mcmc.bds'; 'histogram-2bin.mcmc.bds';
       'histogram-3bin.mcmc.bds'; 'histogram-4bin.mcmc.bds';
       'histogram-5bin.mcmc.bds'};
names={'Power Law'; 'Exponential'; 'Gaussian'; 'Two Gaussians'; 'Log Normal';
       'Histogram (1 Bin)'; 'Histogram (2 Bin)';
       'Histogram (3 Bin)'; 'Histogram (4 Bin)';
       'Histogram (5 Bin)'};
nx=4;
ny=3;
for i = 1:length(files)
    subplot(nx,ny,i);
    data=importdata(files{i});
    [ns,xout]=hist(data(:,1),100);
    bar(xout, ns);
    set(findobj(gca,'Type','patch'),'FaceColor','black','EdgeColor','black');
    axis([max(0,min(data(:,1))) inf -inf inf]);
    hold on
    x10=quantile(data(:,1),0.1);
    line([x10 x10], [0 max(ns)],'Color','black');
    hold off
    title(names{i});
    set(gca, 'YTickLabel', []);
    if i > 7
        xlabel('M_{1%} (Solar Mass)');
    end
end
print -deps '../../Paper/plots/mmin.eps'

% Mmin plots (high-mass)
curFig = curFig + 1;
figure(curFig);
files={'high-mass/power-law.mcmc.bds'; 'high-mass/exp-cutoff.mcmc.bds'; 
       'high-mass/gaussian.mcmc.bds'; 'high-mass/two-gaussian.mcmc.bds'; 'high-mass/log-normal.mcmc.bds';
       'high-mass/histogram-1bin.mcmc.bds'; 'high-mass/histogram-2bin.mcmc.bds';
       'high-mass/histogram-3bin.mcmc.bds'; 'high-mass/histogram-4bin.mcmc.bds';
       'high-mass/histogram-5bin.mcmc.bds'};
names={'Power Law'; 'Exponential'; 'Gaussian'; 'Two Gaussians'; 'Log Normal';
       'Histogram (1 Bin)'; 'Histogram (2 Bin)';
       'Histogram (3 Bin)'; 'Histogram (4 Bin)';
       'Histogram (5 Bin)'};
nx=4;
ny=3;
for i = 1:length(files)
    subplot(nx,ny,i);
    data=importdata(files{i});
    [ns,xout]=hist(data(:,1),100);
    bar(xout,ns);
    set(findobj(gca,'Type','patch'),'FaceColor','black','EdgeColor','black');
    axis([max(0,min(data(:,1))) inf -inf inf]);
    hold on
    x10=quantile(data(:,1),0.1);
    line([x10 x10], [0 max(ns)], 'Color', 'black');
    hold off
    title(names{i});
    set(gca, 'YTickLabel', []);
    if i > 7 
        xlabel('M_{1%} (Solar Mass)');
    end
end
print -deps '../../Paper/plots/mmin-high.eps'

% Exponential plots
curFig=curFig+1;
figure(curFig);
data=importdata('exp-cutoff.mcmc');
hist(data(:,2),100);
set(findobj(gca, 'Type', 'patch'), {'LineStyle'}, {'--'});
hold on
hist(data(:,1),100);
hold off
xlabel('M (Solar Mass)');
set(gca, 'YTickLabel', []);
axis([0 8 -inf inf]);
set(findobj(gca, 'Type', 'patch'), {'FaceColor'}, {'none'}, {'EdgeColor'}, {'black'});
legend('M_0', 'M_{min}');
print -deps '../../Paper/plots/exp-cutoff.eps'

% Exponential plots (high-mass)
curFig=curFig+1;
figure(curFig);
data=importdata('high-mass/exp-cutoff.mcmc');
subplot(2,1,1)
hist(data(:,1),100);
set(findobj(gca,'Type','patch'), 'FaceColor', 'none', 'EdgeColor', 'black');
xlabel('M_{min} (Solar Mass)');
set(gca,'YTickLabel', []);
subplot(2,1,2);
hist(data(:,2), 100);
set(findobj(gca,'Type','patch'), 'FaceColor', 'none', 'EdgeColor', 'black');
xlabel('M_0 (Solar Mass)');
set(gca,'YTickLabel', []);
print -deps '../../Paper/plots/exp-cutoff-high.eps'

% 2D Exponential Plots
curFig=curFig+1;
figure(curFig);
nskip=30;
data=importdata('exp-cutoff.mcmc');
scatter(data(1:nskip:end,1), data(1:nskip:end,2), '.k', 'SizeData', 1);
xlabel('M_{min} (Solar Mass)');
ylabel('M_0 (Solar Mass)');
print -deps '../../Paper/plots/exp-cutoff-2d.eps'

% High-Mass Exponential M_0 plots
curFig=curFig+1;
figure(curFig);
data=importdata('high-mass/exp-cutoff.mcmc');
subplot(2,1,1);
normalizedHist(data(:,1),100);
blackHistogram();
xlabel('M_{min} (Solar Mass)');
ylabel('dN/dM_{min}');
subplot(2,1,2);
normalizedHist(data(:,2),100);
blackHistogram();
xlabel('M_0 (Solar Mass)');
ylabel('dN/dM_0');
print -deps '../../Paper/plots/exp-cutoff-high.eps'

% Gaussian Mean, Sigma Plots.
curFig=curFig+1;
figure(curFig);
data=importdata('gaussian.mcmc');
hist(data(:,2), 50);
set(findobj(gca, 'Type', 'patch'), {'LineStyle'}, {'--'})
hold on
hist(data(:,1), 100);
hold off
xlabel('\mu, \sigma (Solar Mass)');
set(gca, 'YTickLabel', []);
set(findobj(gca, 'Type', 'patch'), {'FaceColor'}, {'none'}, {'EdgeColor'}, {'black'});
axis([0 10 -inf inf]);
legend('\sigma', '\mu');
print -deps '../../Paper/plots/gaussian.eps'

% Gaussian Mean, Sigma Plots (high-mass).
curFig=curFig+1;
figure(curFig);
data=importdata('high-mass/gaussian.mcmc');
hist(data(:,2), 50);
set(findobj(gca, 'Type', 'patch'), 'FaceColor', 'none', 'EdgeColor', 'black', 'LineStyle', '--');
hold on
hist(data(:,1), 75);
hold off
set(findobj(gca, 'Type', 'patch'), 'FaceColor', 'none', 'EdgeColor', 'black');
xlabel('\mu, \sigma (Solar Mass)');
set(gca, 'YTickLabel', []);
legend('\sigma', '\mu');
axis([0 14 -inf inf]);
print -deps '../../Paper/plots/gaussian-high.eps'

% Log Normal
curFig=curFig+1;
figure(curFig);
data=importdata('log-normal.mcmc');
normalizedHist(data(:,2), 100);
set(findobj(gca, 'Type', 'patch'), {'LineStyle'}, {'--'});
hold on
normalizedHist(data(:,1),100);
hold off
set(findobj(gca, 'Type', 'patch'), {'FaceColor'}, {'none'}, {'EdgeColor'}, {'black'});
xlabel('<M>, \sigma_M (Solar Mass)');
set(gca, 'YTickLabel', []);
axis([0 10 -inf inf]);
legend('\sigma_M', '<M>');
print -deps '../../Paper/plots/log-normal.eps'

% Log Normal (high-mass)
curFig=curFig+1;
figure(curFig);
data=importdata('high-mass/log-normal.mcmc');
hist(data(:,2),100);
set(findobj(gca,'Type','patch'),'FaceColor','none','EdgeColor','black','LineStyle','--');
xlabel('<M>, \sigma_M (Solar Mass)');
set(gca,'YTickLabel',[]);
hold on
hist(data(:,1),100);
hold off
set(findobj(gca,'Type','patch'),'FaceColor','none','EdgeColor','black');
legend('\sigma_M', '<M>');
print -deps '../../Paper/plots/log-normal-high.eps'

% Two Gaussian
curFig=curFig+1;
figure(curFig);
data=importdata('two-gaussian.mcmc');
nx=3;ny=1;
subplot(nx,ny,1);
hist(data(:,3),50);
set(findobj(gca, 'Type', 'patch'), {'LineStyle'}, {'--'});
hold on
hist(data(:,1),100);
hold off
axis([0 10 -inf inf])
xlabel('\mu_1, \sigma_1 (Solar Mass)');
set(gca, 'YTickLabel', []);
legend('\sigma_1', '\mu_1');
set(findobj(gca, 'Type', 'patch'), {'FaceColor'}, {'none'}, {'EdgeColor'}, {'black'})
subplot(nx,ny,2);
hist(data(:,4),50);
set(findobj(gca, 'Type', 'patch'), {'LineStyle'}, {'--'})
hold on
hist(data(:,2),100);
hold off
axis([0 15 -inf inf]);
xlabel('\mu_2, \sigma_2 (Solar Mass)');
set(findobj(gca, 'Type', 'patch'), {'FaceColor'}, {'none'}, {'EdgeColor'}, {'black'})
legend('\sigma_2', '\mu_2');
subplot(nx,ny,3);
hist(data(:,5),100);
set(findobj(gca, 'Type', 'patch'), {'FaceColor'}, {'none'}, {'EdgeColor'}, {'black'});
xlabel('\alpha');
print -deps '../../Paper/plots/two-gaussian.eps'

% Two Gaussian (high-mass)
curFig=curFig+1;
figure(curFig);
data=importdata('high-mass/two-gaussian.mcmc');
nx=3;ny=1;
subplot(nx,ny,1);
hist(data(:,3),75);
set(findobj(gca,'Type','patch'),'FaceColor','none','EdgeColor','black','LineStyle','--');
xlabel('\mu_1, \sigma_1 (Solar Mass)');
set(gca,'YTickLabel',[]);
hold on
hist(data(:,1),200);
hold off
set(findobj(gca,'Type','patch'),'FaceColor','none','EdgeColor','black');
legend('\sigma_1','\mu_1');
subplot(nx,ny,2);
hist(data(:,4),50);
set(findobj(gca,'Type','patch'),'FaceColor','none','EdgeColor','black','LineStyle','--');
hold on
hist(data(:,2),150);
hold off
set(findobj(gca,'Type','patch'),'FaceColor','none','EdgeColor','black');
xlabel('\mu_2, \sigma_2 (Solar Mass)');
set(gca,'YTickLabel',[]);
legend('\sigma_2','\mu_2');
subplot(nx,ny,3);
hist(data(:,5),100);
set(findobj(gca,'Type','patch'),'FaceColor','none','EdgeColor','black');
xlabel('\alpha');
set(gca,'YTickLabel',[]);
print -deps '../../Paper/plots/two-gaussian-high.eps'

% Reverse Jump Evidence
curFig = curFig + 1;
figure(curFig);
rjData=importdata('reversible-jump.dat');
xs=1:(length(rjData));
errorbar(xs, rjData(:,1), rjData(:,2),'+k')
hold on
h=bar(rjData(:,1));
hold off
set(h, 'EdgeColor', 'black', 'FaceColor', 'none');
axis([0.5 10.5 -inf inf]);
set(gca, 'XTickLabel', {'PL', 'E', 'G', 'TG', 'LN', 'H1', 'H2', 'H3', 'H4', 'H5'});
xlabel('Model');
ylabel('Relative Evidence');
print -deps '../../Paper/plots/rj.eps'

% High-mass Reverse Jump Evidence
curFig = curFig + 1;
figure(curFig);
rjData=importdata('high-mass/reversible-jump.dat');
xs=1:(length(rjData));
errorbar(xs, rjData(:,1), rjData(:,2), '+k');
hold on
h=bar(rjData(:,1));
hold off
set(h,'FaceColor','none','EdgeColor','black');
axis([0.5 10.5 -inf inf]);
set(gca, 'XTickLabel', {'PL', 'E', 'G', 'TG', 'LN', 'H1', 'H2', 'H3', 'H4', 'H5'});
xlabel('Model');
ylabel('Relative Probability');
print -deps '../../Paper/plots/rj-high.eps'
