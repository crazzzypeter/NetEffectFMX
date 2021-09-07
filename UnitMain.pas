// govnocode detected
unit UnitMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Colors, FMX.Controls.Presentation;

type
  TNetPoint = record
    X, Y: Double;
    Dx, Dy: Double;
  end;

  TFormMain = class(TForm)
    TimerAnimate: TTimer;
    PaintBox: TPaintBox;
    Panel1: TPanel;
    HueTrackBarLinesColor: THueTrackBar;
    HueTrackBarPointsColor: THueTrackBar;
    TrackBarStartFadeDistance: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    StyleBook: TStyleBook;
    procedure TimerAnimateTimer(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
    procedure FormCreate(Sender: TObject);
  private const
    // ������ �����
    Size = 5;
    // ���������� ������ �����
    MinFadeDistance = 200;
  private
    Points: array of TNetPoint;
  public
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.UIConsts;

{$R *.fmx}

procedure TFormMain.FormCreate(Sender: TObject);
var
  I: Integer;
  Angle: Double;
begin
  TrackBarStartFadeDistance.Value := MinFadeDistance;
  HueTrackBarLinesColor.Value := 0.79;
  HueTrackBarPointsColor.Value := 0.6;

  // ���������� �����
  SetLength(Points, 50);
  for I := 0 to High(Points) do
  begin
    // ����������
    Points[I].X := Random * PaintBox.LocalRect.Width;
    Points[I].Y := Random * PaintBox.LocalRect.Height;

    // �������� �� �����������/���������
    Angle := Random * 2 * Pi;
    Points[I].Dx := Cos(Angle) * 4;
    Points[I].Dy := Sin(Angle) * 4;
  end;
end;

procedure TFormMain.PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
var
  Point: TNetPoint;
  I, J: Integer;
  Point1, Point2: TPointF;
  Fade: Double;
  LineCount: Integer;
begin
  // ������ �����
  Canvas.Stroke.Color := HSLtoRGB(HueTrackBarLinesColor.Value, 0.9, 0.7);//;;TAlphaColorF.Create(0.8, 0.0, 1.0, 1.0).ToAlphaColor;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  LineCount := 0;
  for I := 0 to High(Points) do
  begin
    for J := I + 1 to High(Points) do
    begin
      Point1 := TPointF.Create(Points[I].X, Points[I].Y);
      Point2 := TPointF.Create(Points[J].X, Points[J].Y);

      // ��������� ���������� ����� ������� � -00 -> 0..1
      Fade := -(Point1.Distance(Point2) -
        TrackBarStartFadeDistance.Value) / TrackBarStartFadeDistance.Value;

      // ���� ���� ����������� ������
      if Fade > 0 then
      begin
        // �������
        Canvas.Stroke.Thickness := Fade * 5 + 1;
        // draw ...
        Canvas.DrawLine(
          Point1,
          Point2,
          Fade
        );
        Inc(LineCount);
      end;
    end;
  end;

  // ������ ����� ������ �����
  Canvas.Fill.Color := HSLtoRGB(HueTrackBarPointsColor.Value, 0.9, 0.7);
  Canvas.Fill.Kind := TBrushKind.Solid;
  for Point in Points do
  begin
    Canvas.FillEllipse(
      TRectF.Create(
        Point.X - Size,
        Point.Y - Size,
        Point.X + Size,
        Point.Y + Size
      ),
      1.0
    );
  end;

  Caption := 'Line count: ' + LineCount.ToString;
end;

procedure TFormMain.TimerAnimateTimer(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to High(Points) do
  begin
    // ���������� ����� � ����������� �� ���������
    Points[I].X := Points[I].X + Points[I].Dx;
    Points[I].Y := Points[I].Y + Points[I].Dy;

    // ������������ ����� �� �����
    if Points[I].X < 0 then
      Points[I].Dx := Abs(Points[I].Dx);
    if Points[I].X > PaintBox.LocalRect.Width then
      Points[I].Dx := -Abs(Points[I].Dx);
    if Points[I].Y < 0 then
      Points[I].Dy := Abs(Points[I].Dy);
    if Points[I].Y > PaintBox.LocalRect.Height then
      Points[I].Dy := -Abs(Points[I].Dy);
  end;

  PaintBox.Repaint;
end;

end.
