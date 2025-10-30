{ Invokable interface IRentix }

unit RentixIntf;

interface

uses InvokeRegistry, Types, XSBuiltIns, SOAPHTTPClient;

type

  { Invokable interfaces must derive from IInvokable }
  IRentix = interface(IInvokable)
  ['{BE6C9AEB-6ABE-4356-B524-D13A3B22769C}']
    Function TestMe : WideString; stdcall;
    Function GetRentixID(LicentieCode : Widestring; WindowsID:Widestring) : WideString; stdcall;
    Function GetUpdateLijst(RentixID:Widestring;var fout:integer) : WideString; stdcall;
    Function GetRenteBestand(RentixID:Widestring; MaatschappijID:Integer; var fout:integer) : TSOAPAttachment; stdcall;
    Function GetRenteBestandV2(RentixID:Widestring; MaatschappijID:Integer; ClientLaatsteDatum : integer; var ServerLaatsteDatum : integer; var fout:integer) : TSOAPAttachment; stdcall;
    Function GetRenteBestandV3(RentixID:Widestring; MaatschappijID:Integer; ClientLaatsteDatum : TDateTime; var ServerLaatsteDatum : TDateTime; var fout:integer) : TSOAPAttachment; stdcall;
    Function GetRenteBestandV4(RentixID:Widestring; MaatschappijID:Integer; ClientLaatsteDatum : TDateTime; var ServerLaatsteDatum : TDateTime; var fout:integer) : TSOAPAttachment; stdcall;
    Function GetRenteBestandV5(RentixID:Widestring; MaatschappijID:Integer; ClientLaatsteDatum : TDateTime; var ServerLaatsteDatum : TDateTime; var fout:integer; NieuweRentesOphalen:boolean) : TSOAPAttachment; stdcall;
    function GetRenteBestandV6(FinixID: Widestring; MaatschappijID: Integer; var fout: integer; NieuweRentesOphalen: boolean): TSOAPAttachment; stdcall;
    Function PutRenteUpdateBestand(aMaatschappijID:integer; aBestand : TSOAPAttachment; aIngangsdatum : TdateTime; Password : string;Gebruiker:string; Overwrite:boolean) : integer; stdcall;
    Function UpdateAccessDatum(aRentixID:Widestring) : Boolean; stdcall;
    Function AddLicentie(Naam:Widestring; LicentieCode : Widestring; Password:Widestring; var fout:integer): boolean; stdcall;
    function ResetClientUpdateDatum(RentixID:WideString; Password:Widestring):boolean; stdcall;  
    function ResetLicentie(Licentie : widestring; Password: Widestring): boolean; stdcall;
    function KillLicentie(Licentie : widestring; Password: Widestring): boolean; stdcall;    
    function GetMetaUpdate(RentixID:Widestring; LastPatch:Integer; var fout:integer) : WideString; stdcall;
    function GetDatabasePatch(RentixID:Widestring; Patchnummer:Integer; var fout:integer) : widestring; stdcall;
    function RenameLicentie(OldRentixID : widestring; NewPrefix : widestring): boolean; stdcall;
    Function GetSheetVersieEnDatum(FinixID:Widestring; MaatschappijID:Integer; Toekomst : boolean; var Ingangsdatum:TdateTime; var fout:integer) : integer; stdcall;

    { Methods of Invokable interface must not use the default }
    { calling convention; stdcall is recommended }
  end;

  IRentixT=IRentix;
  
function GetIRentix(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IRentix;


implementation

function GetIRentix(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IRentixT;
const
  defWSDL = 'http://ws.euroface.nl/scripts/RentixService.exe/wsdl/IRentix';
  defURL  = 'http://ws.euroface.nl/scripts/RentixService.exe/soap/IRentix';
  defSvc  = 'IRentixservice';
  defPrt  = 'IRentixPort';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as IRentixT);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;

initialization
  { Invokable interfaces must be registered }
  InvRegistry.RegisterInterface(TypeInfo(IRentix));

end.
