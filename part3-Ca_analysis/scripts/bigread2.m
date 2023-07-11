function [imData,fileInfo]=bigread2(path_to_file,sframe,num2read)
%reads tiff files in Matlab bigger than 4GB, allows reading from sframe to sframe+num2read-1 frames of the tiff - in other words, you can read page 200-300 without rading in from page 1.
%based on a partial solution posted on Matlab Central (http://www.mathworks.com/matlabcentral/answers/108021-matlab-only-opens-first-frame-of-multi-page-tiff-stack)
%Darcy Peterka 2014, v1.0
%Darcy Peterka 2014, v1.1
%Darcy Peterka 2016, v1.2(bugs to dp2403@columbia.edu)
%Eftychios Pnevmatikakis 2016, v1.3 (added hdf5 support)
%Hammad Khan 2022, v1.4 (added scanimage support)
%Program checks for bit depth, whether int or float, and byte order.  Assumes uncompressed, non-negative (i.e. unsigned) data.
%
% Usage:  my_data=bigread('path_to_data_file, start frame, num to read);
% "my_data" will be your [M,N,frames] array.
%Will do mild error checking on the inputs - last two inputs are optional -
%if nargin == 2, then assumes second is number of frames to read, and
%starts at frame 1
 
[~,~,ext] = fileparts(path_to_file);
 
if strcmpi(ext,'.tiff') || strcmpi(ext,'.tif');
    
    %get image info
    info = imfinfo(path_to_file);
    
    % if ~isfield(info,'ImageDescription')
    %    blah=size(info);
    %    numFrames= blah(1);
    % else
    %     he=info.ImageDescription;
    %     numFramesStr = regexp(he, 'images=(\d*)', 'tokens');
    %     numFrames = str2double(numFramesStr{1}{1});
    % end
    
    
    %get image size
    stripOffset = info(1).StripOffsets;
    stripByteCounts = info(1).StripByteCounts;
    if length(info)<2
        Nframes=floor(info(1).FileSize/stripByteCounts);
    else
        Nframes=length(info);
    end
    %should add more error checking for args... very ugly code below.  works
    %for me after midnight though...
    if nargin<2
        sframe = 1;
    end
    if nargin<3
        num2read=Nframes-sframe+1;
    end
    if sframe<=0
        sframe=1;
    end
    if num2read<1
        num2read=1;
    end
    if sframe>Nframes
        sframe=Nframes;
        num2read=1;
        display('starting frame has to be less than number of total frames...');
    end
    if (num2read+sframe<= Nframes+1)
        lastframe=num2read+sframe-1;
    else
        num2read=numFrames-sframe+1;
        lastframe=Nframes;
        display('Hmmm...just reading from starting frame until the end');
    end
    
    
    bd=info.BitDepth;
    he=info.ByteOrder;
    bo=strcmp(he,'big-endian');
    if (bd==64)
        form='double';
    elseif(bd==32)
        form='single';
    elseif (bd==16)
        form='uint16';
    elseif (bd==8)
        form='uint8';
    end
    
    % Use low-level File I/O to read the file
    fp = fopen(path_to_file , 'r');
    % The StripOffsets field provides the offset to the first strip. Based on
    % the INFO for this file, each image consists of 1 strip.
    
    he=info.StripOffsets;
    %finds the offset of each strip in the movie.  Image does not have to have
    %uniform strips, but needs uniform bytes per strip/row.
    idss=max(size(info(1).StripOffsets));
    ofds=zeros(Nframes,1);
    start_point = stripOffset(1) + (0:1:(Nframes-1)).*stripByteCounts + 1;
    for i=1:Nframes
        ofds(i)=start_point(i);
        %ofds(i)
    end
    fprintf(['Reading from frame ',num2str(sframe),' to frame ',num2str(num2read+sframe-1),' of ',num2str(Nframes), ' total frames\n']);
    pause(.2)
    %go to start of first strip
    fseek(fp, start_point(1), 'bof');
    %framenum=numFrames;
    framenum=num2read;
    
    he_w=info.Width;
    he_h=info.Height;
    if (he_w && he_h >= 10), imData = zeros(he_h,he_w,framenum,form); end % build correct array for data type; Needs to change this for next update
    if (he_w && he_h < 10), imData = zeros(256,256,framenum,form); end % set interpolate array
    % mul is set to > 1 for debugging only
    mul=1;
    trunc = 0; %index for truncating data array
    if strcmpi(form,'uint16') || strcmpi(form,'uint8')
        if(bo)
            fprintf ('loading image ...\n');
            for cnt = sframe:lastframe
                lineLength = fprintf ('%d/%d', cnt,lastframe);
                %cnt;
                fseek(fp,ofds(cnt),'bof');
                tmp1 = fread(fp, [he_w he_h], form,'ieee-be')';
                if isempty(tmp1) %check to see if image is complete
                    trunc = trunc+1;
                else
                    if (he_w && he_h < 10) % upsample image to 256x256
                        % create interpolant
                        xg = 1:he_h;
                        yg = 1:he_w;
                        he_wScale= he_w/256;
                        he_hScale= he_h/256;
                        temp=cast(tmp1,form);
                        F = griddedInterpolant({xg,yg},single(temp));
                        xq = (0:he_hScale:he_h)';
                        yq = (0:he_wScale:he_w)';
                        vq = uint8(F({xq(xq>0),yq(yq>0)}));
                        imData(:,:,cnt-sframe+1) = vq;
                    else
                        imData(:,:,cnt-sframe+1)=cast(tmp1,form);
                        
                    end
                end
                fprintf(repmat('\b',1,lineLength));
                
            end
            % Now truncate imData based on trunc index
            imData = imData(:,:,1:(end-trunc)); %should now match imagej frame number
            fileInfo.FOV= size(imData);
            fileInfo.dataType = form;
        else
            for cnt=sframe:lastframe
                % cnt;
                fseek(fp,ofds(cnt),'bof');
                tmp1 = fread(fp, [he_w he_h*mul], form, 0, 'ieee-le')';
                imData{cnt-sframe+1}=cast(tmp1,form);
            end
        end
    elseif strcmpi(form,'single')
        if(bo)
            for cnt = sframe:lastframe
                %cnt;
                fseek(fp,ofds(cnt),'bof');
                tmp1 = fread(fp, [he_w he_h*mul], form, 0, 'ieee-be')';
                imData{cnt-sframe+1}=cast(tmp1,'single');
            end
        else
            for cnt = sframe:lastframe
                %cnt;
                fseek(fp,ofds(cnt),'bof');
                tmp1 = fread(fp, [he_w he_h*mul], form, 0, 'ieee-le')';
                imData{cnt-sframe+1}=cast(tmp1,'single');
            end
        end
    elseif strcmpi(form,'double')
        if(bo)
            for cnt = sframe:lastframe
                %cnt;
                fseek(fp,ofds(cnt),'bof');
                tmp1 = fread(fp, [he_w he_h*mul], form, 0, 'ieee-be.l64')';
                imData{cnt-sframe+1}=cast(tmp1,'single');
            end
        else
            for cnt = sframe:lastframe
                %cnt;
                fseek(fp,ofds(cnt),'bof');
                tmp1 = fread(fp, [he_w he_h*mul], form, 0, 'ieee-le.l64')';
                imData{cnt-sframe+1}=cast(tmp1,'single');
            end
        end
    end
    %ieee-le.l64
    fprintf ('\n');
    fprintf ('Done!\n');
    
    
    %     imData=cell2mat(imData);
    %     imData=reshape(imData,[he_h*mul,he_w,framenum]);
    fclose(fp);
elseif strcmpi(ext,'.hdf5') || strcmpi(ext,'.h5');
    info = hdf5info(path_to_file);
    dims = info.GroupHierarchy.Datasets.Dims;
    if nargin < 2
        sframe = 1;
    end
    if nargin < 3
        num2read = dims(end)-sframe+1;
    end
    num2read = min(num2read,dims(end)-sframe+1);
    imData = h5read(path_to_file,'/mov',[ones(1,length(dims)-1),sframe],[dims(1:end-1),num2read]);
else
    error('Unknown file extension. Only .tiff and .hdf5 files are currently supported');
end
