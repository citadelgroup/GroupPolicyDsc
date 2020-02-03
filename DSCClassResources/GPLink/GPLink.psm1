enum Ensure {
    Absent
    Present
}

enum LinkEnabled {
    Yes
    No
}

enum Enforced {
    No
    Yes
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
        $oulinks = (Get-GPInheritance -Target $this.Path).GpoLinks

        if($oulinks.DisplayName -contains $this.GPOName) {
            $gpo = $oulinks.Where{$_.DisplayName -eq $this.GPOName}
            $this.Enabled = $gpo.Enabled
            $this.Enforced = $gpo.Enforced
            $this.Order = $gpo.Order
        }

        return $this
    }
  
    [void] Set() {
        $oulinks = (Get-GPInheritance -Target $this.Path).GpoLinks

        if($this.Ensure -eq [Ensure]::Present) {
            if($oulinks.DisplayName -contains $this.GPOName) {
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
            $oulinks = (Get-GPInheritance -Target $this.Path).GpoLinks # command doesn't appear to respect ErrorAction Preference
        }
        catch {
            $oulinks = $null
        }

        if($this.Ensure -eq [Ensure]::Present) {
            if(($null -ne $oulinks) -and ($oulinks.DisplayName -contains $this.GPOName)) {
                return $true
            }
            else {
                return $false
            }
        }
        else {
            if(($null -ne $oulinks) -and ($oulinks.DisplayName -contains $this.GPOName)) {
                return $false
            }
            else {
                return $true
            }
        }

        return $false
    }
}
