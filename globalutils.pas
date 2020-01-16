(* Common functions / utilities *)

unit globalutils;

{$mode objfpc}{$H+}

interface

(* Select random number from a range *)
function randomRange(fromNumber, toNumber: smallint): smallint;

implementation

// Random(Range End - Range Start) + Range Start;
function randomRange(fromNumber, toNumber: smallint): smallint;
var
  p: smallint;
begin
  p := toNumber - fromNumber;
  Result := random(p + 1) + fromNumber;
end;

end.

