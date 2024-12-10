clc
close all

% 设置基本目录
base_dir = './datasets/ipol/';

in_dir = 'images_clean';
out_dir = 'images_combined';
noise_file = fullfile(base_dir, '10.jpg');

noise_out_np_file = fullfile(base_dir, 'noise_combined.mat');
noise_out_img_file = fullfile(base_dir, 'noise_combined.png');

a=imread(noise_file);
a=im2gray(a);
[m,n,c]=size(a);
shape = [m, n];

% 主函数
create_image_noise('fpn', noise_file, shape); % 将 noise_file 和 shape 作为参数传递

% 创建低频噪声
function noise = create_low_frequency_noise(noise_file, shape, lf_max_strength)
    % 假设噪声是从文件中读取的，或生成的低频噪声
    % 这里只是一个示例，具体噪声的生成方式要根据需求修改
    noise = rand(shape) * lf_max_strength; % 生成低频噪声
end
% 创建列条纹噪声
function noise = create_column_strip(random_generator, shape, sigma_white, sigma_strip)
    white_noise = rand(shape) * sigma_white;  % 使用 rand 生成白噪声
    strip_column = rand([1, shape(2)]) * sigma_strip;  % 生成列条纹噪声
    strip = repmat(strip_column, shape(1), 1);
    noise = strip + white_noise;
end


% 创建随机噪声并保存图像
function create_image_noise(noise_type, noise_file, shape)
    rng(1998); % 设置随机数种子，确保生成的噪声可复现
    sigma_white = 0.01; % 白噪声的标准差
    sigma_strip = 0.05; % 列条纹噪声的标准差
    lf_max_strength = 0.04; % 低频噪声的最大强度
    image_strength = 0.01; % 最终图像噪声强度

    % 根据噪声类型生成不同的噪声
    if strcmp(noise_type, 'lpn')  % 低频噪声
        noise = create_low_frequency_noise(noise_file, shape, lf_max_strength);
    elseif strcmp(noise_type, 'fpn')  % 列条纹噪声
        random_generator = rng; % 使用随机数生成器
        noise = create_column_strip(random_generator, shape, sigma_white, sigma_strip);
    elseif strcmp(noise_type, 'combined')  % 组合噪声（低频 + 列条纹噪声）
        noise_lf = create_low_frequency_noise(noise_file, shape, lf_max_strength);
        random_generator = rng; % 使用随机数生成器
        noise_fpn = create_column_strip(random_generator, shape, sigma_white, sigma_strip);
        noise = noise_lf + noise_fpn;  % 组合噪声
    else
        disp(['Noise type ', noise_type, ' is not supported']);
        return;
    end

    % 展示噪声图像
    figure;
    imshow(noise, []);

    % 设置输入图像和输出文件夹路径
    base_dir = 'path_to_your_base_directory';  % 替换为实际路径
    in_dir = 'input_images';  % 输入图像文件夹
    out_dir = 'output_images';  % 输出图像文件夹

    % 获取输入图像文件夹中的所有图像文件
    files = dir(fullfile(base_dir, in_dir, '*.jpg')); % 获取所有 JPG 文件
    
    for i = 1:length(files)
        file_path = fullfile(base_dir, in_dir, files(i).name);
        image = imread(file_path);
        image = double(image) / 255 * image_strength; % 归一化图像并调整强度
        image = image + noise;  % 添加噪声
        
        % 处理图像溢出（确保像素值在 [0, 1] 范围内）
        image(image > 1) = 1;
        image = image / max(image(:)); % 归一化到 [0, 1]
        image = uint8(image * 255); % 转换为 uint8 类型
        
        % 保存图像
        imwrite(image, fullfile(base_dir, out_dir, files(i).name));
        fprintf('%s overflow count: %d!\n', file_path, sum(image(:) > 255));  % 输出溢出像素的计数
    end
end
