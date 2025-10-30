unit CSV;

interface

uses
  Classes;

const
  //Standaards
  kolLeningGUID = 1;
  kolLooptijd = 2;
  kolRVPcode =3;
  kolDatum = 7;
  kolRente = 8;
  kolRenteNHG = 9;
  kolRenteOmzetten = 10;
  kolRenteNHGomzetten = 11;


type
  TCSVregel = class
    tekst:string;
    AantalKolommen:integer;
    function GetLeningGUID : String;
    function GetLooptijd : integer;
    function GetRVPcode : string;
    function GetDatum : TDatetime;
    function GetRente : Double;
    function GetRenteNHG : Double;
    function GetRenteOmzetten : Double;
    function GetRenteNHGOmzetten : Double;
    function HeeftPlafondRente : boolean;
    function IsOverbruggingRente : boolean;

    function GetKolom(Kolomnr:integer) : String;
    constructor Create(aTekst : string; anAantalKolommen:integer);
  end;

  TCSVobject = class
    AantalKolommen: integer;
    Lijnen : TstringList;
    ProductLijst : TStringList;
    MaatschappijID:integer;
    naam : string;

    procedure LeesBestandIn(filenaam:string);
    function GetKolom(regel:string; Kolomnr:integer) : String;
  end;


implementation

uses SysUtils, StrUtils, RentixTools, BlackBoxEnums;

{ CSVobject }

const
  seperator = ';';

procedure TCSVobject.LeesBestandIn(filenaam: string);
var
  f:textfile;
  s:string;
  prevProd :string;
  regel : TCSVregel;
  PRod:string;
  i:integer;
  sublijst : TStringList;
begin
  Lijnen := TStringList.create;
  ProductLijst := TStringList.Create;
  naam := ExtractFileName(filenaam);

  AssignFile(f, filenaam);
  FileMode := fmOpenRead;
  try
    s := ExtractFileName(filenaam);
    i := pos('_',s) + 1;
    s := copy(s, i , posex('_', s, i)-i);
    MaatschappijID := strtointdef(s, -1);
    if MaatschappijID>=0 then begin
      Reset(f);
      Readln(f,s);
      Closefile(f);

      for i := 1 to length(s) do begin
        if s[i] = seperator then begin
          inc(AantalKolommen);
        end;
      end;
      if (s[length(s)] <> seperator) then begin
        inc(AantalKolommen);
      end;


      sublijst := TStringList.Create;
      prevProd := '';
      Reset(f);
      while not eof(f) do begin
        Readln(f,s);
        Lijnen.add(s);
        Regel := TCSVregel.Create(s, AantalKolommen);
        if regel.GetLeningGUID <> '' then begin  //Filter lege regels en regels met alleen maar lege kolommen eruit (";;;;;;;")
          prod := regel.GetLeningGUID;
          if prevProd <> Prod then begin
            if sublijst.Count >0 then begin
              ProductLijst.AddObject(PrevProd, sublijst);
            end;
            sublijst := TStringList.Create;
          end;
          sublijst.AddObject(s, regel);
        end;
        prevProd := prod;
      end;
      if sublijst.Count >0 then begin
        ProductLijst.AddObject(PrevProd, sublijst);
      end;
      Closefile(f);
    end else begin
      Raise exception.Create('MaatschappijID staat niet in de filenaam van het CSV-bestand.');
    end;
  except
    on e:exception do begin
      raise exception.Create('Inlezen CSV-bestand "' + filenaam +'" mislukt.'#13#10 +
          'Systeemmelding: ' + e.Message );
    end;
  end; //except
end;

function TCSVobject.GetKolom(regel: string; Kolomnr:integer): String;
var
  obj:TCSVregel;
begin
  obj := TCSVregel.Create(regel, Aantalkolommen);
  obj.tekst := regel;
  result := obj.GetKolom(kolomnr);
  obj.free;
end;

{ TCSVregel }

constructor TCSVregel.Create(aTekst: string; anAantalKolommen: integer);
begin
 self.AantalKolommen := anAantalKolommen;
 tekst := aTekst;
end;

function TCSVregel.GetDatum: TDatetime;
var
  s: string;
begin
  s := CorrigeerDatumSeparator(GetKolom(koldatum));
  result := StrToDateDef(s , date());
end;

function TCSVregel.GetKolom(Kolomnr: integer): String;
var
  index:integer;
  PrevIndex:integer;
  gevonden : boolean;
  teller : integer;
begin
  gevonden := false;
  teller := 1;
  PrevIndex := 1;
  result := '';
  repeat
    index := PosEx(seperator, tekst, PrevIndex);
    if teller = AantalKolommen then begin
      result := copy(tekst,PrevIndex, length(tekst));
    end else begin
      if (teller = Kolomnr) and (index>0) then begin
        Result := copy(tekst,PrevIndex, index - PrevIndex);
        gevonden := true;
      end;
    end;
    inc(teller);
    PrevIndex := index + 1;
  until (gevonden) or (teller>AantalKolommen);
end;

function TCSVregel.GetLeningGUID: String;
begin
  result := GetKolom(kolLeningGUID);
end;

function TCSVregel.GetLooptijd: integer;
begin
  Result := strtointdef(getKolom(kolLooptijd), 0 );
end;

function TCSVregel.GetRente: Double;
var
  s: string;
begin
  s := CorrigeerDecimalSeparator(getkolom(kolRente));
  result := strtofloatdef(s, 0);
end;

function TCSVregel.HeeftPlafondRente: Boolean;
var
  s: string;
  int:integer;
begin
  s := GetRVPcode;
  int := strtointdef(s, -1);
  if int>-1 then begin
    result := ((int mod 10) = integer(rvpsPlafond));
  end else begin
    result :=false;
  end;
end;

function TCSVregel.GetRenteNHG: Double;
var
  s: string;
begin
  s := CorrigeerDecimalSeparator(getkolom(kolRenteNHG));
  result := strtofloatdef(s, 0);
end;

function TCSVregel.GetRenteNHGOmzetten: Double;
var
  s: string;
begin
  s := CorrigeerDecimalSeparator(getkolom(kolRenteNHGomzetten));
  result := strtofloatdef(s, 0);
end;

function TCSVregel.GetRenteOmzetten: Double;
var
  s: string;
begin
  s := CorrigeerDecimalSeparator(getkolom(kolRenteOmzetten));
  result := strtofloatdef(s, 0);
end;

function TCSVregel.GetRVPcode: string;
begin
  result := getkolom(kolRVPcode);
end;

function TCSVregel.IsOverbruggingRente: boolean;
var
  s: string;
  int:integer;
begin
  s := GetRVPcode;
  int := strtointdef(s, -1);
  if int>-1 then begin
    result := ((int mod 10) = integer(rvpsOverbrug));
  end else begin
    result :=false;
  end;
end;

end.
