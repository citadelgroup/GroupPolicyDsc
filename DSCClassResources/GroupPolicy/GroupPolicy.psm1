enum Ensure
{
    Absent
    Present
}

[DscResource()]
class GroupPolicy
{
    [DscProperty(Key)]
    [string] $Name
    
    [DscProperty()]
    [ValidateSet("AllSettingsEnabled","UserSettingsDisabled","ComputerSettingsDisabled","AllSettingsDisabled")]
    [string] $Status = "AllSettingsEnabled"
    
    [DscProperty()]
    [Ensure] $Ensure = [Ensure]::Present

    [GroupPolicy] Get() {
        $policy = Get-GPO -Name $this.Name -ErrorAction SilentlyContinue

        if($null -ne $policy) {
            $this.Status = $policy.GpoStatus
            $this.Ensure = [Ensure]::Present
        }
        else {
            $this.Ensure = [Ensure]::Absent
        }

        return $this
    }
  
    [void] Set() {
        $policy = Get-GPO -Name $this.Name -ErrorAction SilentlyContinue

        if($this.Ensure -eq [Ensure]::Present) {
            if($null -eq $policy) {
                $policy = New-GPO -Name $this.Name
            }

            $policy.GpoStatus = $this.Status
        }
        else {
            Remove-GPO -Name $this.Name
        }
    }

    [bool] Test() {
        $policy = Get-GPO -Name $this.Name -ErrorAction SilentlyContinue

        if($this.Ensure -eq [Ensure]::Present) {
            if($null -eq $policy) {
                return $false
            }

            if($this.Status -eq $policy.GpoStatus) {
                return $true
            }
        }
        else {
            if($null -eq $policy) {
                return $true
            }
            else {
                return $false
            }
        }

        return $false
    }
}
