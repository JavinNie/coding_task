function locreal=locrealread(filename)
fid=fopen(filename,'rt');
fgetl(fid);
fgetl(fid);
while(~feof(fid))
    res=fgetl(fid);
    if (length(res)>=4)
        [res2]=sscanf(res,'%d:%d %d %d');
        locreal(res2(1),:)=res2(2:4);
    end
end
fclose(fid);