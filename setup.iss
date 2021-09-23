; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Freelancer HD Edition"
#define MyAppVersion "0.4.1"
#define MyAppPublisher "Freelancer: HD Edition Development Team"
#define MyAppURL "https://github.com/BC46/freelancer-hd-edition"
#define MyAppExeName "Freelancer.exe"

#include ReadReg(HKLM, 'Software\WOW6432Node\Mitrich Software\Inno Download Plugin', 'InstallDir') + '\idp.iss'

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{F40FDCDA-3A45-4CC3-9FDA-167EE480A1E0}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={win}\Freelancer HD Edition
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputBaseFilename=FreelancerHDSetup
SetupIconFile={#SourcePath}\icon.ico
Compression=lzma
SolidCompression=yes
WizardImageFile={#SourcePath}\backgroundpattern.bmp
WizardSmallImageFile={#SourcePath}\icon.bmp
DisableWelcomePage=False

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\EXE\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\EXE\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\EXE\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Messages]
WelcomeLabel2=Freelancer: HD Edition is a mod that aims to improve every aspect of Freelancer while keeping the look and feel as close to vanilla as possible. It also serves as an all-in-one package for players so they don't have to worry about installing countless patches and mods to create the perfect HD and bug-free install.%n%n This installer requires a clean, freshly installed Freelancer directory.

[Code]
var
  DataDirPage: TInputDirWizardPage;
  CallSign: TInputOptionWizardPage;
  StartupRes: TInputOptionWizardPage;
  LogoRes: TInputOptionWizardPage;
  frmOptions: Integer;
  frmOptions2: Integer; 

procedure DirectoryCopy(SourcePath, DestPath: string);
var
  FindRec: TFindRec;
  SourceFilePath: string;
  DestFilePath: string;
begin
  if FindFirst(SourcePath + '\*', FindRec) then
  begin
    try
      repeat
        if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
        begin
          SourceFilePath := SourcePath + '\' + FindRec.Name;
          DestFilePath := DestPath + '\' + FindRec.Name;
          if FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
          begin
            if FileCopy(SourceFilePath, DestFilePath, False) then
            begin
              Log(Format('Copied %s to %s', [SourceFilePath, DestFilePath]));
            end
              else
            begin
              Log(Format('Failed to copy %s to %s', [
                SourceFilePath, DestFilePath]));
            end;
          end
            else
          begin
            if DirExists(DestFilePath) or CreateDir(DestFilePath) then
            begin
              Log(Format('Created %s', [DestFilePath]));
              DirectoryCopy(SourceFilePath, DestFilePath);
            end
              else
            begin
              Log(Format('Failed to create %s', [DestFilePath]));
            end;
          end;
        end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
  end
    else
  begin
    Log(Format('Failed to list %s', [SourcePath]));
  end;
end;

const
  SHCONTCH_NOPROGRESSBOX = 4;
  SHCONTCH_RESPONDYESTOALL = 16;

procedure UnZip(ZipPath, TargetPath: string); 
var
  Shell: Variant;
  ZipFile: Variant;
  TargetFolder: Variant;
begin
  Shell := CreateOleObject('Shell.Application');

  ZipFile := Shell.NameSpace(ZipPath);
  if VarIsClear(ZipFile) then
    RaiseException(
      Format('ZIP file "%s" does not exist or cannot be opened', [ZipPath]));

  TargetFolder := Shell.NameSpace(TargetPath);
  if VarIsClear(TargetFolder) then
    RaiseException(Format('Target path "%s" does not exist', [TargetPath]));

  TargetFolder.CopyHere(
    ZipFile.Items, SHCONTCH_NOPROGRESSBOX or SHCONTCH_RESPONDYESTOALL);
end;

function FileReplaceString(const FileName, SearchString, ReplaceString: string):boolean;
var
  MyFile : TStrings;
  MyText : string;
begin
  MyFile := TStringList.Create;

  try
    result := true;

    try
      MyFile.LoadFromFile(FileName);
      MyText := MyFile.Text;

      { Only save if text has been changed. }
      if StringChangeEx(MyText, SearchString, ReplaceString, True) > 0 then
      begin;
        MyFile.Text := MyText;
        MyFile.SaveToFile(FileName);
      end;
    except
      result := false;
    end;
  finally
    MyFile.Free;
  end;
end;

function CallSignOption():boolean;
var
  FilePath : string;
begin
  FilePath := ExpandConstant('{app}\EXE\freelancer.ini');

  if(CallSign.Values[1]) then // Navy Beta 2-5
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, li_n 2 2-5')
  else if(CallSign.Values[2]) then // Bretonia Police Iota 3-4
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, br_p 8 3-4')
  else if(CallSign.Values[3]) then // Military Epsilon 11-6
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, rh_n 5 11-6')
  else if(CallSign.Values[4]) then // Naval Forces Matsu 4-9
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, ku_n 22 4-9')
  else if(CallSign.Values[5]) then // IMG Red 18-6
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, gd_im 14 18-6')
  else if(CallSign.Values[6]) then // Kishiro Yanagi 7-3
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, co_kt 29 7-3')
  else if(CallSign.Values[7]) then // Outcasts Lambda 9-12
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, fc_ou 10 9-12')
  else if(CallSign.Values[8]) then // Dragons Green 16-13
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, fc_bd 17 16-13')
  else if(CallSign.Values[9]) then // Spa and Cruise Omega 8-0
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, co_os 13 8-0')
  else if(CallSign.Values[10]) then // Daumann Zeta 11-17
  FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, co_khc 6 11-17')
  else if(CallSign.Values[11]) then // Bowex Gamma 5-7
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, co_be 3 5-7')
  else if(CallSign.Values[12]) then // Order Omicron 0-0
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, fc_or 11 0-0')
  else if(CallSign.Values[13]) then // LSF Delta 6-9
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, li_lsf 4 6-9')
  else if(CallSign.Values[14]) then // Hacker Kappa 4-20
    FileReplaceString(FilePath,'DLL = callsign.dll, player 1 1-1','DLL = callsign.dll, fc_lh 9 4-20')
end;

function StartUpLogo():boolean;
var
  FolderPath : string;
  OldFile : string;
  NewFile : string;
begin
  FolderPath := ExpandConstant('{app}\DATA\INTERFACE\INTRO\IMAGES\');
  NewFile := FolderPath + 'startupscreen_1280.tga';

  if(StartupRes.Values[0]) then
    begin 
      OldFile := NewFile
      NewFile := FolderPath + 'startupscreen_1280_1280x960.tga'
    end
  else if(StartupRes.Values[1]) then 
    OldFile := FolderPath + 'startupscreen_1280_1280x720.tga'
  else if(StartupRes.Values[3]) then 
    OldFile := FolderPath + 'startupscreen_1280_1440x1080.tga'
  else if(StartupRes.Values[4]) then 
    OldFile := FolderPath + 'startupscreen_1280_1920x1080.tga'
  else if(StartupRes.Values[5]) then 
    OldFile := FolderPath + 'startupscreen_1280_1920x1440.tga'
  else if(StartupRes.Values[6]) then 
    OldFile := FolderPath + 'startupscreen_1280_2560x1440.tga'
  else if(StartupRes.Values[7]) then 
    OldFile := FolderPath + 'startupscreen_1280_2880x2160.tga'
  else if(StartupRes.Values[8]) then 
    OldFile := FolderPath + 'startupscreen_1280_3840x2160.tga';

  RenameFile(OldFile,NewFile);
  
end;

function FreelancerLogo():boolean;
var
  FolderPath : string;
  OldFile : string;
  NewFile : string;
begin
  FolderPath := ExpandConstant('{app}\DATA\INTERFACE\INTRO\IMAGES\');
  NewFile := FolderPath + 'front_freelancerlogo.tga';

  if(StartupRes.Values[0]) then
    begin 
      OldFile := NewFile
      NewFile := FolderPath + 'front_freelancerlogo_800x600.tga'
    end
  else if(StartupRes.Values[2]) then 
    OldFile := FolderPath + 'front_freelancerlogo_960x720.tga'
  else if(StartupRes.Values[3]) then 
    OldFile := FolderPath + 'front_freelancerlogo_1280x720.tga'
  else if(StartupRes.Values[4]) then 
    OldFile := FolderPath + 'front_freelancerlogo_1440x1080.tga'
  else if(StartupRes.Values[5]) then 
    OldFile := FolderPath + 'front_freelancerlogo_1920x1080.tga'
  else if(StartupRes.Values[6]) then 
    OldFile := FolderPath + 'front_freelancerlogo_1920x1440.tga'
  else if(StartupRes.Values[7]) then 
    OldFile := FolderPath + 'front_freelancerlogo_2560x1440.tga'
  else if(StartupRes.Values[8]) then 
    OldFile := FolderPath + 'front_freelancerlogo_2880x2160.tga'
  else if(StartupRes.Values[8]) then 
    OldFile := FolderPath + 'front_freelancerlogo_3840x2160.tga';

  RenameFile(OldFile,NewFile);
  
end;

// Custom Page
var
  // Advanced Widescreen HUD
  lblWidescreenHud: TLabel;
  WidescreenHud: TCheckBox;

  // Fix clipping with 16:9 resolution planetscapes
  lblPlanetScape: TLabel;
  PlanetScape: TCheckBox;

  // Fix Small Text on 1440p/4K resolutions
  lblSmallText: TLabel;
  SmallText: TCheckBox;

  // Fix Windows 10 compatibility issues
  lblWin10: TLabel;
  Win10: TCheckBox;

  // Add improved reflections
  lblReflections: TLabel;
  Reflections: TCheckBox;

  // Add new missile effects
  lblMissleEffects: TLabel;
  MissileEffects: TCheckBox;

  // Single Player Command Console
  lblSinglePlayer: TLabel;
  SinglePlayer: TCheckBox;

procedure frmOptions_Activate(Page: TWizardPage);
begin
end;

function frmOptions_ShouldSkipPage(Page: TWizardPage): Boolean;
begin
  Result := False;
end;

function frmOptions_BackButtonClick(Page: TWizardPage): Boolean;
begin
  Result := True;
end;

function frmOptions_NextButtonClick(Page: TWizardPage): Boolean;
begin
  Result := True;
end;

procedure frmOptions_CancelButtonClick(Page: TWizardPage; var Cancel, Confirm: Boolean);
begin
end;

function frmOptions_CreatePage(PreviousPageId: Integer): Integer;
var
  Page: TWizardPage;
begin
  Page := CreateCustomPage(
    PreviousPageId,
    'Other Options',
    'Choose other options here'
  );

  // Advanced Widescreen HUD
  lblWidescreenHud := TLabel.Create(Page);
  lblWidescreenHud.Parent := Page.Surface;
  lblWidescreenHud.Caption := 'Advanced Widescreen HUD for 16:9 resolutions';
  lblWidescreenHud.Left := ScaleX(20);

  descWidescreenHud := TNewStaticText.Create(Page);
  descWidescreenHud.Caption := 'This option aSdds two new useful widgets to your HUD. Next to your contact list, you will have a wireframe representation of your selected target. Next to your weapons list, you will have a wireframe of your own ship.'
  '\n\nIf you play in 4:3, disable this option. It only works for widescreen resolutions. If you disable this option, you will still get support for the default 16:9 HUD and corresponding resolutions.
The Advanced Widescreen HUD makes great use of the unused space that you normally see in widescreen, hence we recommend it for all players who play in 16:9. If you choose to enable this, go to the Controls settings in-game and under �User Interface�, disable Target View (Alt + T). This key binding has become obsolete as both the target view and contact list are visible simultaneously.
'

  WidescreenHud := TCheckBox.Create(Page);
  WidescreenHud.Parent := Page.Surface;
  WidescreenHud.Checked := True;

  // Fix clipping with 16:9 resolution planetscapes
  //lblPlanetScape := TLabel.Create(Page);
  //lblPlanetScape.Parent := Page.Surface;
  //lblPlanetScape.Caption := 'Fix clipping with 16:9 resolution planetscapes';
  //lblPlanetScape.Top := ScaleY(20);
  //lblPlanetScape.Left := ScaleX(20);

  //PlanetScape := TCheckBox.Create(Page);
  //PlanetScape.Parent := Page.Surface;
  //PlanetScape.Top := ScaleY(20);
  //PlanetScape.Checked := True;

  // Fix Small Text on 1440p/4K resolutions
  //lblSmallText := TLabel.Create(Page);
  //lblSmallText.Parent := Page.Surface;
  //lblSmallText.Caption := 'Fix small text on 1440p/4K resolutions';
  //lblSmallText.Top := ScaleY(40);
  //lblSmallText.Left := ScaleX(20);

  //SmallText := TCheckBox.Create(Page);
  //SmallText.Parent := Page.Surface;
  //SmallText.Top := ScaleY(40);
  //SmallText.Checked := True;

  with Page do
  begin
    OnActivate := @frmOptions_Activate;
    OnShouldSkipPage := @frmOptions_ShouldSkipPage;
    OnBackButtonClick := @frmOptions_BackButtonClick;
    OnNextButtonClick := @frmOptions_NextButtonClick;
    OnCancelButtonClick := @frmOptions_CancelButtonClick;
  end;

  Result := Page.ID;
end;

function frmOptions2_CreatePage(PreviousPageId: Integer): Integer;
var
  Page: TWizardPage;
begin
  Page := CreateCustomPage(
    PreviousPageId,
    'Other Options',
    'Choose other options here'
  );

  // Fix Windows 10 compatibility issues
  lblWin10 := TLabel.Create(Page);
  lblWin10.Parent := Page.Surface;
  lblWin10.Caption := 'Fix Windows 10 compatibility issues. TRY AT YOUR OWN RISK';
  lblWin10.Top := ScaleY(60);
  lblWin10.Left := ScaleX(20);

  Win10 := TCheckBox.Create(Page);
  Win10.Parent := Page.Surface;
  Win10.Top := ScaleY(60);

  // Add improved reflections
  lblReflections := TLabel.Create(Page);
  lblReflections.Parent := Page.Surface;
  lblReflections.Caption := 'Add improved reflections';
  lblReflections.Top := ScaleY(80);
  lblReflections.Left := ScaleX(20);

  Reflections := TCheckBox.Create(Page);
  Reflections.Parent := Page.Surface;
  Reflections.Top := ScaleY(80);
  Reflections.Checked := True;

  // Add new missile effects
  lblMissleEffects := TLabel.Create(Page);
  lblMissleEffects.Parent := Page.Surface;
  lblMissleEffects.Caption := 'Add new missile effects';
  lblMissleEffects.Top := ScaleY(100);
  lblMissleEffects.Left := ScaleX(20);

  MissileEffects := TCheckBox.Create(Page);
  MissileEffects.Parent := Page.Surface;
  MissileEffects.Top := ScaleY(100);
  MissileEffects.Checked := True;

  // Single Player Command Console
  lblSinglePlayer := TLabel.Create(Page);
  lblSinglePlayer.Parent := Page.Surface;
  lblSinglePlayer.Caption := 'Single Player Command Console';
  lblSinglePlayer.Top := ScaleY(120);
  lblSinglePlayer.Left := ScaleX(20);

  SinglePlayer := TCheckBox.Create(Page);
  SinglePlayer.Parent := Page.Surface;
  SinglePlayer.Top := ScaleY(120);
  SinglePlayer.Checked := True;

  with Page do
  begin
    OnActivate := @frmOptions_Activate;
    OnShouldSkipPage := @frmOptions_ShouldSkipPage;
    OnBackButtonClick := @frmOptions_BackButtonClick;
    OnNextButtonClick := @frmOptions_NextButtonClick;
    OnCancelButtonClick := @frmOptions_CancelButtonClick;
  end;

  Result := Page.ID;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
    if CurStep = ssPostInstall then 
    begin
        // Copy Vanilla game to directory
        DirectoryCopy(DataDirPage.Values[0],ExpandConstant('{app}'));
        // Unzip
        UnZip(ExpandConstant('{tmp}\freelancerhd.zip'),ExpandConstant('{app}'));
        CallSignOption();
        StartUpLogo();
        FreelancerLogo();
    end;
end;

function NextButtonClick(PageId: Integer): Boolean;
begin
    Result := True;
    if (PageId = DataDirPage.ID) and not FileExists(DataDirPage.Values[0] + '\EXE\Freelancer.exe') then begin
        MsgBox('Freelancer does not seem to be installed in that folder.  Please select the correct folder.', mbError, MB_OK);
        Result := False;
        exit;
    end;
end;

procedure InitializeWizard;
var dir : string;
begin
    { Download Mod and store in temp directory }
    idpAddFile('https://github.com/BC46/freelancer-hd-edition/archive/refs/tags/0.4.1.zip', ExpandConstant('{tmp}\freelancerhd.zip'));
    idpDownloadAfter(wpReady);

    { Custom option pages }
    DataDirPage := CreateInputDirPage(wpWelcome,
    'Select Freelancer installation', 'Where is Freelancer installed?',
    'Select the folder in which a fresh copy of Freelancer is installed, then click Next. This is usually C:\Program Files (x86)\Microsoft Games\Freelancer',
    False, '');
    DataDirPage.Add('');

    if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Wow6432Node\Microsoft\Microsoft Games\Freelancer\1.0',
     'AppPath', dir) then
    begin
    // Successfully read the value
      DataDirPage.Values[0] := dir
    end;

    CallSign := CreateInputOptionPage(DataDirPage.ID,
    'Simgle Player ID Code', 'Tired of being called Freelancer Alpha 1-1?',
    'You know when each time an NPC talks to you in-game, they call you Freelancer Alpha 1-1? This is your ID Code. Well, this mod gives you the ability to change your ID Code in Single Player! Just select any option you like and the NPCs will call you by that.',
    True, False);
    CallSign.Add('Freelancer Alpha 1-1 (Default)');
    CallSign.Add('Navy Beta 2-5');
    CallSign.Add('Bretonia Police Iota 3-4');
    CallSign.Add('Military Epsilon 11-6');
    CallSign.Add('Naval Forces Matsu 4-9');
    CallSign.Add('IMG Red 18-6');
    CallSign.Add('Kishiro Yanagi 7-3');
    CallSign.Add('Outcasts Lambda 9-12');
    CallSign.Add('Dragons Green 16-13');
    CallSign.Add('Spa and Cruise Omega 8-0');
    CallSign.Add('Daumann Zeta 11-17');
    CallSign.Add('Bowex Gamma 5-7');
    CallSign.Add('Order Omicron 0-0');
    CallSign.Add('LSF Delta 6-9');
    CallSign.Add('Hacker Kappa 4-20');

    StartupRes := CreateInputOptionPage(CallSign.ID,
    'Startup Screen Resolution', 'Choose your native resolution',
    'By default, the "Freelancer" splash screen you see when you start the game has a resolution of 1280x960. This makes it appear stretched and a bit blurry on HD 16:9 resolutions.' +
    'We recommend setting this option to your monitor''s native resolution.' +
    'Selecting the "None" option removes the start screen.',
    True, False);
    StartupRes.Add('None');
    StartupRes.Add('720p 16:9 - 1280x720');
    StartupRes.Add('960p 4:3 - 1280x960 (Default)');
    StartupRes.Add('1080p 4:3 - 1440x1080');
    StartupRes.Add('1080p 16:9 - 1920x1080');
    StartupRes.Add('1440p 4:3 - 1920x1440');
    StartupRes.Add('1440p 16:9 - 2560x1440');
    StartupRes.Add('4K 4:3 - 2880x2160');
    StartupRes.Add('4K 16:9 - 3840x2160');

    LogoRes := CreateInputOptionPage(StartupRes.ID,
    'Freelancer Logo Resolution', 'In the game''s main menu',
    'This logo has a resolution of 800x600 by default, which makes it look stretched and pixelated/blurry on HD 16:9 monitors.' +
    'Setting this to a higher resolution with the correct aspect ratio makes the logo look nice and sharp and not stretched-out. Hence we recommend setting this option to your monitor''s native resolution.',
    True, False);
    LogoRes.Add('1080p 16:9 - 1920x1080');
    LogoRes.Add('None');
    LogoRes.Add('600p 4:3 - 800x600 (Default)');
    LogoRes.Add('720p 4:3 - 960x720');
    LogoRes.Add('720p 16:9 - 1280x720');
    LogoRes.Add('1080p 4:3 - 1440x1080');
    LogoRes.Add('1440p 4:3 - 1920x1440');
    LogoRes.Add('1440p 16:9 - 2560x1440');
    LogoRes.Add('4K 4:3 - 2880x2160');
    LogoRes.Add('4K 16:9 - 3840x2160');

    frmOptions := frmOptions_CreatePage(LogoRes.ID);
    frmOptions2 := frmOptions2_CreatePage(frmOptions);

 end;

