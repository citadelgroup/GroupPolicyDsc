<#
    .SYNOPSIS
        Creates a new registry value in the GPO "Test GPO", setting HKCU\SOFTWARE\MyCompany\MyApplication-->MySetting to the value 1 (DWord).
#>
Configuration Sample_CreateNewGPRegistryValue {
    Import-DscResource -ModuleName 'GroupPolicyDsc'

    Node localhost {
        $GPOName = "Test GPO"

        GroupPolicy GroupPolicyConfig  {
            Name = $GPOName
        }

        GPRegistryValue GPRegistryValueConfig {
            Name = $GPOName
            Key = "HKCU\SOFTWARE\MyCompany\MyApplication"
            ValueName = "MySetting"
            ValueType = "DWord"
            Value = "1"
            PolicyState = "Set"
        }
    }
}
