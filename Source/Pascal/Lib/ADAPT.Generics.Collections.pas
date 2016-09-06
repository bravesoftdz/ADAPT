{
  AD.A.P.T. Library
  Copyright (C) 2014-2016, Simon J Stuart, All Rights Reserved

  Original Source Location: https://github.com/LaKraven/ADAPT
  Subject to original License: https://github.com/LaKraven/ADAPT/blob/master/LICENSE.md
}
unit ADAPT.Generics.Collections;

{$I ADAPT.inc}

interface

uses
  {$IFDEF ADAPT_USE_EXPLICIT_UNIT_NAMES}
    System.Classes,
  {$ELSE}
    Classes,
  {$ENDIF ADAPT_USE_EXPLICIT_UNIT_NAMES}
  ADAPT.Common, ADAPT.Common.Intf,
  ADAPT.Generics.Common.Intf,
  ADAPT.Generics.Collections.Intf;

  {$I ADAPT_RTTI.inc}

type
  {$IFNDEF FPC}
    { Class Forward Declarations }
    TADArray<T> = class;
    TADObjectArray<T: Class> = class;
  {$ENDIF FPC}

  ///  <summary><c>A Simple Generic Array with basic Management Methods.</c></summary>
  ///  <remarks>
  ///    <para><c>Use IADArray if you want to take advantage of Reference Counting.</c></para>
  ///    <para><c>This is NOT Threadsafe</c></para>
  ///  </remarks>
  TADArray<T> = class(TADObject, IADArray<T>)
  protected
    FArray: TArray<IADValueHolder<T>>;
    FCapacityInitial: Integer;
    // Getters
    function GetCapacity: Integer; virtual;
    function GetItem(const AIndex: Integer): T; virtual;
    // Setters
    procedure SetCapacity(const ACapacity: Integer); virtual;
    procedure SetItem(const AIndex: Integer; const AItem: T); virtual;
  public
    constructor Create(const ACapacity: Integer = 0); reintroduce; virtual;
    destructor Destroy; override;
    procedure Clear; virtual;
    procedure Delete(const AIndex: Integer); virtual;
    procedure Finalize(const AIndex, ACount: Integer); virtual;
    procedure Insert(const AItem: T; const AIndex: Integer); virtual;
    procedure Move(const AFromIndex, AToIndex, ACount: Integer); virtual;
    // Properties
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Items[const AIndex: Integer]: T read GetItem write SetItem; default;
  end;

  ///  <summary><c>A Simple Generic Object Array with basic Management Methods and Item Ownership.</c></summary>
  ///  <remarks>
  ///    <para><c>Will automatically Free any Object contained within the Array on Destruction if </c>OwnsItems<c> is set to </c>True<c>.</c></para>
  ///    <para><c>Use IADObjectArray if you want to take advantage of Reference Counting.</c></para>
  ///    <para><c>This is NOT Threadsafe</c></para>
  ///  </remarks>
  TADObjectArray<T: Class> = class(TADArray<T>, IADObjectOwner)
  private
    FOwnership: TADOwnership;
  protected
    // Getters
    function GetOwnership: TADOwnership; virtual;
    // Setters
    procedure SetOwnership(const AOwnership: TADOwnership); virtual;
  public
    constructor Create(const AOwnership: TADOwnership = oOwnsObjects; const ACapacity: Integer = 0); reintroduce; virtual;
    destructor Destroy; override;
    ///  <summary><c>Empties the Array and sets it back to the original Capacity you specified in the Constructor.</c></summary>
    procedure Clear; override;
    // Properties
    property Ownership: TADOwnership read GetOwnership write SetOwnership;
  end;

  ///  <summary><c>Abstract Base Class for all Collection Types.</c></summary>
  TADCollection = class abstract(TADObject, IADCollection)
  protected
    FCount: Integer;
    FInitialCapacity: Integer;
    FSortedState: TADSortedState;
    // Getters
    { IADCollection }
    function GetCapacity: Integer; virtual; abstract;
    function GetCount: Integer; virtual;
    function GetInitialCapacity: Integer; // Does not need to be Virtual
    function GetIsCompact: Boolean; virtual; abstract;
    function GetIsEmpty: Boolean; virtual;
    function GetSortedState: TADSortedState; virtual;

    // Setters
    { IADCollection }
    procedure SetCapacity(const ACapacity: Integer); virtual; abstract;

    { Overridables }
    procedure CreateArray(const AInitialCapacity: Integer); virtual; abstract;
  public
    constructor Create(const AInitialCapacity: Integer); reintroduce; virtual;

    // Management Methods
    procedure Clear; virtual; abstract;

    // Properties
    { IADCollection }
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount;
    property InitialCapacity: Integer read GetInitialCapacity;
    property IsCompact: Boolean read GetIsCompact;
    property IsEmpty: Boolean read GetIsEmpty;
    property SortedState: TADSortedState read GetSortedState;
  end;

  ///  <summary><c>Abstract Base Class for all List Collection Types.</c></summary>
  TADCollectionList<T> = class abstract(TADCollection, IADCollectionList<T>, IADSortableList<T>)
  private
    FSorter: IADListSorter<T>;
  protected
    FArray: IADArray<T>;
    // Getters
    { IADCollection }
    function GetCapacity: Integer; override;
    function GetIsCompact: Boolean; override;
    { IADSortableList<T> }
    function GetSorter: IADListSorter<T>; virtual;
    { IADCollectionList<T> }
    function GetItem(const AIndex: Integer): T; virtual;

    // Setters
    { IADCollection }
    procedure SetCapacity(const ACapacity: Integer); override;
    { IADSortableList<T> }
    procedure SetSorter(const ASorter: IADListSorter<T>); virtual;

    { TADCollection }
    procedure CreateArray(const AInitialCapacity: Integer = 0); override;
    { Overridables }
    function AddActual(const AItem: T): Integer; virtual; abstract;
  public

    // Management Methods
    { IADCollection }
    procedure Clear; override;
    { IADCollectionList<T> }
    ///  <summary><c>Adds the given Item into the Collection.</c></summary>
    ///  <returns><c>The Index of the Item in the Collection.</c></returns>
    function Add(const AItem: T): Integer; overload; virtual;
    ///  <summary><c>Adds Items from the given List into this List.</c></summary>
    procedure Add(const AItems: IADCollectionList<T>); overload; virtual;
    ///  <summary><c>Adds multiple Items into the Collection.</c></summary>
    procedure AddItems(const AItems: Array of T); virtual;
    ///  <summary><c>Deletes the Item at the given Index.</c></summary>
    procedure Delete(const AIndex: Integer); virtual;
    ///  <summary><c>Deletes the Items from the Start Index to Start Index + Count.</c></summary>
    procedure DeleteRange(const AFirst, ACount: Integer); virtual;

    // Iterators
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure Iterate(const ACallback: TADListItemCallbackAnon<T>; const ADirection: TADIterateDirection = idRight); overload; virtual;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure Iterate(const ACallback: TADListItemCallbackOfObject<T>; const ADirection: TADIterateDirection = idRight); overload; virtual;
    procedure Iterate(const ACallback: TADListItemCallbackUnbound<T>; const ADirection: TADIterateDirection = idRight); overload; virtual;
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure IterateBackward(const ACallback: TADListItemCallbackAnon<T>); overload; virtual;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure IterateBackward(const ACallback: TADListItemCallbackOfObject<T>); overload; virtual;
    procedure IterateBackward(const ACallback: TADListItemCallbackUnbound<T>); overload; virtual;
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure IterateForward(const ACallback: TADListItemCallbackAnon<T>); overload; virtual;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure IterateForward(const ACallback: TADListItemCallbackOfObject<T>); overload; virtual;
    procedure IterateForward(const ACallback: TADListItemCallbackUnbound<T>); overload; virtual;

    // Properties
    property Items[const AIndex: Integer]: T read GetItem; default;
  end;

  ///  <summary><c>Higher Abstract Class for any List Collection Types capable of being Expanded and Compacted.</c></summary>
  TADCollectionListAllocatable<T> = class abstract(TADCollectionList<T>, IADCompactable, IADExpandable)
  private
    FCompactor: IADCompactor;
    FExpander: IADExpander;
  protected
    // Getters
    { IADCompactable }
    function GetCompactor: IADCompactor; virtual;
    { IADExpandable }
    function GetExpander: IADExpander; virtual;

    // Setters
    { IADCompactable }
    procedure SetCompactor(const ACompactor: IADCompactor); virtual;
    { IADExpandable }
    procedure SetExpander(const AExpander: IADExpander); virtual;

    { Overridables }
    ///  <summary><c>Compacts the Array according to the given Compactor Algorithm.</c></summary>
    procedure CheckCompact(const AAmount: Integer); virtual;
    ///  <summary><c>Expands the Array according to the given Expander Algorithm.</c></summary>
    procedure CheckExpand(const AAmount: Integer); virtual;
  public
    ///  <summary><c>Creates an instance of your Collection using the Default Expander and Compactor Types.</c></summary>
    constructor Create(const AInitialCapacity: Integer = 0); reintroduce; overload;
    ///  <summary><c>Creates an instance of your Collection using a Custom Expander Instance, and the default Compactor Type.</c></summary>
    constructor Create(const AExpander: IADExpander; const AInitialCapacity: Integer = 0); reintroduce; overload;
    ///  <summary><c>Creates an instance of your Collection using the default Expander Type, and a Custom Compactor Instance.</c></summary>
    constructor Create(const ACompactor: IADCompactor; const AInitialCapacity: Integer = 0); reintroduce; overload;
    ///  <summary><c>Creates an instance of your Collection using a Custom Expander and Compactor Instance.</c></summary>
    constructor Create(const AExpander: IADExpander; const ACompactor: IADCompactor; const AInitialCapacity: Integer = 0); reintroduce; overload; virtual;

    // Management Methods
    { IADCollectionList<T> }
    function Add(const AItem: T): Integer; overload; override;
    procedure Add(const AItems: IADCollectionList<T>); overload; override;
    procedure AddItems(const AItems: Array of T); override;
    procedure Delete(const AIndex: Integer); override;
    procedure DeleteRange(const AFirst, ACount: Integer); override;

    // Properties
    { IADCompactable }
    property Compactor: IADCompactor read GetCompactor;
    { IADExpandable }
    property Expander: IADExpander read GetExpander;
  end;

  ///  <summary><c>Generic List Type</c></summary>
  ///  <remarks>
  ///    <para><c>This type is NOT Threadsafe.</c></para>
  ///  </remarks>
  TADList<T> = class(TADCollectionListAllocatable<T>, IADList<T>)
  protected
    // Setters
    { IADList<T> }
    procedure SetItem(const AIndex: Integer; const AItem: T); virtual;

    // Management Methods
    ///  <summary><c>Adds the Item to the first available Index of the Array WITHOUT checking capacity.</c></summary>
    function AddActual(const AItem: T): Integer; override;
  public
    // Management Methods
    procedure Clear; override;
    procedure Compact; virtual;
    procedure Insert(const AItem: T; const AIndex: Integer); virtual;
    procedure InsertItems(const AItems: Array of T; const AIndex: Integer); virtual;
    procedure Sort(const AComparer: IADComparer<T>); virtual;

    // Properties
    { IADList<T> }
    property Items[const AIndex: Integer]: T read GetItem write SetItem; default;
  end;

  ///  <summary><c>Generic Object List Type</c></summary>
  ///  <remarks>
  ///    <para><c>Can take Ownership of its Items.</c></para>
  ///    <para><c>This type is NOT Threadsafe.</c></para>
  ///  </remarks>
  TADObjectList<T: class> = class(TADList<T>, IADObjectOwner)
  protected
    // Getters
    function GetOwnership: TADOwnership; virtual;
    // Setters
    procedure SetOwnership(const AOwnership: TADOwnership); virtual;
    // Management Methods
    ///  <summary><c>We need a TADObjectArray instead.</c></summary>
    procedure CreateArray(const AInitialCapacity: Integer = 0); override;
  public
    ///  <summary><c>Creates an instance of your List using the Default Expander and Compactor Types.</c></summary>
    constructor Create(const AInitialCapacity: Integer = 0; const AOwnership: TADOwnership = oOwnsObjects); reintroduce; overload;
    ///  <summary><c>Creates an instance of your List using a Custom Expander Instance, and the default Compactor Type.</c></summary>
    constructor Create(const AExpander: IADExpander; const AInitialCapacity: Integer = 0; const AOwnership: TADOwnership = oOwnsObjects); reintroduce; overload;
    ///  <summary><c>Creates an instance of your List using the default Expander Type, and a Custom Compactor Instance.</c></summary>
    constructor Create(const ACompactor: IADCompactor; const AInitialCapacity: Integer = 0; const AOwnership: TADOwnership = oOwnsObjects); reintroduce; overload;
    ///  <summary><c>Creates an instance of your List using a Custom Expander and Compactor Instance.</c></summary>
    constructor Create(const AExpander: IADExpander; const ACompactor: IADCompactor; const AInitialCapacity: Integer = 0; const AOwnership: TADOwnership = oOwnsObjects); reintroduce; overload; virtual;

    // Properties
    property Ownership: TADOwnership read GetOwnership write SetOwnership;
  end;

  ///  <summary><c>A Generic Fixed-Capacity Revolving List</c></summary>
  ///  <remarks>
  ///    <para><c>When the current Index is equal to the Capacity, the Index resets to 0, and items are subsequently Replaced by new ones.</c></para>
  ///    <para><c>This type is NOT Threadsafe.</c></para>
  ///  </remarks>
  TADCircularList<T> = class(TADCollectionList<T>, IADCircularList<T>)
  protected
    // Getters
    { IADCollection }
    function GetSortedState: TADSortedState; override;
    { IADCircularList<T> }
    function GetNewest: T; virtual;
    function GetNewestIndex: Integer; virtual;
    function GetOldest: T; virtual;
    function GetOldestIndex: Integer; virtual;

    // Setters
    { IADCircularList<T> }
    procedure SetCapacity(const ACapacity: Integer); override;

    // Management Methods
    { IADCircularList<T> }
    function AddActual(const AItem: T): Integer; override;
    procedure CreateArray(const ACapacity: Integer); override;
  public
    constructor Create(const ACapacity: Integer); reintroduce; virtual;
    destructor Destroy; override;

    // Properties
    property Newest: T read GetNewest;
    property NewestIndex: Integer read GetNewestIndex;
    property Oldest: T read GetOldest;
    property OldestIndex: Integer read GetOldestIndex;
  end;

  ///  <summary><c>A Generic Fixed-Capacity Revolving Object List</c></summary>
  ///  <remarks>
  ///    <para><c>When the current Index is equal to the Capacity, the Index resets to 0, and items are subsequently Replaced by new ones.</c></para>
  ///    <para><c>Can take Ownership of its Items.</c></para>
  ///    <para><c>This type is NOT Threadsafe.</c></para>
  ///  </remarks>
  TADCircularObjectList<T: class> = class(TADCircularList<T>, IADObjectOwner)
  private
    FDefaultOwnership: TADOwnership;
  protected
    // Getters
    function GetOwnership: TADOwnership; virtual;
    // Setters
    procedure SetOwnership(const AOwnership: TADOwnership); virtual;
  protected
    procedure CreateArray(const ACapacity: Integer); override;
  public
    constructor Create(const AOwnership: TADOwnership; const ACapacity: Integer); reintroduce; virtual;
    destructor Destroy; override;
  end;

  ///  <summary><c>Generic Sorted List Type.</c></summary>
  ///  <remarks>
  ///    <para><c>This type is NOT Threadsafe.</c></para>
  ///  </remarks>
  TADSortedList<T> = class(TADCollectionListAllocatable<T>, IADSortedList<T>)
  private
    FComparer: IADComparer<T>;
  protected
    // Getters
    { IADComparable<T> }
    function GetComparer: IADComparer<T>; virtual;
    { IADSortedList<T> }
    function GetSortedState: TADSortedState; override;

    // Setters
    { IADComparable<T> }
    procedure SetComparer(const AComparer: IADComparer<T>); virtual;

    // Management Methods
    ///  <summary><c>Adds the Item to the correct Index of the Array WITHOUT checking capacity.</c></summary>
    ///  <returns>
    ///    <para>-1<c> if the Item CANNOT be added.</c></para>
    ///    <para>0 OR GREATER<c> if the Item has be added, where the Value represents the Index of the Item.</c></para>
    ///  </returns>
    function AddActual(const AItem: T): Integer; override;
    ///  <summary><c>Determines the Index at which an Item would need to be Inserted for the List to remain in-order.</c></summary>
    ///  <remarks>
    ///    <para><c>This is basically a Binary Sort implementation.<c></para>
    ///  </remarks>
    function GetSortedPosition(const AItem: T): Integer; virtual;
  public
    ///  <summary><c>Creates an instance of your Sorted List using the Default Expander and Compactor Types.</c></summary>
    constructor Create(const AComparer: IADComparer<T>; const AInitialCapacity: Integer = 0); reintroduce; overload;
    ///  <summary><c>Creates an instance of your Sorted List using a Custom Expander Instance, and the default Compactor Type.</c></summary>
    constructor Create(const AExpander: IADExpander; const AComparer: IADComparer<T>; const AInitialCapacity: Integer = 0); reintroduce; overload;
    ///  <summary><c>Creates an instance of your Sorted List using the default Expander Type, and a Custom Compactor Instance.</c></summary>
    constructor Create(const ACompactor: IADCompactor; const AComparer: IADComparer<T>; const AInitialCapacity: Integer = 0); reintroduce; overload;
    ///  <summary><c>Creates an instance of your Sorted List using a Custom Expander and Compactor Instance.</c></summary>
    constructor Create(const AExpander: IADExpander; const ACompactor: IADCompactor; const AComparer: IADComparer<T>; const AInitialCapacity: Integer = 0); reintroduce; overload; virtual;
    destructor Destroy; override;

    // Management Methods
    { IADSortedList<T> }
    procedure Clear; override;
    procedure Compact; virtual;
    function Contains(const AItem: T): Boolean; virtual;
    function ContainsAll(const AItems: Array of T): Boolean; virtual;
    function ContainsAny(const AItems: Array of T): Boolean; virtual;
    function ContainsNone(const AItems: Array of T): Boolean; virtual;
    function EqualItems(const AList: IADSortedList<T>): Boolean; virtual;
    function IndexOf(const AItem: T): Integer; virtual;
    procedure Remove(const AItem: T); virtual;
    procedure RemoveItems(const AItems: Array of T); virtual;

    // Properties
    { IADComparable<T> }
    property Comparer: IADComparer<T> read GetComparer write SetComparer;
  end;

  ///  <summary><c>Generic Object Sorted List Type</c></summary>
  ///  <remarks>
  ///    <para><c>Can take Ownership of its Items.</c></para>
  ///    <para><c>This type is NOT Threadsafe.</c></para>
  ///  </remarks>
  TADSortedObjectList<T: class> = class(TADSortedList<T>, IADObjectOwner)
  protected
    // Getters
    function GetOwnership: TADOwnership; virtual;
    // Setters
    procedure SetOwnership(const AOwnership: TADOwnership); virtual;
    // Management Methods
    ///  <summary><c>Override to construct an alternative Array type</c></summary>
    procedure CreateArray(const AInitialCapacity: Integer = 0); override;
  public
    // Properties
    property Ownership: TADOwnership read GetOwnership write SetOwnership;
  end;

  ///  <summary><c>A Generic Fixed-Capacity Revolving Sorted List</c></summary>
  ///  <remarks>
  ///    <para><c>When the current Index is equal to the Capacity, the Index resets to 0, and items are subsequently Replaced by new ones.</c></para>
  ///    <para><c>This type is NOT Threadsafe.</c></para>
  ///  </remarks>
  TADSortedCircularList<T> = class(TADCircularList<T>, IADComparable<T>)
  private
    FComparer: IADComparer<T>;
    FSorter: IADListSorter<T>;
  protected
    // Getters
    { IADComparable<T> }
    function GetComparer: IADComparer<T>; virtual;

    // Setters
    { IADComparable<T> }
    procedure SetComparer(const AComparer: IADComparer<T>); virtual;

    { Internal Methods }
    function AddActual(const AItem: T): Integer; override;
    function GetSortedPosition(const AItem: T): Integer; virtual;
  public
    constructor Create(const ACapacity: Integer; const AComparer: IADComparer<T>; const ASorter: IADListSorter<T>); reintroduce; virtual;
    // Properties
    { IADComparable<T> }
    property Comparer: IADComparer<T> read GetComparer write SetComparer;
    { IADSortableList<T> }
    property Sorter: IADListSorter<T> read GetSorter write SetSorter;
  end;

  ///  <summary><c>A Generic Fixed-Capacity Revolving Sorted Object List</c></summary>
  ///  <remarks>
  ///    <para><c>When the current Index is equal to the Capacity, the Index resets to 0, and items are subsequently Replaced by new ones.</c></para>
  ///    <para><c>Can take Ownership of its Items.</c></para>  ///
  ///    <para><c>This type is NOT Threadsafe.</c></para>
  ///  </remarks>
  TADSortedCircularObjectList<T: class> = class(TADSortedCircularList<T>, IADObjectOwner)
  private
    FDefaultOwnership: TADOwnership;
  protected
    // Getters
    function GetOwnership: TADOwnership; virtual;
    // Setters
    procedure SetOwnership(const AOwnership: TADOwnership); virtual;
  protected
    procedure CreateArray(const ACapacity: Integer); override;
  public
    constructor Create(const AOwnership: TADOwnership; const ACapacity: Integer; const AComparer: IADComparer<T>; const ASorter: IADListSorter<T>); reintroduce; virtual;
    destructor Destroy; override;
  end;

  ///  <summary><c>Generic Map Type.</c></summary>
  ///  <remarks>
  ///    <para><c></c></para>
  ///  </remarks>
  TADMap<TKey, TValue> = class(TADObject, IADMap<TKey, TValue>, IADComparable<TKey>, IADSortableMap<TKey, TValue>, IADCompactable, IADExpandable)
  private
    FCompactor: IADCompactor;
    FComparer: IADComparer<TKey>;
    FExpander: IADExpander;
    FInitialCapacity: Integer;
    FSorter: IADMapSorter<TKey, TValue>;
  protected
    FArray: IADArray<IADKeyValuePair<TKey, TValue>>;
    FCount: Integer;
    // Getters
    { IADCompactable }
    function GetCompactor: IADCompactor; virtual;
    { IADComparable<T> }
    function GetComparer: IADComparer<TKey>; virtual;
    { IADExpandable }
    function GetExpander: IADExpander; virtual;
    { IADSortableMap<TKey, TValue> }
    function GetSorter: IADMapSorter<TKey, TValue>; virtual;
    { IADMap<TKey, TValue> }
    function GetCapacity: Integer; virtual;
    function GetCount: Integer; virtual;
    function GetInitialCapacity: Integer;
    function GetIsCompact: Boolean; virtual;
    function GetIsEmpty: Boolean; virtual;
    function GetItem(const AKey: TKey): TValue; virtual;
    function GetPair(const AIndex: Integer): IADKeyValuePair<TKey, TValue>; virtual;
    function GetSortedState: TADSortedState;

    // Setters
    { IADCompactable }
    procedure SetCompactor(const ACompactor: IADCompactor); virtual;
    { IADComparable<T> }
    procedure SetComparer(const AComparer: IADComparer<TKey>); virtual;
    { IADExpandable }
    procedure SetExpander(const AExpander: IADExpander); virtual;
    { IADSortableMap<TKey, TValue> }
    procedure SetSorter(const ASorter: IADMapSorter<TKey, TValue>); virtual;
    { IADMap<TKey, TValue> }
    procedure SetCapacity(const ACapacity: Integer); virtual;

    // Management Methods
    ///  <summary><c>Adds the Item to the correct Index of the Array WITHOUT checking capacity.</c></summary>
    ///  <returns>
    ///    <para>-1<c> if the Item CANNOT be added.</c></para>
    ///    <para>0 OR GREATER<c> if the Item has be added, where the Value represents the Index of the Item.</c></para>
    ///  </returns>
    function AddActual(const AItem: IADKeyValuePair<TKey, TValue>): Integer;
    ///  <summary><c>Compacts the Array according to the given Compactor Algorithm.</c></summary>
    procedure CheckCompact(const AAmount: Integer); virtual;
    ///  <summary><c>Expands the Array according to the given Expander Algorithm.</c></summary>
    procedure CheckExpand(const AAmount: Integer); virtual;
    ///  <summary><c>Override to construct an alternative Array type</c></summary>
    procedure CreateArray(const AInitialCapacity: Integer = 0); virtual;
    ///  <summary><c>Determines the Index at which an Item would need to be Inserted for the List to remain in-order.</c></summary>
    ///  <remarks>
    ///    <para><c>This is basically a Binary Sort implementation.<c></para>
    ///  </remarks>
    function GetSortedPosition(const AKey: TKey): Integer; virtual;
  public
    ///  <summary><c>Creates an instance of your Sorted List using the Default Expander and Compactor Types.</c></summary>
    constructor Create(const AComparer: IADComparer<TKey>; const AInitialCapacity: Integer = 0); reintroduce; overload;
    ///  <summary><c>Creates an instance of your Sorted List using a Custom Expander Instance, and the default Compactor Type.</c></summary>
    constructor Create(const AExpander: IADExpander; const AComparer: IADComparer<TKey>; const AInitialCapacity: Integer = 0); reintroduce; overload;
    ///  <summary><c>Creates an instance of your Sorted List using the default Expander Type, and a Custom Compactor Instance.</c></summary>
    constructor Create(const ACompactor: IADCompactor; const AComparer: IADComparer<TKey>; const AInitialCapacity: Integer = 0); reintroduce; overload;
    ///  <summary><c>Creates an instance of your Sorted List using a Custom Expander and Compactor Instance.</c></summary>
    constructor Create(const AExpander: IADExpander; const ACompactor: IADCompactor; const AComparer: IADComparer<TKey>; const AInitialCapacity: Integer = 0); reintroduce; overload; virtual;
    destructor Destroy; override;

    // Management Methods
    function Add(const AItem: IADKeyValuePair<TKey, TValue>): Integer; overload; virtual;
    function Add(const AKey: TKey; const AValue: TValue): Integer; overload; virtual;
    procedure AddItems(const AItems: Array of IADKeyValuePair<TKey, TValue>); overload; virtual;
    procedure AddItems(const AMap: IADCollectionMap<TKey, TValue>); overload; virtual;
    procedure Clear; virtual;
    procedure Compact; virtual;
    function Contains(const AKey: TKey): Boolean; virtual;
    function ContainsAll(const AKeys: Array of TKey): Boolean; virtual;
    function ContainsAny(const AKeys: Array of TKey): Boolean; virtual;
    function ContainsNone(const AKeys: Array of TKey): Boolean; virtual;
    procedure Delete(const AIndex: Integer); overload; virtual;
    procedure DeleteRange(const AFromIndex, ACount: Integer); overload; virtual;
    function EqualItems(const AList: IADCollectionMap<TKey, TValue>): Boolean; virtual;
    function IndexOf(const AKey: TKey): Integer; virtual;
    procedure Remove(const AKey: TKey); virtual;
    procedure RemoveItems(const AKeys: Array of TKey); virtual;

    // Iterators
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure Iterate(const ACallback: TADListMapCallbackAnon<TKey, TValue>; const ADirection: TADIterateDirection = idRight); overload; virtual;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure Iterate(const ACallback: TADListMapCallbackOfObject<TKey, TValue>; const ADirection: TADIterateDirection = idRight); overload; virtual;
    procedure Iterate(const ACallback: TADListMapCallbackUnbound<TKey, TValue>; const ADirection: TADIterateDirection = idRight); overload; virtual;
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure IterateBackward(const ACallback: TADListMapCallbackAnon<TKey, TValue>); overload; virtual;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure IterateBackward(const ACallback: TADListMapCallbackOfObject<TKey, TValue>); overload; virtual;
    procedure IterateBackward(const ACallback: TADListMapCallbackUnbound<TKey, TValue>); overload; virtual;
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure IterateForward(const ACallback: TADListMapCallbackAnon<TKey, TValue>); overload; virtual;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure IterateForward(const ACallback: TADListMapCallbackOfObject<TKey, TValue>); overload; virtual;
    procedure IterateForward(const ACallback: TADListMapCallbackUnbound<TKey, TValue>); overload; virtual;

    // Properties
    { IADCompactable }
    property Compactor: IADCompactor read GetCompactor write SetCompactor;
    { IADComparable<T> }
    property Comparer: IADComparer<TKey> read GetComparer write SetComparer;
    { IADExpandable }
    property Expander: IADExpander read GetExpander write SetExpander;
    { IADMap<TKey, TValue> }
    property Count: Integer read GetCount;
    property IsCompact: Boolean read GetIsCompact;
    property IsEmpty: Boolean read GetIsEmpty;
    property Item[const AKey: TKey]: TValue read GetItem; default;
    property Pair[const AIndex: Integer]: IADKeyValuePair<TKey, TValue> read GetPair;
  end;

