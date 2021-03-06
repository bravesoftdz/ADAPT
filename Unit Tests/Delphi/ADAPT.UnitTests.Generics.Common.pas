unit ADAPT.UnitTests.Generics.Common;

interface

{$I ADAPT.inc}

uses
  {$IFDEF ADAPT_USE_EXPLICIT_UNIT_NAMES}
    System.Classes, System.SysUtils,
  {$ELSE}
    Classes, SysUtils,
  {$ENDIF ADAPT_USE_EXPLICIT_UNIT_NAMES}
  DUnitX.TestFramework;

type
  TDummyObject = class(TObject)
  private
    FFoo: String;
  public
    constructor Create(const AFoo: String);
    property Foo: String read FFoo;
  end;

const
  BASIC_ITEMS: Array[0..9] of String = (
                                         'Bob',
                                         'Terry',
                                         'Andy',
                                         'Rick',
                                         'Sarah',
                                         'Ellen',
                                         'Hugh',
                                         'Jack',
                                         'Marie',
                                         'Ninette'
                                       );

  NAMES_IN_ORDER: Array[0..9] of String = ('Andy', 'Bob', 'Ellen', 'Hugh', 'Jack', 'Marie', 'Ninette', 'Rick', 'Sarah', 'Terry');

  LETTERS: Array[0..9] of String = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J');

  ALPHABET: Array[0..25] of String = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z');

  BASIC_INTEGER_ITEMS: Array[0..9] of Integer = (
                                                  1337,
                                                  9001,
                                                  10,
                                                  1,
                                                  20,
                                                  2,
                                                  21,
                                                  30,
                                                  55,
                                                  666
                                                );

  NUMBERS_IN_ORDER: Array[0..9] of Integer = (1, 2, 10, 20, 21, 30, 55, 666, 1337, 9001);

implementation

{ TDummyObject }

constructor TDummyObject.Create(const AFoo: String);
begin
  inherited Create;
  FFoo := AFoo;
end;

end.
