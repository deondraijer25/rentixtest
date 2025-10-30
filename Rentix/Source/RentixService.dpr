program RentixService;

{$APPTYPE CONSOLE}

uses
  WebBroker,
  CGIApp,
  WebserviceLock in 'WebserviceExe\WebserviceLock.pas',
  RentixImpl in 'WebserviceExe\RentixImpl.pas',
  RentixIntf in 'WebserviceExe\RentixIntf.pas',
  RentixLicentie in 'WebserviceExe\RentixLicentie.pas',
  RentixLog in 'WebserviceExe\RentixLog.pas',
  RentixWebmoduul in 'WebserviceExe\RentixWebmoduul.pas' {RentixWebmodule: TWebModule},
  RentixLicentieConst in 'General\RentixLicentieConst.pas',
  SOAPAttach in '..\..\D7Extensions\SOAPAttach.pas',
  Rio in '..\..\D7Extensions\Rio.pas',
  DatabaseConnectie in '..\..\HYPOTHEKEN\Source\User Interface\Controllers\DatabaseConnectie.pas',
  ADODB_TLB in '..\..\Blackbox\source\ADODB_TLB.pas',
  MiddlexRTTI in '..\..\3rd Party\QuickRTTI\MiddleXRTTI.pas',
  middlex in '..\..\3rd Party\QuickRTTI\middlex.pas',
  QuickRTTI in '..\..\3rd Party\QuickRTTI\QuickRTTI.pas',
  EfsDialogs in '..\..\HYPOTHEKEN\Source\General\EfsDialogs.pas';

{$R *.res}

begin
  Application.Initialize;               
  Application.CreateForm(TRentixWebmodule, RentixWebmodule);
  Application.Run;
end.
