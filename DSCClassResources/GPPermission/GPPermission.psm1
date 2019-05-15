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
        $gppermissions = Get-GPPermission -Name $this.GPOName -All

        if($gppermissions.Trustee -contains $this.TargetName) {
            $this.PermissionLevel = (Get-GPPermission -Name $this.GPOName -TargetName $this.TargetName -TargetType $this.TargetType).Permission
        }

        return $this
    }
  
    [void] Set() {
        if($this.Ensure -eq [Ensure]::Present) {
            if($this.Force -eq [Force]::No) {
                Set-GPPermission -Name $this.GPOName `
                                 -TargetName $this.TargetName `
                                 -TargetType $this.TargetType `
                                 -PermissionLevel ($this.PermissionLevel).ToString()
            }
            else {
                Set-GPPermission -Name $this.GPOName `
                                -TargetName $this.TargetName `
                                -TargetType $this.TargetType `
                                -PermissionLevel ($this.PermissionLevel).ToString() `
                                -Replace
            }
        }
        else {
            Set-GPPermission -Name $this.GPOName `
                             -TargetName $this.TargetName `
                             -TargetType $this.TargetType `
                             -PermissionLevel ([PermissionLevel]::None).ToString() `
                             -Replace
        }
    }

    [bool] Test() {
        $gppermissions = Get-GPPermission -Name $this.GPOName -All

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
