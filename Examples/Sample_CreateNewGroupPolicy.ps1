<#
    .SYNOPSIS
        Creates a new Group Policy object, with all settings enabled.
#>
Configuration Sample_CreateNewGroupPolicy {
    Import-DscResource -ModuleName 'GroupPolicyDsc'

    Node localhost {
        GroupPolicy GroupPolicyConfig  {
            Name = "Test GPO"
        }
    }
}
