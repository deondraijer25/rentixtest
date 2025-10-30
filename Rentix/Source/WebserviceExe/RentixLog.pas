unit RentixLog;

interface

procedure AddToLog(RentixID : String; s:string); forward;
procedure AddToLogLicentie(Licentie : String; s:string);

implementation

{
Omdat we natuurlijk multi-user moet zijn, mag slechts een client tegelijk
de log-file beschrijven. Om dit af te dwingen wordt gebruik gemaakt van een
lock-file die neergezet wordt als een client de log beschrijft. Na het schrijven
wordt de lock-file weer gewist.
Als de lock-file bestaat, dan wordt toegang voor elke (andere) client geweigerd.

Denkbaar is dat de lock-file per ongeluk blijft staan. Hiervoor is een procedure
ingebouwd dat als een lock-file ouder is dan 1 minuut hij overschreven mag worden.
}

uses SysUtils, WebserviceLock;

const
  Locknaam = 'loglock.lck';
  Lognaam = 'RentixLog.txt';

procedure AddToLogLicentie(Licentie : String; s:string);
var
  f:TextFile;
  naam : string;
  dir : string;
begin
  naam := licentie + '.txt';
  try
    dir := datapath + 'Licentie\RentixLog\' ;
    AssignFile(f, dir + naam);
    if FileExists(dir + naam) then begin
      Append(f);
    end else begin
      rewrite(f);
    end;
    writeln(f,formatdatetime('dd-mmm-yy hh:nn:ss', now) + ' ' + s);
    Flush(f);
  finally
    try
      CloseFile(f);
    except
    end;
  end;
end;

procedure AddToLogIndividueel(RentixID : String; s:string);
var
  licentie:string;
  i : integer;
begin
  licentie := '';
  for i := 1 to length(RentixID) do begin
    if odd(i) then licentie := licentie + RentixID[i];
  end;
  AddToLogLicentie(licentie, s);
end;

procedure AddToLog(RentixID : String;s:string);
var
  f:TextFile;
  fl: file of byte;
  groot:integer;
begin
  if rentixID = '' then begin
    if AddLock(Locknaam) then begin
      try
        AssignFile(fl, datapath + 'Licentie\' + Lognaam);
        Reset(fl);
        Groot := fileSize(fl);
        Closefile(fl);
        if groot>100000 then begin
          RenameFile( datapath + 'Licentie\' + Lognaam, datapath + 'Licentie\' + Lognaam +'.'+FormatDateTime('dd-mm-yyyy', now));
        end;

        AssignFile(f, datapath + 'Licentie\' + Lognaam);
        if FileExists(datapath + 'Licentie\' + Lognaam) then begin
          Append(f);
        end else begin
          rewrite(f);
        end;
        writeln(f,formatdatetime('dd-mmm-yy hh:nn:ss', now) + ' ' + s);

        Flush(f);
        CloseFile(f);
        RemoveLock(Locknaam);
      except
        on e:exception do begin
          RemoveLock(Locknaam);
        end;
      end;
    end;
  end else begin
    AddToLogIndividueel(RentixId,s);
  end;
end;


end.
