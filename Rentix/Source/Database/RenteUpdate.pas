unit RenteUpdate;

interface

uses
  BlackboxEnums, Classes;

function UpdateRentes(aLeningGuid, RVPguid: string; aRVPvorm : RVPsoortT ; aRentebedenktijd : RBTsoortT ; aLooptijd : integer; aRentixID : string; var aRenteLijst :TList; var warnings : integer; var error:string; RVPingangsdatum: TDateTime) : integer; forward;
function VerwerktRentePatch(bestand : string; patch:integer; var MaatschappijID : integer; var Patchnaam:string) : boolean; forward;
function GetRenteID : integer; forward;
procedure UpdateRenteTeksten(aMaatschappijID:integer ; HeeftVerlengingsrente:boolean ; teksten : Tstringlist);
procedure activateNieuweRentes;
function RenteForQuery(aRente : double) : string;

implementation

uses
  RVP, SysUtils, DatabaseConnectie, ClientVariabelen, inifiles,
  RentixTools, StrUtils, dialogs;

type
  RVPdataT = class
    RVPGUID : string;
    RVPvorm : integer;
    Rentebedenktijd : integer;
    Looptijd : integer;
  end;

function RenteForQuery(aRente : double) : string;
begin
  result := Inttostr(trunc(aRente*1000)) +'/1000';
end;
  
procedure UpdateRenteTeksten(aMaatschappijID:integer;HeeftVerlengingsrente:boolean; teksten : Tstringlist);
var
  sql,s:string;
  i: integer;
  rs : TAdoRecordset;
  Bestaat : boolean;
begin
  if teksten.Count = 0 then exit;

  s := '';
  for i:= 0 to teksten.Count -1 do begin
    s := s + teksten[i] + '|';
  end;
  sql := 'SELECT * FROM Rentetekst WHERE [MaatschappijID]=' +inttostr(aMaatschappijID);
  rs := GlobalRenteDbase.OpenQuery(sql);
  Bestaat := not(rs.eof);
  GlobalRenteDbase.CloseQuery(rs);
  if Bestaat then begin
    sql := 'UPDATE Rentetekst SET [Rentetekst] = ' + quotedStr(s) + ', [HeeftVerlengingsrente] = ' +IfThen(HeeftVerlengingsrente, 'True','False')  + ' WHERE [MaatschappijID]=' + inttostr(aMaatschappijID);
  end else begin
    sql := 'INSERT INTO Rentetekst ([MaatschappijID], [HeeftVerlengingsrente], [Rentetekst]) VALUES (' +inttostr(aMaatschappijID) + ', ' + IfThen(HeeftVerlengingsrente, 'True','False') + ', ' + QuotedStr(s) + ')';
  end;
  GlobalRenteDbase.QueryExecute(sql);

end;

function UpdateRentes(aLeningGuid, RVPguid:string; aRVPvorm : RVPsoortT ; aRentebedenktijd : RBTsoortT ; aLooptijd : integer; aRentixID : string; var aRenteLijst :TList; var warnings : integer; var error:string; RVPingangsdatum: TDateTime) : integer;
var
  renteobj : Trente;
  i:integer;
  rs : TAdoRecordset;
  s:string;
//  RVPguid : string;
  aantal : integer;
  Prefix : string;
begin
  Prefix := uppercase(copy(FinixID,1,3));
  result := 0;
  error := '';

  if (RVPguid ='') then begin
    if (Prefix = 'EFS') or (Prefix = 'TST') then begin
      //melding alleen laten zien als het test-licenties zijn!
      //dit in verband met updates van leningdelen die wel in rentixtool komen
      //maar nog niet in de uitstaande HypMaatschappijDB
      inc(Warnings);
      Error := '-> Het rente update bestand geeft een rente aan voor leningproduct ' + aLeningGuid +', met een rentevastperiode van '+ inttostr(aLooptijd) +' maanden met een vorm ' + inttostr(integer(aRVPvorm)) + ', en rentebedenktijd ' + inttostr(integer(aRentebedenktijd)) + '. ' +
               'Deze rentestructuur komt niet voor in de huidige rentedatabase en kan dus niet worden gezet.'+
               'Dit is geen ernstige fout maar betekent dat het rente-update bestand niet geheel aansluit op uw database.';
      result := -1;
    end else begin
      error := '#' + aLeningGuid + '#'+ inttostr(aLooptijd) +'#' + inttostr(integer(aRVPvorm)) + '#' + inttostr(integer(aRentebedenktijd));
    end;
  end;
  if assigned(rs) then GlobalRenteDbase.CloseQuery(rs);

  if result <> -1 then
  begin
    if aRenteLijst.Count = 0 then begin
      inc(warnings);
      error := 'Geen rentes gevonden voor ' + aLeningGuid +' met looptijd: ' + inttostr(aLooptijd) + ', vorm ' + inttostr(integer(aRVPvorm)) + ', rbt ' + inttostr(integer(aRentebedenktijd));
      result := -2;

    end else begin
      for i:= 0 to aRenteLijst.Count -1 do begin
        renteobj := Trente(aRenteLijst.Items[i]);
