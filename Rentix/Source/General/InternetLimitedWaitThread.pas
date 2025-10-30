unit InternetLimitedWaitThread;

interface

uses
  Classes, wininet;

type
  TInternetLimitedWait = class(TThread)
  private
    { Private declarations }
    _Seconds : integer;
    _Hsession : hInternet;
    _result : string;
  protected
    procedure Execute; override;
  public
    function LastResult : string;
    procedure SetTimer(seconds : integer);
    procedure SetInternetconnection (hsession : hInternet);
  end;

implementation

uses SysUtils;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TLimitedWait.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TLimitedWait }

procedure TInternetLimitedWait.Execute;
var
  i:integer;
begin
  { Place thread code here }
  _result := '';
  for i := 0 to (_seconds*10) -1 do begin
    Sleep(100);
    if terminated then break;
  end;
  if not terminated then begin
    InternetCloseHandle(_Hsession);
    _result := 'Internet sessie is onderbroken vanwege tijdsoverscheiding.';
  end;
end;

procedure TInternetLimitedWait.SetInternetconnection(hsession: hInternet);
begin
  _Hsession := hsession;
end;

procedure TInternetLimitedWait.SetTimer(seconds: integer);
begin
  _Seconds := Seconds;
end;

function TInternetLimitedWait.LastResult: string;
begin
  result := _Result;
end;

end.
