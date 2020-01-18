(* Common functions / utilities *)

unit globalutils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  DOM,
  XMLWrite;

(* Select random number from a range *)
function randomRange(fromNumber, toNumber: smallint): smallint;
(* Save game state to XML file *)
procedure saveGame;

implementation

uses
  entities;

// Random(Range End - Range Start) + Range Start;
function randomRange(fromNumber, toNumber: smallint): smallint;
var
  p: smallint;
begin
  p := toNumber - fromNumber;
  Result := random(p + 1) + fromNumber;
end;

procedure saveGame;
var
  i: smallint;
  Doc: TXMLDocument;
  RootNode, npcNode, ItemNode, TextNode: TDOMNode;
begin
  try
    // Create a document
    Doc := TXMLDocument.Create;
    // Create a root node
    RootNode := Doc.CreateElement('Enemies');
    Doc.Appendchild(RootNode);
    RootNode := Doc.DocumentElement;
    // Create nodes
    for i := 1 to entities.npcAmount do
    begin
      npcNode := Doc.CreateElement('NPC');
      TDOMElement(npcNode).SetAttribute('id',IntToStr(i));

      ItemNode := Doc.CreateElement('race');
      TextNode := Doc.CreateTextNode(entities.entityList[i].race);
      ItemNode.AppendChild(TextNode);
      npcNode.AppendChild(ItemNode);

      ItemNode := Doc.CreateElement('currentHP');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].currentHP));
      ItemNode.AppendChild(TextNode);
      npcNode.AppendChild(ItemNode);
      
      ItemNode := Doc.CreateElement('maxHP');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].maxHP));
      ItemNode.AppendChild(TextNode);
      npcNode.AppendChild(ItemNode);

      ItemNode := Doc.CreateElement('attack');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].attack));
      ItemNode.AppendChild(TextNode);
      npcNode.AppendChild(ItemNode);

      RootNode.AppendChild(npcNode);
       end;
      // Save XML
      WriteXMLFile(Doc, 'savegame.xml');
    finally
      Doc.Free;  // free memory
  end;
end;
end.

