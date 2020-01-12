(* Text User Interface - Unit responsible for displaying messages and stats *)

unit tui;

{$mode objfpc}{$H+}

interface

uses
  crt, player;

const
  (* Map limits. With sidebar it comes to 80x24 - standard Unix terminal size. *)
  xmin = 1;
  xmax = 68;
  ymin = 1;
  ymax = 21;
  (* Sidepanel box characters *)
  {$IFDEF WINDOWS}
  tui_ctl = Chr(218); // Top left corner ┌
  tui_ctr = Chr(191); // Top right corner ┐
  tui_hl = Chr(196); // Horizontal line ─
  tui_vl = Chr(179); // Vertical line │
  tui_cbl = Chr(192); // Bottom left corner └
  tui_cbr = Chr(217); // Bottom right corner ┘
  {$ENDIF}

var
  messageArray: array[1..3] of string = (' ', ' ', ' ');

procedure draw_sidepanel; // Draws the panel on side of screen
procedure title_screen; // Display title screen
procedure displayMessage(message: string); // Display message
procedure UpdateHP; // Updates the amount of HP on the sidebar

implementation

(* Draws border around sidepanel *)
procedure draw_sidepanel;
var
  y: longint;
begin
  TextColor(3); // Cyan
  GoToXY(xmax + 1, ymin);
  {$IFDEF WINDOWS}
  Write(tui_ctl, tui_hl, tui_hl, tui_hl, tui_hl, tui_hl, tui_hl,
    tui_hl, tui_hl, tui_hl, tui_hl, tui_ctr);
  {$ENDIF}
  {$IFDEF LINUX}
  Write('+----------+');
  {$ENDIF}
  for y := (ymin + 1) to (ymax - 1) do
  begin
    GoToXY(xmax + 1, y);
    {$IFDEF WINDOWS}
    Write(tui_vl);
    {$ENDIF}
  {$IFDEF LINUX}
    Write('|');
    {$ENDIF}
    GoToXY(80, y);
    {$IFDEF WINDOWS}
    Write(tui_vl);
     {$ENDIF}
  {$IFDEF LINUX}
    Write('|');
      {$ENDIF}
  end;
  GoToXY(xmax + 1, ymax);
  {$IFDEF WINDOWS}
  Write(tui_cbl, tui_hl, tui_hl, tui_hl, tui_hl, tui_hl, tui_hl,
    tui_hl, tui_hl, tui_hl, tui_hl, tui_cbr);
  {$ENDIF}
  {$IFDEF LINUX}
  Write('+----------+');
   {$ENDIF}
  (* Add text to sidepanel *)
  GoToXY(xmax + 2, ymin + 1);
  Write('  Player');
  GoToXY(xmax + 2, ymin + 3);
  Write('HP ', player.ThePlayer.currentHP, '/', player.ThePlayer.maxHP);
end;

(* Draws the title screen *)
procedure title_screen;
begin
  GoToXY(38, 12);
  TextColor(LightGray);
  Write('FLUX');
  GoToXY(25, 14);
  Write('Free pascaL rogUelike eXample');
  TextBackground(LightGray);
  TextColor(Black);
  GoToXY(25, 14);
  write('F');
  GoToXY(35, 14);
  write('L');
  GoToXY(40, 14);
  write('U');
  GoToXY(48, 14);
  write('X');
  TextColor(7);
  TextBackground(0);
end;

procedure displayMessage(message: string);
begin
  TextColor(7); // gray = 7, white = 15
  TextBackground(0);
  messageArray[1] := messageArray[2];
  messageArray[2] := messageArray[3];
  messageArray[3] := message;
  GoToXY(1, ymax + 3);
  ClrEol;
  GoToXY(1, ymax + 3);
  TextColor(15);
  Write(messageArray[3]);
  GoToXY(1, ymax + 2);
  ClrEol;
  GoToXY(1, ymax + 2);
  TextColor(7);
  Write(messageArray[2]);
  GoToXY(1, ymax + 1);
  ClrEol;
  GoToXY(1, ymax + 1);
  TextColor(8);
  Write(messageArray[1]);
end;

procedure UpdateHP;
begin
  TextColor(3);
  // Clear current line
  GoToXY(xmax + 2, ymin + 3);
  Write('          ');
  // Write current HP
  GoToXY(xmax + 2, ymin + 3);
  Write('HP ', player.ThePlayer.currentHP, '/', player.ThePlayer.maxHP);
end;


end.
