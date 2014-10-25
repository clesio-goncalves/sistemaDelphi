unit UCadItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UCadPadrao, ComCtrls, ExtCtrls, DBCtrls, Grids, DBGrids,
  StdCtrls, Buttons, Db, Mask, ADODB, RpCon, RpConDS, RpDefine, RpBase,
  RpSystem, RpRave;

type
  TFrmCadItem = class(TFrmCadPadrao)
    lbCod: TLabel;
    EdtCod: TDBEdit;
    lbNome: TLabel;
    EdtNome: TDBEdit;
    lbPreco: TLabel;
    EdtPreco: TDBEdit;
    lbQnt: TLabel;
    EdtQnt: TDBEdit;
    lbUni: TLabel;
    EdtUni: TDBEdit;
    lbFornecedor: TLabel;
    EdtFornecedor: TDBEdit;
    Label2: TLabel;
    QComprarProdutos: TADOQuery;
    QComprarProdutosCatDesc: TWideStringField;
    QComprarProdutosProdNome: TWideStringField;
    QComprarProdutosProdQtdeEst: TIntegerField;
    sbProdFalta: TSpeedButton;
    RvSysProdFalta: TRvSystem;
    RvDtCnProdFalta: TRvDataSetConnection;
    RvPrjProdFalta: TRvProject;
    FiltraCliente: TButton;
    sbPlanilha: TButton;
    sbGrafico: TButton;
    Label3: TLabel;
    DBLookupComboBox1: TDBLookupComboBox;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure sbProdFaltaClick(Sender: TObject);
    procedure DBNavigator2BeforeAction(Sender: TObject;
      Button: TNavigateBtn);
    procedure RvSysProdFaltaBeforePrint(Sender: TObject);
    procedure RvSysProdFaltaPrint(Sender: TObject);
    procedure Det_RelProdFalta;
    procedure Cab_RelProdFalta;
    procedure sbPesquisarClick(Sender: TObject);
    procedure FiltraClienteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCadItem: TFrmCadItem;
  Ascendente: Boolean;
  Lin: Real;

implementation

uses UDM;

{$R *.dfm}

procedure TFrmCadItem.FormShow(Sender: TObject);
begin
  inherited;

    Dm.Tab_Produtos.Open;
    Ascendente := False;

end;

procedure TFrmCadItem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;

    Dm.Tab_Produtos.Close;

end;

procedure TFrmCadItem.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  inherited;

  If Odd(dm.tab_Produtos.RecNo) and (dm.tab_Produtos.State <> dsInsert) then
  begin //Lembre-se de colocar a unit DB na cl�usula uses na unit da tela.
      DBGrid1.Canvas.Brush.Color := clMoneyGreen; // muda a cor do pincel
      DBGrid1.Canvas.FillRect(Rect); // Preenche o fundo com a cor especificada
      DBGrid1.DefaultDrawDataCell(Rect,Column.Field,State);// desenha as c�lulas da grade
  end;

end;

procedure TFrmCadItem.DBGrid1TitleClick(Column: TColumn);
begin
  inherited;

  Ascendente:= not Ascendente ;

  If Ascendente then
     Dm.tab_Produtos.IndexFieldNames := Column.FieldName + '   ASC'
  else
 	   Dm.tab_Produtos.IndexFieldNames := Column.FieldName + '    DESC';

end;


procedure TFrmCadItem.sbProdFaltaClick(Sender: TObject);
var Qtde : String;
    OK   : Boolean;
begin
  OK := InputQuery('Digite a Quantidade M�nima', 'Quantidade M�nima', Qtde);
  if OK then
  begin
    With QComprarProdutos do
    begin
       Close;
       Parameters[0].value := Qtde;
       Open;
       //RvPrjProdFalta.Execute;
       With RvSysProdFalta do
          begin
            SystemPrinter.Units         := unCM; //unidades em cent�metro
            SystemPrinter.UnitsFactor   := 2.54; // Fator para convers�o polegada
            SystemPrinter.Orientation   := poPortrait; // Modo Retrato
            SystemPreview.RulerType     := rtBothCm; // medidas da r�gua em cm
            //SystemSetups := SystemSetups - [ssAllowSetup]; remove tela de setup
            SystemPreview.FormState  := wsMaximized; // tela relat�rio maximizada
            Execute; // executa o relat�rio
          end;
       Close;
    end;
  end;
end;

procedure TFrmCadItem.DBNavigator2BeforeAction(Sender: TObject;
  Button: TNavigateBtn);
begin
  inherited;
  if (Button = nbInsert) then
    begin
      Dm.Tab_Produtos.Cancel;
      Dm.Tab_Produtos.Append;
      EdtNome.SetFocus;
    end;
end;

