program RentixXE;

{$IF CompilerVersion >= 21.0}
// Verwijder overbodige resources
// Eventueel nog extra compressen met "upx -99999 --lzma <filename.exe>"
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  FastMM4 in '..\..\D7Extensions\FastMM4\FastMM4.pas',
  Forms,
  SysUtils,
  FormMainClient in 'User Interface\FormMainClient.pas' {frmMainformClient},
  XMLimport in 'Objecten\XMLimport.pas',
  RVP in 'Objecten\RVP.pas',
  PlafondBasis in 'Database\PlafondBasis.pas',
  RenteBasis in 'Database\RenteBasis.pas',
  ADODB_TLB in 'General\ADODB_TLB.pas',
  Opties in 'General\Opties.pas',
  BlackBoxEnums in '..\..\Blackbox\source\BlackBoxEnums.pas',
  RentixTools in 'General\RentixTools.pas',
  FormOpties in 'User Interface\FormOpties.pas' {FrmOpties},
  InternetWrap in 'General\InternetWrap.pas',
  InternetLimitedWaitThread in 'General\InternetLimitedWaitThread.pas',
  ClientRunMode in 'Client\ClientRunMode.pas',
  RentixXMLconstanten in 'Objecten\RentixXMLconstanten.pas',
  RenteUpdate in 'Database\RenteUpdate.pas',
  ClientVariabelen in 'Client\ClientVariabelen.pas',
  FormLicentieActivatie in 'Client\FormLicentieActivatie.pas' {frmLicentieActivering},
  BlackboxUtilities in '..\..\Blackbox\source\BlackboxUtilities.pas',
  BBsetup in '..\..\Blackbox\source\BBsetup.pas',
  formDialogRenteUpdate in 'Client\formDialogRenteUpdate.pas' {frmDialogRenteUpdate},
  RentixLicentieConst in 'General\RentixLicentieConst.pas',
  FrameLabelPicture in 'General\FrameLabelPicture.pas' {Frame1: TFrame},
  FormMeldingen in 'User Interface\FormMeldingen.pas' {frmMeldingen},
  ModuleLijstEnum in '..\..\HYPOTHEKEN\Source\Enumeraties\ModuleLijstEnum.pas',
  EnumerationFramework in '..\..\FINANCIELE PLANNING\Source\Framework\Model\EnumerationFramework.pas',
  Enumerations in '..\..\FINANCIELE PLANNING\Source\Data Model\Enumerations.pas',
  DatabaseConnectie in '..\..\HYPOTHEKEN\Source\User Interface\Controllers\DatabaseConnectie.pas',
  RentixIntf in 'WebserviceExe\RentixIntf.pas',
  ProxySupport in '..\..\Hypotheken\Source\User Interface\Controllers\ProxySupport.pas',
  EnvironmentInstellingen in '..\..\Financiele Planning\Source\User Interface\Controllers\EnvironmentInstellingen.pas',
  DeEnCode in '..\..\Hypotheken\Source\decrypt\source\DeEnCode.pas',
  FileVersion in '..\..\Financiele Planning\Source\General\FileVersion.pas',
  MiddleXRTTI in '..\..\3rd Party\QuickRTTI\MiddleXRTTI.pas',
  StrMisc in '..\..\Financiele planning\Source\General\StrMisc.pas',
  CalcMisc in '..\..\Financiele planning\Source\General\CalcMisc.pas',
  ObjArray in '..\..\Financiele planning\Source\General\ObjArray.pas',
  ObjBase in '..\..\Financiele planning\Source\General\ObjBase.pas',
  ObjMisc in '..\..\Financiele planning\Source\General\ObjMisc.pas',
  GlobalObjectManager in '..\..\Financiele planning\Source\General\GlobalObjectManager.pas',
  DebugMisc in '..\..\FINANCIELE PLANNING\Source\General\DebugMisc.pas',
  QuickRTTI in '..\..\3rd Party\QuickRTTI\QuickRTTI.pas',
  middlex in '..\..\3rd Party\QuickRTTI\middlex.pas',
  EfsDialogs in '..\..\Hypotheken\Source\General\EfsDialogs.pas',
  InternetDownloadHandler in '..\..\FinixLicentieActivatie\InternetDownloadHandler.pas',
  InternetDownloader in '..\..\FinixLicentieActivatie\InternetDownloader.pas',
  DialogMultiDownloadVoortgang in '..\..\FinixLicentieActivatie\DialogMultiDownloadVoortgang.pas' {frmMultiDownloadVoortgang},
  DialogDownloadVoortgang in '..\..\FinixLicentieActivatie\DialogDownloadVoortgang.pas' {frmDownloadVoortgang},
  MacAdres in '..\..\Hypotheken\Source\General\MacAdres.pas',
  BlackBoxDatabaseController in '..\..\Blackbox\source\BlackBoxDatabaseController.pas',
  HarddiskSerial in '..\..\Hypotheken\Source\User Interface\Controllers\HarddiskSerial.pas',
  LicentieValidatieMelding in '..\..\FinixWebservice\LicentieValidatieMelding.pas',
  DatabaseConstanten in '..\..\Blackbox\source\DatabaseConstanten.pas',
  u_Utility in '..\..\Financiele Planning\Source\General\u_Utility.pas',
  u_SysFolders in '..\..\FinixInstaller\Source\Units\u_SysFolders.pas',
  FinixWebserviceIntf in '..\..\FinixWebservice\FinixWebserviceIntf.pas',
  TimeManager in '..\..\Hypotheken\Source\General\TimeManager.pas',
  FinixShowMessage in '..\..\Hypotheken\Source\General\FinixShowMessage.pas' {formFinixDialogbox},
  u_QueryCache in '..\..\HYPOTHEKEN\Source\User Interface\Controllers\u_QueryCache.pas',
  Win32Misc in '..\..\FINANCIELE PLANNING\Source\General\Win32Misc.pas',
  DateMisc in '..\..\Financiele planning\Source\General\DateMisc.pas',
  SystemTools in '..\..\HYPOTHEKEN\Source\General\SystemTools.pas',
  FinixLicentieCheck in '..\..\HYPOTHEKEN\Source\User Interface\Controllers\FinixLicentieCheck.pas',
  ClientDatabaseConnectie in 'Database\ClientDatabaseConnectie.pas';

{$R *.res}

begin
  Application.Initialize;
  // Application.ShowMainForm := False;


  if not RentixLocked then
  begin
    LockRentix;
    CheckRunMode;

    // Zet de lokale settings zodat hierover geen verwarring kan zijn
    FormatSettings.DecimalSeparator  := '.';
    FormatSettings.ThousandSeparator := ','; // deze wordt niet gebruikt.
    FormatSettings.DateSeparator     := '-';
    FormatSettings.ShortDateFormat   := 'd-m-yyyy';

    GlobalOpties      := TOpties.Create;
    Application.Title := 'Rentix';
    Application.CreateForm(TfrmMainformClient, frmMainformClient);
  Application.Run;
  end;
  Cleanup(False);

end.
