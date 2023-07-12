clear
dx=0.424;
dy=0.424;
dz=1.503;

input_folder = 'I:\Honours-Project\data\observed\obj\microsphere_50_hydrogel1_21';
input_folder = 'I:\Honours-Project\images\Final Presentation';
input_folder = 'I:\Honours-Project\data\yujie';
input_folder = 'I:\Honours-Project\data\full trombus data\2017.11.09\2';
input_folder = 'C:\Users\Duo\Desktop\image data';
input_folder = 'I:\Honours-Project\data\40x 0_70NA\02_09_2019';
%input_folder = 'I:\Honours-Project\data\simulation\obj';
output_folder = 'I:\Honours-Project\data\40x 0_70NA\02_09_2019\phase';
UP = dir(strcat(input_folder, '\*.tif'));

for index = 1:length(UP)
    %filename = UP(index).name;
    filename = 'NE00_NE10_f2.tif';
    %filename = '1-1.tif';
    %filename = 'hologram_original_cropped.tif';
    %filename = 'MATLAB_0003.avi_frame0.tif';
    input_dir = strcat(input_folder, '\', filename);
    [X,m] = imread(input_dir,1);
    %X=rgb2gray(X);
    %gray=load('test.mat');
    %X=gray.gray;
    %X=X(:,261:1000);
    tic;
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
    % csvwrite('height_r.csv',height_r);
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
    
    toc;
    
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