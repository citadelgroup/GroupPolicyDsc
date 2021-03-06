enum Ensure
{
    Absent
    Present
}

[DscResource()]
class GPRegistryValue
{
    [DscProperty(Key)]
    [string] $Name

    [DscProperty(Key)]
    [string] $Key
    
    [DscProperty(Key)]
    [string] $ValueName
    
    [DscProperty()]
    [string] $ValueType
    
    [DscProperty()]
    [string] $Value
    
    [DscProperty()]
    [Ensure] $Ensure = [Ensure]::Present

    [GPRegistryValue] Get() {
        $currentvalue = Get-GPRegistryValue -Name $this.Name `
                                     -Key $this.Key `
                                     -ValueName $this.ValueName `
                                     -ErrorAction SilentlyContinue

        if($null -ne $currentvalue) {
            $this.ValueType = $currentvalue.Type
            $this.Value = $currentvalue.Value
            $this.Ensure = [Ensure]::Present
        }
        else {
            $this.Ensure = [Ensure]::Absent
        }

        return $this
    }
  
    [void] Set() {
        if($this.Ensure -eq [Ensure]::Present) {
            if($this.ValueType -eq "DWord") {
                Set-GPRegistryValue -Name $this.Name `
                                    -Key $this.Key `
                                    -ValueName $this.ValueName `
                                    -Value ([Int32]::Parse($this.Value)) `
                                    -Type $this.ValueType
            }
            else {
                Set-GPRegistryValue -Name $this.Name `
                                    -Key $this.Key `
                                    -ValueName $this.ValueName `
                                    -Value $this.Value `
                                    -Type $this.ValueType
            }
        }
        else {
            Set-GPRegistryValue -Name $this.Name `
                                -Key $this.Key `
                                -ValueName $this.ValueName `
                                -Value $this.Value `
                                -Disable
        }
    }

    [bool] Test() {
        $currentvalue = Get-GPRegistryValue -Name $this.Name `
                                     -Key $this.Key `
                                     -ValueName $this.ValueName `
                                     -ErrorAction SilentlyContinue

        if($this.Ensure -eq [Ensure]::Present) {
            if($null -eq $currentvalue) {
                return $false
            }

            if($this.ValueType -eq $currentvalue.Type -and $this.Value -eq $currentvalue.Value) {
                return $true
            }
        }
        else {
            if($null -eq $currentvalue) {
                return $true
            }
            else {
                return $false
            }
        }

        return $false
    }
}
