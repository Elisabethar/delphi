unit URelatorioDesenho;

interface

uses
  Windows,
  SysUtils,
  Messages,
  Classes,
  Graphics,
  Controls,
  QuickRpt,
  QRPrntr,
  QRCtrls,
  DBClient,
  QRPDFFilt,
  DB;

type
  TTipoShape = (tsLinha, tsRetangulo);

  TDesenho = class(TObject)
  private
    fComponenteParent: TWinControl;
    fRelatorioParent: TWinControl;
    procedure RedimensionarParent(Componente: TWinControl);
    procedure VerificaParent;
    procedure VerificaField(ANomeField: String; ADataSet: TDataSet);
  public
    property ComponenteParent: TWinControl read fComponenteParent write fComponenteParent;
    property RelatorioParent: TWinControl read fRelatorioParent write fRelatorioParent;

    procedure AdicionarCampoDBLabel(NomeField: String; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer);
    procedure AdicionarCampoLabel(Texto: String; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer);
    procedure AdicionarIncrementoAlturaBand(IncrementoAltura: Integer);
    procedure AdicionarShape(TipoShape: TTipoShape; Linha, Coluna, Comprimento, Altura: Integer);
    procedure ConfigurarCampoLabel(var Componente: TQRCustomLabel; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer);

    constructor Create(ARelatorioParent, AComponenteParent: TWinControl);
    destructor Destroy; override;
  end;

implementation

uses StrUtils;

{ TDesenho }

constructor TDesenho.Create(ARelatorioParent, AComponenteParent: TWinControl);
begin
  fRelatorioParent := ARelatorioParent;
  fComponenteParent := AComponenteParent;
end;

destructor TDesenho.Destroy;
begin
  fComponenteParent := nil;
  fRelatorioParent := nil;
  inherited;
end;

procedure TDesenho.ConfigurarCampoLabel(var Componente: TQRCustomLabel; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer);
begin
  VerificaParent();
  Componente.Parent := ComponenteParent;
  Componente.Left := Coluna;
  Componente.Top := Linha;
  Componente.Font.Size := TamanhoFonte;
  Componente.Width := TamanhoMaxTexto;
  Componente.AutoSize := False;
  if (TamanhoMaxTexto = 0) then
    Componente.AutoSize := True;
  RedimensionarParent(Componente);
end;

procedure TDesenho.AdicionarCampoLabel(Texto: String; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer);
var
  Componente: TQRCustomLabel;
begin
  VerificaParent();
  Componente := TQRLabel.Create(RelatorioParent);
  TQRLabel(Componente).Transparent := True;
  TQRLabel(Componente).Caption := Texto;
  ConfigurarCampoLabel(Componente, Linha, Coluna, TamanhoMaxTexto, TamanhoFonte);
end;

procedure TDesenho.AdicionarCampoDBLabel(NomeField: String; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer);
var
  Componente: TQRCustomLabel;
begin
  VerificaParent();
  Componente := TQRDBText.Create(RelatorioParent);
  TQRDBText(Componente).Transparent := True;

  if (ComponenteParent.ClassType = TQRSubDetail) then
    TQRDBText(Componente).DataSet := TQRSubDetail(ComponenteParent).DataSet
  else
    if (ComponenteParent.ClassType = TQRBand) or (ComponenteParent.ClassType = TQRChildBand) then
      TQRDBText(Componente).DataSet := TQuickRep(RelatorioParent).DataSet
    else
      raise Exception.CreateFmt('N�o identificado Parent para adicionar campo DBLabel %S', [NomeField]);

  TQRDBText(Componente).DataField := NomeField;
  VerificaField(TQRDBText(Componente).DataField, TQRDBText(Componente).DataSet);

  ConfigurarCampoLabel(Componente, Linha, Coluna, TamanhoMaxTexto, TamanhoFonte);
end;

procedure TDesenho.AdicionarShape(TipoShape: TTipoShape; Linha, Coluna, Comprimento, Altura: Integer);
var
  Componente: TQRShape;
begin
  VerificaParent();
  Componente := TQRShape.Create(RelatorioParent);
  case TipoShape of
    tsLinha: Componente.Shape := qrsHorLine;
    tsRetangulo: Componente.Shape := qrsRectangle;
  end;
  Componente.Pen.Style := psDot; { linha tracejada }
  Componente.Parent := ComponenteParent;
  Componente.Left := Coluna;
  Componente.Top := Linha;
  Componente.Width := Comprimento;
  Componente.Height := Altura;
  if (Comprimento = 0) then
    Componente.Width := ComponenteParent.Width - Coluna;
  if (Altura <= 0) then
    raise Exception.Create('Obrigat�rio Informar Altura');
  RedimensionarParent(Componente);
end;

procedure TDesenho.RedimensionarParent(Componente: TWinControl);
{ Result := TWinControl(FindComponent(NomeComponente)); }
var
  TamanhoOcupadoComponente: Integer;
begin
  VerificaParent();
  TamanhoOcupadoComponente := Componente.Top + Componente.Height;
  if (ComponenteParent.Height < TamanhoOcupadoComponente) then
    ComponenteParent.Height := TamanhoOcupadoComponente;
end;

procedure TDesenho.AdicionarIncrementoAlturaBand(IncrementoAltura: Integer);
begin
  VerificaParent();
  TQRCustomBand(ComponenteParent).Height := TQRCustomBand(ComponenteParent).Height + IncrementoAltura;
end;

procedure TDesenho.VerificaParent();
begin
  if (RelatorioParent = nil) then
    raise Exception.Create('Relat�rio Parent n�o informado');
  if (ComponenteParent = nil) then
    raise Exception.Create('Componente Parent n�o informado');
end;

procedure TDesenho.VerificaField(ANomeField: String; ADataSet: TDataSet);
begin
  if (ADataSet.FindField(ANomeField) = nil) then
    raise Exception.CreateFmt('Campo %S n�o existe no DataSet %S', [ANomeField, ADataSet.Name]);
end;

end.
