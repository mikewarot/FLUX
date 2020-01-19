(* Organises the game world in an array and calculates the players FoV *)

unit map;

{$mode objfpc}{$H+}

interface

uses
  crt, SysUtils;

const
  (* Light grey text *)
  DefaultTXTcol = 7;
  (* Black text background *)
  DefaultBKGcol = 0;
  (* Columns of the game map *)
  MAXCOLUMNS = 67;
  (* Rows of the game map *)
  MAXROWS = 19;
  (* Maximum number of tiles in players sight *)
  MAXVISION = 140;
  (* wall tiles *)
  wall = '#';
  (* floor tiles *)
  floor = '.';

type
  (* Tiles that make up the game world *)
  tile = record
    id: smallint;
    Visible, occupied, blocks: boolean;
    character: char;
    defColour, hiColour: byte;
  end;

  (* tiles that make up vision radius of player *)
  maptiles = record
    tileID: smallint;
    inSight: boolean;
    gtx, gty: smallint;
  end;

(* Calculate what the player can see *)
procedure FOV(x, y: smallint);
(* Set up the map array *)
procedure setupMap;
(* remove everything from FoV array *)
procedure clearVision();
(* Clear the visual representation of the FoV *)
procedure removeFOV();
(* Check if the direction to move to is valid *)
function canMove(checkX, checkY: smallint): boolean;
(* Get the character at a certain location on the map *)
function getTileGlyph(checkX, checkY: smallint): char;
(* Check if an object is in players FoV *)
function canSee(checkX, checkY: smallint): boolean;
(* Occupy tile *)
procedure occupy(x, y: smallint);
(* Unoccupy tile *)
procedure unoccupy(x, y: smallint);
(* Check if a map tile is occupied *)
function isOccupied(checkX, checkY: smallint): boolean;
(* Check if player is on a tile *)
function hasPlayer(checkX, checkY: smallint): boolean;
(* Save map to stringlist *)
function saveMap: string;

implementation

uses
  tui, dungeon, player;

var
  r, c: smallint;
  (* FOV tile ID *)
  visID: smallint;
  visionRadius: array[1..MAXVISION] of maptiles;
  maparea: array[1..19, 1..67] of tile;

(* FOV Procedures *)

(* Update the array of visible tiles *)
procedure updateVisibleTiles(i, y, x: smallint);
begin
  visionRadius[i].tileID := maparea[y][x].id;
  visionRadius[i].inSight := True;
  visionRadius[i].gtx := x;
  visionRadius[i].gty := y;
end;

(* Add what can be seen to the FOV array & paint the tiles *)
procedure paintFOV(y1, x1, y2, x2, y3, x3, y4, x4, y5, x5: smallint);
var
  i, x, y: smallint;
begin
  for i := 1 to 5 do
  begin
    case i of
      1:
      begin
        x := x1;
        y := y1;
      end;
      2:
      begin
        x := x2;
        y := y2;
      end;
      3:
      begin
        x := x3;
        y := y3;
      end;
      4:
      begin
        x := x4;
        y := y4;
      end;
      5:
      begin
        x := x5;
        y := y5;
      end;
    end;
    Inc(visID);
    GoToXY(x, y);
    if maparea[y][x].character = '.' then
    begin
      TextColor(maparea[y][x].hiColour);
      Write(floor);
      maparea[y][x].Visible := True;
      updateVisibleTiles(visID, y, x);
    end
    else if (maparea[y][x].character) = '#' then
    begin
      TextColor(maparea[y][x].hiColour);
      Write(wall);
      maparea[y][y].Visible := True;
      updateVisibleTiles(visID, y, x);
      exit;
    end;
  end;
end;


