{
  AD.A.P.T. Library
  Copyright (C) 2014-2016, Simon J Stuart, All Rights Reserved

  Original Source Location: https://github.com/LaKraven/ADAPT
  Subject to original License: https://github.com/LaKraven/ADAPT/blob/master/LICENSE.md
}
unit ADAPT.Math.Delta;

{$I ADAPT.inc}

interface

uses
  {$IFDEF ADAPT_USE_EXPLICIT_UNIT_NAMES}
    System.Classes, System.Diagnostics,
  {$ELSE}
    Classes, {$IFDEF FPC}ADAPT.Stopwatch{$ELSE}Diagnostics{$ENDIF FPC},
  {$ENDIF ADAPT_USE_EXPLICIT_UNIT_NAMES}
  ADAPT.Common, ADAPT.Common.Intf,
  ADAPT.Math.Common.Intf,
  ADAPT.Math.Delta.Intf;

  {$I ADAPT_RTTI.inc}

type
  TADDeltaValue<T> = class abstract(TADObject, IADDeltaValue<T>)
  protected
    // Getters
    { IADDeltaValue<T> }
    function GetValueAt(const ADelta: ADFloat): T; virtual; abstract;
    function GetValueNow: T;

    // Setters
    { IADDeltaValue<T> }
    procedure SetValueAt(const ADelta: ADFloat; const AValue: T); virtual; abstract;
    procedure SetValueNow(const AValue: T);
  public
    constructor Create; override;
    // Properties
    { IADDeltaValue<T> }
    property ValueAt[const ADelta: ADFloat]: T read GetValueAt write SetValueAt;
    property ValueNow: T read GetValueNow write SetValueNow;
  end;

///  <returns><c>The Current "Reference Time" used everywhere "Differential Time" (Delta) is calculated.</c></returns>
function ADReferenceTime: ADFloat;
///  <returns><c>A fresh Instance of a Delta Float.</c></returns>
function ADDeltaFloat: IADDeltaValue<ADFloat>;
///  <returns><c>A fresh Instance of a Delta Integer.</c></returns>
function ADDeltaInteger: IADDeltaValue<Integer>;
///  <returns><c>A fresh Instance of a Delta Int64.</c></returns>
function ADDeltaInt64: IADDeltaValue<Int64>;
///  <returns><c>A fresh Instance of a Delta Cardinal.</c></returns>
function ADDeltaCardinal: IADDeltaValue<Cardinal>;

implementation

var
  ReferenceWatch: TStopwatch;

type
  TADDeltaFloat = class(TADDeltaValue<ADFloat>)

  end;

  TADDeltaInteger = class(TADDeltaValue<Integer>)

  end;

  TADDeltaInt64 = class(TADDeltaValue<Int64>)

  end;

  TADDeltaCardinal = class(TADDeltaValue<Cardinal>)

  end;

function ADReferenceTime: ADFloat;
begin
  Result := TStopwatch.GetTimeStamp / TStopwatch.Frequency;
end;

function ADDeltaFloat: IADDeltaValue<ADFloat>;
begin
  Result := TADDeltaFloat.Create;
end;

function ADDeltaInteger: IADDeltaValue<Integer>;
begin
  Result := TADDeltaInteger.Create;
end;

function ADDeltaInt64: IADDeltaValue<Int64>;
begin
  Result := TADDeltaInt64.Create;
end;

function ADDeltaCardinal: IADDeltaValue<Cardinal>;
begin
  Result := TADDeltaCardinal.Create;
end;

{ TADDeltaValue<T> }

constructor TADDeltaValue<T>.Create;
begin

end;

function TADDeltaValue<T>.GetValueNow: T;
begin
  Result := GetValueAt(ADReferenceTime);
end;

procedure TADDeltaValue<T>.SetValueNow(const AValue: T);
begin
  SetValueAt(ADReferenceTime, AValue);
end;

initialization
  ReferenceWatch := TStopwatch.Create;

end.
