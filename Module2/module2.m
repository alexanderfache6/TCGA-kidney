%run this for all samples in data_augmented
% save as .csv

%run all python features
%save as .csv

% remove FAIL samples from PYTHON_FEATURES.CSV AND PYTHON_LABELS.CSV 
% 5193, 5194, 5195, 5196, 5197, 5198, 5205, 5206, 5207, 5208, 
% 5209, 5210, 5211, 5212, 5213, 5214, 5215, 5216, 5787, 5788, 
% 5789, 5790, 5791, 5792, 5967, 5968, 5969, 5970, 5971, 5972

% read in both csv
% merge into .npy
% MinMaxScaler(feature_range=[0, 1])
% FEATURES.npy
% LABELS.npy from Python

% another batch from PCA

% split randomly into train/test
% X_TRAIN.npy
% Y_TRAIN.npy
% X_TEST.npy
% Y_TEST.npy

clc
clear all
close all

w = warning ('off', 'all');

%%
imgpath = dir('..\data_augmented');
fprintf('Number of files: %d\n', length(imgpath));

FEATURES = [];
% TIME = [];
batch_size = 10;
FIRST_i = 5192; %1-5191 (5189)
LAST_i = length(imgpath);
FAIL = [];

%%
YES = 0;
NO = 0;
% t = cputime;
for i = FIRST_i:1:LAST_i
    
    features = [];
    if contains(imgpath(i).name, '.png')
        out = centroidandaxes(['..\data_augmented\', imgpath(i).name]);
        features = [features, size(out{1}, 1)];
        for j = [2:1:14, 20] %15 - pixels, 16 - cell structure, 17 - complex, 18 - single value, 19 - inf/NaN
            features = [features, mean(out{j}), var(out{j}), median(out{j}), mode(out{j})]; %only this four to eliminate inf/nan occurance
        end
        features = [features, out{18}];

        [~, radii] = hct(['..\data_augmented\', imgpath(i).name]);
        if size(radii, 1) == 0 || size(radii, 2) == 0
            features = [features, zeros(1, 5)];
        else
            features = [features, size(radii, 1), mean(radii), var(radii), median(radii), mode(radii)];
        end

        try
            FEATURES = [FEATURES; features];
        catch
            FAIL = [FAIL, i];
            fprintf('FAIL #%d\n', length(FAIL));
        end
        
        YES = YES + 1;
        
    else
        NO = NO + 1;
    end
    
    if mod(i, batch_size) == 0
        fprintf('i = %d\n', i);
%         TIME = [TIME, cputime - t];
%         t = cputime;
    end

end

fprintf('----\n');
fprintf('YES: %d\n', YES);
fprintf('NO: %d\n', NO);
fprintf('FAIL: %d\n', length(FAIL));
fprintf('FEATURES: %d x %d\n', size(FEATURES, 1), size(FEATURES, 2));
fprintf('FIRST i: %d\n', FIRST_i);
fprintf('LAST i: %d\n', LAST_i);
fprintf('inf: %d\n', sum(sum(isinf(FEATURES))));
fprintf('nan: %d\n', sum(sum(isnan(FEATURES))));
% fprintf('TIME = %.2f (min)\n', sum(TIME)/60);
fprintf('----\n');

%% PLOT TIME PER BATCH
% figure
% plot(1:1:size(TIME, 2), TIME)
% xlabel('batch #')
% ylabel('time per batch (sec)')
% saveas(gcf, ['time_', num2str(FIRST_i), '_', num2str(LAST_i), '.png'])

%% SAVE TO CSV FILE
dlmwrite('MATLAB_FEATURES_UPDATE.csv', FEATURES, 'delimiter', ',', '-append');

%% FEAYESURE EXYESRACYESORS
function [out] = centroidandaxes(img)
    a = imread(img);
    
    graysc = rgb2gray(a);
    bw = graysc < 110;
%     figure
%     imshow(bw)
%     sum(sum(bw)); %BREAKS IF THIS IS 0!!!! INCREASED TRESHOLD 100 -- > 110
    stats = regionprops('table', bw, graysc, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity', 'Orientation', ...
        'Perimeter', 'EquivDiameter', 'Solidity', 'ConvexArea', 'Area', 'FilledArea', 'Extent', ...
        'MaxIntensity', 'MeanIntensity', 'MinIntensity', 'PixelValues');    
    %stats2 = regionprops('table', bw, graysc, 'MaxIntensity', 'MeanIntensity', 'MinIntensity', 'PixelValues');
    convexdeficiency = (stats.ConvexArea - stats.Area) ./ stats.Area;
    pfft = fft(stats.Perimeter, 1024);
    sphericity = min(stats.EquivDiameter) ./ max(stats.EquivDiameter/2);
    compactness = 4*pi*stats.Area ./ stats.Perimeter.^2;
    centroid = stats.Centroid;
    MAL = stats.MajorAxisLength;
    MinAL = stats.MinorAxisLength; 
    ecc = stats.Eccentricity; 
    ori = stats.Orientation;
    per = stats.Perimeter; 
    eqd = stats.EquivDiameter; 
    sol = stats.Solidity;
    cva = stats.ConvexArea;
    area = stats.Area;
    farea = stats.FilledArea; 
    ext = stats.Extent; 
    maxin = stats.MaxIntensity; 
    meanin = stats.MeanIntensity;
    minin = stats.MinIntensity; 
    pix = stats.PixelValues;
    out = {centroid, MAL, MinAL, ecc, ori, per, eqd, sol, cva, area, farea, ext, double(maxin), double(minin), meanin, pix, pfft, sphericity, compactness, convexdeficiency};
end

function [centers, radii] = hct(image)
    [centers, radii] = imfindcircles(imread(image), [4, 18]);    
end