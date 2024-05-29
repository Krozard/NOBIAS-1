function NOBIAS_stepscatter(out, data)

c=colormap('lines');
pixel_size = 49;
raw_obs = data.obs * data.scale_factor * pixel_size ;
raw_displacements = sqrt(raw_obs(1,:).^2 + raw_obs(2,:).^2);
used_state = unique(out.reord_stateSeq);
figure;
hold on;
jitterAmount = 0.5; % Adjust as needed
jitter = (rand(size(out.reord_stateSeq)) - 0.5) * jitterAmount;

figure;
hold on
for i=1:length(used_state)
    index = out.reord_stateSeq == i;
    scatter(out.reord_stateSeq(index) + jitter(index), raw_displacements(index), 5,c(i,:),'filled',...
        'MarkerFaceAlpha', sum(index)/length(raw_displacements));
end
title('Step Displacement by diffusive states');
xticks(used_state);
xticklabels(arrayfun(@num2str , used_state, 'UniformOutput', false));
ylabel('Displacement, nm')
set(gca,'yscale','log')
ylim([10 1000])

end