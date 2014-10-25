unit UCadCliente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UCadPadrao, ComCtrls, ExtCtrls, DBCtrls, Grids, DBGrids,
  StdCtrls, Buttons, Db, Mask, ADODB, RpDefine, RpCon, RpConDS, RpBase,
  RpSystem, RpRave, ComObj;

type
  TFrmCadCliente = class(TFrmCadPadrao)
    lbNome: TLabel;
    EdtNome: TDBEdit;
    lbEndereco: TLabel;
    EdtEndereco: TDBEdit;
    lbCep: TLabel;
    EdtCep: TDBEdit;
    lbCidade: TLabel;
    EdtCidade: TDBEdit;
    lbUf: TLabel;
    EdtUf: TDBEdit;
    lbFone: TLabel;
    EdtFone: TDBEdit;
    lbEmail: TLabel;
    EdtEmail: TDBEdit;
    lbCpf: TLabel;
    EdtCpf: TDBEdit;
    lbRg: TLabel;
    EdtRg: TDBEdit;
    lbContato: TLabel;
    EdtContato: TDBEdit;
    QueryClientes: TADOQuery;
    QueryClientesCliCodigo: TAutoIncField;
    QueryClientesCliNome: TWideStringField;
    QueryClientesCliEnd: TWideStringField;
    QueryClientesCliCep: TWideStringField;
    QueryClientesCliCid: TWideStringField;
    QueryClientesCliEst: TWideStringField;
    QueryClientesCliNumFone: TWideStringField;
    QueryClientesCliEmail: TWideStringField;
    QueryClientesCliDoc1: TWideStringField;
    QueryClientesCliDoc2: TWideStringField;
    QueryClientesCliContato: TWideStringField;
    FiltraCliente: TButton;
    RvDtCnCliente: TRvDataSetConnection;
    RvSysCliente: TRvSystem;
    RvPrjCliente: TRvProject;
    SaveDialog1: TSaveDialog;
    sbGrafico: TButton;
    sbPlanilha: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure ValorCampoChange(Sender: TObject);
    procedure FiltraClienteClick(Sender: TObject);
    procedure RvSysClienteBeforePrint(Sender: TObject);
    procedure RvSysClientePrint(Sender: TObject);
    procedure Det_RelCadCliente;
    procedure Cab_RelCadCliente;
    procedure sbPlanilhaClick(Sender: TObject);
    procedure sbGraficoClick(Sender: TObject);
    procedure DBNavigator2BeforeAction(Sender: TObject;
      Button: TNavigateBtn);
    procedure sbPesquisarClick(Sender: TObject);
    procedure sbImprimirClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCadCliente: TFrmCadCliente;
  Ascendente: Boolean;
  Lin: Real;

implementation

uses UDM, UPesCliCid, UQRRelCliCid, UGraficoCliente;

{$R *.dfm}

procedure TFrmCadCliente.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;

    Dm.Tab_Clientes.Close; // fecha a tabela de clientes

end;

procedure TFrmCadCliente.FormShow(Sender: TObject);
begin
  inherited;

    Dm.Tab_Clientes.Open; // abre a tabela de clientes
    Ascendente := False;

end;

procedure TFrmCadCliente.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  inherited;

      If Odd(dm.tab_Clientes.RecNo) and (dm.tab_Clientes.State <> dsInsert) then
        begin //Lembre-se de colocar a unit DB na cl�usula uses na unit da tela.
          DBGrid1.Canvas.Brush.Color := clMoneyGreen; // muda a cor do pincel
          DBGrid1.Canvas.FillRect(Rect); // Preenche o fundo com a cor especificada
          DBGrid1.DefaultDrawDataCell(Rect,Column.Field,State);// desenha as c�lulas da grade
        end;
        
end;

procedure TFrmCadCliente.DBGrid1TitleClick(Column: TColumn);
begin
  inherited;

    Ascendente:= not Ascendente ;

    If Ascendente then
     Dm.tab_Clientes.IndexFieldNames := Column.FieldName + '   ASC'
    else
 	   Dm.tab_Clientes.IndexFieldNames := Column.FieldName + '    DESC';

end;

procedure TFrmCadCliente.ValorCampoChange(Sender: TObject);
begin
  inherited;

    //Dm.tab_Clientes.Locate( 'CliNome',ValorCampo.Text, [loCaseInsensitive, loPartialKey] );

end;

procedure TFrmCadCliente.sbPesquisarClick(Sender: TObject);
begin
  inherited;
  If not Dm.Tab_Clientes.Locate( 'CliNome',ValorCampo.Text, [loCaseInsensitive]) then
      MessageDlg('Cliente n�o cadastrado!', mtError, [mbOk], 0);
end;

procedure TFrmCadCliente.FiltraClienteClick(Sender: TObject);
Var Cidade : String;
    Ok : Boolean;
begin
   Cidade := 'ALL';
   Ok := InputQuery('Filtra Clientes por Cidade', 'Digite o nome da cidade: (ALL remove o filtro)',Cidade);
   If Ok then
     With dm.Tab_Clientes do
     begin
       Filtered := false; // Desativa o filtro
       if Cidade <>  'ALL' then
       begin      // A fun��o QuotedStr coloca ap�strofos  no string.
         Filter := 'CliCid = ' + QuotedStr(Cidade); // monta o filtro
         Filtered := true; // Ativa o filtro
       end;
     end;
