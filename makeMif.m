fid = fopen("AllWaves.hex");
A = fread(fid,Inf,'uint16');


B = 0:32767;
B = B';

ab = [B A];

fclose(fid);