// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://..../scripts/RentixWebservice.dll/wsdl/IRentix
// Encoding : utf-8
// Version  : 1.0
// (30-7-2003 11:48:28 - 1.33.2.5)
// ************************************************************************ //

unit WebserviceInterface;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"
  // !:int             - "http://www.w3.org/2001/XMLSchema"
  // !:TSOAPAttachment - "http://www.borland.com/namespaces/Types"
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"


  // ************************************************************************ //
  // Namespace : urn:RentixIntf-IRentix
  // soapAction: urn:RentixIntf-IRentix#%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : rpc
  // binding   : IRentixbinding
  // service   : IRentixservice
  // port      : IRentixPort
  // URL       : http://server-euroface/scripts/RentixWebservice.dll/soap/IRentix
  // ************************************************************************ //
  IRentix = interface(IInvokable)
  ['{4AC35816-1EE4-0EF2-3227-D5221EDA1A7F}']
    function  GetRentixID(const LicentieCode: WideString; const WindowsID: WideString): WideString; stdcall;
    function  GetUpdateLijst(const RentixID: WideString;var fout:integer): WideString; stdcall;
    function  GetRenteBestand(const RentixID: WideString; const MaatschappijID: Integer): TSOAPAttachment; stdcall;
    Function  UpdateAccessDatum(aRentixID:Widestring) : Boolean; stdcall;
    function  AddLicentie(const Naam: WideString; const LicentieCode: WideString; const Password: WideString): Boolean; stdcall;
  end;

function GetIRentix(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IRentix;


implementation

uses ClientVariabelen;

function GetIRentix(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IRentix;
var
  defWSDL:string;
  defURL:string;
  defSvc:string;
  defPrt:string;
  RIO: THTTPRIO;
begin
  defWSDL := 'http://' + IPwebserver + '/scripts/RentixWebservice.dll/wsdl/IRentix';
  defURL  := 'http://' + IPwebserver + '/scripts/RentixWebservice.dll/soap/IRentix';
  defSvc  := 'IRentixservice';
  defPrt  := 'IRentixPort';

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
    Result := (RIO as IRentix);
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
  InvRegistry.RegisterInterface(TypeInfo(IRentix), 'urn:RentixIntf-IRentix', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IRentix), 'urn:RentixIntf-IRentix#%operationName%');

end.