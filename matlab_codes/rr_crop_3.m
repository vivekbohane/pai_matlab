img_path = "D:\IITH_Files\PAI\comb_data\all\mcx_31_planarSlit\02_5cros5_width_11_length_384\Hlog_p3f250.png";
img = imread(img_path);

% crop from (615,245) to (1345,780)
img_cropped = img(245:780, 615:1352, :);





%% 

sourceFolder = "D:\IITH_Files\PAI\comb_data\all";

files = dir(fullfile(sourceFolder, '**', '*.png'));

for k = 1:length(files)

    [~, name, ext] = fileparts(files(k).name);

    % Skip images that already end with _crop
    if endsWith(name, '_crop')
        continue;
    end

    inputFile = fullfile(files(k).folder, files(k).name);

    img = imread(inputFile);

    croppedImg = img(245:780, 615:1352, :);

    outputFile = fullfile(files(k).folder, ...
                          [name '_crop' ext]);

    imwrite(croppedImg, outputFile);

    fprintf('Saved: %s\n', outputFile);
end





