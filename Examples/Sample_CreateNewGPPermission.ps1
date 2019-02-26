<#
    .SYNOPSIS
        Creates a new Group Policy link to the Servers OU for the Group Policy "Test GPO".
#>
Configuration Sample_CreateNewGPLink {
    Import-DscResource -ModuleName 'GroupPolicyDsc'

    Node localhost {
        $GPOName = "Test GPO"

        GroupPolicy GroupPolicyConfig  {
            Name = $GPOName
        }

        GPPermission UserPolicyPermissions {
            GPOName = $PolicyName
            TargetName = 'Domain Computers'
            TargetDomain = $DomainNetbiosName
        }
    }
}
