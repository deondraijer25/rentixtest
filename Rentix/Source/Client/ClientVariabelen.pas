unit ClientVariabelen;

interface

uses
  {$ifdef IS_RENTIXCLIENT}
  DatabaseConnectie, ClientDatabaseConnectie,
  {$endif}
  Opties;

var
  FinixID : string;
  {$ifdef IS_RENTIXCLIENT}
  GlobalOpties : TOpties;
  GlobalRenteDbase : TControllerDB;
  GlobalClientDB:TControllerDB;
  GlobalClientDBExtension:TClientControllerDB;
  {$endif}

implementation

end.