//Plafondrente is ongebruikt. If Toch(ooit) then LET OP: rente-alert houdt hier GEEN rekening mee!
//        if aRVPvorm = rvpsPlafond then begin
//          s := 'UPDATE Rentes SET Rentes.Rente = ' + floattostr(renteobj.Rente) + ', ';
//          s:= s + 'Rentes.Plafond = ' + FloatToStr(renteobj.Plafond) + ' ';
//        end else begin
          s := 'UPDATE Rentes SET Rentes.NieuweRente=' +RenteForQuery(renteobj.Rente) + ', Rentes.NieuweRenteIngangsDatum=' + floattostr(RVPingangsdatum);
//        end;

        s := s + ' WHERE ([RVPGUID]=' + quotedstr(RVPguid) + ') and ';
        if renteobj.NHG then begin
          s := s + '[NHG] and ';
          if (renteobj.MaxEW < 999) then begin
            s:= s + '([MaximumTovEW] = '+ FloatToStr(renteobj.MaxEW) +') and ';
          end;
        end else begin
          s := s + '(not [NHG]) and ';
          s:= s + '([MinimumTovEW] = '+ FloatToStr(renteobj.MinEW) +') and ';
          s:= s + '([MaximumTovEW] = '+ FloatToStr(renteobj.MaxEW) +') and ';
        end;
        s:= s + '([NieuweRente] <> '+ RenteForQuery(renteobj.Rente) +') ';

        result := 0;
        try
          aantal := GlobalrenteDbase.QueryExecute(s);
          if aantal>0 then begin
            result := 1;
          end;
        except
          inc(Warnings);
          error := 'Een van de rentes kan niet worden ge-update. Systeemmelding: Query onuitvoerbaar "' + s + '"';
          result := -3;
        end;
      end; //for i
    end; //else (aRenteLijst.Count = 0)
  end; //result
end;


function VerwerktRentePatch(bestand : string; patch:integer; var MaatschappijID : integer; var Patchnaam:string) : boolean;
var
  f : TextFile;
  ini : TIniFile;
  s : string;
  i:integer;
  p:integer;
  fnaam:string;
  actie : integer;
  bool : boolean;
  rvp : TRVP;
  rente : Trente;
  aantalrentes:integer;
  MaxID : integer;
  rs : TAdoRecordset;

