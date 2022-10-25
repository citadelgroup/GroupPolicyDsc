# GroupPolicyDsc

GroupPolicyDsc is a module written to provide PowerShell DSC configuration resources to manipulate Group Policy within a domain.

## Resources

* [GroupPolicy](#grouppolicy): Provides a mechanism to create Group Policy objects.
* [GPLink](#gplink): Provides a mechanism to link Group Policy objects to Organisational Units.
* [GPPermission](#gppermission): Provides a mechanism to set the permission scope of a Group Policy object.
* [GPRegistryValue](#gpregistryvalue): Provides a mechanism to set a registry item within a Grouop Policy object.

### GroupPolicy

Provides a mechanism to create Group Policy objects.

#### Requirements

* This must be run on an Active Directory Domain Controller

#### Parameters

* **[String] Name** _(Key)_: The name of the Group Policy object you want to configure.
* **[String] Status** _(Write)_: The status of the Group Policy object. { *AllSettingsEnabled* | UserSettingsDisabled | ComputerSettingsDisabled | AllSettingsDisabled }
* **[String] Ensure** _(Write)_: Specifies whether the Group Policy object should be present or absent. { *Present* | Absent }

#### Read-Only Properties from Get-TargetResource

None

#### Examples

* [Create new Group Policy object](https://github.com/citadelgroup/GroupPolicyDsc/blob/master/Examples/Sample_CreateNewGroupPolicy.ps1)

### GPLink

Provides a mechanism to link Group Policy objects to Organisational Units.

#### Requirements

* This must be run on an Active Directory Domain Controller

#### Parameters

* **[String] Path** _(Key)_: The X.500 path of the Organisational Unit you want to link to.
* **[String] GPOName** _(Key)_: The name of the Group Policy object you want to configure.
* **[String] Enabled** _(Write)_: The status of the Group Policy link. { *Yes* | No }
* **[String] Enforced** _(Write)_: Whether or not the Group Policy link will be enforced, that is, will override GP inheritance blocks. { *No* | Yes }
* **[Int32] Order** _(Write)_: The order of the link compared to other Group Policy links on the same Organisational Unit. { *1* | 2,3,4,5... }
* **[String] Ensure** _(Write)_: Specifies whether the Group Policy link should be present or absent. { *Present* | Absent }

#### Read-Only Properties from Get-TargetResource

None

#### Examples

* [Create new Group Policy link](https://github.com/citadelgroup/GroupPolicyDsc/blob/master/Examples/Sample_CreateNewGPLink.ps1)

### GPPermission

Provides a mechanism to set the permission scope of a Group Policy object.

#### Requirements

* This must be run on an Active Directory Domain Controller

#### Parameters

* **[String] GPOName** _(Key)_: The name of the Group Policy object you want to configure.
* **[String] TargetName** _(Key)_: The account name of the object you want to configure.
* **[String] TargetType** _(Write)_: The type of the account. { *Group* | User | Computer }
* **[String] PermissionLevel** _(Write)_: The type of the account. { *GpoApply* | GpoRead | GpoApply | GpoEditDeleteModifySecurity | None }
* **[String] Force** _(Write)_: Whether to force the permission to be set as specified or only added to. { *No* | Yes }
* **[String] Ensure** _(Write)_: Specifies whether the permission should be present or absent. { *Present* | Absent }

#### Read-Only Properties from Get-TargetResource

None

#### Examples

* [Create new Group Policy permission](https://github.com/citadelgroup/GroupPolicyDsc/blob/master/Examples/Sample_CreateNewGPPermission.ps1)

### GPRegistryValue

Provides a mechanism to set Registry Values within Group Policy objects.

#### Requirements

* This must be run on an Active Directory Domain Controller

#### Parameters

* **[String] Name** _(Key)_: The name of the Group Policy object you want to configure.
* **[String] Key** _(Key)_: The registry key you want to configure.
* **[String] Name** _(Key)_: The registry key value name you want to configure.
* **[String] ValueType** _(Write)_: The type of the registry value you want to configure. { DWord | Other }
* **[String] Value** _(Write)_: The value of the registry you want to configure.
* **[String] Ensure** _(Write)_: Specifies whether the Group Policy object should be present or absent. { *Present* | Absent }

#### Read-Only Properties from Get-TargetResource

None

#### Examples

* [Create new GP Registry Value](https://github.com/citadelgroup/GroupPolicyDsc/blob/master/Examples/Sample_CreateNewGPRegistryValue.ps1)

## Versions

### 1.0.3 (Waiting for release)

* GPLink can be used to create links to Active Directory Sites.

### 1.0.0

* Initial release of GroupPolicyDsc.
