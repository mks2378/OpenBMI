function [out] = prep_addFeatures(cell_dat, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PREP_ADDFEATRUES - Add features to the former data from the latter datas
% prep_addFeatures (Pre-processing procedure):
%
% Synopsis:
%     [out] = prep_addChannels(DAT1, DAT2)
%     [out] = prep_addChannels({DAT1, DAT2, DAT3, ...})
%
% Example :
%     out = prep_addTrials(dat1, dat2)
%     out = prep_addTrials({dat1, dat2, dat3, dat4, ...})
%
% Arguments:
%     dat1 - Data structure, only continuous
%     dat2 - Data structure to be added to dat1
%
% Returns:
%     out - Append trials to the original data structure (only continuous) 
%
% Description:
%     This function append trials to the former data from the latter data
%     continuous data should be [time * channels]
%
% See also 'https://github.com/PatternRecognition/OpenBMI'
% Seon Min Kim, 04-2016
% seonmin5055@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(varargin)
    if all(cellfun(@isstruct, {cell_dat, varargin{1}}))
        cell_dat = {cell_dat, varargin{1}};
    else
        error('OpenBMI: prep_addFeatures should be specified in a correct form');
    end
end

if ~all(cellfun(@(x) all(isfield(x, {'t', 'fs', 'chan', 'x'})), cell_dat))
    error('OpenBMI: Data structure must have a field named ''t'', ''fs'', ''chan'', and ''x''');
end

out = cell_dat{1};

if ~all(cellfun(@(x) isequal(cell_dat{1}.chan, x.chan), cell_dat))
    warning('OpenBMI: Check channels configurations');
    return
end

if ~all(cellfun(@(x) isequal(cell_dat{1}.fs, x.fs), cell_dat))
    warning('OpenBMI: Check sampling frequencies of your data');
    return
end

if all(cellfun(@(x) ndims(x.x), cell_dat) == 2)
    for i = 2:length(cell_dat)
        out.x = cat(1, out.x, cell_dat{i}.x);
    end
else    
    warning('OpenBMI: Unmatched data dimensions (Epoched or continuous)')
    return
end

if all(cellfun(@(x) isfield(x, 't'), cell_dat))
    for i = 2:length(cell_dat)
        out.t = cat(2, out.t, cell_dat{i}.t + size(out.x,1));
    end
else
    warning('OpenBMI: Time information');   
end

if all(cellfun(@(x) all(isfield(x, {'class', 'y_logic', 'y_dec', 'y_class'})), cell_dat))
    for i = 2:length(cell_dat)
        cls = ~ismember(cell_dat{i}.class(:,2), out.class(:,2));
        out.class = cat(1, out.class, cell_dat{i}.class(cls,:));
        out.y_class = cat(2, out.y_class, cell_dat{i}.y_class);
        out.y_dec = cat(2, out.y_dec, cell_dat{i}.y_dec);
    end
    out.y_logic = [];
    for i = 1:size(out.class,1)    
        out.y_logic = [out.y_logic; ismember(out.y_class, out.class(i,2))];
    end
else
    warning('OpenBMI: Class informations are missed');   
end

out = opt_history(out, mfilename);
end