implementation

uses
  ADAPT.Generics.Common,
  ADAPT.Generics.Allocators,
  ADAPT.Generics.Comparers,
  ADAPT.Generics.Sorters;

{ TADArray<T> }

procedure TADArray<T>.Clear;
begin
  SetLength(FArray, FCapacityInitial);
  if FCapacityInitial > 0 then
    Finalize(0, FCapacityInitial);
end;

constructor TADArray<T>.Create(const ACapacity: Integer);
begin
  inherited Create;
  FCapacityInitial := ACapacity;
  SetLength(FArray, ACapacity);
end;

procedure TADArray<T>.Delete(const AIndex: Integer);
var
  I: Integer;
begin
  FArray[AIndex] := nil;
//  System.FillChar(FArray[AIndex], SizeOf(IADValueHolder<T>), 0);
  if AIndex < Length(FArray) - 1 then
  begin
//    System.Move(FArray[AIndex + 1],
//                FArray[AIndex],
//                ((Length(FArray) - 1) - AIndex) * SizeOf(IADValueHolder<T>));
    for I := AIndex to Length(FArray) - 2 do
      FArray[I] := FArray[I + 1];
  end;
end;

destructor TADArray<T>.Destroy;
begin
//  Clear;
  inherited;
end;

procedure TADArray<T>.Finalize(const AIndex, ACount: Integer);
begin
  System.Finalize(FArray[AIndex], ACount);
  System.FillChar(FArray[AIndex], ACount * SizeOf(T), 0);
