unit InternetWrap;

interface

uses
  Wininet, comctrls, controls, Windows;

const
  Buffersize = 4096;

type
  Pinteger = ^integer;
  TNetWrap= class
  private
    Appname : pchar;
    buffer : array[0..buffersize-1] of char;
    crOld : TCursor;
    procedure SaveCursor;
    procedure RestoreCursor;
  protected
    hSession : hinternet;
    FTPSession : hinternet;
    _LastResult : string;

    FTPhost : string;
    FTPaccount : string;
    FTPpassword : string;
    FTPpoort : INTERNET_PORT;

    Function CreateInternetSession : boolean;
    procedure CloseInternetSession;
  public
    procedure SetFTPinfo ( Host, account, password:string; ftpport:INTERNET_PORT=INTERNET_DEFAULT_FTP_PORT);

    function LogOnFTPsite(passive : boolean) : boolean;
    procedure LogOffFTPsite;
    function FTPdownloadFile(ftpdir, ftpnaam:string; Targetnaam:string; var TerminatePointer : Pinteger; Progressbar: TProgressBar = nil):boolean;
    function FTPuploadFile(sourcenaam:string; ftpdir, ftpnaam:string;  var TerminatePointer : Pinteger; Progressbar: TProgressBar = nil):boolean;
    function FTPChangeCurrentDirectory(Dir : string) : boolean;
    function InternetIsActive:boolean;

    function LastResult : string;
    constructor Create;
  end; //class

implementation

uses SysUtils, Forms, dialogs, InternetLimitedWaitThread;

{ TNetWrap }

constructor TNetWrap.Create;
begin
  Appname := PChar(ExtractFileName(Application.exename));
  hSession := nil;
  FTPSession := nil;
end;

procedure TNetWrap.CloseInternetSession;
begin
  InternetCloseHandle(hSession );
end;

function TNetWrap.CreateInternetSession: boolean;
begin
  _LastResult := '';
  try
    hSession := InternetOpen(Appname , INTERNET_OPEN_TYPE_PRECONFIG, nil,nil, 0);
  except
    hSession := nil;
    _LastResult := 'Internet connectie is niet gelukt.';
  end;
  Result := assigned(hSession);
end;

function TNetWrap.LastResult: string;
begin
  result := _LastResult;
end;

function TNetWrap.LogOnFTPsite(passive : boolean): boolean;
//Maak connectie met een FTP-host. Indien succesvol is de FTPsession gevuld
//indien niet succesvol dan is de _LastResult gevuld
var
  error,getlast:Cardinal;
  bufsize : Cardinal;
  {$IF COMPILERVERSION>=23}
  ptrBuf : PWideChar;
  {$ELSE}
  ptrBuf : PAnsiChar;
  {$IFEND}
  ThreadWait : TInternetLimitedWait ;
  flag : cardinal;
begin
  GetLast := 0;
  SaveCursor;
  ThreadWait := TInternetLimitedWait.Create(true);
  try
    if CreateInternetSession then begin
      try
        //Inloggen op een FTP-site kan oneindig duren als de parameters
        //niet kloppen. Vandaar dat er een thread omheen staat.
        //deze thread sluit de verbinding na een bepaalde tijd (30 seconden)
        ThreadWait.SetTimer(30);
        ThreadWait.SetInternetconnection(hSession);
        ThreadWait.Resume;
        try
          if passive then flag := INTERNET_FLAG_PASSIVE else flag :=0;
          FTPSession := InternetConnect(
                  hSession,
                  pChar(FTPHost),
                  FTPpoort,           //default is 21
                  pChar(FTPaccount),
                  pChar(FTPpassword),
                  INTERNET_SERVICE_FTP, //we gaan FTP-en
                  flag,
                  0);
          ThreadWait.Terminate;
          GetLast := GetLastError;
          if ThreadWait.LastResult <> '' then begin
            GetLast := 1;
          end;
          FreeAndNil(ThreadWait);
        except
          ShowMessage('foutje');
        end;
        if GetLast>0 then begin
          ptrBuf := @buffer;
          bufsize :=  Buffersize;
          if InternetGetLastResponseInfo(error,ptrbuf,Bufsize) then begin
            _LastResult := SysErrorMessage(GetLast) + #13#10 + Buffer;
          end else begin
            _LastResult := '';
          end;
        end else begin
          _LastResult := '';
        end;
      except
        on exc:exception do begin
          FTPSession := nil;
          _LastResult := 'Exception error bij maken FTP-connectie.'#13#10 + exc.message;
        end;
      end;
    end;
  finally
    result := assigned(FTPSession);
    RestoreCursor;
  end;
