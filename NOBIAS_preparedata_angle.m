function data=NOBIAS_preparedata_angle(AllTracks)
% input All tracks is a N by 1 cell array, where each element of the cell
% array is a tracectories with at least 4 colmns, where the 2nd columns
% should correspond to the frame of the tracks (gaps are allowed and 
% should be pre-filtered in tracking step to avoid too huge gaps), the 3rd
% and 4th columns should be the rows and columns of the 2D tracks
% coordinates, pay attention to x-y and row-col difference.

TrID=[];
All_steps={};
All_corrstep={};
All_corrstep_angle = {};
min_length=3;
for i=1:length(AllTracks)
    temptr=AllTracks{i};
    fixedTrack = nan(max(temptr(:,2)),size(temptr,2));
    fixedTrack(temptr(:,2),:) = temptr;
    fixedTrack(1:find(all(isnan(fixedTrack),2)==0,1,'first')-1,:)=[];
    tempstep=fixedTrack(2:end,[4,3])-fixedTrack(1:end-1,[4,3]);
    tempcorrstep=[tempstep(1:end-1,:).*tempstep(2:end,:); nan, nan];
    temp_angle = get_steps_angle(tempstep);
    gapsID=(~isnan(tempstep(:,1)))&(~isnan(tempstep(:,2)));
    tempstep=tempstep(~isnan(tempstep(:,1)),:);
    tempstep=tempstep(~isnan(tempstep(:,2)),:);
    tempcorrstep=tempcorrstep(gapsID,:);
    temp_angle = temp_angle(gapsID);
    if size(tempstep,1)>min_length
        All_steps{end+1}=tempstep;
        All_corrstep{end+1}=tempcorrstep;
        All_corrstep_angle{end+1} = temp_angle;
    end
end
for i=1:length(All_steps)
    TrID=[TrID, ones(1,size(All_steps{i},1))*i];
end
data.obs=cat(1,All_steps{:})';
data.TrID=TrID;
data.obs_corr=cat(1,All_corrstep{:})'; %not needed if motion blur correction not wanted
data.obs_angle = cat(1,All_corrstep_angle{:})';
% scale data to certain varience
data = NOBIAS_scale_data(data);
end

function angle = get_steps_angle(vectors)
    angle = zeros(length(vectors),1);
    for i=1:length(vectors)-1
        vector1=vectors(i,:);
        vector2=vectors(i+1,:);
        dot_product = dot(vector1, vector2);
        magnitude_product = norm(vector1) * norm(vector2);
    if abs(dot_product / magnitude_product) > 1
        angle(i) = NaN;  % Invalid input, return NaN
    else
        % Calculate the angle in radians
        angle_rad = acos(dot_product / magnitude_product);
        
        % Convert the angle to degrees
        angle(i) = rad2deg(angle_rad);

    end
    end
    angle(end)=nan;
end