end;

function TADArray<T>.GetCapacity: Integer;
begin
  Result := Length(FArray);
end;

function TADArray<T>.GetItem(const AIndex: Integer): T;
begin
  if (AIndex < Low(FArray)) or (AIndex > High(FArray)) then
    raise EADGenericsRangeException.CreateFmt('Index [%d] Out Of Range', [AIndex]);
  Result := FArray[AIndex].Value;
end;

procedure TADArray<T>.Insert(const AItem: T; const AIndex: Integer);
begin
  Move(AIndex, AIndex + 1, (Capacity - AIndex) - 1);
  Finalize(AIndex, 1);
  FArray[AIndex] := TADValueHolder<T>.Create(AItem);
end;

procedure TADArray<T>.Move(const AFromIndex, AToIndex, ACount: Integer);
var
  LItem: T;
  I: Integer;
begin
  if AFromIndex < AToIndex then
  begin
    for I := AFromIndex + ACount downto AFromIndex + 1 do
      FArray[I] := FArray[I - (AToIndex - AFromIndex)];
  end else
    System.Move(FArray[AFromIndex], FArray[AToIndex], ACount * SizeOf(T));
end;

procedure TADArray<T>.SetCapacity(const ACapacity: Integer);
begin
  SetLength(FArray, ACapacity);