end;

procedure TNetWrap.SetFTPinfo(
  Host, account, password: string;
  ftpport: INTERNET_PORT);
begin
  FTPhost := host;
  FTPaccount := account;
  FTPpassword  := password ;
  FTPpoort := FTPport;
end;

procedure TNetWrap.LogOffFTPsite;
begin
  InternetCloseHandle(FTPSession);
end;

function TNetWrap.FTPdownloadFile(ftpdir, ftpnaam, Targetnaam: string;
  var TerminatePointer : Pinteger;
  Progressbar: TProgressBar): boolean;
var
  ok:boolean;
  sRec : TWin32FindData;
  FileSize : Cardinal;
  FileSession : HInternet;
  TheFile : File;
  BufSize, dwBytesRead : Cardinal;

begin
  result := false;
  SaveCursor;
  FileSession := nil;
  try
    if not Assigned(FTPSession) then begin
      _LastResult := 'Tip aan de programmeur: Eerst inloggen op een FTP site.';
    end else begin
      _LastResult := '';

      //Verander ftp directory indien nodig
      if ftpdir>'' then begin
        ok := FTPChangeCurrentDirectory(ftpdir);
        if not ok then begin
          _LastResult := 'FTP directory niet gevonden.';
          exit;
        end;
      end;

      if assigned(FtpFindFirstFile(FTPSession, pchar(ftpnaam), sRec, 0, 0)) then begin
        FileSize := sRec.nfileSizeLow;
        if sRec.nfileSizehigh>0 then begin
          ShowMessage('De file is groter dan 4 Gb. Dit wordt niet ondersteund.');
        end;
        if assigned(progressbar) then begin
          Progressbar.Position := 0;
        end;
      end else begin
        _LastResult := 'File "' +ftpnaam + '" niet gevonden in de directory "' + ftpdir + '" van de FTP-site "' + FTPhost +'"';
        result := false;
        exit;
      end;

      FileSession := FtpOpenFile(
                        FTPSession,
                        pChar(ftpnaam),
                        GENERIC_READ,
                        FTP_TRANSFER_TYPE_BINARY,
                        0);

      if assigned(FileSession) then begin
        AssignFile(TheFile, Targetnaam);
        filemode := fmOpenReadWrite;
        try
          Rewrite(TheFile, 1);
        except
          on e:exception do begin
            _LastResult := 'Target file kon niet worden gemaakt.'#13#10 + e.Message;
            exit;
          end;
        end;

        dwBytesRead := 0;
        BufSize := Buffersize;

        while BufSize >0 do begin
          Application.ProcessMessages;

          if not InternetReadFile(FileSession, @buffer, Buffersize, bufsize) then begin
            _LastResult := 'File "' +ftpnaam + '" niet succesvol gelezen in de directory "' + ftpdir + '" van de FTP-site "' + FTPhost +'"';
            break;
          end;

          if (BufSize >0) and (BufSize <=Buffersize) then begin
            BlockWrite(TheFile, buffer, bufsize);
            dwBytesRead := dwBytesRead + bufsize;
            if assigned(progressbar) then begin
              Progressbar.Position := round(dwBytesRead*100/FileSize);
            end;
          end;
          if TerminatePointer^ <> 0 then begin
            Bufsize := 0;
            _LastResult := 'Transmissie gestopt door gebruiker';
          end;
        end; //while
      end;
    end; //if not assigned FTPsession
  finally
    RestoreCursor;
    try
      if assigned(FileSession) then begin
        InternetCloseHandle(FileSession);
      end;
    except
    end;
    try
      CloseFile(TheFile);
    except
    end;
  end;
  Result := (_LastResult ='');
