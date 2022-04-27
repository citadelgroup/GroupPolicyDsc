enum Ensure {
    Absent
    Present
}

enum LinkEnabled {
    No = 1
    Yes = 2
}

enum Enforced {
    No = 1
    Yes = 2
}

[DscResource()]
class GPLink
{
    [DscProperty(Key)]
    [string] $Path

    [DscProperty(Key)]
    [string] $GPOName

    [DscProperty()]
    [LinkEnabled] $Enabled = [LinkEnabled]::Yes

    [DscProperty()]
    [Enforced] $Enforced = [Enforced]::No

    [DscProperty()]
    [Int32] $Order = 1
    
    [DscProperty()]
    [Ensure] $Ensure = [Ensure]::Present

    [GPLink] Get() {
        $gPLink = (Get-ADObject -Identity $this.Path -Properties gpLink).gpLink # Use instead of Get-GPInheritance to support links to sites
        $gPLinkMatches = [regex]::new('\[LDAP://((?:[^\];])+);(\d)\]').Matches($gPLink) # Parsing based on https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-gpol/08090b22-bc16-49f4-8e10-f27a8fb16d18

        $gPO = Get-GPO -Name $this.GPOName

        for($i = 0; $i -le $gPLinkMatches.Count-1; $i++) {
            if($gPLinkMatches[$i].Groups[1].Captures.Value -eq $gPO.Path) { # If this link is a link to the GPO
                $this.Enabled = ([LinkEnabled]::Yes, [LinkEnabled]::No)[(1 -band $gPLinkMatches[$i].Groups[2].Captures.Value)]
                $this.Enforced = ([Enforced]::No, [Enforced]::Yes)[(1 -band ($gPLinkMatches[$i].Groups[2].Captures.Value -shr 1))]
                $this.Order = $i
            }
        }

        return $this
    }
  
    [void] Set() {
        $gPLink = (Get-ADObject -Identity $this.Path -Properties gpLink).gpLink # Use instead of Get-GPInheritance to support links to sites
        $gPLinkMatches = [regex]::new('\[LDAP://((?:[^\];])+);(\d)\]').Matches($gPLink) # Parsing based on https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-gpol/08090b22-bc16-49f4-8e10-f27a8fb16d18

        $gPO = Get-GPO -Name $this.GPOName

        if($this.Ensure -eq [Ensure]::Present) {
            if($gPLinkMatches.ForEach({$_.Groups[1].Captures.Value}) -contains $gPO.Path) { # If there is a link in the list matching the GPO
                Set-GPLink -Name $this.GPOName `
                           -Target $this.Path `
                           -LinkEnabled $this.Enabled `
                           -Order $this.Order `
                           -Enforced $this.Enforced
            }
            else {
                New-GPLink -Name $this.GPOName `
                           -Target $this.Path `
                           -LinkEnabled $this.Enabled `
                           -Order $this.Order `
                           -Enforced $this.Enforced
            }
        }
        else {
            Remove-GPLink -Name $this.GPOName `
                          -Target $this.Path
        }
    }

    [bool] Test() {
        try {
            $gPLink = (Get-ADObject -Identity $this.Path -Properties gpLink).gpLink # Use instead of Get-GPInheritance to support links to sites
            $gPLinkMatches = [regex]::new('\[LDAP://((?:[^\];])+);(\d)\]').Matches($gPLink) # Parsing based on https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-gpol/08090b22-bc16-49f4-8e10-f27a8fb16d18
            $gPO = Get-GPO -Name $this.GPOName
        }
        catch {
            $gPLinkMatches = $null
            $gPO = $null
        }

        if($this.Ensure -eq [Ensure]::Present) {
            for($i = 0; $i -le $gPLinkMatches.Count-1; $i++) {
                if($gPLinkMatches[$i].Groups[1].Captures.Value -eq $gPO.Path) { # If this link is a link to the GPO
                    if($this.Enabled -eq ([LinkEnabled]::Yes, [LinkEnabled]::No)[(1 -band $gPLinkMatches[$i].Groups[2].Captures.Value)] -and `
                        $this.Enforced -eq ([Enforced]::No, [Enforced]::Yes)[(1 -band ($gPLinkMatches[$i].Groups[2].Captures.Value -shr 1))]) {
                        return $true
                    }
                }
            }
            return $false
        }
        else {
            if($gPLinkMatches.ForEach({$_.Groups[1].Captures.Value}) -contains $gPO.Path) { # If there is a link in the list matching the GPO
                return $false
            }
            else {
                return $true
            }
        }

        return $false
    }
}
