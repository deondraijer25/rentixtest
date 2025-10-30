unit RenteBasis;

interface

uses
  DatabaseConnectie, Classes;

Type

  TRenteBasis = Class
  public
    ID : integer;
    MinToEW : integer;
    MaxToEW : integer;
    Factor : Double;
    NHG : boolean;
    Basis : boolean;
    Function ReadFromDB(var rs : TAdoRecordset) : Boolean;
  end;

  TLeningRenteBasis = Class
  private
  public
    MaatschappijID : integer;
    LeningGUID : string;
    RenteBasisLijst : TStringList; //String = ID, lijst van TRenteBasis objecten
    function BepaalRente ( rente:double; EW : Double; NHG:boolean) : Double;
  end;

  TRenteBasisLijst = Class
  private
    _LijstLeningRentebasis : TStringList; //String=LeningGUID, lijst van TLeningRenteBasis objecten
  public
    procedure ReadFromDatabase;
    function GetLeningRentes( MaatschappijID : integer; LeningGUID : string) : TLeningRenteBasis;
  end;

implementation

uses
  {$ifdef is_rentixServer}ServerVariabelen, {$endif}
  SysUtils;

{ TRenteBasisLijst }

function TRenteBasisLijst.GetLeningRentes(
  MaatschappijID: integer;
  LeningGUID: string): TLeningRenteBasis;
var
  i : integer;
  Fout : boolean;
begin
  Fout := false;
  i := _LijstLeningRentebasis.IndexOf(lowercase(LeningGUID));
  if i<0 then begin
    Fout := true;
  end;
  while (not Fout) and (TLeningRenteBasis(_LijstLeningRentebasis.Objects[i]).MaatschappijID <> MaatschappijID) do begin
    inc(i);
    if TLeningRenteBasis(_LijstLeningRentebasis.Objects[i]).LeningGUID <> LeningGUID then begin
      //LeningGUID klopt niet meer -> gevraagde wordt niet gevonden.
      Fout := true;
    end;
  end;
  if not fout then begin
    result := TLeningRenteBasis(_LijstLeningRentebasis.Objects[i]);
  end else begin
    result := nil;
  end;
end;

procedure TRenteBasisLijst.ReadFromDatabase;
{$ifdef is_rentixServer}
var
  rs : TAdoRecordset;
  obj : TRenteBasis;
  SubLijst : TLeningRenteBasis;
  fout : boolean;
  mGUID:integer;
  LastmGUID:integer;
  lGuid : string;
  LastlGuid : string;
{$endif}
begin
{$ifdef is_rentixServer}
  rs := GlobalDbase.OpenQuery('Select * from Rentebasis order by maatschappijGUID, LeningGUID');

  _LijstLeningRentebasis := TStringList.Create;
  _LijstLeningRentebasis.Duplicates := dupAccept;
  _LijstLeningRentebasis.CaseSensitive := false;
  _LijstLeningRentebasis.Sorted := true;

  fout := false;
  LastmGUID := -1;
  LastlGuid := '';
  while not rs.eof do begin
    obj:=TRenteBasis.Create;
    if Obj.ReadFromDB(rs) then begin
      mGUID := ReadDBValue(varInteger, rs, 'MaatschappijGUID', true, fout);
      lGUID := ReadDBValue(varInteger, rs, 'LeningGUID', true, fout);
      if (LastmGUID = mGUID) and (LastlGuid = lGuid) then begin
        //maatschappij en lening zijn gelijk, dan toevoegen aan sublijst
        SubLijst.RenteBasisLijst.AddObject(inttostr(obj.id), obj);
      end else begin
        //anders sublijst toevoegen aan de main lijst
        //en nieuwe sublijst maken
        _LijstLeningRentebasis.AddObject( lowercase(LastlGuid) , Sublijst);
        SubLijst := TLeningRenteBasis.Create ;
        SubLijst.RenteBasisLijst := TStringList.Create;
        SubLijst.MaatschappijID := mGUID;
        SubLijst.LeningGUID := lGuid;
        SubLijst.RenteBasisLijst.AddObject(inttostr(obj.id), obj);

        LastlGuid := lGuid;
        LastmGuid := mGuid;
      end;
    end;
    rs.MoveNext;
  end;
  _LijstLeningRentebasis.AddObject( lowercase(LastlGuid) , Sublijst);
  GlobalDbase.CloseQuery(rs);
{$endif}
end;

{ TLeningRenteBasis }

function TLeningRenteBasis.BepaalRente(
  rente,
  EW: Double;
  NHG: boolean): Double;
var
  i:integer;
  obj : TRenteBasis;
begin
  for i:=0 to RenteBasisLijst.count -1 do begin
    obj := TRenteBasis(RenteBasisLijst.Objects[i]);
    if obj.NHG then begin
      if NHG then begin
         rente := obj.Factor + rente;
         break;
      end;
    end else begin
      if (ew >= obj.MinToEW) and (ew < obj.MaxToEW) then begin
        rente := obj.Factor + rente;
        break;
      end; //if
    end; //NHG
  end; //for
  result := rente;
end; //[proc

{ TRenteBasis }

function TRenteBasis.ReadFromDB(var rs: TAdoRecordset): Boolean;
//Geeft true terug als het inlezen goed is gegaan.
var
  fout : boolean;
begin
  Fout := false;
  ID      := ReadDBValue(varInteger, rs, 'ID', true, Fout);
  MinToEW := ReadDBValue(varInteger, rs, 'MinToEW', true, Fout);
  MaxToEW := ReadDBValue(varInteger, rs, 'MaxToEW', true, Fout);
  Factor  := ReadDBValue(varDouble , rs, 'Factor', true, Fout);
  NHG     := ReadDBValue(varBoolean, rs, 'NHG', true, Fout);
  Basis   := ReadDBValue(varBoolean, rs, 'Basis', true, Fout);

  result  := not fout;
end;

end.