end;

procedure TADArray<T>.SetItem(const AIndex: Integer; const AItem: T);
begin
  FArray[AIndex] := TADValueHolder<T>.Create(AItem);
end;

{ TADObjectArray<T> }

procedure TADObjectArray<T>.Clear;
var
  I: Integer;
begin
  if Ownership = oOwnsObjects then
    for I := Low(FArray) to High(FArray) do
      if ((Assigned(FArray[I]))) and (FArray[I] <> nil) then
        FArray[I].Value.{$IFDEF SUPPORTS_DISPOSEOF}DisposeOf{$ELSE}Free{$ENDIF SUPPORTS_DISPOSEOF};
  inherited;
end;

constructor TADObjectArray<T>.Create(const AOwnership: TADOwnership = oOwnsObjects; const ACapacity: Integer = 0);
begin
  inherited Create(ACapacity);
  FOwnership := AOwnership;
end;

destructor TADObjectArray<T>.Destroy;
begin
  Clear;
  inherited;
end;

function TADObjectArray<T>.GetOwnership: TADOwnership;
begin
  Result := FOwnership;
end;

procedure TADObjectArray<T>.SetOwnership(const AOwnership: TADOwnership);
begin
  FOwnership := AOwnership;
end;

{ TADCollection }

constructor TADCollection.Create(const AInitialCapacity: Integer);
begin
  inherited Create;
  FSortedState := ssUnknown;
  FCount := 0;
  FInitialCapacity := AInitialCapacity;
  CreateArray(AInitialCapacity);
end;

function TADCollection.GetCount: Integer;
begin
  Result := FCount;
end;

function TADCollection.GetInitialCapacity: Integer;
begin
  Result := FInitialCapacity;
end;

function TADCollection.GetIsEmpty: Boolean;
begin
  Result := (FCount = 0);
end;

function TADCollection.GetSortedState: TADSortedState;
begin
  Result := FSortedState;
end;

{ TADCollectionList<T> }

function TADCollectionList<T>.Add(const AItem: T): Integer;
begin
  Result := AddActual(AItem);
end;

procedure TADCollectionList<T>.Add(const AItems: IADCollectionList<T>);
var
  I: Integer;
begin
  for I := 0 to AItems.Count - 1 do
    AddActual(AItems[I]);
end;

procedure TADCollectionList<T>.AddItems(const AItems: array of T);
var
  I: Integer;
