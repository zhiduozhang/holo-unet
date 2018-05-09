
function [centeredfft,fftMagIm,I3,I5,boundary]= imgshapeiden(X,filterScaleFact )

[imx,imy] = size(X); % X and Y dimensions of the input image
% filterRad = floor((sqrt((imy*0.8)^2+(imx*0.8)^2)/2)*...
%     filterScaleFact);
ccdImfft = fftshift(fft2(X));
fftMagIm = log(abs(ccdImfft)+1);
fftMagIm= (fftMagIm - min(min(fftMagIm)))/(max(max(fftMagIm))-min(min(fftMagIm)));
sigma=5;
I_eq = imfilter(fftMagIm, fspecial('gaussian',[sigma*3+1 sigma*3+1],sigma));
level=graythresh(I_eq); %% Get the global thresh level
% disp(level)
% bw = im2bw(I_eq, level+0.05);
% smalls=round((imx/20)*(imy/20)); %% set the dimension of small objective needed to be removed
smalls=round((imx/25)*(imy/25));
bigs=round((imx/2.5)*(imy/2.5));
iy=1;  %% number of objects
inc=0; %% thresholding increasement
stp=level/100;% thresh level increment

while iy~=3
    bw = imbinarize(I_eq, level+inc);
    bw4 = bwareaopen(bw, smalls);
    s = regionprops(bw4);
    [iy,ix]=size(s);
    if iy==3
        area=[s(1,1).Area,s(2,1).Area,s(3,1).Area];
        if max(area)>bigs
            iy=1;
        end
    end
    inc=inc+stp;
    if inc>=1-level
        centeredfft=0;
        fftMagIm=0;
        I3=0;
        I5=0;
        boundary=0;
        return
    end
    
end
B = bwboundaries(bw4);
s_Image = regionprops(bw4,'Image');
%%
po1=s(1).Centroid;
poz1=abs(po1(1))+abs(po1(2));
cen1=abs(abs(po1(1))-abs(po1(2)));
po2=s(2).Centroid;
poz2=abs(po2(1))+abs(po2(2));
cen2=abs(abs(po2(1))-abs(po2(2)));
po3=s(3).Centroid;
poz3=abs(po3(1))+abs(po3(2));
cen3=abs(abs(po3(1))-abs(po3(2)));
[Maxx,which] = max([poz1,poz2,poz3]);
% [Maxxx,whichcen] = min([cen1,cen2,cen3]);
%%
% coverbox= round(s(whichcen).BoundingBox);
% cover_image=zeros(imx,imy);
% cover_image(coverbox(2):coverbox(2)+coverbox(4)-1, ...
%     coverbox(1):coverbox(1)+coverbox(3)-1) = s_Image(whichcen).Image;
% cover_image=~cover_image;
% cover_image=cover_image.*I_eq;
% mm=max(cover_image(:,round(imy/2)))
% I_eq2 = imfilter(cover_image, fspecial('gaussian',[2*3+1 2*3+1],2));
% test=median(cover_image);
% M = median(test);
% cover_image(cover_image<M)=M;
% %%
% bw = imbinarize(cover_image,mm-0.002);
% bw4 = bwareaopen(bw, smalls);
% cover_image= (cover_image - min(min(cover_image)))/(max(max(cover_image))-min(min(cover_image)));
BoundingBox = s(which).BoundingBox;
boundary = B{which};
po=s(which).Centroid;
% Image_m=s_Image(which).Image;
% slightly increase the bounding box
%%
halfx=abs(BoundingBox(1)-po(1));
halfy=abs(BoundingBox(2)-po(2));
halfacux=BoundingBox(3)/2;
halfacuy=BoundingBox(4)/2;
if halfx>halfacux
    BoundingBox(3)=halfx*2;
else
    BoundingBox(1)=po(1)-halfx;
end
if halfy>halfacuy
    BoundingBox(4)=halfy*2;
else
    BoundingBox(2)=po(2)-halfy;
end
%%
% amount = inc+0.3;
%  BoundingBox(1:2) = BoundingBox(1:2) - BoundingBox(3:4)*(amount/2);
%  BoundingBox(3:4) = BoundingBox(3:4) + BoundingBox(3:4)*(amount);
BoundingBox = floor(BoundingBox);
%%
% create a mask
mask = zeros(imx,imy);
% mask(BoundingBox(2):BoundingBox(2)+BoundingBox(4)-1, ...
%     BoundingBox(1):BoundingBox(1)+BoundingBox(3)-1) = Image_m;
% mask=mask.*bw4;
mask(BoundingBox(2):BoundingBox(2)+BoundingBox(4)-1, ...
    BoundingBox(1):BoundingBox(1)+BoundingBox(3)-1) = 1;
% mask=mask.*bw4;
% mask = bwareaopen(mask, smalls);
% figure, imshow(mask)

% create a mask
I3=fftMagIm.*mask;
ccdImfft=ccdImfft.*mask;
centeredfft = zeros(imx,imy);
BoundingBox2 = BoundingBox;


BoundingBox2(1) = round(imy/2 - abs(po(1)-BoundingBox2(1)));
BoundingBox2(2) = round(imx/2 - abs(po(2)-BoundingBox2(2)));
Window = ccdImfft(BoundingBox(2):BoundingBox(2)+BoundingBox(4)-1, ...
    BoundingBox(1):BoundingBox(1)+BoundingBox(3)-1);
