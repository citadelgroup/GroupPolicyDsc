enum Ensure {
    Absent
    Present
}

enum PermissionLevel {
    GpoRead
    GpoApply
    GpoEdit
    GpoEditDeleteModifySecurity
    None
}

enum TargetType {
    Computer
    User
    Group
}

enum Force {
    No
    Yes
}

[DscResource()]
class GPPermission
{
    [DscProperty(Key)]
    [string] $GPOName

    [DscProperty(Key)]
    [string] $TargetName

    [DscProperty()]
    [TargetType] $TargetType = [TargetType]::Group

    [DscProperty()]
    [PermissionLevel] $PermissionLevel = [PermissionLevel]::GpoApply

    [DscProperty()]
    [Force] $Force = [Force]::No
    
    [DscProperty()]
    [Ensure] $Ensure = [Ensure]::Present

    [GPPermission] Get() {
        $NextClosestSiteDC = (Get-ADDomainController -Discover -NextClosestSite).HostName.Value
        $gppermissions = Get-GPPermission -Name $this.GPOName -Server $NextClosestSiteDC -All

        if($gppermissions.Trustee -contains $this.TargetName) {
            $this.PermissionLevel = (Get-GPPermission -Name $this.GPOName -TargetName $this.TargetName -TargetType $this.TargetType -Server $NextClosestSiteDC).Permission
        }

        return $this
    }
  
    [void] Set() {
        $NextClosestSiteDC = (Get-ADDomainController -Discover -NextClosestSite).HostName.Value
        if($this.Ensure -eq [Ensure]::Present) {
            if($this.Force -eq [Force]::No) {
                Set-GPPermission -Name $this.GPOName `
                                 -TargetName $this.TargetName `
                                 -TargetType $this.TargetType `
                                 -PermissionLevel ($this.PermissionLevel).ToString() `
                                 -Server $NextClosestSiteDC
            }
            else {
                Set-GPPermission -Name $this.GPOName `
                                -TargetName $this.TargetName `
                                -TargetType $this.TargetType `
                                -PermissionLevel ($this.PermissionLevel).ToString() `
                                -Server $NextClosestSiteDC `
                                -Replace
            }
        }
        else {
            Set-GPPermission -Name $this.GPOName `
                             -TargetName $this.TargetName `
                             -TargetType $this.TargetType `
                             -PermissionLevel ([PermissionLevel]::None).ToString() `
                             -Server $NextClosestSiteDC `
                             -Replace
        }
    }

    [bool] Test() {
        $NextClosestSiteDC = (Get-ADDomainController -Discover -NextClosestSite).HostName.Value
        $gppermissions = Get-GPPermission -Name $this.GPOName -Server $NextClosestSiteDC -All

        if($this.Ensure -eq [Ensure]::Present) {
            if($gppermissions.Trustee.Name -contains ($this.TargetName).Split('\')[1]) {
                return $true
            }
            else {
                return $false
            }
        }
        else {
            if($gppermissions.Trustee.Name -contains ($this.TargetName).Split('\')[1]) {
                return $false
            }
            else {
                return $true
            }
        }

        return $false
    }
}
