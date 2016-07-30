{
  AD.A.P.T. Library
  Copyright (C) 2014-2016, Simon J Stuart, All Rights Reserved

  Original Source Location: https://github.com/LaKraven/ADAPT
  Subject to original License: https://github.com/LaKraven/ADAPT/blob/master/LICENSE.md
}
unit ADAPT.Generics.Maps.Intf;

{$I ADAPT.inc}

interface

uses
  {$IFDEF ADAPT_USE_EXPLICIT_UNIT_NAMES}
    System.Classes,
  {$ELSE}
    Classes,
  {$ENDIF ADAPT_USE_EXPLICIT_UNIT_NAMES}
  ADAPT.Common.Intf,
  ADAPT.Generics.Common.Intf,
  ADAPT.Generics.Allocators.Intf;

  {$I ADAPT_RTTI.inc}

type
  ///  <summary><c>A Generic Lookup List.</c></summary>
  ///  <remarks>
  ///    <para><c>Lookup Lists utilize Sorted Insertion to ensure that all Lookups can be performed efficiently.</c></para>
  ///    <para><c>Lookup Lists are NOT a "Hashmap" or "Dictionary".</c></para>
  ///  </remarks>
  IADLookupList<T> = interface(IADInterface)
    // Getters
    ///  <returns><c>The nunmber of Items in the List.</c></returns>
    function GetCount: Integer;
    ///  <returns>
    ///    <para>True<c> if there are NO Items in the List.</c></para>
    ///    <para>False<c> if there are Items in the List.</c></para>
    ///  </returns>
    function GetIsEmpty: Boolean;
    ///  <returns><c>The Item at the given Index.</c></returns>
    function GetItem(const AIndex: Integer): T;

    // Setters

    // Management Methods
    ///  <summary><c>Adds the given Item into the List.</c></summary>
    ///  <returns>
    ///    <para><c>The Index of the Item in the List.</c></para>
    ///  </returns>
    function Add(const AItem: T): Integer;
    ///  <summary><c>Adds multiple Items into the List.</c></summary>
    procedure AddItems(const AItems: Array of T);
    ///  <summary><c>Removes all Items from the List.</c></summary>
    procedure Clear;
    ///  <summary><c>Compacts the size of the underlying Array to the minimum required capacity.</c></summary>
    procedure Compact;
    ///  <summary><c>Performs a Lookup to determine whether the given Item is in the List.</c></summary>
    ///  <returns>
    ///    <para>True<c> if the Item is in the List.</c></para>
    ///    <para>False<c> if the Item is NOT in the List.</c></para>
    ///  </returns>
    function Contains(const AItem: T): Boolean;
    ///  <summary><c>Performs Lookups to determine whether the given Items are ALL in the List.</c></summary>
    ///  <returns>
    ///    <para>True<c> if ALL Items are in the List.</c></para>
    ///    <para>False<c> if NOT ALL Items are in the List.</c></para>
    ///  </returns>
    function ContainsAll(const AItems: Array of T): Boolean;
    ///  <summary><c>Deletes the Item at the given Index.</c></summary>
    procedure Delete(const AIndex: Integer); overload;
    ///  <summary><c>Deletes the Items from the Start Index to Start Index + Count.</c></summary>
    procedure DeleteRange(const AFromIndex, ACount: Integer); overload;
    ///  <summary><c>Deletes the Items at each given Index.</c></summary>
    procedure DeleteSelection(const AIndexes: Array of Integer);
    ///  <summary><c>Retreives the Index of the given Item within the List.</c></summary>
    ///  <returns>
    ///    <para>-1<c> if the given Item is not in the List.</c></para>
    ///    <para>0 or Greater<c> if the given Item IS in the List.</c></para>
    ///  </returns>
    function IndexOf(const AItem: T): Integer;
    ///  <summary><c>Deletes the given Item from the List.</c></summary>
    ///  <remarks><c>Performs a Lookup to divine the given Item's Index.</c></remarks>
    procedure Remove(const AItem: T);
    ///  <summary><c>Deletes the given Items from the List.</c></summary>
    ///  <remarks><c>Performs a Lookup for each Item to divine their respective Indexes.</c></remarks>
    procedure RemoveItems(const AItems: Array of T);

    // Properties
    ///  <returns><c>The nunmber of Items in the List.</c></returns>
    property Count: Integer read GetCount;
    ///  <returns>
    ///    <para>True<c> if there are NO Items in the List.</c></para>
    ///    <para>False<c> if there are Items in the List.</c></para>
    ///  </returns>
    property IsEmpty: Boolean read GetIsEmpty;
    ///  <returns><c>The Item at the given Index.</c></returns>
    property Item[const AIndex: Integer]: T read GetItem;
  end;

implementation

end.
