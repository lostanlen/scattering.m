function percent = parfor_progress(N)
narginchk(0, 1);

if nargin < 1
    N = -1;
end

percent = 0;
w = 50; % Width of progress bar

if N > 0
    f = fopen('parfor_progress.txt', 'w');
    if f<0
        error('Do you have write permissions for %s?', pwd);
    end
    fprintf(f, '%d\n', N); % Save N at the top of progress.txt
    fclose(f);
    
    if nargout == 0
        disp(['  0%[>', repmat(' ', 1, w), ']']);
    end
elseif N == 0
    delete('parfor_progress.txt');
    percent = 100;
    
    if nargout == 0
        disp([repmat(char(8), 1, (w+9)), char(10), '100%[', ...
            repmat('=', 1, w+1), ']']);
    end
else
    if ~exist('parfor_progress.txt', 'file')
        error(['parfor_progress.txt not found. ', ...
            'Run PARFOR_PROGRESS(N) before PARFOR_PROGRESS to initialize', ...
            'parfor_progress.txt.']);
    end
    
    f = fopen('parfor_progress.txt', 'a');
    fprintf(f, '1\n');
    fclose(f);
    
    f = fopen('parfor_progress.txt', 'r');
    progress = fscanf(f, '%d');
    fclose(f);
    percent = (length(progress)-1)/progress(1)*100;
    
    if nargout == 0
        perc = sprintf('%3.0f%%', percent); % 4 characters wide, percentage
        disp([repmat(char(8), 1, (w+9)), char(10), perc, '[', ...
            repmat('=', 1, round(percent*w/100)), '>', ...
            repmat(' ', 1, w - round(percent*w/100)), ']']);
    end
end
