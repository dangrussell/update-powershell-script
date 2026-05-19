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
        WSL           = $true;
        Chocolatey    = $false; # Chocolatey verbosity isn't very useful
        Winget        = $true;
        PowerShellGet = $true;
        MSStore       = $true;
        ncu           = $false; # ncu verbosity isn't very useful
        WindowsUpdate = $true;
        npmcache      = $true;
        yarncache     = $false;
        #endregion Sections that use verbosity
    };

    run     = @{
        all           = $false; # Set to `$true` to run all sections
        #region Runnable sections
        WSL           = $true;
        Chocolatey    = $true;
        Winget        = $false;
        PowerShellGet = $false;
        MSStore       = $true;
        ncu           = $true;
        WindowsUpdate = $true;
        ChocoCleaner  = $true;
        npmcache      = $false;
        yarncache     = $false;
        dotnetcache   = $false;
        #endregion Runnable sections
    };
}
