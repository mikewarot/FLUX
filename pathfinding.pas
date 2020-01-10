unit pathfinding;

{$mode objfpc}{$H+}

interface

uses
  crt;

(* Bresenham line between 2 points *)
procedure drawLine(x1, y1, x2, y2: integer);
(* Move 1 step towards a target X position *)
function getX(x1, y1, x2, y2: integer): smallint;
(* Move 1 step towards a target Y position *)
function getY(x1, y1, x2, y2: integer): smallint;

implementation

function getX(x1, y1, x2, y2: integer): smallint;
var
  i, deltax, deltay, numpixels, d, dinc1, dinc2, x, xinc1, xinc2, y,
  yinc1, yinc2: integer;
begin
  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);
  if deltax >= deltay then
  begin
    numpixels := deltax + 1;
    d := (2 * deltay) - deltax;
    dinc1 := deltay shl 1;
    dinc2 := (deltay - deltax) shl 1;
    xinc1 := 1;
    xinc2 := 1;
    yinc1 := 0;
    yinc2 := 1;
  end
  else
  begin
    numpixels := deltay + 1;
    d := (2 * deltax) - deltay;
    dinc1 := deltax shl 1;
    dinc2 := (deltax - deltay) shl 1;
    xinc1 := 0;
    xinc2 := 1;
    yinc1 := 1;
    yinc2 := 1;
  end;
  if x1 > x2 then
  begin
    xinc1 := -xinc1;
    xinc2 := -xinc2;
  end;
  if y1 > y2 then
  begin
    yinc1 := -yinc1;
    yinc2 := -yinc2;
  end;
  x := x1;
  y := y1;
  for i := 1 to numpixels do
  begin
    if i = 2 then
    begin
      Result := x;
      exit;
    end;
    if d < 0 then
    begin
      d := d + dinc1;
      x := x + xinc1;
      y := y + yinc1;
    end
    else
    begin
      d := d + dinc2;
      x := x + xinc2;
      y := y + yinc2;
    end;
  end;
end;

function getY(x1, y1, x2, y2: integer): smallint;
var
  i, deltax, deltay, numpixels, d, dinc1, dinc2, x, xinc1, xinc2, y,
  yinc1, yinc2: integer;
begin
  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);
  if deltax >= deltay then
  begin
    numpixels := deltax + 1;
    d := (2 * deltay) - deltax;
    dinc1 := deltay shl 1;
    dinc2 := (deltay - deltax) shl 1;
    xinc1 := 1;
    xinc2 := 1;
    yinc1 := 0;
    yinc2 := 1;
  end
  else
  begin
    numpixels := deltay + 1;
    d := (2 * deltax) - deltay;
    dinc1 := deltax shl 1;
    dinc2 := (deltax - deltay) shl 1;
    xinc1 := 0;
    xinc2 := 1;
    yinc1 := 1;
    yinc2 := 1;
  end;
  if x1 > x2 then
  begin
    xinc1 := -xinc1;
    xinc2 := -xinc2;
  end;
  if y1 > y2 then
  begin
    yinc1 := -yinc1;
    yinc2 := -yinc2;
  end;
  x := x1;
  y := y1;
  for i := 1 to numpixels do
  begin
    if i = 2 then
    begin
      Result := y;
      exit;
    end;
    if d < 0 then
    begin
      d := d + dinc1;
      x := x + xinc1;
      y := y + yinc1;
    end
    else
    begin
      d := d + dinc2;
      x := x + xinc2;
      y := y + yinc2;
    end;
  end;
end;

procedure drawLine(x1, y1, x2, y2: integer);
var
  i, deltax, deltay, numpixels, d, dinc1, dinc2, x, xinc1, xinc2, y,
  yinc1, yinc2: integer;
begin

  (* Calculate delta X and delta Y for initialisation *)
  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);

  (* Initialize all vars based on which is the independent variable *)
  if deltax >= deltay then
  begin

    (* x is independent variable *)
    numpixels := deltax + 1;
    d := (2 * deltay) - deltax;
    dinc1 := deltay shl 1;
    dinc2 := (deltay - deltax) shl 1;
    xinc1 := 1;
    xinc2 := 1;
    yinc1 := 0;
    yinc2 := 1;
  end
  else
  begin

    (* y is independent variable *)
    numpixels := deltay + 1;
    d := (2 * deltax) - deltay;
    dinc1 := deltax shl 1;
    dinc2 := (deltax - deltay) shl 1;
    xinc1 := 0;
    xinc2 := 1;
    yinc1 := 1;
    yinc2 := 1;
  end;

  (* Make sure x and y move in the right directions *)
  if x1 > x2 then
  begin
    xinc1 := -xinc1;
    xinc2 := -xinc2;
  end;
  if y1 > y2 then
  begin
    yinc1 := -yinc1;
    yinc2 := -yinc2;
  end;

  (* Start drawing at *)
  x := x1;
  y := y1;

  (* Draw the pixels *)
  for i := 1 to numpixels do
  begin
    gotoxy(x, y);
    textcolor(Yellow);
    Write('*');
    if d < 0 then
    begin
      d := d + dinc1;
      x := x + xinc1;
      y := y + yinc1;
    end
    else
    begin
      d := d + dinc2;
      x := x + xinc2;
      y := y + yinc2;
    end;
  end;
end;

end.
