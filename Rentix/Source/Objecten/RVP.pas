unit RVP;

interface

uses
  Classes,
  {$IFNDEF IS_RENTIXCLIENT} CSV, {$ENDIF}
  RenteBasis,
  BlackboxEnums;

type
  Trente=class
    NHG : boolean;
    MinEW : double;
    MaxEW : double;
    Rente : double;
    Plafond : double;
    constructor CreateSimple;
    constructor Create(aRente:Double; isNHG: boolean; aMinEw, aMaxEw : double; aPlafond:double=0);
  end;

  TRVP = class
    private
      _Code : string;
      procedure SetCode(value:string);
    public
      MaatschappijID:integer;
      LeningGUID : string;
      Datum : TDatetime;
      RenteBedenktijdtype : RBTsoortT;
      Rentevorm : RVPsoortT;
      GUID : string;
      Naam : string;
      RBTinMnd : integer;
      BBonder : double;
      BBboven : double;

      Looptijd : integer; //in maanden
      Rentelijst : TList; //lijst van rentes. In de objecten zitten TRente-objecten
      property Code : string read _Code write SetCode;
      procedure Add(aRente : TRente);
      {$IFNDEF IS_RENTIXCLIENT}
      procedure VulRVP(BasisrenteLijst: TLeningRenteBasis; aCSVregel : TCSVregel);
      {$ENDIF}
      constructor Create;
      Destructor destroy; override;
  end;

{**
RVP code is als volgt samengesteld:

1=vaste rente
2=variable rente
3=Bandbreedte
4=correctierente ( HDN code, geen idee wat dit is)
5=plafondrente/click

10=geen rentebedenktijd
20=rentebedenktijd vooraf
30=rentebedenktijd achteraf

code 33 is dus bandbreedte rente met rentebedenktijd achteraf.

De "code" is een string om compatibel te blijven met Stater
}
implementation

uses SysUtils;

{ Trente }

constructor Trente.Create(aRente: Double; isNHG: boolean; aMinEw, aMaxEw: double; aPlafond:double);
begin
  Rente := aRente;
  NHG := isNHG;
  MinEW   := aMinEw;
  MaxEW   := aMaxEw;
  Plafond := aPlafond;
end;

constructor Trente.CreateSimple;
begin
  inherited create;
end;

{ TRVP }

procedure TRVP.Add(aRente: TRente);
begin
  Rentelijst.Add(aRente);
end;

constructor TRVP.Create;
begin
  Rentelijst := TList.Create;
end;

destructor TRVP.destroy;
begin
  Rentelijst.free;
end;

procedure TRVP.SetCode(value: string);
var
  intcode:integer;
begin
  _Code := value;
  intcode := StrToIntDef(_code, -1);
  if intcode >=0 then begin
    case intcode of
      10..19 : RenteBedenktijdtype := rbtsGeen;
      20..29 : RenteBedenktijdtype := rbtsVooraf ;
      30..39 : RenteBedenktijdtype := rbtsAchteraf ;
    end;
    case (intcode mod 10) of
      0 : Rentevorm := rvpsOngedefinieerd;
      1 : Rentevorm := rvpsVast;
      2 : Rentevorm := rvpsVariabel;
      3 : Rentevorm := rvpsBandbreedte;
      4 : Rentevorm := rvpsCorrectierente;
      5 : Rentevorm := rvpsPlafond;
      6 : Rentevorm := rvpsOverbrug;
    end;
  end else begin
    Rentevorm := rvpsOngedefinieerd;
    RenteBedenktijdtype := rbtsOngedefinieerd;
  end;
end;

{$IFNDEF IS_RENTIXCLIENT}
procedure TRVP.VulRVP(BasisrenteLijst: TLeningRenteBasis; aCSVregel: TCSVregel);
var
  brente : double;
  brenteNHG : double;
  datestr : string;
  temp:string;
  obj : Trente;
  i:integer;
  renteElement: TRenteBasis;
begin
  MaatschappijID := BasisrenteLijst.MaatschappijID;
  LeningGUID := BasisrenteLijst.LeningGUID;
  datestr := aCSVregel.GetKolom(kolDatum);
  Datum := StrToDateDef(datestr, date );
  Code := aCSVregel.GetKolom(kolRVPcode);
  Looptijd := StrToIntDef(aCSVregel.GetKolom(kolLooptijd), 0);
  temp := StringReplace( aCSVregel.GetKolom(kolrente) , ',',DecimalSeparator,[rfReplaceAll] );
  brente := strtofloatdef(temp, 0);
  temp := StringReplace( aCSVregel.GetKolom(kolRenteNHG) , ',',DecimalSeparator,[rfReplaceAll] );
  brenteNHG := strtofloatdef(temp,0);

  for i := 0 to BasisrenteLijst.RenteBasisLijst.Count-1 do begin
    renteElement := TRenteBasis( BasisrenteLijst.RenteBasisLijst.Objects[i]);
    obj := Trente.Create( brente + renteElement.Factor , false, renteElement.MinToEW, renteElement.MaxToEW);
    Rentelijst.Add(obj);
  end;
end;{$ENDIF}


end.
