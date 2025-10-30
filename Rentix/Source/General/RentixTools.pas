unit RentixTools;

interface

{$warn SYMBOL_PLATFORM	off}


function CorrigeerDecimalSeparator(value : string) : string; Forward;
function CorrigeerDatumSeparator(value : string) : string; Forward;
function ConvertDatumYearFirst(value : string) : TDateTime; Forward;
Function GetTempDir : String; Forward;
Function Enigma(value:String; DoeCodeer : boolean; Codewoord:string) : string; forward;
Function GetWindowsID:string; forward;

var
  IDbekend : boolean = false;
  WinID : string;

implementation

uses
  SysUtils, DateUtils, Windows, Shellapi, registry,                                            
  u_Utility, u_SysFolders;

Function Enigma(value:String; DoeCodeer : boolean; Codewoord:string) : string;
var
  i,j:integer;
  k:integer;
  r:string;
begin
  if DoeCodeer then begin
    r := value;
    for i := 1 to length(value) do begin
      j := i mod 5;
      k := ord(value[i]) + ord(codewoord[j]);
      if k>255 then begin
        k := k-255;
      end;
      r[i] := chr(k);
    end;
    result :=r;
  end else begin
    r := value;
    for i := 1 to length(value) do begin
      j := i mod 5;
      k := ord(value[i]) - ord(codewoord[j]);
      if k<0 then begin
        k := k +255;
      end;
      r[i] := chr(k);
    end;
    result :=r;
  end;
end;

function CorrigeerDecimalSeparator(value : string) : string;
var
  NotTheDecimalSeparator : char;
begin
  NotTheDecimalSeparator := ',';
  if DecimalSeparator = '.' then NotTheDecimalSeparator := ',';
  if DecimalSeparator = ',' then NotTheDecimalSeparator := '.';
  result := StringReplace(value, NotTheDecimalSeparator , DecimalSeparator, [rfReplaceAll]);
end;

function CorrigeerDatumSeparator(value : string) : string;
var
  i:integer;
begin
  result := '';
  for i := 1 to length(value) do begin
    if not (value[i] in ['0'..'9']) then begin
      result := result + DateSeparator;
    end else begin
      result := result + value[i];
    end;
  end;
end;

function ConvertDatumYearFirst(value : string) : TDateTime;
var
  y,m,d:integer;
begin
  if length(value) = 8 then begin
    y := StrToInt(copy(value,1,4));
    m := StrToInt(copy(value,5,2));
    d := StrToInt(copy(value,7,2));
    Result := encodeDate(y,m,d);
  end else begin
    result := date;
  end;
end;

Function GetTempDir : String;
//var
//  buffer:array[0..255] of char;
//  i:integer;
begin
//  i:=GetTempPath ( 255, @buffer);
//  if i<>0 then begin
//    result := IncludeTrailingBackslash(buffer);
//  end else begin
//    Result := 'c:\temp\';
//  end;
//  try
//    ForceDirectories(result);
//  except
//  end;
  Result := TSysFolders.TempFolder;
end;

Function GetWindowsID:string;
var
  reg:TRegistry;
  key:array[1..6] of string;
  s:string;
begin
  if IDbekend then begin
    Result := WinID;
  end else begin
    key[5] := inttostr(round(date) + random(10000) );
    reg :=TRegistry.create(KEY_READ);
    reg.RootKey := HKEY_LOCAL_MACHINE;
    key[1] := 'software';
    if reg.OpenKeyReadOnly('\' + key[1]) then begin
      key[2] := 'microsoft';
      key[6] := 'Product';
      if reg.OpenKeyReadOnly(key[2]) then begin
        key[3] :='Windows';
        if reg.OpenKeyReadOnly(key[3]) then begin
          key[4] := 'CurrentVersion';
          key[6] := Key[6] + 'ID';
          if reg.OpenKeyReadOnly(key[4]) then begin
             key[5]:= reg.ReadString(Key[6]);
             IDbekend := true;
          end;
          s := key[4];
          key[4] := key[5];
          Key[5] := s;
        end;
        s := key[3];
        WinID := key[4];
        key[3] := key[4];
        Key[4] := s;
      end;
      s := key[2];
      key[2] := key[3];
      Key[3] := s;
    end;
    s := key[1];
    Reg.CloseKey;
    key[1] := key[2];
    reg.Free;
    Key[2] := s;
    Result := Key[1];
  end;
end;

end.
