unit PlafondBasis;

interface

uses
  Classes,SysUtils;

type
  TPlafondBasis = class
    MaatschappijID : integer;
    LeningGuid:string;
    Looptijd : integer;
    NHG:boolean;
    Factor : double;
  end;

  TPlafondBasisLijst = class
    private
      _LijstPlafondBasis: TStringList;

      Procedure ReadLijstFromDB;

    public
      Function GetPlafondFactor(aMaatschappijID:integer; aLening:String; aLooptijd:integer; NHG:boolean): Double;
      Destructor Destroy; override;
  end;

var
  PlafondBasisLijst : TPlafondBasisLijst;
  PlafondBasisLijstCached : boolean = false;

implementation

uses
  {$ifdef is_rentixServer}ServerVariabelen, {$endif}
  DatabaseConnectie;

{ TPlafondBasisLijst }


destructor TPlafondBasisLijst.Destroy;
begin
  if Assigned(_LijstPlafondBasis) then _LijstPlafondBasis.Free;
  inherited;
end;

function TPlafondBasisLijst.GetPlafondFactor(aMaatschappijID: integer;
  aLening: String; aLooptijd: integer; NHG: boolean): Double;
var
  i:integer;
  obj : TPlafondBasis;
  gevonden : Boolean;

begin
  if not PlafondBasisLijstCached then begin
    _LijstPlafondBasis := TStringList.Create;
    ReadLijstFromDB;
  end;
  aLening := LowerCase(aLening);
  i := _LijstPlafondBasis.IndexOf(aLening);
  result := 0;
  gevonden := false;
  if i>=0 then begin
    repeat
      obj := TPlafondBasis(_LijstPlafondBasis.Objects[i]);
      if (obj.MaatschappijID = aMaatschappijID) and
         (obj.Looptijd = aLooptijd) and
         (obj.nhg=NHG) then
      begin
          Result := obj.Factor;
          gevonden := true;
      end;
      inc(i);
    until (i=_LijstPlafondBasis.count) or (obj.LeningGUID <> aLening) or (gevonden);
  end;
end;

procedure TPlafondBasisLijst.ReadLijstFromDB;
{$ifdef is_rentixserver}
var
  rs : TAdoRecordset;
  fout:boolean;
  obj : TPlafondBasis;
{$endif}
begin
{$ifdef is_rentixserver}
  rs := GlobalDbase.OpenQuery('Select * from Plafondbasis order by maatschappijID, LeningGUID');
  _LijstPlafondBasis.Sort;
  while not rs.eof do begin
    fout := false;
    obj:=TPlafondBasis.Create;
    obj.MaatschappijID := ReadDBValue(varInteger, rs, 'MaatschappijID', True, Fout);
    obj.LeningGuid := lowercase(ReadDBValue(varString, rs, 'LeningGUID', True, Fout));
    obj.Looptijd := ReadDBValue(varInteger, rs, 'Looptijd', True, Fout);
    obj.NHG := ReadDBValue(varInteger, rs, 'NHG', True, Fout);
    obj.Factor := ReadDBValue(varDouble, rs, 'Plafondfactor', true, fout);
    _LijstPlafondBasis.AddObject(obj.LeningGuid , obj);

    rs.MoveNext;
  end;
  rs.Close;
{$endif}
end;

{$ifdef is_rentixserver}
initialization
  PlafondBasisLijst := TPlafondBasisLijst.Create;
{$endif}
end.
