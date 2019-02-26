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

        GPLink GPLinkConfig  {
            Path = "OU=Servers,DC=domain,DC=com"
            GPOName = $GPOName
        }
    }
}
