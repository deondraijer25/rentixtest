unit XMLimport;

interface

uses
  Classes, RVP;

type
  TXMLimport = class
    private
      _MaatschappijID : integer;
      _Leningen : TStringList;
      _RenteTeksten : TStringList;
      _HeeftVerlengingsrente : boolean;
      _LastResult :string;
      _XML:string;
      CurrentLguid:string;
      Function CutPart(XMLpart:string; sectie : string; var NextCharIndex:Integer):String;
      Function ReadValue(XMLpart:string; Valuenaam : string):String;
      Function LoadFileIntoXML(Filenaam: string):boolean;
      function ReadLeningFromXML(XMLpart : String) : TList;
      function ReadRenteFromXML(XMLpart : String) : TList;
    public
      Property XML : String read _XML write _XML;
      Property Leningen : TStringList read _Leningen; //lijst van leningen. In de objecten zitten TRVP-objecten
      Property RenteTeksten : TStringList read _RenteTeksten;
      Property MaatschappijID : integer read _MaatschappijID;
      property HeeftVerlengingsrente : boolean read _HeeftVerlengingsrente;
      function LastResult : string;
      Function ImportFile(Filenaam:string; MaatschappijID : integer):Boolean;
      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses
  SysUtils, StrUtils, RentixTools, RentixXMLconstanten;

{ TXMLimport }

constructor TXMLimport.Create;
begin
  _Leningen := TStringList.Create;
  _RenteTeksten := TStringList.Create;
  _LastResult := '';
end;

function TXMLimport.CutPart(XMLpart,sectie: string; var NextCharIndex:Integer): String;
var
  First : integer;
  second:integer;
begin
  //methode 1
  //<sectie> ..... </sectie>
  first := pos('<' + sectie + '>' , xmlpart);
  Second := pos('</' + sectie + '>' , xmlpart);
  if (first>0) and (second>0) then begin
    result := copy(XMLpart, first + length(sectie)+2, Second - (first + length(sectie)+2) );
    NextCharIndex := Second + length(sectie)+3;
    exit;
  end;
  //methode 2
  //<sectie  x="1" y="rfwer" z= "tfgtr" />
  first := pos('<' + sectie , xmlpart);
  Second := pos('/>' , xmlpart);
  if (first>0) and (second>0) then begin
    result := copy(XMLpart, first + length(sectie)+1, Second - (first + length(sectie)+1) );
    NextCharIndex := Second + 2;
    exit;
  end;
  result := '';
end;

function TXMLimport.ReadValue(XMLpart, Valuenaam: string): String;
var
  First, Second : integer;
  value : string;
begin
  //methode 1
  //<valuenaam>value</valuenaam>
  First := pos('<' + Valuenaam + '>' , XMLpart);
  Second := pos('</' + Valuenaam + '>' , XMLpart);
  if (first >0) and (Second >0) then begin
    value := copy(XMLpart, First + length(Valuenaam) +2 , Second - (First + length(Valuenaam) +2));
    result := value;
    exit;
  end;
  //methode 2
  //<.....  valuenaam="value" />
  first := pos(valuenaam + '="', XMLpart);
  second := posex('"', XMLpart, first + length(valuenaam)+2);
  if (first >0) and (Second >0) then begin
    result := copy(XMLpart, First + length(Valuenaam) +2 , Second - (First + length(Valuenaam) +2));
    exit;
  end;
  result := '';
end;

destructor TXMLimport.Destroy;
begin
  _Leningen.Free;
  _RenteTeksten.Free;
end;

function TXMLimport.ImportFile(Filenaam: string; MaatschappijID : integer): Boolean;
var
  i:integer;
  part, Lening : string;
  LeningGuid : string;
  LastCharIndex : integer;
  RenteTekst : string;
