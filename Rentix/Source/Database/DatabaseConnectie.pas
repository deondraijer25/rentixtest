unit DatabaseConnectie;

interface

uses
  ADODB_TLB, Classes;

type
  TAdoRecordset = recordset;

  TControllerDB = class
  private
    procedure OpenDatabase(naam:string);
  protected
    _DBConnection: Connection;
  public
    DBversion : integer;
    DBversionstring : string;
    DBnaam:string;
    Property DBconnection : Connection read _DBconnection;

    function CheckWritable( MakeWritable : boolean = false): Boolean;
    Function CheckConnection : Boolean;
    Function OpenQuery(sql:string) : TAdoRecordset;
    Procedure CloseQuery(var rs : TAdoRecordset);
    function QueryExecute(sql: String): integer;

    procedure GetVersion; virtual;
    Constructor Create(aDatabasenaam:String); virtual;
    Destructor Destroy; override;
  end;

function ReadDBValue(variableType: integer; RSet: RecordSet;
  fieldname: string; EmptyIsFataal: boolean;
  var FataleFout: boolean): Variant; Forward;

implementation

uses
   Variants, SysUtils, Dialogs;


function TControllerDB.CheckConnection: Boolean;
begin
  result :=  Assigned(_DBConnection);
end;


function TControllerDB.CheckWritable(MakeWritable:boolean=false): Boolean;
var
  Attr : integer;
begin
  result := false;
  try
    if not FileExists(DBnaam) then begin  
      result := false;
    end else begin
      attr := FileGetAttr(DBnaam);
      result := (attr and faReadOnly <> 0);    
      if MakeWritable and result then begin
        FileSetAttr(DBnaam, Attr - faReadOnly);
        if Assigned(_DBConnection) then begin
          //re-open database om de "read-only" veranderd is.
          _DBConnection.Close;
          OpenDatabase(dbnaam);
        end;
      end;
    end;
  except
    Showmessage('De file ' + DBnaam + ' is niet beschrijfbaar.'#13#10'Dit kan problemen voor de werking van dit programma.');
  end;
end;

procedure TControllerDB.CloseQuery(var rs: recordset);
begin
  rs.Close;
end;

constructor TControllerDB.Create(aDatabasenaam:String);
begin
  _DBConnection := nil;
  openDatabase(aDatabasenaam);
end;


function ReadDBValue(variableType: integer; RSet: RecordSet;
  fieldname: string; EmptyIsFataal: boolean;
  var FataleFout: boolean): Variant;
begin
  if FataleFout then exit;

  result:= RSet.Fields.Item[fieldname].value;
  if varisempty(result) then result := null;
  if VarIsNull(result) and EmptyIsFataal then begin
    result :=0;
    FataleFout := true;
    exit;
  end;

  case variableType of
    varInteger,varSmallint:
      if (VarIsEmpty(result)) or (VarIsNull(result)) then result := 0;
    varString,varOleStr,varStrArg:
      if (VarIsEmpty(result)) or (VarIsNull(result)) then result := '';
    varDate:
      if (VarIsEmpty(result)) or (VarIsNull(result)) then result := 0;
    varBoolean:
      if (VarIsEmpty(result)) or (VarIsNull(result)) then result := false;
    varDouble,varSingle:
      if (VarIsEmpty(result)) or (VarIsNull(result)) then result := 0;
    else
      if (VarIsEmpty(result)) or (VarIsNull(result)) then
        result := 0
      else
        result := RSet.fields.Item[fieldname].value;
  end;
end;


destructor TControllerDB.Destroy;
begin
  if Assigned(_DBConnection) then begin
    _DBConnection.Close;
  end;
  inherited;
end;

procedure TControllerDB.GetVersion;
var
  fout : boolean;
  sql:string;
  rs : TAdoRecordset;
  ra : olevariant;
begin
  try
    Fout := false;
    sql := 'Select * from Version';
    rs := _DBconnection.execute(sql,ra,0);
    if not rs.eof then begin
      DBversion := ReadDBValue(varInteger, rs,'Versie', True, fout);
      DBversionstring := ReadDBvalue(varString, rs, 'VersieString', True,fout);
    end else begin
      fout := true;
    end;
    rs.close;
  finally
    if Fout then begin
      Raise Exception.Create('Databaseversie laat zich niet lezen.');
    end;
  end;
end;

procedure TControllerDB.OpenDatabase(naam:string);
var
  ConnectionString : String;
begin
  _DBConnection := coConnection.Create;
  DBnaam := Naam; 
  if not FileExists(DBnaam) then begin
    Raise Exception.Create('Benodigde database bestaat niet. Naam: '+ DBnaam + #13#10'Fatale fout. Het programma zal worden afgesloten.');
  end;

  try
    ConnectionString:='Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + DBnaam;
    _DBConnection.open(ConnectionString ,'','',0);
  except
    on e:exception do begin
      Raise Exception.Create('Database wil niet open.'#13#10'Systeemmelding: ' + e.Message);
    end;
  end;
end;

function TControllerDB.OpenQuery(sql: string): TAdoRecordset;
var
  ra : olevariant;
begin
  if CheckConnection then begin
    try
      result := _DBconnection.execute(sql,ra,0);
    except
      on e:exception do begin
        result := nil;
        Raise Exception.Create('Deze sql-query kan niet worden uitgevoerd: '#13#10+'"' + sql + '"' + #13#10'Systeemmelding: ' + e.Message);
      end;
    end;
  end;
end;

function TControllerDB.QueryExecute(sql: String): integer;
var
  ra : OleVariant;
begin
  try
    _DBconnection.execute(sql,ra,0);
    if VarIsNumeric(ra) then begin
      Result := ra;
    end else begin
      result := 0;
    end;
  except
    on e:exception do begin
      Raise Exception.Create('Deze sql-query kan niet worden uitgevoerd: '#13#10+'"' + sql + '"' + #13#10'Systeemmelding: ' + e.Message);
      Result := 0;
    end;
  end;
end;


end.
