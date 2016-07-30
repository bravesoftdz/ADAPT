{
  AD.A.P.T. Library
  Copyright (C) 2014-2016, Simon J Stuart, All Rights Reserved

  Original Source Location: https://github.com/LaKraven/ADAPT
  Subject to original License: https://github.com/LaKraven/ADAPT/blob/master/LICENSE.md
}
unit ADAPT.Generics.Common;

{$I ADAPT.inc}

interface

uses
  {$IFDEF ADAPT_USE_EXPLICIT_UNIT_NAMES}
    System.Classes,
  {$ELSE}
    Classes,
  {$ENDIF ADAPT_USE_EXPLICIT_UNIT_NAMES}
  ADAPT.Common, ADAPT.Common.Intf,
  ADAPT.Generics.Common.Intf;

  {$I ADAPT_RTTI.inc}

type
  // Exceptions
  EADGenericsException = class(EADException);
      EADGenericsIterateException = class(EADGenericsException);
      EADGenericsIterateDirectionUnknownException = class(EADGenericsIterateException);
    EADGenericsRangeException = class(EADGenericsException);
    EADGenericsParameterInvalidException = class(EADGenericsException);
      EADGenericsCapacityLessThanCount = class(EADGenericsParameterInvalidException);
      EADGenericsCompactorNilException = class(EADGenericsParameterInvalidException);
      EADGenericsExpanderNilException = class(EADGenericsParameterInvalidException);

implementation

end.