begin
  if LoadFileIntoXML(filenaam) then begin
    if CutPart(_xml, HdrGeld, LastCharIndex) <> '' then begin
      LastCharIndex :=0;

      //zoek de node <Verleningsrente>
      part := _xml;
      part := CutPart(part , HdrVerleningsRente, LastCharIndex);
      _HeeftVerlengingsrente := (LowerCase(part) = 'ja');

      //zoek de node <Rentetekst>  (dit kunnen er meer zijn)
      part := _xml;
      repeat
        part := copy(part,LastCharIndex, length(part));
        RenteTekst := CutPart(part , HdrRenteTekst, LastCharIndex);
        if rentetekst <> '' then begin
          RenteTeksten.Add(RenteTekst);
        end;
      until RenteTekst = '';

      //zoek de node <Lening>  (dit kunnen er meer zijn)
      i := strtointdef(ReadValue(_xml, propNummer),-1);
      if MaatschappijID = i then begin
        Part := _XML;
        repeat
          Lening := CutPart(part, HdrLening, LastCharIndex);
          if Lening <> '' then begin
            LeningGuid := ReadValue(lening, propNummer);
            CurrentLguid := LeningGUID;
            _Leningen.AddObject(LeningGuid , ReadLeningFromXML(Lening) );

            Delete(Part, 1, LastCharIndex -1);
          end;
        until Lening= '';
        result := true;
      end else begin
        result := false;
        _LastResult := 'MaatschappijID uit bestandsnaam matched niet met de maatschappijID in het XML.';
      end;
    end else begin
      result := false;
      _LastResult := 'Dit is geen XML-bestand dat door Rentix gebruikt kan worden.';
    end;
  end else begin
    result := false;
    _LastResult := 'Inlezen XML-bestand mislukt.';
  end;
  if _Leningen.Count =0 then begin
    result := false;
    _LastResult := 'Het XML-bestand bevat geen enkel leningproduct (dus ook geen rentes).';
  end;
end;

function TXMLimport.LastResult: string;
begin
  result := _LastResult;
end;

function TXMLimport.LoadFileIntoXML(Filenaam: string): boolean;
var
  f:textfile;
  s:string;
begin
  _XML := '';
  if FileExists(filenaam) then begin
    AssignFile(f,Filenaam);
    FileMode := fmOpenRead;
    reset(f);
    while not eof(f) do begin
      Readln(f,s);
      StringReplace(s,#13,'',[rfReplaceAll]); //CR weghalen
      StringReplace(s,#10,'',[rfReplaceAll]); //LF weghalen
      StringReplace(s,#9,#32,[rfReplaceAll]);  //tabs vertalen naar spatie
      StringReplace(s,#32#32,#32,[rfReplaceAll]);  //twee spaties verkorten naar 1
      _XML := _XML + s;
    end;
    CloseFile(f);
    result := true;
  end else begin
    result := false;
  end;
end;

function TXMLimport.ReadLeningFromXML(XMLpart: String): TList;
var
  RVPpart:string;
  LastCharIndex : integer;
  obj : TRVP;
begin
  Result := TList.Create;
  repeat
    RVPpart := CutPart(XMLpart, HdrRvp , LastCharIndex);
    if RVPpart <> '' then begin
      obj := TRVP.create;
      obj.MaatschappijID := _MaatschappijID;
      obj.LeningGUID := CurrentLguid;
      Obj.Datum := ConvertDatumYearFirst(ReadValue(RVPpart, PropDatum));
      obj.Code := ReadValue(RVPpart, PropCode);
      obj.GUID := ReadValue(RVPpart, PropGUID);
      obj.Looptijd := StrToIntdef(readvalue(RVPpart, PropLooptijd),0);
      obj.Rentelijst := ReadRenteFromXML(RVPpart);
      Result.add(obj);
      Delete(XMLpart, 1, LastCharIndex -1);
    end;
  until RVPpart ='';
end;

function TXMLimport.ReadRenteFromXML(XMLpart: String): TList;
var
  RentePart:string;
  LastCharIndex : integer;
  nhg : Boolean;
  Rente:Double;
  Plafond : double;
  MinEW,MaxEW:double;
begin
  Result := TList.Create;
  repeat
    RentePart := CutPart(XMLpart, hdrRentes, LastCharIndex);
    if RentePart <> '' then begin
      NHG := (ReadValue(RentePart, propNhg) = '1');
      Rente := StrToFloatDef(CorrigeerDecimalSeparator(ReadValue(RentePart,propRente)),0);
      Plafond := StrToFloatDef(CorrigeerDecimalSeparator(ReadValue(RentePart,propPlafond)),0);
      if not NHG then begin    
        minEW := StrToFloatDef(ReadValue(RentePart,PropMinew),0);
        maxEW := StrToFloatDef(ReadValue(RentePart,PropMaxew),0);
      end else begin
        minEW := StrToFloatDef(ReadValue(RentePart,PropMinew),-1);
        maxEW := StrToFloatDef(ReadValue(RentePart,PropMaxew),-1);

        if (minew=-1) or (maxEW=-1) then begin        
          minEW := 0;
          maxEW := 999;
        end;        
      end;
      Result.add(TRente.Create(Rente, NHG, Minew,Maxew,plafond));

      Delete(XMLpart, 1, LastCharIndex -1);
    end;
  until RentePart ='';
end;


end.
