unit RenteXMLmaak;

interface

uses
  Classes;

type
  TRenteXMLmaak = class
    private
      Tekst : TStringList;
    public
      constructor Create;
      Destructor Destroy; override;

      procedure AddStartMaatschappijID(aMaatschappijID : integer);
      procedure AddEndMaatschappijID;

      procedure AddStartProduct(aProductGUID : string);
      procedure AddEndProduct;

      procedure AddStartRVP(aCode : string; aLooptijd: integer; aDatum:TDatetime);
      procedure AddEndRVP;

      procedure AddStartRente(aRente:double; aNHG : boolean; aMinEW, aMaxEW :double; aPlafond:Double=-100);
      procedure AddEndRente;

      function SaveToFile(Filenaam:string) : string;
      function GetText : string;

  end;

implementation

uses
  SysUtils, RentixXMLconstanten;

{ TRenteXMLmaak }

procedure TRenteXMLmaak.AddEndMaatschappijID;
begin
  tekst.add('</' + hdrGeld + '>');
end;

procedure TRenteXMLmaak.AddEndProduct;
begin
  tekst.add('</' + HdrLening + '>');
end;

procedure TRenteXMLmaak.AddEndRente;
begin
//  tekst.add('</' + HdrRentes + '>');
end;

procedure TRenteXMLmaak.AddEndRVP;
begin
  tekst.add('</' + HdrRvp + '>');
end;

procedure TRenteXMLmaak.AddStartMaatschappijID(aMaatschappijID: integer);
begin
  tekst.add('<' + hdrGeld + '>');
  tekst.add('<' + PropNummer + '>' + IntToStr (aMaatschappijID ) + '</' + PropNummer +'>');
end;

procedure TRenteXMLmaak.AddStartProduct(aProductGUID: string);
begin
  tekst.add('<' + HdrLening + '>');
  tekst.add('<' + PropNummer + '>' + aProductGUID + '</' + PropNummer +'>');
end;

procedure TRenteXMLmaak.AddStartRente(aRente: double; aNHG: boolean;
  aMinEW, aMaxEW: double; aPlafond:Double);
var
  s: string;
begin
{  tekst.add('<' + HdrRentes + '>');
  if aNHG then begin
    tekst.add('<' + PropNhg  + '>1</' + propNhg +'>');
  end else begin
    tekst.add('<' + PropNhg  + '>0</' + propNhg +'>');
    tekst.add('<'+ PropMinew +'>'+ FloatToStr(aMinEW) +'</'+ PropMinew +'>');
    tekst.add('<'+ PropMaxew +'>'+ FloatToStr(aMaxEW) +'</'+ PropMaxew +'>');
  end;
  Tekst.Add('<'+ PropRente +'>' + FloatToStr(aRente ) + '</'+ PropRente +'>');
  if aPlafond <> -100 then begin
    Tekst.Add('<'+ PropPlafond +'>' + FloatToStr(aPlafond) + '</'+ PropPlafond +'>');
  end;
}
  s := '<' + HdrRentes + ' ';
  if aNHG then begin
    s := s + PropNhg + '="1" ';
  end else begin
    s := s + PropNhg + '="0" ' + PropMinew + '="' + FloatToStr(aMinEW) +'" ';
    s := s + PropMaxew + '="' + FloatToStr(aMaxEW) +'" ';
  end;
  s := s + PropRente + '="' + FloatToStr(aRente ) + '" ';
  if aPlafond <> -100 then begin
    s := s + PropPlafond + '="' + FloatToStr(aPlafond ) + '" ';
  end;
  s := s + ' />';
  Tekst.add(s);

end;

procedure TRenteXMLmaak.AddStartRVP(aCode: string; aLooptijd: integer;
  aDatum: TDatetime);
begin
  tekst.add('<' + HdrRvp + '>');
  tekst.add('<'+PropCode + '>' + aCode + '</' + PropCode + '>');
  tekst.add('<'+Proplooptijd + '>' + IntToStr (aLooptijd) + '</'+Proplooptijd + '>');
  tekst.add('<'+PropDatum + '>' +  FormatDateTime('yyyymmdd', aDatum )  + '</'+PropDatum + '>');
end;

constructor TRenteXMLmaak.Create;
begin
  Tekst := TStringList.Create;
end;

destructor TRenteXMLmaak.Destroy;
begin
  Tekst.free;
end;

function TRenteXMLmaak.GetText: string;
begin
  result := Tekst.GetText;
end;

function TRenteXMLmaak.SaveToFile(Filenaam: string) : string;
var
  f:textfile;
  i:integer;
begin
  Assignfile(f, filenaam);
  FileMode := fmOpenReadWrite;
  try
    rewrite(f);
    for i := 0 to Tekst.Count -1 do begin
      Writeln(f, tekst.strings[i]);
    end;
    closefile(f);
    result := '';
  except
    on e:exception do begin
      result := 'Er is iets misgegaan bij het saven van de file : "'#13#10
                + filenaam + '"'#13#10 + e.message;
    end;
  end;
end;

end.