end;

procedure TFrmCadCliente.sbImprimirClick(Sender: TObject);
begin
  inherited;
    FrmPesCliCid:= TFrmPesCliCid.Create(Self); //cria��o manual
    FrmPesCliCid.ShowModal; //exibe a tela no modo modal
    FrmPesCliCid.Release; //libera a tela da mem�ria
    FrmPesCliCid:= nil; //atribui o conte�do nulo para a vari�vel FrmPesCliCid
    //FrmPesCliCid.ShowModal;
    //FrmRelCliCid.QuickRep1.Preview;
    //RvPrjCliente.Execute;

    If QueryClientes.RecordCount > 0 then  // se qtde de registros > 0
      begin
        With RvSysCliente do
          begin
            SystemPrinter.Units         := unCM; //unidades em cent�metro
            SystemPrinter.UnitsFactor   := 2.54; // Fator para convers�o polegada
            SystemPrinter.Orientation   := poPortrait; // Modo Retrato
            SystemPreview.RulerType     := rtBothCm; // medidas da r�gua em cm
            //SystemSetups := SystemSetups - [ssAllowSetup]; remove tela de setup
            SystemPreview.FormState  := wsMaximized; // tela relat�rio maximizada
            Execute; // executa o relat�rio
          end;
      end
    else
      ShowMessage ('Nenhum Registro Encontrado.');
end;

procedure TFrmCadCliente.RvSysClienteBeforePrint(Sender: TObject);
begin

  With RvSysCliente .BaseReport do
    begin
      FontName := 'Arial'; //define a fonte como Arial
      FontSize := 11;//define o tamanho da fonte para 11
      Bold := false; // desabilita o estilo de fonte negrito
      SetPaperSize(DMPAPER_A4, 0, 0); //ajusta tamanho do papel
    end;

end;

procedure TFrmCadCliente.RvSysClientePrint(Sender: TObject);
begin

  With RvSysCliente.BaseReport do
    begin
      QueryClientes.First; // vai para o primeiro registro da query
      While (not QueryClientes.Eof) do // enquanto n�o for fim de arquivo
      begin
        Lin := 1; // Declarar vari�vel Lin com o tipo Real e escopo global
        Cab_RelCadCliente; // chama a procedure cabe�alho do relat�rio
        While (not QueryClientes.Eof) and (Lin <= 29) do
        begin
          Det_RelCadCliente; // chama a procedure detalhe do relat�rio
          QueryClientes.Next; //vai para o pr�ximo registro
        end;
        if not QueryClientes.Eof then
          NewPage; //  insere uma nova p�gina ao relat�rio
      end;
      Lin := Lin - 0.2;
      MoveTo(0.7,Lin); //move o cursor para a coluna e linha indicados
      LineTo(20.5,Lin);//tra�a uma linha at� posi��o coluna x linha  indicada.
      Lin := Lin + 0.5;
    end;

end;

procedure TFrmCadCliente.Det_RelCadCliente; // Detalhe do relat�rio
begin
  with RvSysCliente.BaseReport do
  begin
    Gotoxy(0.7,Lin);//tabula coluna e linha no relat�rio
    Print (QueryClientesCliNome.AsString); // Imprime Nome do cliente
    Gotoxy(9,Lin);
    Print (QueryClientesCliEnd.AsString);
    Gotoxy(13.5,Lin);
    Print (QueryClientesCliNumFone.AsString);
    Gotoxy(17.5,Lin);
    Print(QueryClientesCliCid.AsString);
    Lin := Lin + 0.5;
  end;
end;

procedure TFrmCadCliente.Cab_RelCadCliente; // Cabe�alho
begin
  with RvSysCliente.BaseReport do
  begin
    Gotoxy(0.7,Lin); // Declarar variable Lin com o tipo Real e escopo global
    Print('Data:' + FormatDateTime('dd/mm/yyyy " - Hora:" hh:mm:ss',now));
    Bold := False;
    Gotoxy(18,Lin); // tabula coluna e linha de impress�o
    Print('P�g.:'+Macro(midCurrentPage)+'/'+Macro(midTotalPages));
    Bold := True; //define estilo da fonte para negrito
    Gotoxy(08,Lin);
    Print('Empresa Distribuidora York'); // Escreve dados no relat�rio
    Lin := Lin + 0.5;
    Gotoxy(08,Lin);
    Print('Relat�rio de Clientes');
    Lin := Lin + 0.5;
    Gotoxy(0.7, Lin);
    Lin := Lin + 0.5;
    Gotoxy(6,Lin);
    MoveTo(0.7,Lin);
    LineTo(20.5,Lin);
    Lin := Lin + 0.5;

    Gotoxy(0.7,Lin);
    Print ('Nome');
    Gotoxy(9,Lin);
    Print ('Endere�o');
    Gotoxy(13.5,Lin);
    Print ('Fone');
    Gotoxy(17.5,Lin);
    Print('Cidade');

    Lin := Lin + 0.2;
    MoveTo(0.7,Lin);
    LineTo(20.5,Lin);
    Lin := Lin + 0.5;
    Bold := False;
  end;