begin
  for I := Low(AItems) to High(AItems) do
    AddActual(AItems[I]);
end;

procedure TADCollectionList<T>.Clear;
begin
  FArray.Clear;
  FCount := 0;
end;

procedure TADCollectionList<T>.CreateArray(const AInitialCapacity: Integer);
begin
  FArray := TADArray<T>.Create(AInitialCapacity);
end;

procedure TADCollectionList<T>.Delete(const AIndex: Integer);
begin
  FArray.Delete(AIndex);
  Dec(FCount);
  FSortedState := ssUnsorted;
end;

procedure TADCollectionList<T>.DeleteRange(const AFirst, ACount: Integer);
begin
  FArray.Finalize(AFirst, ACount);
  if AFirst + FCount < FCount - 1 then
    FArray.Move(AFirst + FCount + 1, AFirst, ACount); // Shift all subsequent items left
  Dec(FCount, ACount);
  FSortedState := ssUnsorted;
end;

function TADCollectionList<T>.GetCapacity: Integer;
begin
  Result := FArray.Capacity;
end;

function TADCollectionList<T>.GetIsCompact: Boolean;
begin
  Result := (FArray.Capacity = FCount);
end;

function TADCollectionList<T>.GetItem(const AIndex: Integer): T;
begin
  Result := FArray[AIndex];
end;

function TADCollectionList<T>.GetSorter: IADListSorter<T>;
begin
  Result := FSorter;
end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TADCollectionList<T>.Iterate(const ACallback: TADListItemCallbackAnon<T>; const ADirection: TADIterateDirection = idRight);
  begin
    case ADirection of
      idLeft: IterateBackward(ACallback);
      idRight: IterateForward(ACallback);
      else
        raise EADGenericsIterateDirectionUnknownException.Create('Unhandled Iterate Direction given.');
    end;
  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADCollectionList<T>.Iterate(const ACallback: TADListItemCallbackOfObject<T>; const ADirection: TADIterateDirection);
begin
  case ADirection of
    idLeft: IterateBackward(ACallback);
    idRight: IterateForward(ACallback);
    else
      raise EADGenericsIterateDirectionUnknownException.Create('Unhandled Iterate Direction given.');
  end;
end;

procedure TADCollectionList<T>.Iterate(const ACallback: TADListItemCallbackUnbound<T>; const ADirection: TADIterateDirection);
begin
  case ADirection of
    idLeft: IterateBackward(ACallback);
    idRight: IterateForward(ACallback);
    else
      raise EADGenericsIterateDirectionUnknownException.Create('Unhandled Iterate Direction given.');
  end;
end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TADCollectionList<T>.IterateBackward(const ACallback: TADListItemCallbackAnon<T>);
  var
    I: Integer;
  begin
    for I := FCount - 1 downto 0 do
      ACallback(FArray[I]);
  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADCollectionList<T>.IterateBackward(const ACallback: TADListItemCallbackOfObject<T>);
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    ACallback(FArray[I]);
end;

procedure TADCollectionList<T>.IterateBackward(const ACallback: TADListItemCallbackUnbound<T>);
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    ACallback(FArray[I]);
end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TADCollectionList<T>.IterateForward(const ACallback: TADListItemCallbackAnon<T>);
  var
    I: Integer;
  begin
    for I := 0 to FCount - 1 do
      ACallback(FArray[I]);
  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADCollectionList<T>.IterateForward(const ACallback: TADListItemCallbackOfObject<T>);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    ACallback(FArray[I]);
end;

procedure TADCollectionList<T>.IterateForward(const ACallback: TADListItemCallbackUnbound<T>);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    ACallback(FArray[I]);
end;

procedure TADCollectionList<T>.SetCapacity(const ACapacity: Integer);
begin
  if ACapacity < FCount then
    raise EADGenericsCapacityLessThanCount.CreateFmt('Given Capacity of %d insufficient for a Collection containing %d Items.', [ACapacity, FCount])
  else
    FArray.Capacity := ACapacity;
end;

procedure TADCollectionList<T>.SetSorter(const ASorter: IADListSorter<T>);
begin
  FSorter := ASorter;
end;

{ TADCollectionListAllocatable<T> }

constructor TADCollectionListAllocatable<T>.Create(const AInitialCapacity: Integer);
begin
  Create(ADCollectionExpanderDefault, ADCollectionCompactorDefault, AInitialCapacity);
end;

constructor TADCollectionListAllocatable<T>.Create(const AExpander: IADExpander; const AInitialCapacity: Integer);
begin
  Create(AExpander, ADCollectionCompactorDefault, AInitialCapacity);
end;

constructor TADCollectionListAllocatable<T>.Create(const ACompactor: IADCompactor; const AInitialCapacity: Integer);
begin
  Create(ADCollectionExpanderDefault, ACompactor, AInitialCapacity);
end;

function TADCollectionListAllocatable<T>.Add(const AItem: T): Integer;
begin
  CheckExpand(1);
  Result := Inherited;
end;

procedure TADCollectionListAllocatable<T>.Add(const AItems: IADCollectionList<T>);
begin
  CheckExpand(AItems.Count);
  inherited;
end;

procedure TADCollectionListAllocatable<T>.AddItems(const AItems: array of T);
begin
  CheckExpand(Length(AItems));
  inherited;
end;

procedure TADCollectionListAllocatable<T>.CheckCompact(const AAmount: Integer);
var
  LShrinkBy: Integer;
begin
  LShrinkBy := Compactor.CheckCompact(FArray.Capacity, FCount, AAmount);
  if LShrinkBy > 0 then
    FArray.Capacity := FArray.Capacity - LShrinkBy;
end;

procedure TADCollectionListAllocatable<T>.CheckExpand(const AAmount: Integer);
var
  LNewCapacity: Integer;
begin
  LNewCapacity := Expander.CheckExpand(FArray.Capacity, FCount, AAmount);
  if LNewCapacity > 0 then
    FArray.Capacity := FArray.Capacity + LNewCapacity;
end;

constructor TADCollectionListAllocatable<T>.Create(const AExpander: IADExpander; const ACompactor: IADCompactor; const AInitialCapacity: Integer);
begin
  inherited Create(AInitialCapacity);
  FSorter := TADListSorterQuick<T>.Create;
  FExpander := AExpander;
  FCompactor := ACompactor;
end;

procedure TADCollectionListAllocatable<T>.Delete(const AIndex: Integer);
begin
  inherited;
  CheckCompact(1);
end;

procedure TADCollectionListAllocatable<T>.DeleteRange(const AFirst, ACount: Integer);
begin
  inherited;
  CheckCompact(ACount);
end;

function TADCollectionListAllocatable<T>.GetCompactor: IADCompactor;
begin
  Result := FCompactor;
end;

function TADCollectionListAllocatable<T>.GetExpander: IADExpander;
begin
  Result := FExpander;
end;

procedure TADCollectionListAllocatable<T>.SetCompactor(const ACompactor: IADCompactor);
begin
  if ACompactor = nil then
    raise EADGenericsCompactorNilException.Create('Cannot assign a Nil Compactor.')
  else
    FCompactor := ACompactor;

  CheckCompact(0);
end;

procedure TADCollectionListAllocatable<T>.SetExpander(const AExpander: IADExpander);
begin
  if AExpander = nil then
    raise EADGenericsExpanderNilException.Create('Cannot assign a Nil Expander.')
  else
    FExpander := AExpander;
end;

{ TADList<T> }

function TADList<T>.AddActual(const AItem: T): Integer;
begin
  FArray[FCount] := AItem;
  Result := FCount;
  Inc(FCount);
  FSortedState := ssUnsorted;
end;

procedure TADList<T>.Clear;
begin
  FArray.Finalize(0, FCount);
  FCount := 0;
  FArray.Capacity := FInitialCapacity;
  FSortedState := ssUnknown;
end;

procedure TADList<T>.Compact;
begin
  FArray.Capacity := FCount;
end;

procedure TADList<T>.Insert(const AItem: T; const AIndex: Integer);
begin
  //TODO -oDaniel -cTADList<T>: Implement Insert method
  FSortedState := ssUnsorted;
end;

procedure TADList<T>.InsertItems(const AItems: Array of T; const AIndex: Integer);
begin
  //TODO -oDaniel -cTADList<T>: Implement InsertItems method
  FSortedState := ssUnsorted;
end;

procedure TADList<T>.SetItem(const AIndex: Integer; const AItem: T);
begin
  FArray[AIndex] := AItem;
end;

procedure TADList<T>.Sort(const AComparer: IADComparer<T>);
begin
  FSorter.Sort(FArray, AComparer, 0, FCount - 1);
  FSortedState := ssSorted;