end;

procedure TNetWrap.RestoreCursor;
begin
  Screen.Cursor := crOld;
end;

procedure TNetWrap.SaveCursor;
begin
  crOld := Screen.Cursor;
  Screen.Cursor := crHourglass;
end;

function TNetWrap.FTPuploadFile(sourcenaam, ftpdir, ftpnaam: string;
  var TerminatePointer : Pinteger;
  Progressbar: TProgressBar): boolean;
var
  FS : Cardinal;
  FileSession : HInternet;
  TheFile : File;
  BufSize, dwBytesWriten, NumBytesWriten : Cardinal;

begin
  SaveCursor;
  FileSession := nil;
  try
    if not Assigned(FTPSession) then begin
      _LastResult := 'Tip aan de programmeur: Eerst inloggen op een FTP site.';
    end else begin
      _LastResult := '';

      if assigned(progressbar) then begin
        Progressbar.Position := 0;
      end;

      if FileExists(Sourcenaam) then begin

        FileSession := FtpOpenFile(
                        FTPSession,
                        pChar(ftpnaam),
                        GENERIC_WRITE ,
                        FTP_TRANSFER_TYPE_BINARY,
                        0);

        Assignfile(TheFile, Sourcenaam);
        filemode := fmOpenRead;
        reset(TheFile,1);
        FS := FileSize(TheFile);
        bufsize := Buffersize;
        dwBytesWriten := 0;

        while bufsize > 0 do begin
          Application.ProcessMessages;
          BlockRead(TheFile, Buffer, Buffersize,  bufsize);
          if BufSize >0 then begin
            if not InternetWriteFile(FileSession, @buffer, bufsize, NumBytesWriten) then begin
              _LastResult := 'Uploaden van bestand niet succesvol. ' + inttostr(dwBytesWriten) + 'bytes van de ' + inttostr(FS) + ' geupload.';
              break;
            end;
            dwBytesWriten := dwBytesWriten + NumBytesWriten;
          end;
          if assigned(progressbar) then begin
            Progressbar.Position := round(dwBytesWriten *100 / FS);
          end;
          if TerminatePointer^ <> 0  then begin
            bufsize := 0;
            _LastResult := 'Transmissie gestopt door gebruiker';
          end;
        end;
      end else begin
        _LastResult := Sourcenaam + ' bestaat niet. Uploaden onuitvoerbaar.';
      end;
    end; //if not assigned ftp-session
  finally
    RestoreCursor;
    try
      if assigned(FileSession) then begin
        InternetCloseHandle(FileSession);
      end;
    except
    end;
    try
      CloseFile(TheFile);
    except
    end;
  end;
  Result := (_LastResult = '');
end;

function TNetWrap.FTPChangeCurrentDirectory(Dir: string): boolean;
begin
  try
    if Assigned(FTPSession) then begin
      result := FtpSetCurrentDirectory(FTPsession, pchar(dir));
    end else begin
      Result := false;
    end;
  except
    result := false;
    _LastResult := 'Directory kon niet veranderd worden.';
  end;
end;

function TNetWrap.InternetIsActive: boolean;
var
  dwConnectionTypes: DWORD;
begin
  dwConnectionTypes :=
    INTERNET_CONNECTION_MODEM +
    INTERNET_CONNECTION_LAN +
    INTERNET_CONNECTION_PROXY;
  Result := InternetGetConnectedState(@dwConnectionTypes, 0);

end;


end.