(* TODO : check if out of bounds *)
procedure FOV(x, y: smallint);
begin
  visID := 0;
  (* First octant *)
  paintFOV(y - 1, x, y - 2, x, y - 3, x, y - 4, x, y - 5, x);
  paintFOV(y - 1, x, y - 2, x, y - 3, x + 1, y - 4, x + 1, y - 5, x + 1);
  paintFOV(y - 1, x, y - 2, x + 1, y - 3, x + 1, y - 4, x + 2, y - 4, x + 2);
  paintFOV(y - 1, x + 1, y - 2, x + 2, y - 3, x + 2, y - 3, x + 3, y - 4, x + 3);
  paintFOV(y - 1, x + 1, y - 1, x + 2, y - 2, x + 3, y - 3, x + 4, y - 3, x + 4);
  paintFOV(y, x + 1, y - 1, x + 2, y - 1, x + 3, y - 2, x + 4, y - 2, x + 5);
  paintFOV(y, x + 1, y, x + 2, y - 1, x + 3, y - 1, x + 4, y - 1, x + 5);
  (* Second octant *)
  paintFOV(y, x + 1, y, x + 2, y, x + 3, y, x + 4, y, x + 5);
  paintFOV(y, x + 1, y, x + 2, y + 1, x + 3, y + 1, x + 4, y + 1, x + 5);
  paintFOV(y, x + 1, y + 1, x + 2, y + 1, x + 3, y + 2, x + 4, y + 2, x + 5);
  paintFOV(y + 1, x + 1, y + 2, x + 2, y + 2, x + 3, y + 3, x + 3, y + 3, x + 4);
  paintFOV(y + 1, x + 1, y + 2, x + 1, y + 3, x + 2, y + 4, x + 3, y + 4, x + 3);
  paintFOV(y + 1, x, y + 2, x + 1, y + 3, x + 1, y + 4, x + 2, y + 4, x + 3);
  paintFOV(y + 1, x, y + 2, x, y + 3, x + 1, y + 4, x + 1, y + 5, x + 1);
  (* Third octant *)
  paintFOV(y + 1, x, y + 2, x, y + 3, x, y + 4, x, y + 5, x);
  paintFOV(y + 1, x, y + 2, x, y + 3, x - 1, y + 4, x - 1, y + 5, x - 1);
  paintFOV(y + 1, x, y + 2, x - 1, y + 3, x - 1, y + 4, x - 2, y + 4, x - 3);
  paintFOV(y + 1, x - 1, y + 2, x - 1, y + 3, x - 2, y + 4, x - 3, y + 4, x - 3);
  paintFOV(y + 1, x - 1, y + 2, x - 2, y + 2, x - 3, y + 3, x - 3, y + 3, x - 4);
  paintFOV(y, x - 1, y + 1, x - 2, y + 1, x - 3, y + 2, x - 4, y + 2, x - 5);
  paintFOV(y, x - 1, y, x - 2, y + 1, x - 3, y + 1, x - 4, y + 1, x - 5);
  (* Fourth octant *)
  paintFOV(y, x - 1, y, x - 2, y, x - 3, y, x - 4, y, x - 5);
  paintFOV(y, x - 1, y, x - 2, y - 1, x - 3, y - 1, x - 4, y - 1, x - 5);
  paintFOV(y, x - 1, y - 1, x - 2, y - 1, x - 3, y - 2, x - 4, y - 2, x - 5);
  paintFOV(y - 1, x - 1, y - 1, x - 2, y - 2, x - 3, y - 3, x - 4, y - 3, x - 4);
  paintFOV(y - 1, x - 1, y - 2, x - 2, y - 3, x - 2, y - 3, x - 3, y - 4, x - 3);
  paintFOV(y - 1, x, y - 2, x - 1, y - 3, x - 1, y - 4, x - 2, y - 4, x - 2);
  paintFOV(y - 1, x, y - 2, x, y - 3, x - 1, y - 4, x - 1, y - 5, x - 1);
end;

procedure setupMap;
var
  id_int: smallint; // give each tile a unique ID number
begin
  // Generate a dungeon
  dungeon.generate();
  id_int := 0;
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      Inc(id_int);
      maparea[r][c].id := id_int;
      maparea[r][c].blocks := False;
      maparea[r][c].Visible := False;
      maparea[r][c].occupied := False;
      maparea[r][c].defColour := 7;
      maparea[r][c].hiColour := 15;
      if dungeon.dungeonArray[r][c] = '#' then
      begin
        maparea[r][c].character := wall;
        maparea[r][c].blocks := True;
      end;
      if dungeon.dungeonArray[r][c] = '.' then
      begin
        maparea[r][c].character := floor;
      end;
    end;
  end;
end;

function canMove(checkX, checkY: smallint): boolean;
begin
  Result := False;
  if (checkX < tui.xmax) and (checkX > tui.xmin) and (checkY > tui.ymin) and
    (checkY < tui.ymax) and (maparea[checkY][checkX].blocks) = False then
    Result := True;
end;

function getTileGlyph(checkX, checkY: smallint): char;
begin
  Result := maparea[checkY][checkX].character;
end;

function canSee(checkX, checkY: smallint): boolean;
var
  i: smallint;
begin
  Result := False;
  for i := 1 to MAXVISION do
  begin
    if (maparea[checkY][checkX].id) = (visionRadius[i].tileID) then
    begin
      if visionRadius[i].inSight = True then
        Result := True;
    end;
  end;
end;

procedure occupy(x, y: smallint);
begin
  maparea[y][x].occupied := True;
end;

procedure unoccupy(x, y: smallint);
begin
  maparea[y][x].occupied := False;
end;

function isOccupied(checkX, checkY: smallint): boolean;
begin
  Result := False;
  if (maparea[checkY][checkX].occupied = True) then
    Result := True;
end;

function hasPlayer(checkX, checkY: smallint): boolean;
begin
  Result := False;
  if (player.ThePlayer.posX = checkX) and (player.ThePlayer.posY = checkY) then
    Result := True;
end;

function saveMap: string;
var
  r, c: smallint;
  line: string;
begin
  line := '(';
  for r := 1 to MAXROWS do
  begin
    line := line + '(''';
    for c := 1 to MAXCOLUMNS do
      line := line + maparea[r][c].character + ''',''';
    line := line + ')';
  end;
  line := line + ')';
  Result := line;
end;

(* repaints any tiles not in FOV *)
procedure removeFOV();
var
  i, r, c: smallint;
begin
  for i := 1 to MAXVISION do
  begin
    if visionRadius[i].inSight = True then
    begin
      // Search map for vision radius tile ID
      for r := 1 to MAXROWS do
      begin
        for c := 1 to MAXCOLUMNS do
        begin
          if maparea[r][c].id = visionRadius[i].tileID then
          begin
            // get X Y position
            GoToXY(visionRadius[i].gtx, visionRadius[i].gty);
            TextColor(maparea[r][c].defColour);
            Write(maparea[r][c].character);
          end;
        end;
      end;
    end;
  end;
end;

(* Clears all tiles in players vision *)
procedure clearVision();
var
  i: smallint;
begin
  for i := 1 to MAXVISION do
  begin
    visionRadius[i].tileID := i;
    visionRadius[i].inSight := False;
    visionRadius[i].gtx := 0;
    visionRadius[i].gty := 0;
  end;
end;

end.
