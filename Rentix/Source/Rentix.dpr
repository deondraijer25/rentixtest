program Rentix;

uses
  FastMM4 in '..\..\D7Extensions\FastMM4\FastMM4.pas',
  VistaManifest in '..\..\D7Extensions\Vista\VistaManifest.pas',
  OPToSOAPDomConv in '..\..\D7Extensions\OPToSoapDomConv.pas',
  Rio in '..\..\D7Extensions\Rio.pas',
  SOAPAttach in '..\..\D7Extensions\SOAPAttach.pas',
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
  ClientDatabaseConnectie in 'Database\ClientDatabaseConnectie.pas',
  ClientVariabelen in 'Client\ClientVariabelen.pas',
  FormLicentieActivatie in 'Client\FormLicentieActivatie.pas' {frmLicentieActivering},
  BlackboxUtilities in '..\..\Blackbox\source\BlackboxUtilities.pas',
  BBsetup in '..\..\Blackbox\source\BBsetup.pas',
  formDialogRenteUpdate in 'Client\formDialogRenteUpdate.pas' {frmDialogRenteUpdate},
  RentixLicentieConst in 'General\RentixLicentieConst.pas',
  FrameLabelPicture in 'General\FrameLabelPicture.pas' {Frame1: TFrame},
  FormMeldingen in 'User Interface\FormMeldingen.pas' {frmMeldingen},
  FinixLicentieCheck in '..\..\HYPOTHEKEN\Source\User Interface\Controllers\FinixLicentieCheck.pas',
  ModuleLijstEnum in '..\..\HYPOTHEKEN\Source\Enumeraties\ModuleLijstEnum.pas',
  EnumerationFramework in '..\..\FINANCIELE PLANNING\Source\Framework\Model\EnumerationFramework.pas',
  Enumerations in '..\..\FINANCIELE PLANNING\Source\Data Model\Enumerations.pas',
  DatabaseConnectie in '..\..\HYPOTHEKEN\Source\User Interface\Controllers\DatabaseConnectie.pas',
  RentixIntf in 'WebserviceExe\RentixIntf.pas',
  ProxySupport in '..\..\Hypotheken\Source\User Interface\Controllers\ProxySupport.pas',
  EnvironmentInstellingen in '..\..\Financiele Planning\Source\User Interface\Controllers\EnvironmentInstellingen.pas',
  FastMM4Messages in '..\..\D7Extensions\FastMM4\FastMM4Messages.pas',
  DeEnCode in '..\..\Hypotheken\Source\decrypt\source\DeEnCode.pas',
  FileVersion in '..\..\Financiele Planning\Source\General\FileVersion.pas',
  MiddlexRTTI in '..\..\3rd Party\QuickRTTI\MiddleXRTTI.pas',
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
  TimeManager in '..\..\Hypotheken\Source\General\TimeManager.pas';

{$R *.res}


begin
  Application.Initialize;
  {$undef EnableMemoryLeakReporting}
  if not RentixLocked then begin
    LockRentix;
    CheckRunMode;
    //Zet de lokale settings zodat hierover geen verwarring kan zijn
    DecimalSeparator := '.';
    ThousandSeparator := ','; //deze wordt niet gebruikt.
    DateSeparator := '-';
    ShortDateFormat := 'd-m-yyyy';

    GlobalOpties := TOpties.Create;
    Application.Title := 'Rentix';
    Application.CreateForm(TfrmMainformClient, frmMainformClient);
  Application.Run;
  end;
  Cleanup(False);
end.
