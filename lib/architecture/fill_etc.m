function etc = fill_etc(etc_opts)
etc.is_waitbar_shown = default(etc_opts, 'is_waitbar_shown', false);
if etc.is_waitbar_shown
    etc.is_waitbar_docked = default(etc_opts, 'is_waitbar_docked', false);
end
end