end;

procedure TFrmCadCliente.sbPlanilhaClick(Sender: TObject);
var   Pasta : Variant; // este tipo aceita qualquer tipo de informa��o, inclusive Objeto OLE
      Linha : Integer;
begin
  dm.Tab_Clientes.Filtered := False;
  Linha := 2;
  Pasta := CreateOleObject('Excel.Application'); // cria uma aplica��o do Excel
  Pasta.WorkBooks.Add(1); // adiciona uma pasta do Excel
  Pasta.Caption := 'Cadastro de Clientes'; // T�tulo da planilha
  Pasta.Visible := False; // Deixa a planilha invis�vel
  Pasta.Cells[1,1] := 'C�digo'; // insere o conte�do 'C�digo' na c�lula A1
  Pasta.Cells[1,2] := 'Cliente'; // insere o conte�do 'Cliente' na c�lula A2
  Pasta.Cells[1,3] := 'Endere�o'; // insere o conte�do 'Endere�o'na c�lula A3
  Pasta.Cells[1,4] := 'Cep'; // insere o conte�do 'Cep'na c�lula A4
  Pasta.Cells[1,5] := 'Cidade'; // insere o conte�do 'Cidade'na c�lula A5
  Pasta.Cells[1,6] := 'UF'; // insere o conte�do 'UF'na c�lula A6
  Pasta.Cells[1,7] := 'Fone'; // insere o conte�do 'Fone'na c�lula A7
  Pasta.Cells[1,8] := 'E-mail'; // insere o conte�do 'E-mail'na c�lula A8
  Pasta.Cells[1,9] := 'CPF'; // insere o conte�do 'CPF'na c�lula A9
  Pasta.Cells[1,10] := 'RG'; // insere o conte�do 'RG'na c�lula A10
  Pasta.Cells[1,11] := 'Contato'; // insere o conte�do 'Contato'na c�lula A11
  dm.Tab_Clientes.DisableControls; // desabilita os controles de dados
  Try
     While not dm.Tab_Clientes.Eof do //executa enquanto n�o for fim de arquivo de clientes
     begin
          Pasta.Cells[Linha,1] := dm.Tab_ClientesCliCodigo.Value;
          Pasta.Cells[Linha,2] := dm.Tab_ClientesCliNome.Value;
          Pasta.Cells[Linha,3] := dm.Tab_ClientesCliEnd.Value;
          Pasta.Cells[Linha,4] := dm.Tab_ClientesCliCep.Value;
          Pasta.Cells[Linha,5] := dm.Tab_ClientesCliCid.Value;
          Pasta.Cells[Linha,6] := dm.Tab_ClientesCliEst.Value;
          Pasta.Cells[Linha,7] := dm.Tab_ClientesCliNumFone.Value;
          Pasta.Cells[Linha,8] := dm.Tab_ClientesCliEmail.Value;
          Pasta.Cells[Linha,9] := dm.Tab_ClientesCliDoc1.Value;
          Pasta.Cells[Linha,10] := dm.Tab_ClientesCliDoc2.Value;
          Pasta.Cells[Linha,11] := dm.Tab_ClientesCliContato.Value;
          Linha := Linha + 1; // Incrementa a vari�vel Linha em 01
          dm.Tab_Clientes.Next; //vai para o pr�ximo registro da tabela de clientes
      end;
      Pasta.Columns.AutoFit; // Faz auto ajuste das colunas do Excel
      Pasta.WorkBooks[1].Sheets[1].Protect(DrawingObjects:=True, Contents:=True,   Scenarios:=True,         Password:='1234'); // Coloca Senha de Prote��o na Planilha 01
      If  SaveDialog1.Execute then // O componente SaveDialogs est� na paleta Dialogs 
         Pasta.WorkBooks[1].SaveAs(SaveDialog1.FileName); // Salva a Planilha (Salvar como)
     Pasta.Visible := True; //Deixa a planilha vis�vel
     Finally
         dm.Tab_Clientes.EnableControls;  // sempre ser� executada essa linha
         Pasta := Unassigned;
     end;
end;

procedure TFrmCadCliente.sbGraficoClick(Sender: TObject);
begin

    FrmGraficoCliente:= TFrmGraficoCliente.Create(Self); //cria��o manual
    FrmGraficoCliente.ShowModal; //exibe a tela no modo modal
    FrmGraficoCliente.Release; //libera a tela da mem�ria
    FrmGraficoCliente:= nil; //atribui o conte�do nulo para a vari�vel FrmGraficoCliente

end;

procedure TFrmCadCliente.DBNavigator2BeforeAction(Sender: TObject;
  Button: TNavigateBtn);
begin
  inherited;
if (Button = nbInsert) then 
begin
   Dm.Tab_Clientes.Cancel;
   Dm.Tab_Clientes.Append;
   EdtNome.SetFocus;
end;

end;

end.






