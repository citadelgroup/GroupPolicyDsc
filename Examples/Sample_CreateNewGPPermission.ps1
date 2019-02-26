<#
    .SYNOPSIS
        Creates a new permission allowing MYDOMAIN\AllServers to access and apply the GPO "Test GPO".
#>
Configuration Sample_CreateNewGPPermission {
    Import-DscResource -ModuleName 'GroupPolicyDsc'

    Node localhost {
        $GPOName = "Test GPO"

        GroupPolicy GroupPolicyConfig  {
            Name = $GPOName
        }

        GPPermission GPPermissionConfig {
            GPOName = $GPOName
            TargetName = 'MYDOMAIN\AllServers'
        }
    }
}
