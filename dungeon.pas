(* Generate a random, grid based dungeon *)

unit dungeon;

{$mode objfpc}{$H+}

interface

uses
  crt;

const
  (* Columns of the game map *)
  MAXCOLUMNS = 67;
  (* Rows of the game map *)
  MAXROWS = 19;

var
  r, c, i: integer;
  dungeonArray: array[1..MAXROWS, 1..MAXCOLUMNS] of char;
  totalRooms, roomSquare: smallint;
  (* Player starting position *)
  startX, startY: smallint;
  (* start creating corridors once this rises above 1 *)
  roomCounter: smallint;
  (* Centre of rooms for connecting corridors *)
  oldX, oldY, newX, newY: smallint;

(* Carve a horizontal tunnel *)
procedure carveHorizontally(x1, x2, y: smallint);
(* Carve a vertical tunnel *)
procedure carveVertically(y1, y2, x: smallint);
(* Create a room *)
procedure createRoom(gridNumber: smallint);
(* Generate a dungeon *)
procedure generate();

implementation

procedure carveHorizontally(x1, x2, y: smallint);
var
  x: byte;
begin
  if x1 < x2 then
  begin
    for x := x1 to x2 do
      dungeonArray[y][x] := '.';
  end;
  if x1 > x2 then
  begin
    for x := x2 to x1 do
      dungeonArray[y][x] := '.';
  end;
end;

procedure carveVertically(y1, y2, x: smallint);
var
  y: byte;
begin
  if y1 < y2 then
  begin
    for y := y1 to y2 do
      dungeonArray[y][x] := '.';
  end;
  if y1 > y2 then
  begin
    for y := y2 to y1 do
      dungeonArray[y][x] := '.';
  end;
end;

procedure createCorridor(fromX, fromY, toX, toY: smallint);
var
  direction: byte;
begin
  // flip a coin to decide whether to first go horizontally or vertically
  direction := Random(2);
  // horizontally first
  if direction = 1 then
  begin
    carveHorizontally(fromX, toX, fromY);
    carveVertically(fromY, toY, toX);
  end
  // vertically first
  else
  begin
    carveVertically(fromY, toY, toX);
    carveHorizontally(fromX, toX, fromY);
  end;
end;

procedure createRoom(gridNumber: smallint);
var
  topLeftX, topLeftY, roomHeight, roomWidth, drawHeight, drawWidth,
  nudgeDown, nudgeAcross: smallint;
begin
  // row 1
  if (gridNumber >= 1) and (gridNumber <= 13) then
  begin
    topLeftX := (gridNumber * 5) - 3;
    topLeftY := 2;
  end;
  // row 2
  if (gridNumber >= 14) and (gridNumber <= 26) then
  begin
    topLeftX := (gridNumber * 5) - 68;
    topLeftY := 8;
  end;
  // row 3
  if (gridNumber >= 27) and (gridNumber <= 39) then
  begin
    topLeftX := (gridNumber * 5) - 133;
    topLeftY := 14;
  end;
  (* Randomly select room dimensions between 2 - 4 tiles in height / width *)
  roomHeight := Random(2) + 2;
  roomWidth := Random(2) + 2;
  (* Change starting point of each room so they don't all start
     drawing from the top left corner                           *)
  case roomHeight of
    2: nudgeDown := Random(0) + 2;
    3: nudgeDown := Random(0) + 1;
    else
      nudgeDown := 0;
  end;
  case roomWidth of
    2: nudgeAcross := Random(0) + 2;
    3: nudgeAcross := Random(0) + 1;
    else
      nudgeAcross := 0;
  end;
  (* Save coordinates of the centre of the room *)
  newX := (topLeftX + nudgeAcross) + (roomWidth div 2);
  newY := (topLeftY + nudgeDown) + (roomHeight div 2);
  (* Draw room within the grid square *)
  for drawHeight := 0 to roomHeight do
  begin
    for drawWidth := 0 to roomWidth do
    begin
      dungeonArray[(topLeftY + nudgeDown) + drawHeight][(topLeftX + nudgeAcross) +
        drawWidth] := '.';
    end;
  end;
end;

procedure generate();
begin
  roomCounter := 0;
  // fill map with walls
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      dungeonArray[r][c] := '#';
    end;
  end;
  // Random(Range End - Range Start) + Range Start;
  totalRooms := Random(5) + 15; // between 15 - 20 rooms
  for i := 1 to totalRooms do
  begin
    // randomly choose grid location from 1 to 39
    roomSquare := Random(38) + 1;
    createRoom(roomSquare);
    Inc(roomCounter);
    if roomCounter = 1 then
    begin
      startX := newX;
      startY := newY;
      oldX := newX;
      oldY := newY;
    end;
    if roomCounter > 1 then
      createCorridor(oldX, oldY, newX, newY);
    oldX := newX;
    oldY := newY;
  end;
end;

end.

