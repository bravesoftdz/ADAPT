{
  AD.A.P.T. Library
  Copyright (C) 2014-2016, Simon J Stuart, All Rights Reserved

  Original Source Location: https://github.com/LaKraven/ADAPT

  Formerlly known as "LaKraven Studios Standard Library" or "LKSL".
  "ADAPT" supercedes the former LKSL codebase as of 2016.

  License:
    - You may use this library as you see fit, including use within commercial applications.
    - You may modify this library to suit your needs, without the requirement of distributing
      modified versions.
    - You may redistribute this library (in part or whole) individually, or as part of any
      other works.
    - You must NOT charge a fee for the distribution of this library (compiled or in its
      source form). It MUST be distributed freely.
    - This license and the surrounding comment block MUST remain in place on all copies and
      modified versions of this source code.
    - Modified versions of this source MUST be clearly marked, including the name of the
      person(s) and/or organization(s) responsible for the changes, and a SEPARATE "changelog"
      detailing all additions/deletions/modifications made.

  Disclaimer:
    - Your use of this source constitutes your understanding and acceptance of this
      disclaimer.
    - Simon J Stuart, nor any other contributor, may be held liable for your use of this source
      code. This includes any losses and/or damages resulting from your use of this source
      code, be they physical, financial, or psychological.
    - There is no warranty or guarantee (implicit or otherwise) provided with this source
      code. It is provided on an "AS-IS" basis.

  Donations:
    - While not mandatory, contributions are always appreciated. They help keep the coffee
      flowing during the long hours invested in this and all other Open Source projects we
      produce.
    - Donations can be made via PayPal to PayPal [at] LaKraven (dot) Com
                                          ^  Garbled to prevent spam!  ^
}
unit ADAPT.Streams;

{$I ADAPT.inc}

interface

uses
  {$IFDEF ADAPT_USE_EXPLICIT_UNIT_NAMES}
    System.Classes, System.SysUtils,
  {$ELSE}
    Classes, SysUtils,
  {$ENDIF ADAPT_USE_EXPLICIT_UNIT_NAMES}
  ADAPT.Common, ADAPT.Common.Intf,
  ADAPT.Generics.Lists.Intf,
  ADAPT.Streams.Intf;

  {$I ADAPT_RTTI.inc}

