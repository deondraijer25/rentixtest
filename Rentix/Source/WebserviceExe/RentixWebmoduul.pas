{ SOAP WebModule }
unit RentixWebmoduul;

interface

uses
  SysUtils, Classes, HTTPApp, InvokeRegistry, WSDLIntf, TypInfo,
  WebServExp, WSDLBind, XMLSchema, WSDLPub, SOAPPasInv, SOAPHTTPPasInv,
  SOAPHTTPDisp, WebBrokerSOAP, Rentixlog, ComServ;

type
  TRentixWebmodule = class(TWebModule)
    HTTPSoapDispatcher1: THTTPSoapDispatcher;
    HTTPSoapPascalInvoker1: THTTPSoapPascalInvoker;
    WSDLHTMLPublish1: TWSDLHTMLPublish;
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure RentixWebmodulelicentieAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RentixWebmodule: TRentixWebmodule;

implementation

{$R *.dfm}

uses
  Inifiles, WebserviceLock, RentixLicentie, StrUtils, ComObj, forms;

type 
  dataT = class
    naam :string;
    datum :string; 
    actief :string; 
    RentixID :string; 
    Lic :string;
  end;

  procedure TRentixWebmodule.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  WSDLHTMLPublish1.ServiceInfo(Sender, Request, Response, Handled);
end;

function GetdateStr(dt:string):string;
var
  j,m,d,h,mm,s:string;
begin
  if dt='' then begin
    result := '';
    exit;
  end;
  j := copy(dt,1,4);
  delete(dt,1,5);
  m := copy(dt,1, pos(',',dt)-1);
  delete(dt,1,pos(',',dt));
  d := copy(dt,1, pos(',',dt)-1);
  delete(dt,1,pos(',',dt));
  h := RightStr('00' + copy(dt,1, pos(',',dt)-1),2) ;
  delete(dt,1,pos(',',dt));
  mm := rightstr('00'+copy(dt,1, pos(',',dt)-1), 2);
  delete(dt,1,pos(',',dt));
  s := rightstr('00' + copy(dt,1, pos(',',dt)-1), 2);

  result := d + '-' + m + '-' + j + ', ' + h + ':' +mm + ':' + s;    

end;

procedure TRentixWebmodule.RentixWebmodulelicentieAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);

   
  
var
  obj : dataT;
  s: TSearchRec;
  door:boolean;
  f:TIniFile;
  sl:TstringList;
  u:string;
  code : string;
  i:integer;
  Lockpath:string;
  tf:textfile;
begin
  lockpath := datapath + 'Licentie\';

  u := '<html><body><h1><u>RENTIX LICENTIES</u></h1><p>'#13;
  code := copy(Request.Query,2,10);
  if code = inttostr(trunc(date)) then begin

    i := findfirst(datapath + licdir + '*.lic', faAnyFile , s);
    if i=0 then begin
      door := true;
      sl := TStringList.Create;
      sl.Sorted := true;
      u := u + '<table width="100%" border="1">'#13;
      u := u + '  <td width="50" valign=center bgcolor="#000000" STYLE="color: #ffffff">'#13;
      u := u + '    <b>Licentie</b>'#13'</td>'#13;
      u := u + '  <td width="50" valign=center bgcolor="#000000" STYLE="color: #ffffff">'#13;
      u := u + '    <b>Naam</b>'#13'</td>'#13;
      u := u + '  <td width="50" valign=center bgcolor="#000000" STYLE="color: #ffffff">'#13;
      u := u + '    <b>datum laatst actief</b>'#13'</td>'#13;
      u := u + '  <td width="50" valign=center bgcolor="#000000" STYLE="color: #ffffff">'#13;
      u := u + '    <b>RentixID</b>'#13'</td>'#13;
      u := u + '  <td width="50" valign=center bgcolor="#000000" STYLE="color: #ffffff">'#13;
      u := u + '    <b>Aanmaakdatum</b>'#13'</td>'#13;
    
      While door do begin
        f := TIniFile.Create(datapath + licdir +s.Name);
        obj := dataT.Create;
        
        obj.naam := f.ReadString('licentie', 'naam','');
        obj.datum := f.ReadString('licentie', 'accessdatum','');
        obj.actief := f.ReadString('licentie', 'aanmaakdatum',''); 
        obj.RentixID := f.ReadString('licentie', 'rentixid','');
        obj.Lic := f.ReadString('licentie', 'licentiecode','');

        f.Free;
        obj.datum := GetdateStr(obj.datum);
        obj.actief := GetdateStr(obj.actief);
        if obj.datum = '' then obj.datum := 'Nog niet geactiveerd';

        sl.AddObject(obj.Lic, obj);
      
        door := (FindNext(s)=0);
      end;
      FindClose(s);

      for i :=0 to sl.Count -1 do begin
        obj := dataT(sl.objects[i]);
        u := u +'<tr>'#13;
        u := u + '<td valign=center>' + obj.lic + '</td>'#13;
        u := u + '<td valign=center>' + obj.naam + '</td>'#13;
        u := u + '<td valign=center>' + obj.datum + '</td>'#13;
        u := u + '<td valign=center>' + obj.RentixID + '</td>'#13;
        u := u + '<td valign=center>' + obj.actief + '</td>'#13;
        u := u + '</tr>'#13;
      end;


      u := u + '</table>'#13;
    end else begin
      u := u + 'Licentiebestanden niet gevonden of er is een fout opgetreden.<p>'#13;
      u := u + 'datapath = "' + datapath + '"<p>'#13;
      u := u + 'Licdir = "' + licdir + '"<p>'#13;
    end;
  end else begin
    u := u + 'U heeft geen toegang op deze pagina.<p>'#13;
    try
      u := u + 'datapath = "' + lockpath +'loglock.lck"<p>'#13;
      Assignfile(tf,lockpath +'loglock.lck');
      rewrite(tf);
      writeln(tf,'bla');
      CloseFile(tf);
      u := u + 'Lockfile oke<p>'#13;
    except
      on e:exception do begin
        u := u + 'lockfile mislukt ' + e.Message + '<br>';
      end;
    end;
    try
      DeleteFile(lockpath + 'loglock.lck');
      u := u + 'Lockfile deleted<p>'#13;
    except
      on e:exception do begin
        u := u + 'lockfile verwijderen mislukt ' + e.Message + '<br>';
      end;
    end;



    try
      AddToLog('', 'Kale aanroep licentie');
      u := u + 'Logged<p>'#13;
    except
      on e:exception do begin
        u := u + 'error ' + e.Message;
      end;
    end;

  end;
  u := u + '</body></html>'#13;

  Response.Content := u;
end;

end.













