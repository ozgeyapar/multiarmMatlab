function CheckandCreateDir( foldertosave )
%CHECKANDCREATEDIR Summary of this function goes here
%   Detailed explanation goes here
    if ~exist(foldertosave, 'dir')
       mkdir(foldertosave)
    end
end

