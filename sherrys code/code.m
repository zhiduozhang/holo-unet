clear
dx=0.424;
dy=0.424;
dz=1.503;

input_folder = 'I:\Honours-Project\data\full trombus data\agg';
output_folder = 'I:\Honours-Project\data\test dataset\agg';
UP = dir(strcat(input_folder, '\*.tif'));

for index = 1:length(UP)
    %filename = UP(index).name;
    filename = 'c1.tif';
    input_dir = strcat(input_folder, '\', filename);
    [X,m] = imread(input_dir,1);
    X=rgb2gray(X);
    X=X(:,261:1000);
    [ phase, intensity, curve] = IP_sigle_hologram( X,0,1 );
    height=phase*dz;
    height_s= imfilter(height, fspecial('gaussian',[3*3+1 3*3+1],3));
    [imx,imy]=size(phase);
    height_r=height_s;
    height_r(height_r<0)=0;
    s_areatotal= imx*imy*dx*dy;
    %%
    bw1 = imbinarize(height_r);
    B = bwboundaries(bw1);
    smalls=round(sqrt(imx*imy)/40);
    bigs=round((imx*imy)/30);
    se= strel('disk',smalls);
    bw2 = imclose(bw1,se);
    bw3 = bwareaopen(bw2, bigs);
    %     bw3=imclearborder(bw3);
    s = regionprops(bw3);
    B = bwboundaries(bw3);
    height_remove=height_s.*bw3;
    csvwrite('height_r.csv',height_r);
    [count,w]=size(s);
    %     boundary=ones(:,:,count);
    if count ~=0
        for m=1:count
            box = s(m).BoundingBox;
            box(1)=round(box(1));
            box(2)=round(box(2));
            box(3)=floor(box(3));
            box(4)=floor(box(4));
            imagesub=height_remove(box(2):box(2)+box(4)-1,box(1):box(1)+box(3)-1);
            volume(m)=sum(sum(imagesub(:,:)))*dx*dy;
            height_peak(m)=max(max(imagesub(:,:)));
            area(m)=dx*dy*s(m).Area;
        end
    end
    %%
    
    figure1 = figure;
    axes1 =axes('Parent',figure1,'YDir','reverse','Layer','top','DataAspectRatio',[1 1 1]);
    %     box(axes1,'on');
    hold(axes1,'all');
    image(height_r,'Parent',axes1,'CDataMapping','scaled');
    axis tight;
    colorbar('peer',axes1);
    if count~=0
        hold on
        for m=1:count
            boundary=B{m};
            plot(boundary(:,2), boundary(:,1),'r', 'LineWidth', 1)%%
            hold on
        end
    end
    newname = strsplit(filename,'.');
    disp(newname{1})
    saveas(gcf,[output_folder,'\data\', newname{1},'Figure.png']);
    %close all
    save([output_folder,'\data\', newname{1},'heightmap.mat'],'height_r');
    xlswrite([output_folder,'\data\', newname{1},'data.xlsx'], volume','v');
    xlswrite([output_folder,'\data\', newname{1},'data.xlsx'], height_peak','p');
    xlswrite([output_folder,'\data\', newname{1},'data.xlsx'], area','area');
    clear volume height_peak area
end
%     endR