function [ phase, intensity, curve] = IP_sigle_hologram( X,curve,showif )
% Summary of this function goes here
%   include all the image process for single hologram without digital-focus
cut=10;
[yy,xx]=size(X);
filterScaleFact = 0.51; % Filter scale factor (input from filter knob)
[centeredfft_sample,I2,I3,I4,boundary]= imgshapeiden( X,filterScaleFact );
if centeredfft_sample==0
    phase=0;
    intensity=0;
    curve=0;
    return
end

%% display
if showif==1
    figure;
    subplot(2,2,1)
    imagesc(X)
    colormap(gray);
    title('Hologram Image','FontSize',14);
    xlabel('(a)','FontSize',11) ;
    subplot(2,2,2)
    imagesc(I2)
    colormap(gray);
    hold on
    plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)%%
    hold off
    title('FFT Hologram Image','FontSize',14);
    xlabel('(b)','FontSize',11) ;
    subplot(2,2,3)
    imagesc(I3)
    colormap(gray);
    title('Filtered FFT Image','FontSize',14);
    xlabel('(c)','FontSize',11);
    subplot(2,2,4)
    imagesc(I4)
    colormap(gray);
    title('Centered Filtered FFT Image','FontSize',14);
    xlabel('(d)','FontSize',11) ;
end
%% ifft
centeredImage_s = ifft2(fftshift(centeredfft_sample));
%% unwrap the phase image
f=angle(centeredImage_s);
intensity=abs(centeredImage_s);
pp =double( Miguel_2D_unwrapper(single(f)));
if sum(curve(:))==0;
    pp=pp(cut:yy-cut,cut:xx-cut);
    intensity=intensity(cut:yy-cut,cut:xx-cut);
    [curve] = cruveremoval(pp);
    phase=pp-curve;
    csvwrite('pp.csv',pp);
    csvwrite('curve.csv',curve);
else
    pp=pp(cut:yy-cut,cut:xx-cut);
    phase=pp-curve;
    intensity=intensity(cut:yy-cut,cut:xx-cut);
end

