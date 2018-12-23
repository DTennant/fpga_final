clear 
clc

image_array = imread('santa.jpg');

[height,width,z]=size(image_array);   % 128*128*3


red   = image_array(:,:,1); 
green = image_array(:,:,2);
blue  = image_array(:,:,3);

r = uint32(reshape(red'   , 1 ,height*width));
g = uint32(reshape(green' , 1 ,height*width));
b = uint32(reshape(blue'  , 1 ,height*width));

rgb=zeros(1,height*width);

for i = 1:height*width
    rgb(i) = bitshift(bitshift(r(i),-4),8) + bitshift(bitshift(g(i),-4),4) + bitshift(bitshift(b(i),-4),0);
end

fid = fopen( 'santa.coe', 'w+' );

fprintf( fid, 'memory_initialization_radix=16;\n');

fprintf( fid, 'memory_initialization_vector =\n');

fprintf( fid, '%x,\n',rgb(1:end-1));

fprintf( fid, '%x;',rgb(end));

fclose( fid );