type
  { Forward Declarations }
  TADStreamCaret = class;
  TADStream = class;

  { Class Reference Types }
  TADStreamCaretClass = class of TADStreamCaret;

  { Collection Types }
  IADStreamCaretList = IADList<IADStreamCaret>;

  ///  <summary><c>Abstract Base Class for all Stream Caret Types.</c></summary>
  TADStreamCaret = class(TADObject, IADStreamCaret)
  private
    ///  <summary><c>Weak Rerefence to the owning Stream object.</c></summary>
    ///  <remarks><c>Use </c>GetStream<c> to cast the Reference back to </c>IADStream<c>.</c></remarks>
    FStream: Pointer;
    { IADStreamCaret }
    function GetIsInvalid: Boolean;
    function GetIsValid: Boolean;
    function GetPosition: Int64;
    procedure SetPosition(const APosition: Int64);

    function GetStream: IADStream;
  public
    { IADStreamCaret }
    ///  <summary><c>Deletes the given number of Bytes from the current Position in the Stream, then compacts the Stream by that number of Bytes (shifting any subsequent Bytes to the left)</c></summary>
    ///  <returns><c>Returns the number of Bytes deleted.</c></returns>
    ///  <remarks>
    ///    <para><c>Automatically shifts the Position of subsequent Carets by the offset of Bytes deleted.</c></para>
    ///  </remarks>
    function Delete(const ALength: Int64): Int64;

    ///  <summary><c>Inserts the given Buffer into the current Position within the Stream (shifting any subsequent Bytes to the right)</c></summary>
    ///  <returns><c>Returns the number of Bytes actually written.</c></returns>
    ///  <remarks>
    ///    <para><c>Automatically shifts the Position of subsequent Carets by the offset of Bytes inserted.</c></para>
    ///  </remarks>
    function Insert(const ABuffer; const ALength: Int64): Int64;

    ///  <summary><c>Reads the specified number of Bytes from the Array into the specified Address</c></summary>
    ///  <returns><c>Returns the number of Bytes actually read.</c></returns>
    function Read(var ABuffer; const ALength: Int64): Int64;

    ///  <summary><c>Writes the given Buffer into the current Position within the Stream (overwriting any existing data, and expanding the Size of the Stream if required)</c></summary>
    ///  <returns><c>Returns the number of Bytes actually written.</c></returns>
    ///  <remarks>
    ///    <para><c>DOES NOT shift the position of any subsequent Carets!</c></para>
    ///  </remarks>
    function Write(const ABuffer; const ALength: Int64): Int64;

    ///  <returns><c>Returns the new </c>Position<c> in the Stream.</c></returns>
    function Seek(const AOffset: Int64; const AOrigin: TSeekOrigin): Int64;

    ///  <summary><c>Has an operation on the Stream rendered this Caret invalid?</c></summary>
    property IsInvalid: Boolean read GetIsInvalid;
    ///  <summary><c>If </c>True<c>, this Caret is still Valid.</c></summary>
    property IsValid: Boolean read GetIsValid;
    ///  <summary><c>The Position of this Caret within the Stream.</c></summary>
    property Position: Int64 read GetPosition write SetPosition;
    ///  <summary><c>Reference to the Caret's owning Stream</c></summary>
    property Stream: IADStream read GetStream;
  end;

  ///  <summary><c>Abstract Base Class for all Stream Types.</c></summary>
  TADStream = class(TADObject, IADStream)
  private
    FCaretList: IADStreamCaretList;
    { IADStream }
    function GetSize: Int64;
    procedure SetSize(const ASize: Int64);
  protected
    function GetCaretType: TADStreamCaretClass; virtual; abstract;
  public
    constructor Create; override;
    destructor Destroy; override;

    { IADStream }
    ///  <summary><c>Populate the Stream from a File.</c></summary>
    procedure LoadFromFile(const AFileName: String);
    ///  <summary><c>Populate the Stream from the contents of another Stream.</c></summary>
    procedure LoadFromStream(const AStream: IADStream); overload;
    ///  <summary><c>Populate the Stream from the contents of another Stream.</c></summary>
    procedure LoadFromStream(const AStream: TStream); overload;

    ///  <returns><c>A new Stream Caret.</c></returns>
    function NewCaret: IADStreamCaret; overload;
    ///  <returns><c>A new Stream Caret.</c></returns>
    function NewCaret(const APosition: Int64): IADStreamCaret; overload;

    ///  <summary><c>Save contents of the Stream to a File.</c></summary>
    procedure SaveToFile(const AFileName: String);
    ///  <summary><c>Save contents of the Stream to another Stream.</c></summary>
    procedure SaveToStream(const AStream: IADStream); overload;
    ///  <summary><c>Save contents of the Stream to another Stream.</c></summary>
    procedure SaveToStream(const AStream: TStream); overload;

    // Properties
    ///  <summary><c>Size of the Stream.</c></summary>
    property Size: Int64 read GetSize write SetSize;
  end;

implementation

uses
  ADAPT.Generics.Lists;

  {$I ADAPT_RTTI.inc}

type
  TADStreamCaretList = class(TADList<IADStreamCaret>);

{ TADStreamCaret }

function TADStreamCaret.Delete(const ALength: Int64): Int64;
begin

end;

function TADStreamCaret.GetIsInvalid: Boolean;
begin

end;

function TADStreamCaret.GetIsValid: Boolean;
begin

end;

function TADStreamCaret.GetPosition: Int64;
begin

end;

function TADStreamCaret.GetStream: IADStream;
begin
  Result := IADStream(FStream^);
end;

function TADStreamCaret.Insert(const ABuffer; const ALength: Int64): Int64;
begin

end;

function TADStreamCaret.Read(var ABuffer; const ALength: Int64): Int64;
begin

end;

function TADStreamCaret.Seek(const AOffset: Int64; const AOrigin: TSeekOrigin): Int64;
begin

end;

procedure TADStreamCaret.SetPosition(const APosition: Int64);
begin

end;

function TADStreamCaret.Write(const ABuffer; const ALength: Int64): Int64;
begin

end;

{ TADStream }

constructor TADStream.Create;
begin
  inherited;
  FCaretList := TADStreamCaretList.Create;
end;

destructor TADStream.Destroy;
begin

  inherited;
end;

function TADStream.GetSize: Int64;
begin

end;

procedure TADStream.LoadFromFile(const AFileName: String);
begin

end;

procedure TADStream.LoadFromStream(const AStream: IADStream);
begin

end;

procedure TADStream.LoadFromStream(const AStream: TStream);
begin

end;

function TADStream.NewCaret(const APosition: Int64): IADStreamCaret;
begin

end;

function TADStream.NewCaret: IADStreamCaret;
begin

end;

procedure TADStream.SaveToFile(const AFileName: String);
begin

end;

procedure TADStream.SaveToStream(const AStream: TStream);
begin

end;

procedure TADStream.SaveToStream(const AStream: IADStream);
begin

end;

procedure TADStream.SetSize(const ASize: Int64);
begin

end;

end.