unit WebserviceLock;

interface

var
  datapath : string;  //de directory waar de webservice-DLL staat

{
Omdat we natuurlijk multi-user moet zijn, mag slechts een client tegelijk
de file beschrijven. Om dit af te dwingen wordt gebruik gemaakt van een
lock-file die neergezet wordt als een client de file beschrijft. Na het schrijven
wordt de lock-file weer gewist.
Als de lock-file bestaat, dan wordt toegang voor elke (andere) client geweigerd.

Denkbaar is dat de lock-file per ongeluk blijft staan. Hiervoor is een procedure
ingebouwd dat als een lock-file ouder is dan 1 minuut hij overschreven mag worden.

Lockfiles komen in dezelfde directory te staan als waar de webservice-DLL staat.
}


Function  AddLock(locknaam : String) : boolean; forward;
procedure RemoveLock(locknaam : String);  forward;


implementation

uses
  SysUtils, ComServ;

var
  lockpath : string;

Function AddLock(locknaam : String) : boolean;
var
  f:Textfile;
  teller:integer;
  oke:boolean;
begin
  result := false;
  Teller:=1;
  repeat
    oke := not FileExists(lockpath +locknaam);
    if not oke then begin
      if now - FileDateToDateTime(FileAge(lockpath +locknaam)) > 0.0007 then begin
        //lock-file bestaat al langer dan een minuut. Dit zou theoretisch niet kunnen.
        //verwijder de lockfile dus maar om deadlock te voorkomen.
        //  1/24/60 = 0.00069 = 1 minuut
        DeleteFile(lockpath +locknaam);
      end;
    end;
    if not oke then sleep(100);
    inc(teller);
  until oke or (Teller>10);
  if oke then begin
    try
      Assignfile(f,lockpath +locknaam);
      rewrite(f);
      writeln(f,'bla');
      CloseFile(f);
      result := true;
    except
      on e:exception do begin
        result := false;
      end;
    end;
  end;
end;

procedure RemoveLock(locknaam : String);
var
  teller:integer;
  oke:boolean;
begin
  teller := 1;
  oke := false;
  repeat
    if DeleteFile(lockpath +locknaam) then begin
      oke := True;
    end else begin
      teller:= teller+1;
      sleep(100);
    end;
  until oke or (teller>10);
end;

initialization
//Bepaal het pad waarin de webservice DLL geinstalleerd is (op de webserver).
  datapath := IncludeTrailingPathDelimiter(ExtractFileDir(ComServer.ServerFileName)) ;
  lockpath := datapath + 'Licentie\';
end.
