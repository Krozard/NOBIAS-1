function NOBIAS_stackbar(out, data)



c=colormap('lines');
pixel_size = 49;
raw_obs = data.obs * data.scale_factor * pixel_size ;
raw_displacements = sqrt(raw_obs(1,:).^2 + raw_obs(2,:).^2);
used_state = unique(out.reord_stateSeq);
figure;
hold on;

numBins = 20;

% Get the bin edges
edges = linspace(min(raw_displacements), max(raw_displacements), numBins+1);

% Initialize the matrix to store counts for each class
counts = zeros(numBins, 3);

% Count the number of elements in each bin for each class
for i = 1:length(used_state)
    state_disp= raw_displacements(out.reord_stateSeq == i);
    counts(:, i) = histcounts(state_disp, edges);
end

h = bar(edges(1:end-1) + diff(edges)/2, counts, 'stacked');

for i = 1:length(used_state)
    h(i).FaceColor = c(i, :);
end
legend('State 1', 'State 2', 'State 3');
title('Cumulative step displacement histogram by state');
xlabel('Displacement, nm');
ylabel('Occurance');
hold off


% Calculate the size of each batch
[uniqueTrIDs, ~, trIndices] =  unique(data.TrID);
trackSizes = accumarray(trIndices, 1);

% Find unique batch sizes
uniquetrackSizes = unique(trackSizes);

% Initialize the matrix to store counts for each class in each batch size
numtrackSizes = length(uniquetrackSizes);
numStates = length(unique(out.reord_stateSeq));
counts = zeros(numtrackSizes, numStates);

% Count the number of elements in each batch size for each class
for i = 1:numtrackSizes
    trackSize = uniquetrackSizes(i);
    trackIDsWithThisSize = uniqueTrIDs(trackSizes == trackSize);
    for j = 1:numStates
        counts(i, j) = sum(ismember(data.TrID, trackIDsWithThisSize) & (out.reord_stateSeq == j));
%         weightedCounts(i, j) = sum(ismember(data.TrID, trackIDsWithThisSize) & (out.reord_stateSeq == j)) * trackSize;
    end
end

% Plot the cumulative bar graph (stacked histogram)
figure;
h = bar(uniquetrackSizes, counts, 'stacked');
title('Cumulative Bar Graph by Track Length');
xlabel('Track Length');
ylabel('Occurance');


for i = 1:numStates
    h(i).FaceColor = c(i, :);
end
legend('State 1', 'State 2', 'State 3');

end