end;

{ TADObjectList<T> }

constructor TADObjectList<T>.Create(const AInitialCapacity: Integer; const AOwnership: TADOwnership);
begin
  Create(ADCollectionExpanderDefault, ADCollectionCompactorDefault, AInitialCapacity, AOwnership);
end;

constructor TADObjectList<T>.Create(const ACompactor: IADCompactor; const AInitialCapacity: Integer; const AOwnership: TADOwnership);
begin
  Create(ADCollectionExpanderDefault, ACompactor, AInitialCapacity, AOwnership);
end;

constructor TADObjectList<T>.Create(const AExpander: IADExpander; const AInitialCapacity: Integer; const AOwnership: TADOwnership);
begin
  Create(AExpander, ADCollectionCompactorDefault, AInitialCapacity, AOwnership);
end;

constructor TADObjectList<T>.Create(const AExpander: IADExpander; const ACompactor: IADCompactor; const AInitialCapacity: Integer; const AOwnership: TADOwnership);
begin
  inherited Create(AExpander, ACompactor, AInitialCapacity);
  TADObjectArray<T>(FArray).Ownership := AOwnership;
end;

procedure TADObjectList<T>.CreateArray(const AInitialCapacity: Integer = 0);
begin
  FArray := TADObjectArray<T>.Create(oOwnsObjects, AInitialCapacity);
end;

function TADObjectList<T>.GetOwnership: TADOwnership;
begin
  Result := TADObjectArray<T>(FArray).Ownership;
end;

procedure TADObjectList<T>.SetOwnership(const AOwnership: TADOwnership);
begin
  TADObjectArray<T>(FArray).Ownership := AOwnership;
end;

{ TADCircularList<T> }

function TADCircularList<T>.AddActual(const AItem: T): Integer;
begin
  if FCount < FArray.Capacity then
    Inc(FCount)
  else
    FArray.Delete(0);

  Result := FCount - 1;

  FArray[Result] := AItem;         // Assign the Item to the Array at the Index.
end;

constructor TADCircularList<T>.Create(const ACapacity: Integer);
begin
  inherited Create(ACapacity);
end;

procedure TADCircularList<T>.CreateArray(const ACapacity: Integer);
begin
  FArray := TADArray<T>.Create(ACapacity);
end;

destructor TADCircularList<T>.Destroy;
begin
  inherited;
end;

function TADCircularList<T>.GetNewest: T;
var
  LIndex: Integer;
begin
  LIndex := GetNewestIndex;
  if LIndex > -1 then
    Result := FArray[LIndex];
end;

function TADCircularList<T>.GetNewestIndex: Integer;
begin
  Result := FCount - 1;
end;

function TADCircularList<T>.GetOldest: T;
var
  LIndex: Integer;
begin
  LIndex := GetOldestIndex;
  if LIndex > -1 then
    Result := FArray[LIndex];
end;

function TADCircularList<T>.GetOldestIndex: Integer;
begin
  if FCount = 0 then
    Result := -1
  else
    Result := 0;
end;

function TADCircularList<T>.GetSortedState: TADSortedState;
begin
  Result := ssUnsorted;
end;

procedure TADCircularList<T>.SetCapacity(const ACapacity: Integer);
begin
  //TODO -cTADCircularList<T> -oDaniel: Expand Array and repopulate with existing Items in order!
end;

{ TADCircularObjectList<T> }

constructor TADCircularObjectList<T>.Create(const AOwnership: TADOwnership; const ACapacity: Integer);
begin
  FDefaultOwnership := AOwnership;
  inherited Create(ACapacity);
end;

procedure TADCircularObjectList<T>.CreateArray(const ACapacity: Integer);
begin
  FArray := TADObjectArray<T>.Create(FDefaultOwnership, ACapacity);
end;

destructor TADCircularObjectList<T>.Destroy;
begin

  inherited;
end;

function TADCircularObjectList<T>.GetOwnership: TADOwnership;
begin
  Result := TADObjectArray<T>(FArray).Ownership;
end;

procedure TADCircularObjectList<T>.SetOwnership(const AOwnership: TADOwnership);
begin
  TADObjectArray<T>(FArray).Ownership := AOwnership;
end;

{ TADSortedList<T> }

function TADSortedList<T>.AddActual(const AItem: T): Integer;
begin
  // TODO -oDaniel -cTADSortedList<T>: Need to add check to ensure Item not already in List. This MIGHT need to be optional!
  Result := GetSortedPosition(AItem);
  if Result = FCount then
    FArray[FCount] := AItem
  else
    FArray.Insert(AItem, Result);

  Inc(FCount);
end;

procedure TADSortedList<T>.Clear;
begin
  inherited;
  FArray.Clear;
  FArray.Capacity := FInitialCapacity;
end;

procedure TADSortedList<T>.Compact;
begin
  FArray.Capacity := FCount;
end;

function TADSortedList<T>.Contains(const AItem: T): Boolean;
var
  LIndex: Integer;
begin
  LIndex := IndexOf(AItem);
  Result := (LIndex > -1);
end;

function TADSortedList<T>.ContainsAll(const AItems: array of T): Boolean;
var
  I: Integer;
begin
  Result := True; // Optimistic
  for I := Low(AItems) to High(AItems) do
    if (not Contains(AItems[I])) then
    begin
      Result := False;
      Break;
    end;
end;

function TADSortedList<T>.ContainsAny(const AItems: array of T): Boolean;
var
  I: Integer;
begin
  Result := False; // Pessimistic
  for I := Low(AItems) to High(AItems) do
    if Contains(AItems[I]) then
    begin
      Result := True;
      Break;
    end;
end;

function TADSortedList<T>.ContainsNone(const AItems: array of T): Boolean;
begin
  Result := (not ContainsAny(AItems));
end;

constructor TADSortedList<T>.Create(const AComparer: IADComparer<T>; const AInitialCapacity: Integer);
begin
  Create(ADCollectionExpanderDefault, ADCollectionCompactorDefault, AComparer, AInitialCapacity);
end;

constructor TADSortedList<T>.Create(const AExpander: IADExpander; const AComparer: IADComparer<T>; const AInitialCapacity: Integer);
begin
  Create(AExpander, ADCollectionCompactorDefault, AComparer, AInitialCapacity);
end;

constructor TADSortedList<T>.Create(const ACompactor: IADCompactor; const AComparer: IADComparer<T>; const AInitialCapacity: Integer);
begin
  Create(ADCollectionExpanderDefault, ACompactor, AComparer, AInitialCapacity);
end;

constructor TADSortedList<T>.Create(const AExpander: IADExpander; const ACompactor: IADCompactor; const AComparer: IADComparer<T>; const AInitialCapacity: Integer);
begin
  inherited Create(AExpander, ACompactor, AInitialCapacity);
  FComparer := AComparer;
end;

destructor TADSortedList<T>.Destroy;
begin

  inherited;
end;

function TADSortedList<T>.EqualItems(const AList: IADSortedList<T>): Boolean;
var
  I: Integer;
begin
  Result := AList.Count = FCount;
  if Result then
    for I := 0 to AList.Count - 1 do
      if (not FComparer.AEqualToB(AList[I], FArray[I])) then
      begin
        Result := False;
        Break;
      end;
end;

function TADSortedList<T>.GetComparer: IADComparer<T>;
begin
  Result := FComparer;
end;

function TADSortedList<T>.GetSortedPosition(const AItem: T): Integer;
var
  LIndex, LLow, LHigh: Integer;
begin
  Result := 0;
  LLow := 0;
  LHigh := FCount - 1;
  if LHigh = -1 then
    Exit;
  if LLow < LHigh then
  begin
    while (LHigh - LLow > 1) do
    begin
      LIndex := (LHigh + LLow) div 2;
      if FComparer.ALessThanOrEqualToB(AItem, FArray[LIndex]) then
        LHigh := LIndex
      else
        LLow := LIndex;
    end;
  end;
  if FComparer.ALessThanB(FArray[LHigh], AItem) then
    Result := LHigh + 1
  else if FComparer.ALessThanB(FArray[LLow], AItem) then
    Result := LLow + 1
  else
    Result := LLow;
end;

function TADSortedList<T>.GetSortedState: TADSortedState;
begin
  Result := ssSorted;
end;

function TADSortedList<T>.IndexOf(const AItem: T): Integer;
var
  LLow, LHigh, LMid: Integer;
begin
  Result := -1; // Pessimistic
  LLow := 0;
  LHigh := FCount - 1;
  repeat
    LMid := (LLow + LHigh) div 2;
    if FComparer.AEqualToB(FArray[LMid], AItem) then
    begin
      Result := LMid;
      Break;
    end
    else if FComparer.ALessThanB(AItem, FArray[LMid]) then
      LHigh := LMid - 1
    else
      LLow := LMid + 1;
  until LHigh < LLow;
