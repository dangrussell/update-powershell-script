@{
    colors  = @{
        banner    = "DarkMagenta";
        section   = "DarkRed";
        status    = "Red";
        highlight = "Cyan";
    };

    verbose = @{
        all           = $false; # Set to `$true` to turn on verbosity for all sections
        #region Sections that use verbosity
        WSL           = $false;
        Chocolatey    = $false; # Chocolatey verbosity isn't very useful
        Winget        = $true;
        PowerShellGet = $true;
        MSStore       = $false; # MSStore verbosity isn't very useful
        ncu           = $false; # ncu verbosity isn't very useful
        # skills        = $false; # underlying command doesn't have an option for verbose output
        WindowsUpdate = $true;
        # ChocoCleaner  = $false; # underlying command doesn't have an option for verbose output
        npmcache      = $true;
        yarncache     = $false;
        # dotnetcache   = $false; # underlying command doesn't have an option for verbose output
        #endregion Sections that use verbosity
    };

    run     = @{
        all           = $false; # Set to `$true` to run all sections
        #region Runnable sections
        WSL           = $false;
        Chocolatey    = $true;
        Winget        = $false;
        PowerShellGet = $false;
        MSStore       = $true;
        ncu           = $true;
        skills        = $true;
        WindowsUpdate = $true;
        ChocoCleaner  = $true;
        npmcache      = $false;
        yarncache     = $false;
        dotnetcache   = $false;
        #endregion Runnable sections
    };
}
