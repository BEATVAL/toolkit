; Cli programs register/unregister
[Code]
procedure EnvAddPath(Path: string);
var
    Paths: string;
begin
    { Retrieve current path (use empty string if entry not exists) }
    if not RegQueryStringValue(HKEY_CURRENT_USER, 'Environment', 'Path', Paths) then
        Paths := '';

    { Skip if string already found in path }
    if Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';') > 0 then
        exit;

    { App string to the end of the path variable }
    Paths := Paths + ';'+ Path //+';'

    { Overwrite (or create if missing) path environment variable }
    if RegWriteStringValue(HKEY_CURRENT_USER, 'Environment', 'Path', Paths) then
        Log(Format('The [%s] added to PATH: [%s]', [Path, Paths]))
    else
        Log(Format('Error while adding the [%s] to PATH: [%s]', [Path, Paths]));
end;

procedure EnvRemovePath(Path: string);
var
    Paths: string;
    P: Integer;
begin
    { Skip if registry entry not exists }
    if not RegQueryStringValue(HKEY_CURRENT_USER, 'Environment', 'Path', Paths) then
        exit;

    { Skip if string not found in path }
    P := Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';');
    if P = 0 then
        exit;

    { Update path variable }
    Delete(Paths, P - 1, Length(Path) + 1);

    { Overwrite path environment variable }
    if RegWriteStringValue(HKEY_CURRENT_USER, 'Environment', 'Path', Paths) then
        Log(Format('The [%s] removed from PATH: [%s]', [Path, Paths]))
    else
        Log(Format('Error while removing the [%s] from PATH: [%s]', [Path, Paths]));
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
    if CurStep = ssPostInstall then
    begin
        if WizardIsComponentSelected('analysis\capa') then EnvAddPath(ExpandConstant('{#MyAppToolsFolder}') + '\Analysis\CAPA');
        if WizardIsComponentSelected('monitor\hollowshunter') then EnvAddPath(ExpandConstant('{#MyAppToolsFolder}') + '\Monitor\HollowsHunter');
        if WizardIsComponentSelected('monitor\pesieve') then EnvAddPath(ExpandConstant('{#MyAppToolsFolder}') + '\Monitor\PE-sieve');
        if WizardIsComponentSelected('other\floss') then EnvAddPath(ExpandConstant('{#MyAppToolsFolder}') + '\Other\FLOSS');
        if WizardIsComponentSelected('other\processdump') then EnvAddPath(ExpandConstant('{#MyAppToolsFolder}') + '\Other\Process-Dump');
        if WizardIsComponentSelected('other\strings') then EnvAddPath(ExpandConstant('{#MyAppToolsFolder}') + '\Other\Strings');
        if WizardIsComponentSelected('unpacking\de4dot') then EnvAddPath(ExpandConstant('{#MyAppToolsFolder}') + '\UnPacking\De4Dot');
    end
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
    if CurUninstallStep = usPostUninstall then
    begin
        EnvRemovePath(ExpandConstant('{#MyAppToolsFolder}') + '\Analysis\CAPA');
        EnvRemovePath(ExpandConstant('{#MyAppToolsFolder}') + '\Monitor\HollowsHunter');
        EnvRemovePath(ExpandConstant('{#MyAppToolsFolder}') + '\Monitor\PE-sieve');
        EnvRemovePath(ExpandConstant('{#MyAppToolsFolder}') + '\Other\FLOSS');
        EnvRemovePath(ExpandConstant('{#MyAppToolsFolder}') + '\Other\Process-Dump');
        EnvRemovePath(ExpandConstant('{#MyAppToolsFolder}') + '\Other\Strings');
        EnvRemovePath(ExpandConstant('{#MyAppToolsFolder}') + '\UnPacking\De4Dot');
    end
end;