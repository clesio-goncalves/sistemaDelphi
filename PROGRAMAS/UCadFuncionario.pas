unit UCadFuncionario;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UCadPadrao, ComCtrls, ExtCtrls, DBCtrls, Grids, DBGrids,
  StdCtrls, Buttons, Db, Mask, ADODB, RpCon, RpConDS, RpBase, RpSystem,
  RpDefine, RpRave, ComObj;

type
  TFrmCadFuncionario = class(TFrmCadPadrao)
    lbNome: TLabel;
    EdtNome: TDBEdit;
    lbEndereco: TLabel;
    EdtEndereco: TDBEdit;
    lbCep: TLabel;
    EdtCep: TDBEdit;
    lbCidade: TLabel;
    EdtCidade: TDBEdit;
    LbUf: TLabel;
    EdtUf: TDBEdit;
    lbFone: TLabel;
    EdtFone: TDBEdit;
    lbDataAdmissao: TLabel;
    EdtDataAdmissao: TDBEdit;
    lbSalario: TLabel;
    EdtSalario: TDBEdit;
    RvPrjFuncionario: TRvProject;
    RvSysFuncionario: TRvSystem;
    RvDtCnFuncionario: TRvDataSetConnection;
    QueryFuncionarios: TADOQuery;
    QueryFuncionariosFunNome: TWideStringField;
    QueryFuncionariosFunNumFone: TWideStringField;
    QueryFuncionariosFunDatAdm: TDateTimeField;
    QueryFuncionariosFunSalario: TBCDField;
    FiltraCliente: TButton;
    sbPlanilha: TButton;
    sbGrafico: TButton;
    SaveDialog1: TSaveDialog;
    procedure FormShow(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure DBNavigator2BeforeAction(Sender: TObject;
      Button: TNavigateBtn);
    procedure sbPesquisarClick(Sender: TObject);
    procedure sbImprimirClick(Sender: TObject);
    procedure RvSysFuncionarioBeforePrint(Sender: TObject);
    procedure RvSysFuncionarioPrint(Sender: TObject);
    procedure Det_RelCadFuncionario;
    procedure Cab_RelCadFuncionario;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FiltraClienteClick(Sender: TObject);
    procedure sbPlanilhaClick(Sender: TObject);
    procedure sbGraficoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCadFuncionario: TFrmCadFuncionario;
  Ascendente: Boolean;
  Lin: Real;

implementation

uses UDM, UGraficoFuncionario;

{$R *.dfm}

procedure TFrmCadFuncionario.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;

    Dm.Tab_Funcionarios.Close;

end;

procedure TFrmCadFuncionario.FormShow(Sender: TObject);
begin
  inherited;

    Dm.Tab_Funcionarios.Open;
    Ascendente := False; 

end;

procedure TFrmCadFuncionario.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  inherited;

  If Odd(dm.tab_Funcionarios.RecNo) and (dm.tab_Funcionarios.State <> dsInsert) then
  begin //Lembre-se de colocar a unit DB na cl�usula uses na unit da tela.
      DBGrid1.Canvas.Brush.Color := clMoneyGreen; // muda a cor do pincel
      DBGrid1.Canvas.FillRect(Rect); // Preenche o fundo com a cor especificada
      DBGrid1.DefaultDrawDataCell(Rect,Column.Field,State);// desenha as c�lulas da grade
  end;

end;

procedure TFrmCadFuncionario.DBGrid1TitleClick(Column: TColumn);
begin
  inherited;

  Ascendente:= not Ascendente ;

  If Ascendente then
     Dm.tab_Funcionarios.IndexFieldNames := Column.FieldName + '   ASC'
  else
 	   Dm.tab_Funcionarios.IndexFieldNames := Column.FieldName + '    DESC';

end;

procedure TFrmCadFuncionario.DBNavigator2BeforeAction(Sender: TObject;
  Button: TNavigateBtn);
begin
  inherited;
if (Button = nbInsert) then 
begin
   Dm.Tab_Funcionarios.Cancel;
   Dm.Tab_Funcionarios.Append;
   EdtNome.SetFocus;
end;
end;

procedure TFrmCadFuncionario.sbPesquisarClick(Sender: TObject);
begin
  inherited;
    If not Dm.Tab_Funcionarios.Locate( 'FunNome',ValorCampo.Text, [loCaseInsensitive]) then
      MessageDlg('Funcion�rio n�o cadastrado!', mtError, [mbOk], 0);

end;

procedure TFrmCadFuncionario.sbImprimirClick(Sender: TObject);
var Qtde : String;
    OK   : Boolean;
begin
  OK := InputQuery('Digite o S�l�rio M�nimo', 'Sal�rio M�nimo', Qtde);
  if OK then
  begin
    With QueryFuncionarios do
    begin
       Close;
       Parameters[0].value := Qtde;
       Open;
       //RvPrjFuncionario.Execute;
       With RvSysFuncionario do
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

procedure TFrmCadFuncionario.RvSysFuncionarioBeforePrint(Sender: TObject);
begin

   With RvSysFuncionario .BaseReport do
    begin
      FontName := 'Arial'; //define a fonte como Arial
      FontSize := 11;//define o tamanho da fonte para 11
      Bold := false; // desabilita o estilo de fonte negrito
      SetPaperSize(DMPAPER_A4, 0, 0); //ajusta tamanho do papel
    end;

end;

procedure TFrmCadFuncionario.RvSysFuncionarioPrint(Sender: TObject);
begin
   With RvSysFuncionario.BaseReport do
    begin
      QueryFuncionarios.First; // vai para o primeiro registro da query
      While (not QueryFuncionarios.Eof) do // enquanto n�o for fim de arquivo
      begin
        Lin := 1; // Declarar vari�vel Lin com o tipo Real e escopo global
        Cab_RelCadFuncionario; // chama a procedure cabe�alho do relat�rio
        While (not QueryFuncionarios.Eof) and (Lin <= 29) do
        begin
          Det_RelCadFuncionario; // chama a procedure detalhe do relat�rio
          QueryFuncionarios.Next; //vai para o pr�ximo registro
        end;
        if not QueryFuncionarios.Eof then
          NewPage; //  insere uma nova p�gina ao relat�rio
      end;
      Lin := Lin - 0.2;
      MoveTo(0.7,Lin); //move o cursor para a coluna e linha indicados
      LineTo(20.5,Lin);//tra�a uma linha at� posi��o coluna x linha  indicada.
      Lin := Lin + 0.5;
    end;
end;

procedure TFrmCadFuncionario.Det_RelCadFuncionario; // Detalhe do relat�rio
begin
  with RvSysFuncionario.BaseReport do
  begin
    Gotoxy(0.7,Lin);//tabula coluna e linha no relat�rio
    Print (QueryFuncionariosFunNome.AsString); // Imprime Nome do funcion�rio
    Gotoxy(9,Lin);
    Print (QueryFuncionariosFunNumFone.AsString);
    Gotoxy(13,Lin);
    Print (QueryFuncionariosFunDatAdm.AsString);
    Gotoxy(18,Lin);
    Print(QueryFuncionariosFunSalario.AsString);
    Lin := Lin + 0.5;
  end;
end;

procedure TFrmCadFuncionario.Cab_RelCadFuncionario; // Cabe�alho
begin
  with RvSysFuncionario.BaseReport do
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
    Print('Relat�rio de Funcion�rios');
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
    Print ('Fone');
    Gotoxy(13,Lin);
    Print ('Data de Admiss�o');
    Gotoxy(18,Lin);
    Print('Sal�rio');

    Lin := Lin + 0.2;
    MoveTo(0.7,Lin);
    LineTo(20.5,Lin);
    Lin := Lin + 0.5;
    Bold := False;
  end;
end;

procedure TFrmCadFuncionario.FiltraClienteClick(Sender: TObject);
Var Salario : String;
    Ok : Boolean;
begin
   Salario := 'ALL';
   Ok := InputQuery('Filtra Funcion�rios por Sal�rio', 'Digite o valor do sal�rio: (ALL remove o filtro)',Salario);
   If Ok then
     With dm.Tab_Funcionarios do
     begin
       Filtered := false; // Desativa o filtro
       if Salario <>  'ALL' then
       begin      // A fun��o QuotedStr coloca ap�strofos  no string.
         Filter := 'FunSalario = ' + QuotedStr(Salario); // monta o filtro
         Filtered := true; // Ativa o filtro
       end;
     end;


end;

procedure TFrmCadFuncionario.sbPlanilhaClick(Sender: TObject);
var   Pasta : Variant; // este tipo aceita qualquer tipo de informa��o, inclusive Objeto OLE
      Linha : Integer;
begin
  dm.Tab_Funcionarios.Filtered := False;
  Linha := 2;
  Pasta := CreateOleObject('Excel.Application'); // cria uma aplica��o do Excel
  Pasta.WorkBooks.Add(1); // adiciona uma pasta do Excel
  Pasta.Caption := 'Cadastro de Funcion�rios'; // T�tulo da planilha
  Pasta.Visible := False; // Deixa a planilha invis�vel
  Pasta.Cells[1,1] := 'C�digo'; // insere o conte�do 'C�digo' na c�lula A1
  Pasta.Cells[1,2] := 'Funcion�rio'; // insere o conte�do 'Funcion�rio' na c�lula A2
  Pasta.Cells[1,3] := 'Endere�o'; // insere o conte�do 'Endere�o' na c�lula A3
  Pasta.Cells[1,4] := 'Cep'; // insere o conte�do 'Cep'na c�lula A4
  Pasta.Cells[1,5] := 'Cidade'; // insere o conte�do 'Cidade'na c�lula A5
  Pasta.Cells[1,6] := 'UF'; // insere o conte�do 'UF'na c�lula A6
  Pasta.Cells[1,7] := 'Fone'; // insere o conte�do 'Fone'na c�lula A7
  Pasta.Cells[1,8] := 'Data de Admiss�o'; // insere o conte�do 'Data de Admiss�o'na c�lula A8
  Pasta.Cells[1,9] := 'Sal�rio'; // insere o conte�do 'Sal�rio'na c�lula A9
  dm.Tab_Funcionarios.DisableControls; // desabilita os controles de dados
  Try
     While not dm.Tab_Funcionarios.Eof do //executa enquanto n�o for fim de arquivo de funcionarios
     begin
          Pasta.Cells[Linha,1] := dm.Tab_FuncionariosFunCodigo.Value;
          Pasta.Cells[Linha,2] := dm.Tab_FuncionariosFunNome.Value;
          Pasta.Cells[Linha,3] := dm.Tab_FuncionariosFunEnder.Value;
          Pasta.Cells[Linha,4] := dm.Tab_FuncionariosFunCep.Value;
          Pasta.Cells[Linha,5] := dm.Tab_FuncionariosFunCid.Value;
          Pasta.Cells[Linha,6] := dm.Tab_FuncionariosFunEst.Value;
          Pasta.Cells[Linha,7] := dm.Tab_FuncionariosFunNumFone.Value;
          Pasta.Cells[Linha,8] := dm.Tab_FuncionariosFunDatAdm.Value;
          Pasta.Cells[Linha,9] := dm.Tab_FuncionariosFunSalario.Value;
          Linha := Linha + 1; // Incrementa a vari�vel Linha em 01
          dm.Tab_Funcionarios.Next; //vai para o pr�ximo registro da tabela de funcion�rios
      end;
      Pasta.Columns.AutoFit; // Faz auto ajuste das colunas do Excel
      Pasta.WorkBooks[1].Sheets[1].Protect(DrawingObjects:=True, Contents:=True,   Scenarios:=True,         Password:='1234'); // Coloca Senha de Prote��o na Planilha 01
      If  SaveDialog1.Execute then // O componente SaveDialogs est� na paleta Dialogs
         Pasta.WorkBooks[1].SaveAs(SaveDialog1.FileName); // Salva a Planilha (Salvar como)
     Pasta.Visible := True; //Deixa a planilha vis�vel
     Finally
         dm.Tab_Funcionarios.EnableControls;  // sempre ser� executada essa linha
         Pasta := Unassigned;
     end;

end;

procedure TFrmCadFuncionario.sbGraficoClick(Sender: TObject);
begin

    FrmGraficoFuncionario:= TFrmGraficoFuncionario.Create(Self); //cria��o manual
    FrmGraficoFuncionario.ShowModal; //exibe a tela no modo modal
    FrmGraficoFuncionario.Release; //libera a tela da mem�ria
    FrmGraficoFuncionario:= nil; //atribui o conte�do nulo para a vari�vel FrmGraficoFuncionarios

end;

end.