begin
  fnaam := GetTempDir + 'p' + IntToStr(patch) + '.ini';
  assignfile(f, fnaam);
  MaatschappijID := -1;
  try
    rewrite(f);
    p:=0;
    while p < length(bestand) do begin
      s := '';
      while (bestand[p]<>'#') and (p<=length(bestand)) do begin
        s := s + bestand[p];
        inc(p);
      end;
      writeln(f, s);
      inc(p);
      s := '';      
    end;
    closefile(f);
    ini := TIniFile.Create(fnaam);
    bool := ini.Readbool('info','Toevoegen',false);
    actie := -1;
    if bool then begin
      actie :=1;
    end else begin
      bool := ini.Readbool('info','Verwijderen',false);
      if bool then actie := 3;
    end;
    if actie=-1 then begin 
      result := false;
      exit;
    end;
    patchnaam := ini.ReadString('info','patchnaam',''); 
    rvp := TRVP.Create;
    rvp.MaatschappijID := ini.ReadInteger('info','maatschappijID' , -1);
    MaatschappijID := rvp.MaatschappijID; 
    rvp.LeningGUID := ini.ReadString('info', 'leningguid', '');
    rvp.guid := ini.ReadString('info','guid','');
    rvp.Naam := ini.ReadString('info','naam','');
    rvp.Rentevorm := RVPsoortT(ini.ReadInteger('info','vorm',0));
    rvp.RenteBedenktijdtype := RBTsoortT(ini.ReadInteger('info','rbtvorm',0));
    rvp.Looptijd := ini.ReadInteger('info','looptijd',0);
    rvp.RBTinMnd := ini.ReadInteger('info','rbt',0);
    s := ini.ReadString('info','bbonder','0');
    s := StringReplace(s, '.' , DecimalSeparator, [rfReplaceAll] ) ;
    s := StringReplace(s, ',' , DecimalSeparator, [rfReplaceAll] ) ;
    rvp.BBonder  := StrToFloat(s);
    s := ini.ReadString('info','bbboven','0');
    s := StringReplace(s, '.' , DecimalSeparator, [rfReplaceAll] ) ;
    s := StringReplace(s, ',' , DecimalSeparator, [rfReplaceAll] ) ;
    rvp.BBboven  := StrToFloat(s);
    aantalrentes := ini.ReadInteger('info','aantal',0);
    rvp.Rentelijst := Tlist.Create;
    for i := 1 to aantalrentes do begin
      rente := Trente.CreateSimple;
      rente.NHG := ini.ReadBool('rente' + inttostr(i) , 'nhg' , false);
      s := ini.Readstring('rente' + inttostr(i) , 'rente' , '0');
      s := StringReplace(s, '.' , DecimalSeparator, [rfReplaceAll] ) ;
      s := StringReplace(s, ',' , DecimalSeparator, [rfReplaceAll] ) ;
      rente.Rente := strtofloat(s);      
      if rente.NHG then begin
        rente.MinEW := 0;
        rente.MaxEW := 999;
      end else begin
        rente.MinEW := ini.ReadInteger('rente' + inttostr(i) , 'MINEW' , 0);
        rente.MaxEW := ini.ReadInteger('rente' + inttostr(i) , 'MAXEW' , 0);
      end;
      rvp.Rentelijst.Add(rente);
    end;

    //inlezen patch klaar
    ini.Free;
    DeleteFile(fnaam);

    bool:=false;
    rs := GlobalRenteDbase.OpenQuery('select max(ID) as maxid from rentes',false);
    MaxID := ReadDBValue(varInteger,rs,'maxid', false, bool);
    GlobalRenteDbase.CloseQuery(rs);

    MaxID := MaxID + 1;

    case actie of
      1:  //toevoegen
         begin
           try
             //haal eventueel oude rvp weg
             GlobalRenteDbase.QueryExecute('Delete from rvp where [rvp].[GUID] = ' + quotedstr(rvp.GUID));
           except
           end;

           s :=     'insert into RVP';
           s := s + '([GUID], Naam, LeningGUID, Vorm, LooptijdInMaanden, Rentebedenktijd, Rentebedenktijdvorm, BandbreedteOnder, BandbreedteBoven) ';
           s := s + 'VALUES (' +
               quotedstr(rvp.GUID) + ',' +
               quotedstr(rvp.Naam) + ',' +
               quotedstr(rvp.LeningGUID) + ',' +
               inttostr(integer(rvp.Rentevorm)) + ',' +
               inttostr(rvp.Looptijd) + ',' +
               inttostr(rvp.RBTinMnd) + ',' +
               inttostr(integer(rvp.RenteBedenktijdtype)) + ',' +
               floattostr(rvp.BBonder) + ',' +
               floattostr(rvp.BBboven) + ')';

           try
             GlobalRenteDbase.QueryExecute(s);
           except
             result := false;
             exit;
           end;

           for i:= 0 to rvp.Rentelijst.Count-1 do begin
             rente := Trente(rvp.Rentelijst[i]);
             s := 'insert into rentes';
             s := s + '( [id], [RVPGUID], NHG , MinimumTovEW, MaximumTovEW, Rente, NieuweRente, IngangsDatum, NieuweRenteIngangsDatum) values (' + inttostr(maxid) + ', ';
             s := s + quotedstr(rvp.GUID) + ',';
             if rente.NHG then begin
               s := s + 'True,';
             end else begin
               s := s + 'False,';
             end;
             s := s + FloatToStr(rente.MinEW) + ',';
             s := s + FloatToStr(rente.MaxEW) + ',';
             s := s + Floattostr(rente.rente) + ',';
             s := s + Floattostr(rente.rente) + ',';
             s := s + Floattostr(date()) + ',';
             s := s + Floattostr(date());
             s := s + ')';
             try
               p := GlobalRenteDbase.QueryExecute(s);
               maxid := maxid + 1;
             except
               GlobalRenteDbase.QueryExecute('Delete from rvp where [rvp].[GUID] = ' + quotedstr(rvp.GUID));             
               result := false;
               exit;
             end;
           end;
         end;
      3: //verwijderen
         begin
           try
             GlobalRenteDbase.QueryExecute('Delete from rvp where [rvp].[GUID] = ' + quotedstr(rvp.GUID));             
           except
             result := false;
             exit;
           end;
         end;        
    end;
    result := true;
  except
    result := false;
    exit;
  end;
end;

function  GetrenteID:integer;
var
  rs : TAdoRecordset;
begin
  rs := GlobalRenteDbase.OpenQuery('SELECT [guid] FROM rentes where (len([guid])>4) order by [guid] desc');
  try
    result := rs.Fields.Item[0].Value +1;
    GlobalRenteDbase.CloseQuery(rs);     
  except
    result := -1;
  end;
end;

procedure activateNieuweRentes;
var
  sql:string;
begin
  sql := 'UPDATE Rentes SET Rentes.Rente=Rentes.NieuweRente, Rentes.IngangsDatum=Rentes.NieuweRenteIngangsDatum';
  sql := sql + ' WHERE ([Rentes.NieuweRenteIngangsDatum]<=' + FloatToStr(date()) + ')';
  GlobalrenteDbase.QueryExecute(sql);
end;

end.