centeredfft(BoundingBox2(2):BoundingBox2(2)+BoundingBox2(4)-1, ...
    BoundingBox2(1):BoundingBox2(1)+BoundingBox2(3)-1) = Window;
% figure, imshow(I4)
Window1 = I3(BoundingBox(2):BoundingBox(2)+BoundingBox(4)-1, ...
    BoundingBox(1):BoundingBox(1)+BoundingBox(3)-1);
I5=zeros(imx,imy);
I5(BoundingBox2(2):BoundingBox2(2)+BoundingBox2(4)-1, ...
    BoundingBox2(1):BoundingBox2(1)+BoundingBox2(3)-1) = Window1;

% figure, imshow(I5)
end
%
% function [centeredfft,fftMagIm,I3,I5,boundary]= imgshapeiden(X,filterScaleFact )
%
% [imx,imy] = size(X); % X and Y dimensions of the input image
% % filterRad = floor((sqrt((imy*0.8)^2+(imx*0.8)^2)/2)*...
% %     filterScaleFact);
% ccdImfft = fftshift(fft2(X));
% fftMagIm = log(abs(ccdImfft)+1);
% fftMagIm= (fftMagIm - min(min(fftMagIm)))/(max(max(fftMagIm))-min(min(fftMagIm)));
% sigma=4;
% I_eq = imfilter(fftMagIm, fspecial('gaussian',[sigma*3+1 sigma*3+1],sigma));
% level=graythresh(I_eq); %% Get the global thresh level
% % disp(level)
% % bw = im2bw(I_eq, level+0.05);
% % smalls=round((imx/20)*(imy/20)); %% set the dimension of small objective needed to be removed
% smalls=round((imx/35)*(imy/35));
% bigs=round((imx/1.3)*(imy/1.3));
% iy=1;  %% number of objects
% inc=0; %% thresholding increasement
% stp=level/100;% thresh level increment
%
% while iy~=3
% bw = imbinarize(I_eq, level+inc);
% bw4 = bwareaopen(bw, smalls);
% s = regionprops(bw4);
% [iy,ix]=size(s);
% if iy==3
%     area=[s(1,1).Area,s(2,1).Area,s(3,1).Area];
%     if max(area)>bigs
%         iy=1;
%     end
% end
%     inc=inc+stp;
%     if inc>=0.03
%         centeredfft=0;
%         fftMagIm=0;
%         I3=0;
%         I5=0;
%         boundary=0;
%         return
%     end
%
% end
% po1=s(1).Centroid;
% poz1=abs(abs(imy/2-po1(1))+abs(imx/2-po1(2)));
% po2=s(2).Centroid;
% poz2=abs(abs(imy/2-po2(1))+abs(imx/2-po2(2)));
% B = bwboundaries(bw4);
% s_Image = regionprops(bw4,'Image');
% if poz1>poz2
% BoundingBox = s(3).BoundingBox;
% boundary = B{3};
% Image_m=s_Image(3).Image;
% else
%     BoundingBox = s(3).BoundingBox;
%     boundary = B{3};
%     Image_m=s_Image(3).Image;
% end
% % slightly increase the bounding box
% % amount = inc+0.1;
% % BoundingBox(1:2) = BoundingBox(1:2) - BoundingBox(3:4)*(amount/2);
% % BoundingBox(3:4) = BoundingBox(3:4) + BoundingBox(3:4)*(amount);
%  BoundingBox = round(BoundingBox);
%
% % create a mask
% mask = zeros(imx,imy);
% mask(BoundingBox(2):BoundingBox(2)+BoundingBox(4)-1, ...
%     BoundingBox(1):BoundingBox(1)+BoundingBox(3)-1) = Image_m;
% mask=mask.*bw4;
% % mask = bwareaopen(mask, smalls);
% % figure, imshow(mask)
%
% % create a mask
% I3=fftMagIm.*mask;
% ccdImfft=ccdImfft.*mask;
% centeredfft = zeros(imx,imy);
% BoundingBox2 = BoundingBox;
% BoundingBox2(1) = round(imy/2 - BoundingBox2(3)/2);
% BoundingBox2(2) = round(imx/2 - BoundingBox2(4)/2);
% Window = ccdImfft(BoundingBox(2):BoundingBox(2)+BoundingBox(4), ...
%             BoundingBox(1):BoundingBox(1)+BoundingBox(3));
% centeredfft(BoundingBox2(2):BoundingBox2(2)+BoundingBox2(4), ...
%    BoundingBox2(1):BoundingBox2(1)+BoundingBox2(3)) = Window;
% % figure, imshow(I4)
% Window1 = I3(BoundingBox(2):BoundingBox(2)+BoundingBox(4), ...
%             BoundingBox(1):BoundingBox(1)+BoundingBox(3));
% I5=zeros(imx,imy);
% I5(BoundingBox2(2):BoundingBox2(2)+BoundingBox2(4), ...
%    BoundingBox2(1):BoundingBox2(1)+BoundingBox2(3)) = Window1;
%
% % figure, imshow(I5)
% end