end;

procedure TADSortedList<T>.Remove(const AItem: T);
var
  LIndex: Integer;
begin
  LIndex := IndexOf(AItem);
  if LIndex > -1 then
    Delete(LIndex);
end;

procedure TADSortedList<T>.RemoveItems(const AItems: array of T);
var
  I: Integer;
begin
  for I := Low(AItems) to High(AItems) do
    Remove(AItems[I]);
end;

procedure TADSortedList<T>.SetComparer(const AComparer: IADComparer<T>);
begin
  FComparer := AComparer;
  FSorter.Sort(FArray, AComparer, 0, FCount - 1);
end;

{ TADSortedObjectList<T> }

procedure TADSortedObjectList<T>.CreateArray(const AInitialCapacity: Integer);
begin
  FArray := TADObjectArray<T>.Create(oOwnsObjects, AInitialCapacity);
end;

function TADSortedObjectList<T>.GetOwnership: TADOwnership;
begin
  Result := TADObjectArray<T>(FArray).Ownership;
end;

procedure TADSortedObjectList<T>.SetOwnership(const AOwnership: TADOwnership);
begin
  TADObjectArray<T>(FArray).Ownership := AOwnership;
end;

{ TADSortedCircularList<T> }

function TADSortedCircularList<T>.AddActual(const AItem: T): Integer;
begin
  Result := GetSortedPosition(AItem);
  if Result = 0 then
    FArray[0] := AItem
  else if Result = FCount then
    FArray[FCount] := AItem
  else
  begin
    if FCount < FArray.Capacity then
      Inc(FCount)
    else
    begin
      FArray.Delete(0);
      Dec(Result);
    end;
    FArray.Insert(AItem, Result);
  end;
end;

constructor TADSortedCircularList<T>.Create(const ACapacity: Integer; const AComparer: IADComparer<T>; const ASorter: IADListSorter<T>);
begin
  inherited Create(ACapacity);
  FComparer := AComparer;
  FSorter := ASorter;
end;

function TADSortedCircularList<T>.GetComparer: IADComparer<T>;
begin
  Result := FComparer;
end;

function TADSortedCircularList<T>.GetSortedPosition(const AItem: T): Integer;
var
  LIndex, LLow, LHigh: Integer;
begin
  Result := 0;
  LLow := 0;
  LHigh := FCount - 1;
  if LHigh = -1 then
    Exit;
  if LLow < LHigh then
  begin
    while (LHigh - LLow > 1) do
    begin
      LIndex := (LHigh + LLow) div 2;
      if FComparer.ALessThanOrEqualToB(AItem, FArray[LIndex]) then
        LHigh := LIndex
      else
        LLow := LIndex;
    end;
  end;
  if FComparer.ALessThanB(FArray[LHigh], AItem) then
    Result := LHigh + 1
  else if FComparer.ALessThanB(FArray[LLow], AItem) then
    Result := LLow + 1
  else
    Result := LLow;
end;

procedure TADSortedCircularList<T>.SetComparer(const AComparer: IADComparer<T>);
begin
  FComparer := AComparer;
end;

{ TADSortedCircularObjectList<T> }

constructor TADSortedCircularObjectList<T>.Create(const AOwnership: TADOwnership; const ACapacity: Integer; const AComparer: IADComparer<T>; const ASorter: IADListSorter<T>);
begin
  FDefaultOwnership := AOwnership;
  inherited Create(ACapacity, AComparer, ASorter);
end;

procedure TADSortedCircularObjectList<T>.CreateArray(const ACapacity: Integer);
begin
  FArray := TADObjectArray<T>.Create(FDefaultOwnership, ACapacity);
end;

destructor TADSortedCircularObjectList<T>.Destroy;
begin

  inherited;
end;

function TADSortedCircularObjectList<T>.GetOwnership: TADOwnership;
begin
  Result := TADObjectArray<T>(FArray).Ownership;
end;

procedure TADSortedCircularObjectList<T>.SetOwnership(const AOwnership: TADOwnership);
begin
  TADObjectArray<T>(FArray).Ownership := AOwnership;
end;

{ TADMap<TKey, TValue> }

function TADMap<TKey, TValue>.Add(const AItem: IADKeyValuePair<TKey, TValue>): Integer;
begin
  CheckExpand(1);
  Result := AddActual(AItem);
end;

function TADMap<TKey, TValue>.Add(const AKey: TKey; const AValue: TValue): Integer;
var
  LPair: IADKeyValuePair<TKey, TValue>;
begin
  LPair := TADKeyValuePair<TKey, TValue>.Create(AKey, AValue);
  Result := Add(LPair);
end;

function TADMap<TKey, TValue>.AddActual(const AItem: IADKeyValuePair<TKey, TValue>): Integer;
begin
  // TODO -oDaniel -cTADMapList<TKey, TValue>: Need to add check to ensure Item not already in List. This MIGHT need to be optional!
  Result := GetSortedPosition(AItem.Key);
  if Result = FCount then
    FArray[FCount] := AItem
  else
    FArray.Insert(AItem, Result);

  Inc(FCount);
end;

procedure TADMap<TKey, TValue>.AddItems(const AItems: Array of IADKeyValuePair<TKey, TValue>);
var
  I: Integer;
begin
  CheckExpand(Length(AItems));
  for I := Low(AItems) to High(AItems) do
    AddActual(AItems[I]);
end;

procedure TADMap<TKey, TValue>.AddItems(const AMap: IADCollectionMap<TKey, TValue>);
var
  I: Integer;
begin
  CheckExpand(AMap.Count);
  for I := 0 to AMap.Count - 1 do
    AddActual(AMap.Pairs[I]);
end;

procedure TADMap<TKey, TValue>.CheckCompact(const AAmount: Integer);
var
  LShrinkBy: Integer;
begin
  LShrinkBy := FCompactor.CheckCompact(FArray.Capacity, FCount, AAmount);
  if LShrinkBy > 0 then
    FArray.Capacity := FArray.Capacity - LShrinkBy;
end;

procedure TADMap<TKey, TValue>.CheckExpand(const AAmount: Integer);
var
  LNewCapacity: Integer;
begin
  LNewCapacity := FExpander.CheckExpand(FArray.Capacity, FCount, AAmount);
  if LNewCapacity > 0 then
    FArray.Capacity := FArray.Capacity + LNewCapacity;
end;

procedure TADMap<TKey, TValue>.Clear;
begin
//  FArray.Finalize(0, FCount);
  FArray.Clear;
  FCount := 0;
  FArray.Capacity := FInitialCapacity;
end;

procedure TADMap<TKey, TValue>.Compact;
begin
  FArray.Capacity := FCount;
end;

function TADMap<TKey, TValue>.Contains(const AKey: TKey): Boolean;
var
  LIndex: Integer;
begin
  LIndex := IndexOf(AKey);
  Result := (LIndex > -1);
end;

function TADMap<TKey, TValue>.ContainsAll(const AKeys: array of TKey): Boolean;
var
  I: Integer;
begin
  Result := True; // Optimistic
  for I := Low(AKeys) to High(AKeys) do
    if (not Contains(AKeys[I])) then
    begin
      Result := False;
      Break;
    end;
end;

function TADMap<TKey, TValue>.ContainsAny(const AKeys: array of TKey): Boolean;
var
  I: Integer;
begin
  Result := False; // Pessimistic
  for I := Low(AKeys) to High(AKeys) do
    if Contains(AKeys[I]) then
    begin
      Result := True;
      Break;
    end;
end;

function TADMap<TKey, TValue>.ContainsNone(const AKeys: array of TKey): Boolean;
begin
  Result := (not ContainsAny(AKeys));
end;

constructor TADMap<TKey, TValue>.Create(const AComparer: IADComparer<TKey>; const AInitialCapacity: Integer);
begin
  Create(ADCollectionExpanderDefault, ADCollectionCompactorDefault, AComparer, AInitialCapacity);
end;

constructor TADMap<TKey, TValue>.Create(const AExpander: IADExpander; const AComparer: IADComparer<TKey>; const AInitialCapacity: Integer);
begin
  Create(AExpander, ADCollectionCompactorDefault, AComparer, AInitialCapacity);
end;

constructor TADMap<TKey, TValue>.Create(const ACompactor: IADCompactor; const AComparer: IADComparer<TKey>; const AInitialCapacity: Integer);
begin
  Create(ADCollectionExpanderDefault, ACompactor, AComparer, AInitialCapacity);
end;

