function [xpts, ypts, counts] = hist3d( xs,ys,data )
    % hist3d: 3D Histograms.
    
    counts = zeros(length(ys)-1, length(xs)-1);
    N=size(data,1);

    % Horrible: For loop.
    for i = 1:length(xs)-1
        xmin=xs(i);
        xmax=xs(i+1);
        for j = 1:length(ys)-1
            ymin=ys(j);
            ymax=ys(j+1);
            counts(j,i) = sum((xmin <= data(:,1)) & (xmax > data(:,1)) & (ymin <= data(:,2)) & (ymax > data(:,2)))/((xmax-xmin)*(ymax-ymin)*N);
        end
    end
    
    xpts=0.5*(xs(1:end-1) + xs(2:end));
    ypts=0.5*(ys(1:end-1) + ys(2:end));

    surf(xpts, ypts, counts)
end

