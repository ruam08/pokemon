unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.StdCtrls, System.json, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent, IdComponent,
  IdSSLOpenSSLHeaders,
  IdTCPConnection, IdTCPClient, IdHTTP, System.ImageList, FMX.ImgList,
  IPPeerClient, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope;

type
  TfrmPrincipal = class(TForm)
    ListView1: TListView;
    AniIndicator1: TAniIndicator;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    function GetUrlJsonArray(url: string): TJSONArray;
    function DownloadIMG(url: string): TStream;
    procedure TratamentoListagem(Sender: TObject);
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

const
  API_URL = 'https://pokeapi.glitch.me/v1/pokemon/6';

implementation

{$R *.fmx}

procedure TfrmPrincipal.FormShow(Sender: TObject);
var
  LoadPokebola: TThread;
  JsonArrayPokemon: TJSONArray;
  JsonPokemon: TJSONObject;
  Sprinte: TStream;
begin
  AniIndicator1.Enabled := true;
  AniIndicator1.Visible := true;
  LoadPokebola := TThread.CreateAnonymousThread(
    procedure
    var
      I: integer;
      LItem: TListViewItem;
    begin
      JsonArrayPokemon := GetUrlJsonArray(API_URL);

      for I := 0 to JsonArrayPokemon.Size - 1 do
      begin
        JsonPokemon := JsonArrayPokemon.Get(I) as TJSONObject;
        Sprinte := DownloadIMG(JsonPokemon.GetValue('sprite').Value);
        TThread.Synchronize(TThread.CurrentThread,
          procedure
          begin
            frmPrincipal.ListView1.BeginUpdate;
            LItem := frmPrincipal.ListView1.Items.Add;
            LItem.Bitmap.LoadFromStream(Sprinte);
            LItem.Text := JsonPokemon.GetValue('name').Value;
            LItem.Detail := JsonPokemon.GetValue('name').Value;
            frmPrincipal.ListView1.EndUpdate;
          end);
      end;
    end);
  LoadPokebola.OnTerminate := TratamentoListagem;
  LoadPokebola.start();
end;

function TfrmPrincipal.GetUrlJsonArray(url: string): TJSONArray;
begin
  RESTClient1.BaseURL := url;
  RESTRequest1.Execute;
  result := TJSONObject.ParseJSONValue
    (TEncoding.UTF8.GetBytes(RESTResponse1.Content), 0) as TJSONArray;
end;

procedure TfrmPrincipal.TratamentoListagem(Sender: TObject);
begin
  if ((Sender as TThread).FatalException = nil) then
  begin
    AniIndicator1.Visible := false;
  end
  else
  begin
    AniIndicator1.Visible := false;

    ShowMessage('Falha ao conultar a lista de Pokemons, erro:' +
      ((Sender as TThread).FatalException as Exception).Message + ' -- ' +
      WhichFailedToLoad());
  end;
end;

function TfrmPrincipal.DownloadIMG(url: string): TStream;
var
  IMG: TMemoryStream;
begin
    try
      IMG := TMemoryStream.Create;
      RESTClient1.BaseURL := url;
      RESTRequest1.Execute;
      IMG.Write(RESTResponse1.RawBytes,Length(RESTResponse1.RawBytes));
      result := IMG;
    except

    end;
end;

end.