constructor TADMap<TKey, TValue>.Create(const AExpander: IADExpander; const ACompactor: IADCompactor; const AComparer: IADComparer<TKey>; const AInitialCapacity: Integer);
begin
  inherited Create;
  FCount := 0;
  FExpander := AExpander;
  FCompactor := ACompactor;
  FComparer := AComparer;
  FSorter := TADMapSorterQuick<TKey, TValue>.Create;
  FInitialCapacity := AInitialCapacity;
  CreateArray(AInitialCapacity);
end;

destructor TADMap<TKey, TValue>.Destroy;
begin

  inherited;
end;

procedure TADMap<TKey, TValue>.CreateArray(const AInitialCapacity: Integer);
begin
  FArray := TADArray<IADKeyValuePair<TKey, TValue>>.Create(AInitialCapacity);
end;

procedure TADMap<TKey, TValue>.Delete(const AIndex: Integer);
begin
  FArray.Delete(AIndex);
  Dec(FCount);
end;

procedure TADMap<TKey, TValue>.DeleteRange(const AFromIndex, ACount: Integer);
var
  I: Integer;
begin
  for I := AFromIndex + ACount - 1 downto AFromIndex do
    Delete(I);
end;

function TADMap<TKey, TValue>.EqualItems(const AList: IADCollectionMap<TKey, TValue>): Boolean;
var
  I: Integer;
begin
  Result := AList.Count = FCount;
  if Result then
    for I := 0 to AList.Count - 1 do
      if (not FComparer.AEqualToB(AList.Pairs[I].Key, FArray[I].Key)) then
      begin
        Result := False;
        Break;
      end;
end;

function TADMap<TKey, TValue>.GetCapacity: Integer;
begin
  Result := FArray.Capacity;
end;

function TADMap<TKey, TValue>.GetCompactor: IADCompactor;
begin
  Result := FCompactor;
end;

function TADMap<TKey, TValue>.GetComparer: IADComparer<TKey>;
begin
  Result := FComparer;
end;

function TADMap<TKey, TValue>.GetCount: Integer;
begin
  Result := FCount;
end;

function TADMap<TKey, TValue>.GetExpander: IADExpander;
begin
  Result := FExpander;
end;

function TADMap<TKey, TValue>.GetInitialCapacity: Integer;
begin
  Result := FInitialCapacity;
end;

function TADMap<TKey, TValue>.GetIsCompact: Boolean;
begin
  Result := FArray.Capacity = FCount;
end;

function TADMap<TKey, TValue>.GetIsEmpty: Boolean;
begin
  Result := (FCount = 0);
end;

function TADMap<TKey, TValue>.GetItem(const AKey: TKey): TValue;
var
  LIndex: Integer;
begin
  LIndex := IndexOf(AKey);
  if LIndex > -1 then
    Result := FArray[LIndex].Value;
end;

function TADMap<TKey, TValue>.GetPair(const AIndex: Integer): IADKeyValuePair<TKey, TValue>;
begin
  Result := FArray[AIndex];
end;

function TADMap<TKey, TValue>.GetSortedPosition(const AKey: TKey): Integer;
var
  LIndex, LLow, LHigh: Integer;
begin
  Result := 0;
  LLow := 0;
  LHigh := FCount - 1;
  if LHigh = -1 then
    Exit;
  if LLow < LHigh then
  begin
    while (LHigh - LLow > 1) do
    begin
      LIndex := (LHigh + LLow) div 2;
      if FComparer.ALessThanOrEqualToB(AKey, FArray[LIndex].Key) then
        LHigh := LIndex
      else
        LLow := LIndex;
    end;
  end;
  if FComparer.ALessThanB(FArray[LHigh].Key, AKey) then
    Result := LHigh + 1
  else if FComparer.ALessThanB(FArray[LLow].Key, AKey) then
    Result := LLow + 1
  else
    Result := LLow;
end;

function TADMap<TKey, TValue>.GetSortedState: TADSortedState;
begin
  Result := ssSorted;
end;

function TADMap<TKey, TValue>.GetSorter: IADMapSorter<TKey, TValue>;
begin
  Result := FSorter;
end;

function TADMap<TKey, TValue>.IndexOf(const AKey: TKey): Integer;
var
  LLow, LHigh, LMid: Integer;
begin
  Result := -1; // Pessimistic
  LLow := 0;
  LHigh := FCount - 1;
  repeat
    LMid := (LLow + LHigh) div 2;
    if FComparer.AEqualToB(FArray[LMid].Key, AKey) then
    begin
      Result := LMid;
      Break;
    end
    else if FComparer.ALessThanB(AKey, FArray[LMid].Key) then
      LHigh := LMid - 1
    else
      LLow := LMid + 1;
  until LHigh < LLow;
end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TADMap<TKey, TValue>.Iterate(const ACallback: TADListMapCallbackAnon<TKey, TValue>; const ADirection: TADIterateDirection = idRight);
  begin
    case ADirection of
      idLeft: IterateBackward(ACallback);
      idRight: IterateForward(ACallback);
      else
        raise EADGenericsIterateDirectionUnknownException.Create('Unhandled Iterate Direction given.');
    end;
  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADMap<TKey, TValue>.Iterate(const ACallback: TADListMapCallbackOfObject<TKey, TValue>; const ADirection: TADIterateDirection);
begin
  case ADirection of
    idLeft: IterateBackward(ACallback);
    idRight: IterateForward(ACallback);
    else
      raise EADGenericsIterateDirectionUnknownException.Create('Unhandled Iterate Direction given.');
  end;
end;

procedure TADMap<TKey, TValue>.Iterate(const ACallback: TADListMapCallbackUnbound<TKey, TValue>; const ADirection: TADIterateDirection);
begin
  case ADirection of
    idLeft: IterateBackward(ACallback);
    idRight: IterateForward(ACallback);
    else
      raise EADGenericsIterateDirectionUnknownException.Create('Unhandled Iterate Direction given.');
  end;
end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TADMap<TKey, TValue>.IterateBackward(const ACallback: TADListMapCallbackAnon<TKey, TValue>);
  var
    I: Integer;
  begin
    for I := FCount - 1 downto 0 do
      ACallback(FArray[I].Key, FArray[I].Value);
  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADMap<TKey, TValue>.IterateBackward(const ACallback: TADListMapCallbackOfObject<TKey, TValue>);
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    ACallback(FArray[I].Key, FArray[I].Value);
end;

procedure TADMap<TKey, TValue>.IterateBackward(const ACallback: TADListMapCallbackUnbound<TKey, TValue>);
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    ACallback(FArray[I].Key, FArray[I].Value);
end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TADMap<TKey, TValue>.IterateForward(const ACallback: TADListMapCallbackAnon<TKey, TValue>);
  var
    I: Integer;
  begin
    for I := 0 to FCount - 1 do
      ACallback(FArray[I].Key, FArray[I].Value);
  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TADMap<TKey, TValue>.IterateForward(const ACallback: TADListMapCallbackOfObject<TKey, TValue>);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    ACallback(FArray[I].Key, FArray[I].Value);
end;

procedure TADMap<TKey, TValue>.IterateForward(const ACallback: TADListMapCallbackUnbound<TKey, TValue>);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    ACallback(FArray[I].Key, FArray[I].Value);
end;

procedure TADMap<TKey, TValue>.Remove(const AKey: TKey);
var
  LIndex: Integer;
begin
  LIndex := IndexOf(AKey);
  if LIndex > -1 then
    Delete(LIndex);
end;

procedure TADMap<TKey, TValue>.RemoveItems(const AKeys: Array of TKey);
var
  I: Integer;
begin
  for I := Low(AKeys) to High(AKeys) do
    Remove(AKeys[I]);
end;

procedure TADMap<TKey, TValue>.SetCapacity(const ACapacity: Integer);
begin
  if ACapacity < FCount then
    raise EADGenericsCapacityLessThanCount.CreateFmt('Given Capacity of %d insufficient for a List containing %d Items.', [ACapacity, FCount])
  else
    FArray.Capacity := ACapacity;
end;

procedure TADMap<TKey, TValue>.SetCompactor(const ACompactor: IADCompactor);
begin
  FCompactor := ACompactor;
  CheckCompact(0);
end;

procedure TADMap<TKey, TValue>.SetComparer(const AComparer: IADComparer<TKey>);
begin
  FComparer := AComparer;
  FSorter.Sort(FArray, AComparer, 0, FCount - 1);
end;

procedure TADMap<TKey, TValue>.SetExpander(const AExpander: IADExpander);
begin
  FExpander := AExpander;
end;

procedure TADMap<TKey, TValue>.SetSorter(const ASorter: IADMapSorter<TKey, TValue>);
begin
  FSorter := ASorter;
end;

end.