procedure TFrmCadItem.RvSysProdFaltaBeforePrint(Sender: TObject);
begin
  inherited;

  With RvSysProdFalta .BaseReport do
  begin
    FontName := 'Arial'; //define a fonte como Arial
    FontSize := 11;//define o tamanho da fonte para 11
    Bold := false; // desabilita o estilo de fonte negrito 
    SetPaperSize(DMPAPER_A4, 0, 0); //ajusta tamanho do papel
  end; 

end;

procedure TFrmCadItem.RvSysProdFaltaPrint(Sender: TObject);
begin
  inherited;

  With RvSysProdFalta .BaseReport do
    begin
      QComprarProdutos.First; // vai para o primeiro registro da query
      While (not QComprarProdutos.Eof) do // enquanto n�o for fim de arquivo
      begin
        Lin := 1; // Declarar vari�vel Lin com o tipo Real e escopo global
        Cab_RelProdFalta; // chama a procedure cabe�alho do relat�rio
        While (not QComprarProdutos.Eof) and (Lin <= 29) do
        begin
          Det_RelProdFalta; // chama a procedure detalhe do relat�rio
          QComprarProdutos.Next; //vai para o pr�ximo registro
        end;
        if not QComprarProdutos.Eof then
          NewPage; //  insere uma nova p�gina ao relat�rio
      end;
      Lin := Lin - 0.2;
      MoveTo(0.7,Lin); //move o cursor para a coluna e linha indicados
      LineTo(20.5,Lin);//tra�a uma linha at� posi��o coluna x linha  indicada. 
      Lin := Lin + 0.5; 
    end;

end;

procedure TFrmCadItem.Det_RelProdFalta; // Detalhe do relat�rio
begin
  with RvSysProdFalta .BaseReport do
  begin
    Gotoxy(0.7,Lin);//tabula coluna e linha no relat�rio
    Print (QComprarProdutosCatDesc.AsString); // Imprime Nome da Catedoria
    Gotoxy(6.5,Lin);
    Print (QComprarProdutosProdNome.AsString);
    Gotoxy(18,Lin);
    Print(QComprarProdutosProdQtdeEst.AsString);
    Lin := Lin + 0.5;
  end;	
end;

procedure TFrmCadItem.Cab_RelProdFalta; // Cabe�alho 
begin
  with RvSysProdFalta .BaseReport do
  begin
    Gotoxy(0.7,Lin); // Declarar variable Lin com o tipo Real e escopo global
    Print('Data:' + FormatDateTime('dd/mm/yyyy " - Hora:" hh:mm:ss',now));
    Bold := False;
    Gotoxy(18,Lin); // tabula coluna e linha de impress�o
    Print('P�g.:'+Macro(midCurrentPage)+'/'+Macro(midTotalPages));
    Bold := True; //define estilo da fonte para negrito
    Gotoxy(08,Lin);
    Print('Empresa Empresa Distribuidora York'); // Escreve dados no relat�rio 
    Lin := Lin + 0.5;
    Gotoxy(08,Lin);
    Print('Relat�rio de Produtos para Compra');
    Lin := Lin + 0.5;
    Gotoxy(0.7, Lin);
    Lin := Lin + 0.5;
    Gotoxy(6,Lin);
    MoveTo(0.7,Lin);
    LineTo(20.5,Lin);
    Lin := Lin + 0.5;

    Gotoxy(0.7,Lin);
    Print ('Categoria');
    Gotoxy(6.5,Lin);
    Print ('Nome do Produto');
    Gotoxy(16,Lin);
    Print('Quantidade em Estoque');

    Lin := Lin + 0.2;
    MoveTo(0.7,Lin);
    LineTo(20.5,Lin);
    Lin := Lin + 0.5;
    Bold := False;
  end;
end;


procedure TFrmCadItem.sbPesquisarClick(Sender: TObject);
begin
  inherited;
    If not Dm.Tab_Produtos.Locate( 'ProNome',ValorCampo.Text, [loCaseInsensitive]) then
      MessageDlg('Produto n�o cadastrado!', mtError, [mbOk], 0);

end;

procedure TFrmCadItem.FiltraClienteClick(Sender: TObject);
begin
{Var Categoria : String;
    Ok : Boolean;
begin
   Categoria := 'ALL';
   Ok := InputQuery('Filtra Itens por Categoria', 'Digite o nome da categoria: (ALL remove o filtro)',Categoria);
   If Ok then
     With dm.Tab_Produtos do
     begin
       Filtered := false; // Desativa o filtro
       if Categoria <>  'ALL' then
       begin      // A fun��o QuotedStr coloca ap�strofos  no string.
         Filter := 'Categoria = ' + QuotedStr(Categoria); // monta o filtro
         Filtered := true; // Ativa o filtro
       end;
     end;}
end;

end.
