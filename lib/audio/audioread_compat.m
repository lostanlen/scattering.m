function [y,Fs] = audioread_compat(file_path,samples,dataType)
% Read audio file (backwards-compatible with version < 2014a)
switch nargin
    case 1
        try
            [y,Fs] = audioread(file_path);
        catch message;
            if strcmp(message,'MATLAB:UndefinedFunction')
                [y,Fs] = wavread(file_path);
            else
                throw(message);
            end
        end
    case 2
        try
            [y,Fs] = audioread(file_path,samples);
        catch message;
            if strcmp(message,'MATLAB:UndefinedFunction')
                [y,Fs] = wavread(file_path,samples);
            else
                throw(message);
            end
        end
    case 3
        try
            [y,Fs] = audioread(file_path,samples,dataType);
        catch message;
            if strcmp(message,'MATLAB:UndefinedFunction')
                [y,Fs] = wavread(file_path,samples,dataType);
            else
                throw(message);
            end
        end
end
end
