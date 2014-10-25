unit UPesCliCid;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Db;

type
  TFrmPesCliCid = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    EdtCidade: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure EdtCidadeKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPesCliCid: TFrmPesCliCid;

implementation

uses UCadCliente;

{$R *.dfm}

procedure TFrmPesCliCid.Button1Click(Sender: TObject);
begin

  With FrmCadCliente.QueryClientes do
  Begin
     Close; // fecha a query
     Parameters[0].Value := EdtCidade.Text; //define par�metro de pesquisa
     Open; //abre a query e executa os comandos SQL
  End;
FrmPesCliCid.Close;

end;

procedure TFrmPesCliCid.EdtCidadeKeyPress(Sender: TObject; var Key: Char);
begin


  // se �ltima tecla for letra, espa�o ou Backspace
  If not (Key in ['A'..'Z','a'..'z', #32, #8]) then
    Key := #0; // ignora a �ltima tecla digitada

end;

end.
