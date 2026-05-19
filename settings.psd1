@{
    colors  = @{
        color1 = "DarkMagenta";
        color2 = "DarkRed";
        color3 = "Red";
        color4 = "Cyan";
    };

    verbose = @{
        all           = $false; # Set to `$true` to turn on verbosity for all sections
        # Sections that use verbosity
        WSL           = $true;
        Chocolatey    = $false; # Chocolatey verbosity isn't very useful
        Winget        = $true;
        PowerShellGet = $true;
        MSStore       = $true;
        ncu           = $false; # ncu verbosity isn't very useful
        WindowsUpdate = $true;
        npmcache      = $true;
        yarncache     = $false;
    };

    run     = @{
        WSL           = $true; # Run Windows Subsystem for Linux (WSL) update
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
    };
}
