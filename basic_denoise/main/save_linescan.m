
%% save branch
data_branch.raw_f = b_raw_f;
data_branch.raw_df = b_raw_df;
data_branch.denoise_f = b_raw_f_denoise;
data_branch.s_raw_df_denoise = b_raw_df_denoise;
data_branch.filt_df = b_filt_df_denoise;

%% save spine
data_spine.raw_f = s_raw_f;
data_spine.raw_df = s_raw_df;
data_spine.denoise_f = s_raw_f_denoise;
data_spine.s_raw_df_denoise = s_raw_df_denoise;
data_spine.filt_df = s_filt_df_denoise;

save(fullfile(foldername, sprintf('data_%s.mat', filename(1:end-3))), 'data_spine', 'data_branch', 'dt', 't');
