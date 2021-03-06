unit MainForm;

interface

uses
   System.AnsiStrings, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
   Vcl.StdCtrls, Math, Menus, StrUtils, System.types,
   ProcessViewer, ShellApi, ActiveX, ComObj, Xml.xmldom,
   Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc,
   Vcl.ComCtrls, Wininet, Dialogs, MMSystem, ShLwApi, Registry, WinSvc,
   Winapi.ShlObj, Vcl.Themes, Winapi.UxTheme,
   Clipbrd, Vcl.Extctrls, VirtualTrees, VirtualTrees.Utils, PngImageList, Vcl.ImgList,
   System.UITypes, uFLDThread, uPrestartThread, uPrecacheThread, uEjectThread, uRegisterThread, uUnregisterThread,
   System.ImageList, Vcl.Buttons, PngSpeedButton, PngImage, PngBitBtn, Syncobjs;

type

   LastUsedIDS = record
      fdCID: AnsiString;
      fdGUID: AnsiString;
      sdCID: AnsiString;
      sdGUID: AnsiString;
   end;
   PData = ^TData;

   TData = record
      FVMImageIndex: Integer;
      FId, FVName, FDDisplayName, SDDisplayName: string;
      FFDImageIndex, FSDImageIndex: Integer;
      Ptype: Byte;
      ModeLoadVM: Byte;
      VMID: string;
      VMName: string;
      VMPath: string;
      ExeParams: string;
      FirstDriveName: AnsiString;
      FirstDriveFound: Boolean;
      FirstDriveBusType: Byte;
      FirstDriveNumber: SmallInt;
      FDMountPointsStr: string;
      FDMountPointsArr: array of string;
      SecondDriveName: AnsiString;
      SecondDriveFound: Boolean;
      SecondDriveBusType: Byte;
      SecondDriveNumber: SmallInt;
      SDMountPointsStr: string;
      SDMountPointsArr: array of string;
      InternalHDD: string;
      CDROMName: string;
      CDROMType: Byte;
      MemorySize: Word;
      AudioCard: Byte;
      RunAs: Byte;
      CPUPriority: Byte;
      luIDS: LastUsedIDS;
      VBCPUVirtualization: Byte;
      UseHostIOCache: Boolean;
   end;

function GetEnvVarValue(const VarName: string): string;
function FindDriveWithVendorProductSize(const drvName: AnsiString): ShortInt;
procedure FindDrives;
function GetDriveSize(const hDrive: THandle): Int64;
function GetDriveVendorAndProductID(const hDrive: THandle): AnsiString;
function GetBusType(const hDrive: THandle): Byte;
function GenGuid: AnsiString;
function GenID: AnsiString;
procedure Replacebks(var ws: string; const len: Integer);
procedure GetVBVersion;
function GetLangTextDef(const IntBaseParam: Integer; const StrParams: array of AnsiString; const DefStr: AnsiString): string;
function GetLangTextFormatDef(const IntBaseParam: Integer; const StrParams: array of AnsiString; const VarRec: array of TVarRec; const DefStr: AnsiString): string;
function CStyleEscapes(const InputText: string): string;
function IsAppNotStartedByAdmin(const ProcessID: THandle): Boolean;
function CheckTokenMembership(TokenHandle: THandle; SidToCheck: PSID; var IsMember: BOOL): BOOL; stdcall; external advapi32;
function CustomMessageBox(const OwnerHandle: THandle; const Msg: string; const Caption: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; DefaultButton: TMsgDlgBtn; const CbText: string = ''): Integer;
function GetStrBusType(const BusType: Byte): string;
function GetIntBusType(const BusType: string): Byte;
function IsAeroEnabled: Boolean;
procedure Wait(dt: DWORD);
function FindFirstVolumeW(lpszVolumeName: PWideChar; cchBufferLength: DWord): THandle; stdcall;
function FindNextVolumeW(hFindVolume: THandle; lpszVolumeName: PWideChar; cchBufferLength: DWORD): BOOL; stdcall;
function FindVolumeClose(hFindVolume: THandle): BOOL; stdcall;
function GetVolumePathNamesForVolumeNameW(lpszVolumeName, lpszVolumePathNames: PWideChar; cchBufferLength: DWORD; var lpcchReturnLength: DWORD): BOOL; stdcall;
procedure SetThemeDependantParams;
procedure ResetLastError;
function ServiceStatus(sService: string = 'VBoxDRV'): TServiceStatus;
function ServiceCreate(const sBinPath: string; sService: string = 'VBoxDRV'; const DisplayName: string = ''): Boolean;
function ServiceStart(sService: string = 'VBoxDRV'): Boolean;
function ServiceStop(sService: string = 'VBoxDRV'): Boolean;
function ServiceDelete(sService: string = 'VBoxDRV'): Boolean;
function SetEnvVariable(Name, Value: string): Boolean;
function ServiceDisplayName(sService: string = 'VBoxDRV'): string;
function GetProcessHandleFromID(ID: DWORD): THandle;
function InstallInf(const PathToInf, HardwareID: string): Smallint;
function UninstallInf(HardwareID: string): Smallint;
function CheckInstalledInf(HardwareID: string): Smallint;

type
   VolumeInfo = record
      Name: array[0..MAX_PATH] of WideChar;
      Path: array[0..MAX_PATH] of WideChar;
      Handle: THandle;
      DriveProp: string;
      FirstDrv: Boolean;
   end;

   _STORAGE_DEVICE_NUMBER = record
      DeviceType: DWORD;
      DeviceNumber: DWORD;
      PartitionNumber: DWORD;
   end;

   STORAGE_DEVICE_NUMBER = _STORAGE_DEVICE_NUMBER;

   _GET_LENGTH_INFORMATION = record
      Length: Int64;
   end;

   TGetLengthInformation = _GET_LENGTH_INFORMATION;
   PDevBroadcastHdr = ^DEV_BROADCAST_HDR;

   DEV_BROADCAST_HDR = packed record
      dbch_size: DWORD;
      dbch_devicetype: DWORD;
      dbch_reserved: DWORD;
   end;

   PDevBroadcastVolume = ^TDevBroadcastVolume;

   TDevBroadcastVolume = packed record
      dbcv_size: DWORD;
      dbcv_devicetype: DWORD;
      dbcv_reserved: DWORD;
      dbcv_unitmask: DWORD;
      dbcv_flags: Word;
   end;

   PDevBroadcastDeviceInterface = ^DEV_BROADCAST_DEVICEINTERFACE;

   DEV_BROADCAST_DEVICEINTERFACE = record
      dbcc_size: DWORD;
      dbcc_devicetype: DWORD;
      dbcc_reserved: DWORD;
      dbcc_classguid: TGUID;
      dbcc_name: array[0..255] of Char;
   end;

type
   TVirtualStringTree = class(VirtualTrees.TVirtualStringTree)
   end;

type
   TfrmMain = class(TForm)
      xmlGen: TXMLDocument;
      xmlVBox: TXMLDocument;
      xmlVBoxCompare: TXMLDocument;
      xmlLanguage: TXMLDocument;
      pmVMs: TPopupMenu;
      mmRefresh: TMenuItem;
      mmOptions: TMenuItem;
      mmHelp: TMenuItem;
      mmNumPlus: TMenuItem;
      mmEsc: TMenuItem;
      mmEnter: TMenuItem;
      mmUp: TMenuItem;
      mmDown: TMenuItem;
      mmMoveDownH: TMenuItem;
      mmMoveUpH: TMenuItem;
      mmDeleteH: TMenuItem;
      mmEditH: TMenuItem;
      mmMoveDown: TMenuItem;
      mmMoveUp: TMenuItem;
      mmDelete: TMenuItem;
      mmEdit: TMenuItem;
      mmAdd: TMenuItem;
      pnlBackground: TPanel;
      vstVMs: TVirtualStringTree;
      pmHeaders: TPopupMenu;
      mmCrt: TMenuItem;
      mmVMName: TMenuItem;
      mmDrive: TMenuItem;
      mmSecondDrive: TMenuItem;
      tmAnimation: TTimer;
      imlVST16: TPngImageList;
      imlVST24: TPngImageList;
      imlVST32: TPngImageList;
      btnAdd: TPngSpeedButton;
      btnDelete: TPngSpeedButton;
      btnEdit: TPngSpeedButton;
      btnExit: TPngSpeedButton;
      btnOptions: TPngSpeedButton;
      btnStart: TPngSpeedButton;
      imlVST_header: TPngImageList;
      mmCloneH: TMenuItem;
      mmClone: TMenuItem;
      mmStartVBM: TMenuItem;
      tmCheckCTRL: TTimer;
      btnManager: TPngSpeedButton;
      pmManagers: TPopupMenu;
      mmVirtualBoxManager: TMenuItem;
      mmQEMUManager: TMenuItem;
      mmEject: TMenuItem;
      imlVST_items: TPngImageList;
      imlBtn24: TPngImageList;
      imlBtn16: TPngImageList;
      imlReg16: TPngImageList;
      imlReg24: TPngImageList;
      TrayIcon: TTrayIcon;
      imlTray: TPngImageList;
      pmTray: TPopupMenu;
      mmExit: TMenuItem;
      mmShowHideMainWindow: TMenuItem;
      mmStart: TMenuItem;
      mmHideTrayIcon: TMenuItem;
      btnShowTrayIcon: TPngSpeedButton;
      tmCloseHint: TTimer;
      imlBtn20: TPngImageList;
      imlVst20: TPngImageList;
      imlReg20: TPngImageList;
      imlVst28: TPngImageList;
      imlBtn32: TPngImageList;
      imlBtn28: TPngImageList;
      procedure btnExitClick(Sender: TObject);
      procedure btnAddClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure btnEditClick(Sender: TObject);
      procedure btnDeleteClick(Sender: TObject);
      procedure MoveUp(Sender: TObject);
      procedure MoveDown(Sender: TObject);
      procedure btnStartClick(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure WindProc(var Message: TMessage);
      procedure FormResize(Sender: TObject);
      procedure pmHeadersPopup(Sender: TObject);
      procedure mmHeadersClick(Sender: TObject);
      procedure mmDownClick(Sender: TObject);
      procedure mmUpClick(Sender: TObject);
      procedure mmEnterClick(Sender: TObject);
      procedure mmEscClick(Sender: TObject);
      procedure mmNumPlusClick(Sender: TObject);
      procedure btnOptionsClick(Sender: TObject);
      procedure mmHelpClick(Sender: TObject);
      procedure mmOptionsClick(Sender: TObject);
      procedure mmRefreshClick(Sender: TObject);
      procedure AcceptFiles(var Msg: TMessage); message WM_DROPFILES;
      procedure vstVMsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
      procedure vstVMsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
      procedure vstVMsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure vstVMsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
      procedure vstVMsBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
      procedure vstVMsHeaderDrawQueryElements(Sender: TVTHeader; var PaintInfo: THeaderPaintInfo; var Elements: THeaderPaintElements);
      procedure vstVMsAdvancedHeaderDraw(Sender: TVTHeader; var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements);
      procedure vstVMsHeaderMouseUp(Sender: TVTHeader; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure WmNclButtonDown(var Msg: TMessage); message WM_NCLBUTTONDOWN;
      procedure WmExitSizeMove(var Msg: TMessage); message WM_EXITSIZEMOVE;
      procedure vstVMsContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
      procedure vstVMsHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
      procedure pnlBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure vstVMsDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
      procedure vstVMsDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
      procedure vstVMsDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
      procedure FormShow(Sender: TObject);
      procedure vstVMsColumnResize(Sender: TVTHeader; Column: TColumnIndex);
      procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
      procedure tmAnimationTimer(Sender: TObject);
      procedure vstVMsBeforeColumnWidthTracking(Sender: TVTHeader; Column: TColumnIndex; Shift: TShiftState);
      procedure vstVMsAfterColumnWidthTracking(Sender: TVTHeader; Column: TColumnIndex);
      procedure vstVMsMeasureItem(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
         var NodeHeight: Integer);
      procedure vstVMsBeforeItemErase(Sender: TBaseVirtualTree;
         TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
         var ItemColor: TColor; var EraseAction: TItemEraseAction);
      procedure vstVMsDrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas;
         Node: PVirtualNode; Column: TColumnIndex; const Text: string;
         const CellRect: TRect; var DefaultDraw: Boolean);
      procedure vstVMsShowScrollBar(Sender: TBaseVirtualTree; Bar: Integer;
         Show: Boolean);
      procedure vstVMsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure mmCloneClick(Sender: TObject);
      procedure StartManagersClick(Sender: TObject);
      procedure tmCheckCTRLTimer(Sender: TObject);
      procedure vstVMsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
         Column: TColumnIndex);
      procedure btnManagerClick(Sender: TObject);
      procedure mmStartManagersClick(Sender: TObject);
      procedure vstVMsDblClick(Sender: TObject);
      procedure mmOpenInEXplorerClick(Sender: TObject);
      procedure mmEjectClick(Sender: TObject);
      procedure pmTrayPopup(Sender: TObject);
      procedure mmShowHideMainWindowClick(Sender: TObject);
      procedure mmHideTrayIconClick(Sender: TObject);
      procedure btnShowTrayIconClick(Sender: TObject);
      procedure tmCloseHintTimer(Sender: TObject);
      procedure TrayIconBalloonClick(Sender: TObject);
      procedure TrayIconMouseDown(Sender: TObject; Button: TMouseButton;
         Shift: TShiftState; X, Y: Integer);
   private
      { Private declarations }
      Hotkey_id: NativeUINT;
      procedure SortAfterColumn(const ColumnIndex: Integer);
      procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
   public
      { Public declarations }
      procedure RealignColumns(const NoRedraw: Boolean = True);
      procedure LoadVMentries(const FileName: string);
      procedure SaveVMentries(const FileName: string);
      function LoadCFG(const FileName: string): Boolean;
      procedure SaveCFG(const FileName: string);
      procedure AppAct(Sender: TObject);
      procedure AppDeact(Sender: TObject);
      procedure ModEnd(Sender: TObject);
      procedure ModBeg(Sender: TObject);
      procedure AppMinimize(Sender: TObject);
      procedure AppRestore(Sender: TObject);
      procedure OpenInternetHelp(const OwnerWindowHandle: THandle; const SiteHelp: array of string);
      function FindCDROMLetter(const CDROMName: AnsiString): AnsiChar;
      procedure AppException(Sender: TObject; E: Exception);
      procedure ChangeCompLang;
      function GetItemIndex: Integer;
      procedure StartFirstDriveAnimation;
      procedure StartSecDriveAnimation;
      procedure StartVMAnimation;
      procedure StopFirstDriveAnimation;
      procedure StopSecDriveAnimation;
      procedure StopVMAnimation;
      procedure HideAutoSustainScrollbars;
      //function LoadIconFromResource(const nIndex: Integer): HIcon;
      procedure SetTrayIcon;
      procedure StopTrayAnimation;
      procedure ShowTray;
      procedure HideTray;
      procedure StartVBNewMachineWizzard;
   end;

type
   TComponentDrive = class(TComponent)
   private
      FWindowHandle: HWND;
      FHandle: Pointer;
      procedure WndProc(var Msg: TMessage);
      procedure DriveRegister;
   protected
      procedure WMDeviceChange(var Msg: TMessage); dynamic;
   public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
   end;

type
   TMessageForm = class(TForm)
   private
      lbMessage: TLabel;
      cbConfirmation: TCheckbox;
      procedure HelpButtonClick(Sender: TObject);
   protected
      procedure CustomKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      function GetFormText: string;
   public
      constructor CreateNew(AOwner: TComponent); reintroduce;
   end;

const
   PNP_VetoTypeUnknown = 0; // Name is unspecified
   {$EXTERNALSYM PNP_VetoTypeUnknown}
   PNP_VetoLegacyDevice = 1; // Name is an Instance Path
   {$EXTERNALSYM PNP_VetoLegacyDevice}
   PNP_VetoPendingClose = 2; // Name is an Instance Path
   {$EXTERNALSYM PNP_VetoPendingClose}
   PNP_VetoWindowsApp = 3; // Name is a Module
   {$EXTERNALSYM PNP_VetoWindowsApp}
   PNP_VetoWindowsService = 4; // Name is a Service
   {$EXTERNALSYM PNP_VetoWindowsService}
   PNP_VetoOutstandingOpen = 5; // Name is an Instance Path
   {$EXTERNALSYM PNP_VetoOutstandingOpen}
   PNP_VetoDevice = 6; // Name is an Instance Path
   {$EXTERNALSYM PNP_VetoDevice}
   PNP_VetoDriver = 7; // Name is a Driver Service Name
   {$EXTERNALSYM PNP_VetoDriver}
   PNP_VetoIllegalDeviceRequest = 8; // Name is an Instance Path
   {$EXTERNALSYM PNP_VetoIllegalDeviceRequest}
   PNP_VetoInsufficientPower = 9; // Name is unspecified
   {$EXTERNALSYM PNP_VetoInsufficientPower}
   PNP_VetoNonDisableable = 10; // Name is an Instance Path
   {$EXTERNALSYM PNP_VetoNonDisableable}
   PNP_VetoLegacyDriver = 11; // Name is a Service
   {$EXTERNALSYM PNP_VetoLegacyDriver}
   PNP_VetoInsufficientRights = 12; // Name is unspecified
   {$EXTERNALSYM PNP_VetoInsufficientRights}
   CR_SUCCESS = $00000000;
   {$EXTERNALSYM CR_SUCCESS}
   CR_DEFAULT = $00000001;
   {$EXTERNALSYM CR_DEFAULT}
   CR_OUT_OF_MEMORY = $00000002;
   {$EXTERNALSYM CR_OUT_OF_MEMORY}
   CR_INVALID_POINTER = $00000003;
   {$EXTERNALSYM CR_INVALID_POINTER}
   CR_INVALID_FLAG = $00000004;
   {$EXTERNALSYM CR_INVALID_FLAG}
   CR_INVALID_DEVNODE = $00000005;
   {$EXTERNALSYM CR_INVALID_DEVNODE}
   CR_INVALID_DEVINST = CR_INVALID_DEVNODE;
   {$EXTERNALSYM CR_INVALID_DEVINST}
   CR_INVALID_RES_DES = $00000006;
   {$EXTERNALSYM CR_INVALID_RES_DES}
   CR_INVALID_LOG_CONF = $00000007;
   {$EXTERNALSYM CR_INVALID_LOG_CONF}
   CR_INVALID_ARBITRATOR = $00000008;
   {$EXTERNALSYM CR_INVALID_ARBITRATOR}
   CR_INVALID_NODELIST = $00000009;
   {$EXTERNALSYM CR_INVALID_NODELIST}
   CR_DEVNODE_HAS_REQS = $0000000A;
   {$EXTERNALSYM CR_DEVNODE_HAS_REQS}
   CR_DEVINST_HAS_REQS = CR_DEVNODE_HAS_REQS;
   {$EXTERNALSYM CR_DEVINST_HAS_REQS}
   CR_INVALID_RESOURCEID = $0000000B;
   {$EXTERNALSYM CR_INVALID_RESOURCEID}
   CR_DLVXD_NOT_FOUND = $0000000C; // WIN 95 ONLY
   {$EXTERNALSYM CR_DLVXD_NOT_FOUND}
   CR_NO_SUCH_DEVNODE = $0000000D;
   {$EXTERNALSYM CR_NO_SUCH_DEVNODE}
   CR_NO_SUCH_DEVINST = CR_NO_SUCH_DEVNODE;
   {$EXTERNALSYM CR_NO_SUCH_DEVINST}
   CR_NO_MORE_LOG_CONF = $0000000E;
   {$EXTERNALSYM CR_NO_MORE_LOG_CONF}
   CR_NO_MORE_RES_DES = $0000000F;
   {$EXTERNALSYM CR_NO_MORE_RES_DES}
   CR_ALREADY_SUCH_DEVNODE = $00000010;
   {$EXTERNALSYM CR_ALREADY_SUCH_DEVNODE}
   CR_ALREADY_SUCH_DEVINST = CR_ALREADY_SUCH_DEVNODE;
   {$EXTERNALSYM CR_ALREADY_SUCH_DEVINST}
   CR_INVALID_RANGE_LIST = $00000011;
   {$EXTERNALSYM CR_INVALID_RANGE_LIST}
   CR_INVALID_RANGE = $00000012;
   {$EXTERNALSYM CR_INVALID_RANGE}
   CR_FAILURE = $00000013;
   {$EXTERNALSYM CR_FAILURE}
   CR_NO_SUCH_LOGICAL_DEV = $00000014;
   {$EXTERNALSYM CR_NO_SUCH_LOGICAL_DEV}
   CR_CREATE_BLOCKED = $00000015;
   {$EXTERNALSYM CR_CREATE_BLOCKED}
   CR_NOT_SYSTEM_VM = $00000016; // WIN 95 ONLY
   {$EXTERNALSYM CR_NOT_SYSTEM_VM}
   CR_REMOVE_VETOED = $00000017;
   {$EXTERNALSYM CR_REMOVE_VETOED}
   CR_APM_VETOED = $00000018;
   {$EXTERNALSYM CR_APM_VETOED}
   CR_INVALID_LOAD_TYPE = $00000019;
   {$EXTERNALSYM CR_INVALID_LOAD_TYPE}
   CR_BUFFER_SMALL = $0000001A;
   {$EXTERNALSYM CR_BUFFER_SMALL}
   CR_NO_ARBITRATOR = $0000001B;
   {$EXTERNALSYM CR_NO_ARBITRATOR}
   CR_NO_REGISTRY_HANDLE = $0000001C;
   {$EXTERNALSYM CR_NO_REGISTRY_HANDLE}
   CR_REGISTRY_ERROR = $0000001D;
   {$EXTERNALSYM CR_REGISTRY_ERROR}
   CR_INVALID_DEVICE_ID = $0000001E;
   {$EXTERNALSYM CR_INVALID_DEVICE_ID}
   CR_INVALID_DATA = $0000001F;
   {$EXTERNALSYM CR_INVALID_DATA}
   CR_INVALID_API = $00000020;
   {$EXTERNALSYM CR_INVALID_API}
   CR_DEVLOADER_NOT_READY = $00000021;
   {$EXTERNALSYM CR_DEVLOADER_NOT_READY}
   CR_NEED_RESTART = $00000022;
   {$EXTERNALSYM CR_NEED_RESTART}
   CR_NO_MORE_HW_PROFILES = $00000023;
   {$EXTERNALSYM CR_NO_MORE_HW_PROFILES}
   CR_DEVICE_NOT_THERE = $00000024;
   {$EXTERNALSYM CR_DEVICE_NOT_THERE}
   CR_NO_SUCH_VALUE = $00000025;
   {$EXTERNALSYM CR_NO_SUCH_VALUE}
   CR_WRONG_TYPE = $00000026;
   {$EXTERNALSYM CR_WRONG_TYPE}
   CR_INVALID_PRIORITY = $00000027;
   {$EXTERNALSYM CR_INVALID_PRIORITY}
   CR_NOT_DISABLEABLE = $00000028;
   {$EXTERNALSYM CR_NOT_DISABLEABLE}
   CR_FREE_RESOURCES = $00000029;
   {$EXTERNALSYM CR_FREE_RESOURCES}
   CR_QUERY_VETOED = $0000002A;
   {$EXTERNALSYM CR_QUERY_VETOED}
   CR_CANT_SHARE_IRQ = $0000002B;
   {$EXTERNALSYM CR_CANT_SHARE_IRQ}
   CR_NO_DEPENDENT = $0000002C;
   {$EXTERNALSYM CR_NO_DEPENDENT}
   CR_SAME_RESOURCES = $0000002D;
   {$EXTERNALSYM CR_SAME_RESOURCES}
   CR_NO_SUCH_REGISTRY_KEY = $0000002E;
   {$EXTERNALSYM CR_NO_SUCH_REGISTRY_KEY}
   CR_INVALID_MACHINENAME = $0000002F; // NT ONLY
   {$EXTERNALSYM CR_INVALID_MACHINENAME}
   CR_REMOTE_COMM_FAILURE = $00000030; // NT ONLY
   {$EXTERNALSYM CR_REMOTE_COMM_FAILURE}
   CR_MACHINE_UNAVAILABLE = $00000031; // NT ONLY
   {$EXTERNALSYM CR_MACHINE_UNAVAILABLE}
   CR_NO_CM_SERVICES = $00000032; // NT ONLY
   {$EXTERNALSYM CR_NO_CM_SERVICES}
   CR_ACCESS_DENIED = $00000033; // NT ONLY
   {$EXTERNALSYM CR_ACCESS_DENIED}
   CR_CALL_NOT_IMPLEMENTED = $00000034;
   {$EXTERNALSYM CR_CALL_NOT_IMPLEMENTED}
   CR_INVALID_PROPERTY = $00000035;
   {$EXTERNALSYM CR_INVALID_PROPERTY}
   CR_DEVICE_INTERFACE_ACTIVE = $00000036;
   {$EXTERNALSYM CR_DEVICE_INTERFACE_ACTIVE}
   CR_NO_SUCH_DEVICE_INTERFACE = $00000037;
   {$EXTERNALSYM CR_NO_SUCH_DEVICE_INTERFACE}
   CR_INVALID_REFERENCE_STRING = $00000038;
   {$EXTERNALSYM CR_INVALID_REFERENCE_STRING}
   CR_INVALID_CONFLICT_LIST = $00000039;
   {$EXTERNALSYM CR_INVALID_CONFLICT_LIST}
   CR_INVALID_INDEX = $0000003A;
   {$EXTERNALSYM CR_INVALID_INDEX}
   CR_INVALID_STRUCTURE_SIZE = $0000003B;
   {$EXTERNALSYM CR_INVALID_STRUCTURE_SIZE}
   NUM_CR_RESULTS = $0000003C;
   {$EXTERNALSYM NUM_CR_RESULTS}
   ANYSIZE_ARRAY = 1;
   {$EXTERNALSYM ANYSIZE_ARRAY}
   DIGCF_DEFAULT = $00000001; // only valid with DIGCF_DEVICEINTERFACE
   {$EXTERNALSYM DIGCF_DEFAULT}
   DIGCF_PRESENT = $00000002;
   {$EXTERNALSYM DIGCF_PRESENT}
   DIGCF_ALLCLASSES = $00000004;
   {$EXTERNALSYM DIGCF_ALLCLASSES}
   DIGCF_PROFILE = $00000008;
   {$EXTERNALSYM DIGCF_PROFILE}
   DIGCF_DEVICEINTERFACE = $00000010;
   {$EXTERNALSYM DIGCF_DEVICEINTERFACE}
   SP_MAX_MACHINENAME_LENGTH = MAX_PATH + 3;
   {$EXTERNALSYM SP_MAX_MACHINENAME_LENGTH}
   DIF_REMOVE = $00000005;
   DI_REMOVEDEVICE_GLOBAL = $00000001;

type
   LPCTCH = LPSTR;
   LPTCH = LPSTR;
   {$EXTERNALSYM LPTCH}
   PTCH = LPSTR;
   {$EXTERNALSYM PTCH}
   PTSTR = LPSTR;
   {$EXTERNALSYM PTSTR}
   LPTSTR = LPSTR;
   {$EXTERNALSYM LPTSTR}
   PCTSTR = LPCSTR;
   {$EXTERNALSYM PCTSTR}
   LPCTSTR = LPCSTR;
   {$EXTERNALSYM LPCTSTR}
   PPNP_VETO_TYPE = ^PNP_VETO_TYPE;
   {$EXTERNALSYM PPNP_VETO_TYPE}
   PNP_VETO_TYPE = DWORD;
   {$EXTERNALSYM PNP_VETO_TYPE}
   DEVINST = DWORD;
   {$EXTERNALSYM DEVINST}
   RETURN_TYPE = DWORD;
   {$EXTERNALSYM RETURN_TYPE}
   CONFIGRET = RETURN_TYPE;
   {$EXTERNALSYM CONFIGRET}
   HDEVINFO = Pointer;
   {$EXTERNALSYM HDEVINFO}
   PSPDeviceInterfaceDetailDataW = ^TSPDeviceInterfaceDetailDataW;
   SP_DEVICE_INTERFACE_DETAIL_DATA_W = packed record
      cbSize: DWORD;
      DevicePath: array[0..ANYSIZE_ARRAY - 1] of WideChar;
   end;
   {$EXTERNALSYM SP_DEVICE_INTERFACE_DETAIL_DATA_W}
   TSPDeviceInterfaceDetailDataW = SP_DEVICE_INTERFACE_DETAIL_DATA_W;
   PSPDeviceInterfaceDetailData = PSPDeviceInterfaceDetailDataW;
   PSPDeviceInterfaceData = ^TSPDeviceInterfaceData;
   SP_DEVICE_INTERFACE_DATA = packed record
      cbSize: UINT;
      InterfaceClassGuid: TGUID;
      Flags: UINT;
      Reserved: IntPtr;
   end;
   {$EXTERNALSYM SP_DEVICE_INTERFACE_DATA}
   TSPDeviceInterfaceData = SP_DEVICE_INTERFACE_DATA;
   PSPDevInfoData = ^TSPDevInfoData;
   SP_DEVINFO_DATA = packed record
      cbSize: UINT;
      ClassGuid: TGUID;
      DevInst: UINT; // DEVINST handle
      Reserved: IntPtr;
   end;
   {$EXTERNALSYM SP_DEVINFO_DATA}
   TSPDevInfoData = SP_DEVINFO_DATA;
   TSPDeviceInterfaceDetailData = TSPDeviceInterfaceDetailDataW;
   DI_FUNCTION = UINT; // Function type for device installer
   SP_DEVINFO_LIST_DETAIL_DATA_W = packed record
      cbSize: DWORD;
      ClassGuid: TGUID;
      RemoteMachineHandle: THandle;
      RemoteMachineName: array[0..SP_MAX_MACHINENAME_LENGTH - 1] of WideChar;
   end;
   TSPDevInfoListDetailDataW = SP_DEVINFO_LIST_DETAIL_DATA_W;
   //   TSPDevInfoListDetailData = TSPDevInfoListDetailDataW;
   SP_DEVINFO_LIST_DETAIL_DATA_A = packed record
      cbSize: DWORD;
      ClassGuid: TGUID;
      RemoteMachineHandle: THandle;
      RemoteMachineName: array[0..SP_MAX_MACHINENAME_LENGTH - 1] of AnsiChar;
   end;
   TSPDevInfoListDetailDataA = SP_DEVINFO_LIST_DETAIL_DATA_A;
   TSPDevInfoListDetailData = TSPDevInfoListDetailDataW;
   HMACHINE = THandle;
   {$EXTERNALSYM HMACHINE}
   PSPClassInstallHeader = ^TSPClassInstallHeader;
   SP_CLASSINSTALL_HEADER = packed record
      cbSize: DWORD;
      InstallFunction: DI_FUNCTION;
   end;
   {$EXTERNALSYM SP_CLASSINSTALL_HEADER}
   TSPClassInstallHeader = SP_CLASSINSTALL_HEADER;
   PSPRemoveDeviceParams = ^TSPRemoveDeviceParams;
   SP_REMOVEDEVICE_PARAMS = packed record
      ClassInstallHeader: TSPClassInstallHeader;
      Scope: DWORD;
      HwProfile: DWORD;
   end;
   {$EXTERNALSYM SP_REMOVEDEVICE_PARAMS}
   TSPFileCallbackW = function(Context: Pointer; Notification: UINT;
      Param1, Param2: UINT_PTR): UINT; stdcall;
   TSPRemoveDeviceParams = SP_REMOVEDEVICE_PARAMS;
   PSPDevInstallParamsW = ^TSPDevInstallParamsW;
   TSPFileCallback = TSPFileCallbackW;
   HSPFILEQ = Pointer;
   SP_DEVINSTALL_PARAMS_W = packed record
      cbSize: DWORD;
      Flags: DWORD;
      FlagsEx: DWORD;
      hwndParent: HWND;
      InstallMsgHandler: TSPFileCallback;
      InstallMsgHandlerContext: Pointer;
      FileQueue: HSPFILEQ;
      ClassInstallReserved: ULONG_PTR;
      Reserved: DWORD;
      DriverPath: array[0..MAX_PATH - 1] of WideChar;
   end;
   TSPDevInstallParamsW = SP_DEVINSTALL_PARAMS_W;
   PSPDevInstallParams = PSPDevInstallParamsW;

function GetDrivesDevInstByDeviceNumber(DeviceNumber: Integer): DEVINST;
function SetupDiGetClassDevs(ClassGuid: PGUID; const Enumerator: PChar; hwndParent: HWND; Flags: DWORD): HDEVINFO; stdcall; external 'Setupapi.dll' name 'SetupDiGetClassDevsW';
function SetupDiGetDeviceRegistryProperty(DeviceInfoSet: HDEVINFO; const DeviceInfoData: TSPDevInfoData; Property_: DWORD; var PropertyRegDataType: DWORD; PropertyBuffer: PBYTE; PropertyBufferSize: DWORD; var RequiredSize: DWORD): LongBool; stdcall; external 'Setupapi.dll' name 'SetupDiGetDeviceRegistryPropertyW';
function SetupDiDestroyDeviceInfoList(DeviceInfoSet: HDEVINFO): LongBool; stdcall; external 'Setupapi.dll' name 'SetupDiDestroyDeviceInfoList';
function SetupDiGetINFClass(const InfName: PChar; var ClassGuid: TGUID; ClassName: PChar; ClassNameSize: DWORD; RequiredSize: PDWORD): LongBool; stdcall; external 'Setupapi.dll' name 'SetupDiGetINFClassW';
function SetupDiCreateDeviceInfoList(ClassGuid: PGUID; hwndParent: HWND): HDEVINFO; stdcall; external 'Setupapi.dll' name 'SetupDiCreateDeviceInfoList';
function SetupDiCreateDeviceInfo(DeviceInfoSet: HDEVINFO; const DeviceName: PChar; var ClassGuid: TGUID; const DeviceDescription: PChar; hwndParent: HWND; CreationFlags: DWORD; DeviceInfoData: PSPDevInfoData): LongBool; stdcall; external 'Setupapi.dll' name 'SetupDiCreateDeviceInfoW';
function SetupDiSetDeviceRegistryProperty(DeviceInfoSet: HDEVINFO; var DeviceInfoData: TSPDevInfoData; Property_: DWORD; const PropertyBuffer: PBYTE; PropertyBufferSize: DWORD): LongBool; stdcall; external 'Setupapi.dll' name 'SetupDiSetDeviceRegistryPropertyW';
function SetupDiCallClassInstaller(InstallFunction: DI_FUNCTION; DeviceInfoSet: HDEVINFO; DeviceInfoData: PSPDevInfoData): Bool; stdcall; external 'Setupapi.dll' name 'SetupDiCallClassInstaller';
function UpdateDriverForPlugAndPlayDevices(hwndParent: THandle; HardwareId: PChar; FullInfPath: PChar; InstallFlags: DWORD; bRebootRequired: PBOOL): BOOL; stdcall; external 'newdev.dll' name 'UpdateDriverForPlugAndPlayDevicesW';
//function SetupDiClassNameFromGuid(ClassGuid: PGUID; ClassName: PChar; ClassNameSize: DWORD; RequiredSize: PDWORD): BOOL; stdcall; external 'Setupapi.dll' name 'SetupDiClassNameFromGuidW';
function SetupDiGetClassDevsEx(ClassGuid: PGUID; const Enumerator: PTSTR; hwndParent: HWND; Flags: DWORD; DeviceInfoSet: HDEVINFO; const MachineName: PTSTR; Reserved: Pointer): HDEVINFO; stdcall; external 'Setupapi.dll' name 'SetupDiGetClassDevsExW';
function SetupDiEnumDeviceInfo(DeviceInfoSet: HDEVINFO; MemberIndex: DWORD; var DeviceInfoData: TSPDevInfoData): BOOL; stdcall; external 'Setupapi.dll' name 'SetupDiEnumDeviceInfo';
//function SetupDiOpenDevRegKey(DeviceInfoSet: HDEVINFO; var DeviceInfoData: TSPDevInfoData; Scope, HwProfile, KeyType: DWORD; samDesired: REGSAM): HKEY; stdcall; external 'Setupapi.dll' name 'SetupDiOpenDevRegKey';
function SetupDiGetDeviceInterfaceDetail(DeviceInfoSet: HDEVINFO; DeviceInterfaceData: PSPDeviceInterfaceData; DeviceInterfaceDetailData: PSPDeviceInterfaceDetailData; DeviceInterfaceDetailDataSize: DWORD; var RequiredSize: DWORD; Device: PSPDevInfoData): BOOL; stdcall; external 'Setupapi.dll' name 'SetupDiGetDeviceInterfaceDetailW';
function CM_Request_Device_Eject(dnDevInst: DEVINST; pVetoType: PPNP_VETO_TYPE; pszVetoName: PTSTR; ulNameLength: ULONG; ulFlags: ULONG): CONFIGRET; stdcall; external 'Setupapi.dll' name 'CM_Request_Device_EjectW';
function SetupDiEnumDeviceInterfaces(DeviceInfoSet: HDEVINFO; DeviceInfoData: PSPDevInfoData; const InterfaceClassGuid: TGUID; MemberIndex: DWORD; var DeviceInterfaceData: TSPDeviceInterfaceData): BOOL; stdcall; external 'Setupapi.dll' name 'SetupDiEnumDeviceInterfaces';
function CM_Get_Parent(var dnDevInstParent: DEVINST; dnDevInst: DEVINST; ulFlags: ULONG): CONFIGRET; stdcall; external 'Setupapi.dll' name 'CM_Get_Parent';
function SetupDiClassGuidsFromNameEx(const ClassName: PChar; ClassGuidList: PGUID; ClassGuidListSize: DWORD; var RequiredSize: DWORD; const MachineName: PChar; Reserved: Pointer): LongBool; stdcall; external 'Setupapi.dll' name 'SetupDiClassGuidsFromNameExW';
function SetupDiGetDeviceInfoListDetail(DeviceInfoSet: HDEVINFO; var DeviceInfoSetDetailData: TSPDevInfoListDetailData): BOOL; stdcall; external 'Setupapi.dll' name 'SetupDiGetDeviceInfoListDetailW';
function CM_Get_Device_ID(dnDevInst: DEVINST; Buffer: PChar; BufferLen: ULONG; ulFlags: ULONG): CONFIGRET; stdcall; external 'Setupapi.dll' name 'CM_Get_Device_IDW';
function SetupDiSetClassInstallParams(DeviceInfoSet: HDEVINFO; DeviceInfoData: PSPDevInfoData; ClassInstallParams: PSPClassInstallHeader; ClassInstallParamsSize: DWORD): BOOL; stdcall; external 'Setupapi.dll' name 'SetupDiSetClassInstallParamsW';

const
   BaseVersion = ' 1.7';
   {$IFDEF WIN32}
   appVersion = BaseVersion + ' x86';
   {$ENDIF}
   {$IFDEF WIN64}
   appVersion = BaseVersion + ' x64';
   {$ENDIF}
   MAX_IDE_DRIVES = 16;
   METHOD_BUFFERED = 0;
   FILE_ANY_ACCESS = 0;
   FILE_DEVICE_FILE_SYSTEM = $00000009;
   FILE_DEVICE_MASS_STORAGE = $0000002D;
   IOCTL_STORAGE_BASE = FILE_DEVICE_MASS_STORAGE;
   IOCTL_STORAGE_GET_DEVICE_NUMBER = ((IOCTL_STORAGE_BASE shl 16) or (FILE_ANY_ACCESS shl 14) or ($0420 shl 2) or METHOD_BUFFERED);
   FILE_READ_ACCESS = $00000001;
   IOCTL_DISK_BASE = $00000007;
   IOCTL_DISK_GET_LENGTH_INFO = ((IOCTL_DISK_BASE shl 16) or FILE_READ_ACCESS shl 14) or ($0017 shl 2) or METHOD_BUFFERED; { CTL_CODE }
   IOCTL_STORAGE_QUERY_PROPERTY = (IOCTL_STORAGE_BASE shl 16) or (FILE_ANY_ACCESS shl 14) or ($0500 shl 2) or (METHOD_BUFFERED);
   IOCTL_DISK_UPDATE_PROPERTIES = ((IOCTL_DISK_BASE shl 16) or (FILE_ANY_ACCESS shl 14) or ($0050 shl 2) or METHOD_BUFFERED);
   defvmdk: array[1..6] of AnsiString = ('# Disk DescriptorFile'#10'version=1'#10'CID=', #10'parentCID=ffffffff'#10'createType="fullDevice"'#10#10'# Extent description'#10'RW ', ' FLAT "\\.\PhysicalDrive', '" 0'#10#10'# The disk Data Base'#10'#DDB'#10#10'ddb.virtualHWVersion = "4"'#10'ddb.adapterType="ide"'#10'ddb.geometry.cylinders="', '"'#10'ddb.geometry.heads="16"'#10'ddb.geometry.sectors="63"'#10'ddb.uuid.image="', '"'#10'ddb.uuid.parent="00000000-0000-0000-0000-000000000000"'#10'ddb.uuid.modification="00000000-0000-0000-0000-000000000000"'#10'ddb.uuid.parentmodification="00000000-0000-0000-0000-000000000000"'#10);
   DefSiteHelp: array[1..2] of string = ('http://reboot.pro/topic/18736-virtual-machine-usb-boot/', 'http://reboot.pro/index.php?showtopic=18736');
   GUID_DEVINTERFACE_USB_DEVICE: TGUID = '{A5DCBF10-6530-11D2-901F-00C04FB951ED}';
   GUID_DEVINTERFACE_DISK: TGUID = '{53F56307-B6BF-11D0-94F2-00A0C91EFB8B}';
   DBT_DEVICEARRIVAL = $8000; // system detected a new device
   DBT_DEVICEREMOVECOMPLETE = $8004; // device is gone
   DBT_DEVTYP_DEVICEINTERFACE = $00000005; // device interface class
   DBT_DEVTYP_VOLUME = $00000002; // volume interface class

var
   frmMain: TfrmMain;
   fOldTWndMethod: TWndMethod;
   VMentriesFile, CfgFile, psEntries, psCFG, ExeVBPath, ExeQPath, ExeQManager, ExeVBPathToo: string;
   isVBPortable: Boolean = False;
   isVBInstalledToo: Boolean = False;
   QEMUDefaultParameters: string = '-name "USB Boot Test" -boot c -m 512 -soundhw sb16';
   LastError: Int64 = -1;
   OSDrive: Byte;
   envProgramFiles: string = '';
   envProgramFilesx86: string = '';
   StartRegToo: Boolean = False;
   MainLeft, MainTop, MainHeight, MainWidth, IntLeft, IntTop, IntHeight, IntWidth: Integer;
   DriveMessageShowed: Boolean = False;
   StartMessageShowed: Boolean = False;
   AddSecondDrive: Boolean = False;
   LockVolumes: Boolean = True;
   LastSelected: Integer = 0;
   UpdateVM: Byte = 0;
   isInstalledVersion: Boolean;
   useLoadedFromInstalled: Boolean = True;
   Randomized: Boolean = False;
   VolumesInfo: array of VolumeInfo;
   MainActivated: Boolean;
   VBVMWasClosed: TTime;
   FlushWaitTime: Integer = 500;
   DefaultVMType: Byte = 0;
   RemoveDrive: Boolean = False;
   WaitForVBSVC: Boolean = True;
   VBSVC2x: Boolean = True;
   VBWinClass: string = 'QWidget';
   DriveDetect: TComponentDrive;
   FindDrivesScheduled: Boolean;
   ListOnlyUSBDrives: Boolean = False;
   CFGFoundAndLoaded: Boolean = False;
   AutomaticFont: Boolean = True;
   FontName: AnsiString;
   FontSize: Word;
   FontBold, FontItalic, FontUnderline, FontStrikeOut: Boolean;
   FontColor: TColor;
   FontScript: Word;
   DefaultFontName: AnsiString;
   DefaultFontSize: Word;
   DefaultFontBold, DefaultFontItalic, DefaultFontUnderline, DefaultFontStrikeOut: Boolean;
   DefaultFontColor: TColor;
   DefaultFontScript: Word;
   EscapeKeyClosesMain: Boolean = True;
   DriveToAdd: Integer = -1;
   idxInterface: Integer = 1;
   idxLanguage: Integer = 0;
   idxMain: Integer = 1;
   idxAddEdit: Integer = 2;
   idxOptions: Integer = 3;
   idxMessages: Integer = 4;
   LngFolder: string;
   CurrLanguageFile: string = 'ENGLISH';
   TryAgain: Boolean = False;
   ColumnResized: Boolean = False;
   ConfirmationDeleteShow: Boolean = True;
   DarkenBckColor, BrightenBckColor: TColor;
   AlreadyRuned: Boolean = False;
   CustomMessageTop: Integer = -10000;
   CustomMessageHorzCenter: Integer = -10000;
   CustomMessageBottom: Integer = -10000;
   DlgOffsPos: Integer = 5;
   ShowEventLog: Boolean = True;
   isBusyStartVM: Boolean = False;
   IsBusyManager: Boolean = False;
   IsBusyEjecting: Boolean = False;
   isBusyClosing: Boolean = False;
   DoNotUnregister: Boolean = False;
   FocusFirstDrive: Boolean = False;
   FocusSecDrive: Boolean = False;
   EditModalResult: Integer = 0;
   CurSelNode: Cardinal;
   AnimationStartIndex: Integer = 9;
   AnimationEndIndex: Integer = 53;
   AnimTrayStartCopyIndex: Integer = 4;
   VMAnimImageIndex: Integer = 9;
   FirstDriveAnimImageIndex: Integer = 9;
   SecDriveAnimImageIndex: Integer = 9;
   ShowVMAnim: Boolean = False;
   ShowFirstDriveAnim: Boolean = False;
   ShowSecDriveAnim: Boolean = False;
   FLDThread: TFLDThread = nil;
   FPSThread: TPrestartThread = nil;
   FPCThread: TPrecacheThread = nil;
   FEjectThread: TEjectThread = nil;
   FRegThread: TRegisterThread = nil;
   FUnregThread: TUnregisterThread = nil;
   PrecacheVBFiles: Boolean = False;
   PrestartVBExeFiles: Boolean = False;
   FLDIndStart: SmallInt = 0;
   FDLSkipTo: SmallInt = 0;
   FLDAreaProblem: Smallint;
   FLDFailedInd: SmallInt;
   FLDJobDone: Boolean = True;
   FPSJobDone: Boolean = True;
   FPCJobDone: Boolean = True;
   FEjectJobDone: Boolean = True;
   FRegJobDone: Boolean = True;
   FUnregJobDone: Boolean = True;
   StartSvcToo: Boolean = False;
   DoColumnShift: Boolean = False;
   DoFDThread: Boolean;
   LastExceptionStr: string = '';
   VertScrollBarVisible: Boolean = False;
   HorzScrollBarVisible: Boolean = False;
   DoNothingOnScrollBarShow: Boolean = False;
   DisableLockAndDismount: Boolean = False;
   ColWereAligned: Boolean = True;
   PathsToOpen: array of string;
   HalfSpaceCharVST: Char = #8198;
   HalfSpaceCharCMB: Char = #8198;
   HalfSpaceCharMSG: Char = #8198;
   FIsAeroEnabled: Boolean = True;
   PrestartVBFilesAgain: Boolean = False;
   svcThrProcessInfo: TProcessInformation;
   HideConsoleWindow: Boolean = True;
   EjectResult: Boolean = False;
   FDevInstParent: MainForm.DEVINST;
   VBOX_USER_HOME: string;
   LoadNetPortable: Boolean = False;
   LoadUSBPortable: Boolean = False;
   strRegErrMsg: string = '';
   ExeVBPathTemp: string = '';
   LoadNetPortableTemp: Boolean = False;
   LoadUSBPortableTemp: Boolean = False;
   useLoadedFromInstalledTemp: Boolean = True;
   ChangeFromTempToReal: Boolean = False;
   ShowTrayIcon: Boolean = False;
   ReallyClose: Boolean = False;
   StartKeyComb: TShortcut = Ord('V') + scCtrl + scShift;
   isOnModal: Boolean = False;
   VMisOff: Boolean = True;
   SystemIconSize: Integer = 16;
   SnapResize: Integer = 10;
   PreviousDPI: Integer = 96;
   fDPI: Single = 1;
   mEvent: TEvent;
   NumberOfProcessors: Cardinal;
   EmulationBusType: Byte = 1;

   IconIDs: array[TMsgDlgType] of PChar = (
      IDI_EXCLAMATION,
      IDI_HAND,
      IDI_ASTERISK,
      IDI_QUESTION,
      nil
      );
   ButtonNames: array[TMsgDlgBtn] of string = (
      '&Yes',
      '&No',
      '&OK',
      '&Cancel',
      '&Abort',
      '&Retry',
      '&Ignore',
      '&All',
      '&Close All',
      '&Choose',
      '&Help',
      '&Close'
      );
   ModalResults: array[TMsgDlgBtn] of Integer = (
      mrYes,
      mrNo,
      mrOk,
      mrCancel,
      mrAbort,
      mrRetry,
      mrIgnore,
      mrAll,
      mrNoToAll,
      mrYesToAll,
      mrHelp,
      mrClose
      );

   cbConfirmationSt: Boolean = False;

implementation

uses AddEdit, Options;

{$R *.dfm}

function FindFirstVolumeW; external kernel32 name 'FindFirstVolumeW';
function FindNextVolumeW; external kernel32 name 'FindNextVolumeW';
function FindVolumeClose; external kernel32 name 'FindVolumeClose';
function GetVolumePathNamesForVolumeNameW; external kernel32 name 'GetVolumePathNamesForVolumeNameW';

procedure ResetLastError;
begin
   SetLastError(0);
   MainForm.LastError := -1;
   LastExceptionStr := '';
end;

procedure ShortCutToHotKey(HotKey: TShortCut; var Key: Word; var Modifiers: Uint);
var
   Shift: TShiftState;
begin
   ShortCutToKey(HotKey, Key, Shift);
   Modifiers := 0;
   if (ssShift in Shift) then
      Modifiers := Modifiers or MOD_SHIFT;
   if (ssAlt in Shift) then
      Modifiers := Modifiers or MOD_ALT;
   if (ssCtrl in Shift) then
      Modifiers := Modifiers or MOD_CONTROL;
end;

procedure TfrmMain.OpenInternetHelp(const OwnerWindowHandle: THandle; const SiteHelp: array of string);
const
   INTERNET_CONNECTION_MODEM = 1;
   INTERNET_CONNECTION_LAN = 2;
   INTERNET_CONNECTION_PROXY = 4;
   INTERNET_CONNECTION_MODEM_BUSY = 8;
var
   i, dwConnectionTypes: Integer;
   isConnected: Boolean;
   NetHandle: HINTERNET;
   UrlHandle: HINTERNET;
   Buffer: array[0..1024] of Char;
   BytesRead: DWORD;
   StrToDisplay: string;
begin
   while True do
   begin
      try
         dwConnectionTypes := INTERNET_CONNECTION_MODEM + INTERNET_CONNECTION_LAN + INTERNET_CONNECTION_PROXY;
         ResetLastError;
         isConnected := InternetGetConnectedState(@dwConnectionTypes, 0);
         LastError := GetLastError;
         if isConnected then
            Break;
      except
         on E: Exception do
            LastExceptionStr := E.Message;
      end;
      StrToDisplay := GetLangTextDef(idxMain, ['Messages', 'NoInternet'], 'No internet connection detected !');
      if LastError > 0 then
         StrToDisplay := StrToDisplay + #13#10#13#10 + 'System message: ' + SysErrorMessage(LastError)
      else if LastExceptionStr <> '' then
         StrToDisplay := StrToDisplay + #13#10#13#10 + 'Exception: ' + LastExceptionStr;
      case CustomMessageBox(OwnerWindowHandle, StrToDisplay, GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbAbort, mbRetry, mbIgnore], mbAbort) of
         mrRetry:
            Continue;
         mrIgnore:
            Break;
         else
            Exit;
      end;
   end;
   while True do
   begin
      for i := Low(SiteHelp) to High(SiteHelp) do
      begin
         NetHandle := InternetOpen(PChar(Application.Title), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
         if not Assigned(NetHandle) then
            Continue;
         try
            UrlHandle := InternetOpenUrl(NetHandle, PChar(SiteHelp[i]), nil, 0, INTERNET_FLAG_RELOAD, 0);
            if not Assigned(UrlHandle) then
               Continue;
            try
               try
                  InternetReadFile(UrlHandle, @Buffer, 1024, BytesRead);
                  if BytesRead <> 1024 then
                     Continue;
               except
                  Continue;
               end;
            finally
               InternetCloseHandle(UrlHandle);
            end;
         finally
            InternetCloseHandle(NetHandle);
         end;
         if ShellExecute(OwnerWindowHandle, 'open', PChar(SiteHelp[i]), nil, nil, SW_SHOW) > 32 then
            Exit;
      end;
      if CustomMessageBox(OwnerWindowHandle, (GetLangTextDef(idxMain, ['Messages', 'NoHelp'], 'Help site not found, error opening browser or your antivirus is blocking the connection !')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbAbort, mbRetry], mbAbort) <> mrRetry then
         Exit;
   end;
end;

procedure Replacebks(var ws: string; const len: Integer);
var
   i: Integer;
begin
   i := 1;
   while i <= len do
   begin
      if ws[i] = '/' then
         ws[i] := '\';
      Inc(i);
   end;
end;

function FindDriveWithVendorProductSize(const drvName: AnsiString): ShortInt;
var
   i, j, l, ls: Integer;
   sz: Double;
   hDrive: THandle;
   strTemp, csz, mu: AnsiString;

   procedure Round3;
   var
      k, n: Integer;
   begin
      k := 0;
      if sz < 100 then
      begin
         while sz < 1000 do
         begin
            sz := sz * 10;
            Inc(k);
         end;
         Dec(k);
         csz := AnsiString(IntToStr(Round(sz / 10)));
         if k <= 2 then
            Insert('.', csz, 4 - k)
         else
         begin
            for n := 1 to k - 2 do
               csz := '0' + csz;
            Insert('.', csz, 2);
         end;
      end
      else if sz > 1000 then
      begin
         while sz > 100 do
         begin
            sz := sz / 10;
            Inc(k);
         end;
         Dec(k);
         csz := AnsiString(IntToStr(Round(sz * 10)));
         for n := 1 to k do
            csz := csz + '0';
      end
      else
         csz := AnsiString(IntToStr(Round(sz)));
   end;

begin
   Result := -1;
   l := Length(drvName);
   for i := 0 to MAX_IDE_DRIVES - 1 do
   begin
      if i = OSDrive then
         Continue;
      hDrive := INVALID_HANDLE_VALUE;
      try
         ResetLastError;
         hDrive := CreateFile(PChar('\\.\PHYSICALDRIVE' + IntToStr(i)), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
         LastError := GetLastError;
      except
         on E: Exception do
            LastExceptionStr := E.Message;
      end;
      if hDrive <> INVALID_HANDLE_VALUE then
      begin
         if ListOnlyUSBDrives and (GetBusType(hDrive) <> 7) then
         begin
            try
               CloseHandle(hDrive);
            except
            end;
            Continue;
         end;
         strTemp := GetDriveVendorAndProductID(hDrive);
         ls := Length(strTemp);
         if ls > l then
         begin
            try
               CloseHandle(hDrive);
            except
            end;
            Continue;
         end;
         j := 1;
         while j <= ls do
         begin
            if strTemp[j] <> drvName[j] then
               Break;
            Inc(j);
         end;
         if j <= ls then
         begin
            try
               CloseHandle(hDrive);
            except
            end;
            Continue;
         end;
         sz := GetDriveSize(hDrive) / 1073741824;
         try
            CloseHandle(hDrive);
         except
         end;
         if sz <= 0 then
            Continue
         else
         begin
            if sz < 1 then
            begin
               sz := sz * 1024;
               mu := ' MB';
            end
            else if sz > 1000 then
            begin
               sz := sz / 1024;
               mu := ' TB';
            end
            else
               mu := ' GB';
            Round3;
            strTemp := strTemp + ', ' + csz + mu;
         end;
         if Length(strTemp) = l then
         begin
            while j <= l do
            begin
               if strTemp[j] <> drvName[j] then
                  Break;
               Inc(j);
            end;
            if j > l then
            begin
               Result := i;
               Exit;
            end;
         end;
      end;
   end;
end;

procedure FindDrives;
var
   i, j, k, l: Integer;
   sz: Double;
   hDrive, hVolume, hSrcVol: THandle;
   strTemp, csz, mu: AnsiString;
   BusType: Byte;
   Data: PData;
   Node: PVirtualNode;
   dwBytesReturned, dwBytesRead, dwBytesSize: DWORD;
   sdn: STORAGE_DEVICE_NUMBER;
   bSuccess: Boolean;
   volName, volBuffer: array[0..MAX_PATH] of WideChar;
   VolPaths: PWideChar;

   procedure Round3;
   var
      k, n: Integer;
   begin
      k := 0;
      if sz < 100 then
      begin
         while sz < 1000 do
         begin
            sz := sz * 10;
            Inc(k);
         end;
         Dec(k);
         csz := AnsiString(IntToStr(Round(sz / 10)));
         if k <= 2 then
            Insert('.', csz, 4 - k)
         else
         begin
            for n := 1 to k - 2 do
               csz := '0' + csz;
            Insert('.', csz, 2);
         end;
      end
      else if sz > 1000 then
      begin
         while sz > 100 do
         begin
            sz := sz / 10;
            Inc(k);
         end;
         Dec(k);
         csz := AnsiString(IntToStr(Round(sz * 10)));
         for n := 1 to k do
            csz := csz + '0';
      end
      else
         csz := AnsiString(IntToStr(Round(sz)));
   end;

begin
   if frmMain.vstVMs.RootNodeCount = 0 then
      Exit;
   Node := frmMain.vstVMs.GetFirst;
   while Node <> nil do
   begin
      Data := frmMain.vstVMs.GetNodeData(Node);
      Data^.FirstDriveFound := False;
      Data^.FirstDriveNumber := -1;
      Data^.FDMountPointsStr := '[';
      SetLength(Data^.FDMountPointsArr, 0);
      Data^.SecondDriveFound := False;
      Data^.SecondDriveNumber := -1;
      Data^.SDMountPointsStr := '[';
      SetLength(Data^.SDMountPointsArr, 0);
      Node := frmMain.vstVMs.GetNext(Node);
   end;
   for i := 0 to MAX_IDE_DRIVES - 1 do
   begin
      if i = OSDrive then
         Continue;
      hDrive := INVALID_HANDLE_VALUE;
      try
         ResetLastError;
         hDrive := CreateFile(PChar('\\.\PHYSICALDRIVE' + IntToStr(i)), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
         LastError := GetLastError;
      except
         on E: Exception do
            LastExceptionStr := E.Message;
      end;
      if hDrive <> INVALID_HANDLE_VALUE then
      begin
         BusType := GetBusType(hDrive);
         if ListOnlyUSBDrives and (BusType <> 7) then
         begin
            try
               CloseHandle(hDrive);
            except
            end;
            Continue;
         end;
         strTemp := GetDriveVendorAndProductID(hDrive);
         if strTemp = '' then
         begin
            try
               CloseHandle(hDrive);
            except
            end;
            Continue;
         end;
         sz := GetDriveSize(hDrive) / 1073741824;
         try
            CloseHandle(hDrive);
         except
         end;
         if sz <= 0 then
            Continue
         else
         begin
            if sz < 1 then
            begin
               sz := sz * 1024;
               mu := ' MB';
            end
            else if sz > 1000 then
            begin
               sz := sz / 1024;
               mu := ' TB';
            end
            else
               mu := ' GB';
            Round3;
            strTemp := strTemp + ', ' + csz + mu;
         end;
         l := Length(strTemp);
         Node := frmMain.vstVMs.GetFirst;
         while Node <> nil do
         begin
            Data := frmMain.vstVMs.GetNodeData(Node);
            if Length(Data^.FirstDriveName) = l then
            begin
               k := 1;
               while k <= l do
               begin
                  if strTemp[k] <> Data^.FirstDriveName[k] then
                     Break;
                  Inc(k);
               end;
               if k > l then
               begin
                  Data^.FirstDriveFound := True;
                  Data^.FirstDriveBusType := BusType;
                  Data^.FirstDriveNumber := i;
               end;
            end;
            if AddSecondDrive then
            begin
               if Length(Data^.SecondDriveName) = l then
               begin
                  k := 1;
                  while k <= l do
                  begin
                     if strTemp[k] <> Data^.SecondDriveName[k] then
                        Break;
                     Inc(k);
                  end;
                  if k > l then
                  begin
                     Data^.SecondDriveFound := True;
                     Data^.SecondDriveBusType := BusType;
                     Data^.SecondDriveNumber := i;
                  end;
               end;
            end;
            Node := frmMain.vstVMs.GetNext(Node);
         end;
      end;
   end;

   try
      hSrcVol := FindFirstVolumeW(@volName, SizeOf(volName));
      LastError := GetLastError;
   except
      hSrcVol := INVALID_HANDLE_VALUE;
   end;
   if hSrcVol <> INVALID_HANDLE_VALUE then
   begin
      repeat
         if Copy(volName, 1, 4) = '\\?\' then
         begin
            try
               GetVolumePathNamesForVolumeNameW(volName, nil, 0, dwBytesRead);
               LastError := GetLastError;
            except
               on E: Exception do
            end;
            if (LastError = ERROR_MORE_DATA) and (dwBytesRead >= 5) then
            begin
               dwBytesSize := 2 * dwBytesRead;
               VolPaths := AllocMem(dwBytesSize);
               try
                  try
                     bSuccess := GetVolumePathNamesForVolumeNameW(volName, VolPaths, dwBytesSize, dwBytesRead);
                     LastError := GetLastError;
                  except
                     bSuccess := False;
                  end;
                  if bSuccess then
                  begin
                     while VolName[StrLen(VolName) - 1] = '\' do
                        VolName[StrLen(VolName) - 1] := #0;
                     i := 0;
                     while i < (Integer(dwBytesRead) - 1) do
                     begin
                        try
                           if ((i > 1) and (VolPaths[i - 1] = #0) and (VolPaths[i] <> #0)) or (i = 0) then
                           begin
                              VolBuffer[0] := VolPaths[i];
                              j := i;
                              repeat
                                 Inc(i);
                                 VolBuffer[i - j] := VolPaths[i];
                              until VolPaths[i] = #0;
                              try
                                 case GetDriveType(VolBuffer) of
                                    DRIVE_REMOVABLE, DRIVE_FIXED:
                                       begin
                                          try
                                             hVolume := CreateFile(VolName, 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                                          except
                                             hVolume := INVALID_HANDLE_VALUE;
                                          end;
                                          if hVolume <> INVALID_HANDLE_VALUE then
                                          begin
                                             BusType := GetBusType(hVolume);
                                             if ListOnlyUSBDrives and (BusType <> 7) then
                                             begin
                                                try
                                                   CloseHandle(hVolume);
                                                except
                                                end;
                                                Continue;
                                             end;
                                             dwBytesReturned := 0;
                                             try
                                                if DeviceIoControl(hVolume, IOCTL_STORAGE_GET_DEVICE_NUMBER, nil, 0, @sdn, SizeOf(sdn), dwBytesReturned, nil) and (sdn.DeviceNumber <> OSDrive) then
                                                begin
                                                   if sdn.DeviceNumber = OSDrive then
                                                      Continue;
                                                   Node := frmMain.vstVMs.GetFirst;
                                                   while Node <> nil do
                                                   begin
                                                      Data := frmMain.vstVMs.GetNodeData(Node);
                                                      if Smallint(sdn.DeviceNumber) = Data^.FirstDriveNumber then
                                                      begin
                                                         Data^.FDMountPointsStr := Data^.FDMountPointsStr + ExcludeTrailingPathDelimiter(string(VolBuffer)) + ', ';
                                                         SetLength(Data^.FDMountPointsArr, Length(Data^.FDMountPointsArr) + 1);
                                                         Data^.FDMountPointsArr[High(Data^.FDMountPointsArr)] := ExcludeTrailingPathDelimiter(string(VolBuffer));
                                                      end;
                                                      if AddSecondDrive then
                                                      begin
                                                         if Smallint(sdn.DeviceNumber) = Data^.SecondDriveNumber then
                                                         begin
                                                            Data^.SDMountPointsStr := Data^.SDMountPointsStr + ExcludeTrailingPathDelimiter(string(VolBuffer)) + ', ';
                                                            SetLength(Data^.SDMountPointsArr, Length(Data^.SDMountPointsArr) + 1);
                                                            Data^.SDMountPointsArr[High(Data^.SDMountPointsArr)] := ExcludeTrailingPathDelimiter(string(VolBuffer));
                                                         end;
                                                      end;
                                                      Node := frmMain.vstVMs.GetNext(Node);
                                                   end;
                                                end;
                                             finally
                                                try
                                                   CloseHandle(hVolume);
                                                except
                                                end;
                                             end;
                                          end;
                                       end;
                                 end;
                              except
                              end
                           end;
                        finally
                           Inc(i);
                        end;
                     end;
                  end;
               finally
                  FreeMem(VolPaths);
               end;
            end;
         end;
         try
            bSuccess := FindNextVolumeW(hSrcVol, @volName, SizeOf(volName));
         except
            bSuccess := False;
         end;
      until not bSuccess;
      FindVolumeClose(hSrcVol);
   end;

   Node := frmMain.vstVMs.GetFirst;
   while Node <> nil do
   begin
      Data := frmMain.vstVMs.GetNodeData(Node);
      if Length(Data^.FDMountPointsStr) > 1 then
      begin
         Delete(Data^.FDMountPointsStr, Length(Data^.FDMountPointsStr) - 1, 2);
         Data^.FDMountPointsStr := Data^.FDMountPointsStr + ']';
      end
      else
         Data^.FDMountPointsStr := Data^.FDMountPointsStr + ' ]';
      if Length(Data^.SDMountPointsStr) > 1 then
      begin
         Delete(Data^.SDMountPointsStr, Length(Data^.SDMountPointsStr) - 1, 2);
         Data^.SDMountPointsStr := Data^.SDMountPointsStr + ']';
      end
      else
         Data^.SDMountPointsStr := Data^.SDMountPointsStr + ' ]';
      Node := frmMain.vstVMs.GetNext(Node);
   end;
end;

function GetDriveSize(const hDrive: THandle): Int64;
var
   dwBytesReturned: DWORD;
   LengthInformation: TGetLengthInformation;
begin
   try
      ResetLastError;
      if DeviceIoControl(hDrive, IOCTL_DISK_GET_LENGTH_INFO, nil, 0, @LengthInformation, SizeOf(TGetLengthInformation), dwBytesReturned, nil) then
         Result := LengthInformation.Length
      else
         Result := -1;
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         LastExceptionStr := E.Message;
         Result := -1;
      end;
   end;
end;

type
   {$Z4}
   STORAGE_QUERY_TYPE = (PropertyStandardQuery = 0, PropertyExistsQuery, PropertyMaskQuery, PropertyQueryMaxDefined);
   {$Z1}
   {$Z4}
   STORAGE_PROPERTY_ID = (StorageDeviceProperty = 0, StorageAdapterProperty);
   {$Z1}

type
   STORAGE_BUS_TYPE = (BusTypeUnknown = $00, BusTypeScsi, BusTypeAtapi, BusTypeAta, BusType1394, BusTypeSsa, BusTypeFibre, BusTypeUsb, BusTypeRAID, BusTypeiScsi, BusTypeSas, BusTypeSata, BusTypeSd, BusTypeMmc, BusTypeVirtual, BusTypeFileBackedVirtual, BusTypeMax, BusTypeNvme, BusTypeMaxReserved = $7F);

   STORAGE_PROPERTY_QUERY = record
      PropertyId: STORAGE_PROPERTY_ID;
      QueryType: STORAGE_QUERY_TYPE;
      AdditionalParameters: array[0..1 - 1] of UCHAR;
   end;

   PSTORAGE_PROPERTY_QUERY = ^STORAGE_PROPERTY_QUERY;

   STORAGE_DEVICE_DESCRIPTOR = record
      Version: Cardinal;
      Size: Cardinal;
      DeviceType: Byte;
      DeviceTypeModifier: Byte;
      RemovableMedia: Byte;
      CommandQueueing: Byte;
      VendorIdOffset: Cardinal;
      ProductIdOffset: Cardinal;
      ProductRevisionOffset: Cardinal;
      SerialNumberOffset: Cardinal;
      BusType: STORAGE_BUS_TYPE;
      RawPropertiesLength: Cardinal;
      RawDeviceProperties: array[0..1 - 1] of Byte;
   end;

   PSTORAGE_DEVICE_DESCRIPTOR = ^STORAGE_DEVICE_DESCRIPTOR;
   {$ALIGN on}

function crt_isspace(ch: Integer): Integer; cdecl; external 'msvcrt.dll' name 'isspace';

function crt_tolower(ch: Integer): Integer; cdecl; external 'msvcrt.dll' name 'tolower';

function crt_isprint(ch: Integer): Integer; cdecl; external 'msvcrt' name 'isprint';

function GetDriveVendorAndProductID(const hDrive: THandle): AnsiString;

   function tolower(ch: AnsiChar): AnsiChar;
   begin
      Result := AnsiChar(Chr(crt_tolower(Ord(ch))));
   end;

   function isspace(ch: AnsiChar): Boolean;
   begin
      Result := crt_isspace(Ord(ch)) <> 0;
   end;

   function isprint(ch: AnsiChar): Boolean;
   begin
      Result := crt_isprint(Ord(ch)) <> 0;
   end;

   function flipAndCodeBytes(str: PAnsiChar; pos: Integer; flip: Integer; buf: PAnsiChar): AnsiString;
   var
      i, j, k: Integer;
      p: Integer;
      c: AnsiChar;
      t: AnsiChar;
   begin
      j := 0;
      k := 0;

      buf[0] := Chr(0);
      if (pos <= 0) then
      begin
         Result := buf;
         Exit;
      end;

      if (j = 0) then
      begin
         p := 0;

         j := 1;
         k := 0;
         buf[k] := Chr(0);
         i := pos;
         while (j <> 0) and (str[i] <> Chr(0)) do
         begin
            c := tolower(str[i]);

            if (isspace(c)) then
               c := Chr(0);

            Inc(p);
            buf[k] := AnsiChar(Chr(Ord(buf[k]) shl 4));

            if ((c >= '0') and (c <= '9')) then
               buf[k] := AnsiChar(Chr(Ord(buf[k]) or Byte(Ord(c) - Ord('0'))))
            else if ((c >= 'a') and (c <= 'f')) then
               buf[k] := AnsiChar(Chr(Ord(buf[k]) or Byte(Ord(c) - Ord('a') + 10)))
            else
            begin
               j := 0;
               Break;
            end;

            if (p = 2) then
            begin
               if ((buf[k] <> Chr(0)) and (not isprint(buf[k]))) then
               begin
                  j := 0;
                  Break;
               end;
               Inc(k);
               p := 0;
               buf[k] := Chr(0);
            end;
            Inc(i);
         end;
      end;

      if (j = 0) then
      begin
         j := 1;
         k := 0;
         i := pos;
         while ((j <> 0) and (str[i] <> Chr(0))) do
         begin
            c := str[i];

            if (not isprint(c)) then
            begin
               j := 0;
               Break;
            end;

            buf[(k)] := c;
            Inc(k);
            Inc(i);
         end;
      end;

      if (j = 0) then
         k := 0;

      buf[k] := Chr(0);

      if (flip <> 0) then
      begin
         j := 0;
         while (j < k) do
         begin
            t := buf[j];
            buf[j] := buf[j + 1];
            buf[j + 1] := t;
            j := j + 2;
         end
      end;

      i := -1;
      j := -1;
      k := 0;
      while (buf[k] <> Chr(0)) do
      begin
         if (not isspace(buf[k])) then
         begin
            if (i < 0) then
               i := k;
            j := k;
         end;
         Inc(k);
      end;

      if ((i >= 0) and (j >= 0)) then
      begin
         k := i;
         while ((k <= j) and (buf[k] <> Chr(0))) do
         begin
            buf[k - i] := buf[k];
            Inc(k);
         end;
         buf[k - i] := Chr(0);
      end;

      Result := buf;
   end;

   function SerialNumberToString(SerNum: string): string;
   var
      I, StrLen: Integer;
      Pair: string;
      B: Byte;
      Ch: Char absolute B;
   begin
      Result := '';
      StrLen := Length(SerNum);
      if Odd(StrLen) then
         Exit;
      I := 1;
      while I < StrLen do
      begin
         Pair := Copy(SerNum, I, 2);
         HexToBin(PChar(Pair), PChar(@B), 1);
         Result := Result + Chr(B);
         Inc(I, 2);
      end;
      I := 1;
      while I < Length(Result) do
      begin
         Ch := Result[I];
         Result[I] := Result[I + 1];
         Result[I + 1] := Ch;
         Inc(I, 2);
      end;
   end;

var
   query: STORAGE_PROPERTY_QUERY;
   cbBytesReturned: Cardinal;
   Buffer, vendorID, modelNumber: array[0..10000 - 1] of AnsiChar;
   descrip: PSTORAGE_DEVICE_DESCRIPTOR;
begin
   cbBytesReturned := 0;
   FillMemory(@query, SizeOf(query), 0);
   query.PropertyId := StorageDeviceProperty;
   query.QueryType := PropertyStandardQuery;
   FillMemory(@Buffer, SizeOf(Buffer), 0);
   try
      ResetLastError;
      if DeviceIoControl(hDrive, IOCTL_STORAGE_QUERY_PROPERTY, @query, SizeOf(query), @Buffer, SizeOf(Buffer), cbBytesReturned, nil) then
      begin
         descrip := PSTORAGE_DEVICE_DESCRIPTOR(@Buffer);
         flipAndCodeBytes(Buffer, descrip^.VendorIdOffset, 0, vendorID);
         flipAndCodeBytes(Buffer, descrip^.ProductIdOffset, 0, modelNumber);
         Result := Trim(AnsiString(vendorID) + ' ' + AnsiString(modelNumber));
      end
      else
         Result := '';
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         LastExceptionStr := E.Message;
         Result := '';
      end;
   end;
end;

procedure UpdateDrive(const aDrive: Byte);
var
   hDrive: THandle;
   dwBytesReturned: Cardinal;
begin
   hDrive := INVALID_HANDLE_VALUE;
   try
      hDrive := CreateFile(PChar('\\.\PHYSICALDRIVE' + IntToStr(aDrive)), 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
   except
   end;
   if hDrive <> INVALID_HANDLE_VALUE then
   begin
      try
         ResetLastError;
         DeviceIoControl(hDrive, IOCTL_DISK_UPDATE_PROPERTIES, nil, 0, nil, 0, dwBytesReturned, nil);
         LastError := GetLastError;
      except
         on E: Exception do
            LastExceptionStr := E.Message;
      end;
      try
         CloseHandle(hDrive);
      except
      end;
   end;
end;

function GetBusType(const hDrive: THandle): Byte;
var
   query: STORAGE_PROPERTY_QUERY;
   dwBytesReturned: DWORD;
   Buffer: array[0..1023] of Byte;
   sdd: STORAGE_DEVICE_DESCRIPTOR absolute Buffer;
begin
   Result := Byte(BusTypeUnknown);
   dwBytesReturned := 0;
   FillChar(query, SizeOf(query), 0);
   FillChar(Buffer, SizeOf(Buffer), 0);
   sdd.Size := SizeOf(Buffer);
   query.PropertyId := StorageDeviceProperty;
   query.QueryType := PropertyStandardQuery;
   try
      ResetLastError;
      if DeviceIoControl(hDrive, IOCTL_STORAGE_QUERY_PROPERTY, @query, SizeOf(query), @Buffer, SizeOf(Buffer), dwBytesReturned, nil) then
         Result := Byte(sdd.BusType);
      LastError := GetLastError;
   except
      on E: Exception do
         LastExceptionStr := E.Message;
   end;
end;

function GetEnvVarValue(const VarName: string): string;
var
   BufSize: Integer;
begin
   try
      BufSize := GetEnvironmentVariable(PChar(VarName), nil, 0);
      LastError := GetLastError;
      if LastError = ERROR_ENVVAR_NOT_FOUND then
      begin
         ResetLastError;
         Result := '';
         Exit;
      end;
   except
      on E: Exception do
      begin
         BufSize := 0;
         LastExceptionStr := E.Message;
      end;
   end;
   if BufSize > 0 then
   begin
      SetLength(Result, BufSize - 1);
      ResetLastError;
      try
         GetEnvironmentVariable(PChar(VarName), PChar(Result), BufSize);
         LastError := GetLastError;
      except
         on E: Exception do
            LastExceptionStr := E.Message;
      end;
   end
   else
      Result := '';
end;

function GenGuid: AnsiString;
var
   g: TGUID;
   r: Boolean;
begin
   try
      r := CreateGUID(g) = S_OK;
   except
      r := False;
   end;
   if r then
   begin
      try
         Result := AnsiString(GUIDToString(g));
         Result := AnsiString(LowerCase(Copy(string(Result), 2, Length(Result) - 2)));
      except
         Result := '';
      end;
   end
   else
      Result := '';
   if Result = '' then
   begin
      if not Randomized then
      begin
         Randomize;
         Randomized := True;
      end;
      Result := AnsiString((LowerCase(string(IntToHex(Random(16777216), 6) + IntToHex(Random(256), 2) + '-' + IntToHex(Random(65536), 4) + '-' + IntToHex(Random(65536), 4) + '-' + IntToHex(Random(65536), 4) + '-' + IntToHex(Random(16777216), 6) + IntToHex(Random(16777216), 6)))));
   end;
end;

function GenID: AnsiString;
var
   g: TGUID;
   r: Boolean;
begin
   try
      r := CreateGUID(g) = S_OK;
   except
      r := False;
   end;
   if r then
   begin
      try
         Result := AnsiString(GUIDToString(g));
         Result := AnsiString((LowerCase(string(Result[2] + Result[6] + Result[11] + Result[14] + Result[18] + Result[22] + Result[28] + Result[34]))))
      except
         Result := '';
      end;
   end
   else
      Result := '';
   if Result = '' then
   begin
      if not Randomized then
      begin
         Randomize;
         Randomized := True;
      end;
      Result := AnsiString(LowerCase(string(IntToHex(Random(16777216), 6) + IntToHex(Random(256), 2))));
   end;
end;

procedure TfrmMain.LoadVMentries(const FileName: string);
var
   i, j, l, p, c: Integer;
   t: TFileStream;
   st: string;
   wsa: array of string;
   Node: PVirtualNode;
   Data: PData;
begin
   t := nil;
   while True do
   try
      t := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
      Break;
   except
      on E: Exception do
      begin
         if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CantOpenToRead'], [FileName, E.Message], 'Could not open "%s" for reading !'#13#10#13#10'System message: %s')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbRetry, mbIgnore], mbIgnore) = mrIgnore then
            Exit;
      end;
   end;
   l := 0;
   while True do
   try
      l := Min(1048576, t.Size div 2);
      SetLength(psEntries, l);
      t.Position := 0;
      t.ReadBuffer(Pointer(psEntries)^, l * 2);
      Break;
   except
      on E: Exception do
         if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CantRead'], [FileName, E.Message], 'Could not read from "%s" !'#13#10#13#10'System message: %s')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbRetry, mbIgnore], mbIgnore) = mrIgnore then
            Break;
   end;
   try
      t.Free;
   except
   end;

   if psEntries = '' then
      Exit;
   try
      SetLength(wsa, 0);
      p := 2;
      i := PosEx(#13, psEntries, 2);
      while i > 0 do
      begin
         SetLength(wsa, Length(wsa) + 1);
         wsa[High(wsa)] := Trim(Copy(psEntries, p, i - p));
         p := i + 1;
         if i < l then
            if psEntries[i + 1] = #10 then
               Inc(p);
         i := PosEx(#13, psEntries, p);
      end;
      if p <= l then
      begin
         SetLength(wsa, Length(wsa) + 1);
         wsa[High(wsa)] := Trim(Copy(psEntries, p, l - p + 1));
      end;
   except
   end;

   c := -1;
   Data := nil;
   for i := 0 to High(wsa) do
   begin
      l := Length(wsa[i]);
      if l < 3 then
         Continue;
      if (wsa[i][1] = '[') and (wsa[i][l] = ']') then
      begin
         st := Trim(Copy(wsa[i], 2, Min(1024, l - 2)));
         if st <> '' then
         begin
            Inc(c);
            Data := vstVMs.GetNodeData(vstVMs.AddChild(nil));
            with Data^ do
            begin
               ModeLoadVM := 2;
               UseHostIOCache := False;
               CPUPriority := 1;
               FirstDriveName := 'Unknown';
               VBCPUVirtualization := 0;
               CDROMType := 0;
               MemorySize := 512;
               AudioCard := 0;
            end;
         end;
      end;
      if c > -1 then
         with Data^ do
         begin
            if (pos(string('Type='), wsa[i]) = 1) and (l > 5) then
            begin
               st := Trim(Copy(wsa[i], 6, Min(100, l - 5)));
               if st = 'VirtualBox' then
               begin
                  Ptype := 0;
                  ModeLoadVM := 0;
               end
               else if st = 'Qemu' then
                  Ptype := 1
               else
               begin
                  Ptype := 0;
                  ModeLoadVM := 0;
               end;
            end;
            if Ptype <> 1 then
               if (pos(string('ModeToLoadVM='), wsa[i]) = 1) and (l > 13) then
               begin
                  st := Trim(Copy(wsa[i], 14, Min(1024, l - 13)));
                  if st = 'VMName' then
                     ModeLoadVM := 0
                  else if st = 'PathToVM' then
                     ModeLoadVM := 1
                  else if st = 'ExeParameters' then
                     ModeLoadVM := 2
                  else if Ptype = 1 then
                     ModeLoadVM := 2
                  else
                     ModeLoadVM := 0;
               end;
            if (pos(string('ExeParams='), wsa[i]) = 1) and (l > 10) then
               ExeParams := Trim(Copy(wsa[i], 11, Min(10240, l - 10)));
            if Ptype <> 1 then
            begin
               if (pos(string('VMID='), wsa[i]) = 1) and (l > 5) then
                  VMID := Trim(Copy(wsa[i], 6, Min(1024, l - 5)));
               if (pos(string('PathToVM='), wsa[i]) = 1) and (l > 9) then
                  VMPath := Trim(Copy(wsa[i], 10, Min(1024, l - 9)));
            end;
            if (pos(string('VMName='), wsa[i]) = 1) and (l > 7) then
               VMName := Trim(Copy(wsa[i], 8, l - 7));
            if (pos(string('FirstDriveName='), wsa[i]) = 1) and (l > 15) then
               FirstDriveName := AnsiString(Trim(Copy(wsa[i], 16, Min(1024, l - 15))));
            if (pos(string('FirstDriveBusType='), wsa[i]) = 1) and (l > 18) then
               FirstDriveBusType := GetIntBusType(Trim(Copy(wsa[i], 19, Min(1024, l - 18))));
            if (pos(string('SecondDriveName='), wsa[i]) = 1) and (l > 16) then
               SecondDriveName := AnsiString(Trim(Copy(wsa[i], 17, Min(1024, l - 16))));
            if (pos(string('SecondDriveBusType='), wsa[i]) = 1) and (l > 19) then
               SecondDriveBusType := GetIntBusType(Trim(Copy(wsa[i], 20, Min(1024, l - 19))));
            if (pos(string('UseHostIOCache='), wsa[i]) = 1) and (l > 15) then
               UseHostIOCache := Trim(Copy(wsa[i], 16, Min(1024, l - 15))) = 'On';
            if (pos(string('EnableCPUVirtualization='), wsa[i]) = 1) and (l > 24) then
            begin
               st := Trim(Copy(wsa[i], 25, Min(1024, l - 24)));
               if st = 'Unchanged' then
                  VBCPUVirtualization := 0
               else if st = 'On' then
                  VBCPUVirtualization := 1
               else if st = 'Off' then
                  VBCPUVirtualization := 2
               else if st = 'Switch' then
                  VBCPUVirtualization := 3
               else
                  VBCPUVirtualization := 0;
            end;
            if (pos(string('InternalHDD='), wsa[i]) = 1) and (l > 12) then
               InternalHDD := Trim(Copy(wsa[i], 13, Min(1024, l - 12)));
            if (pos(string('CDDVDName='), wsa[i]) = 1) and (l > 10) then
               CDROMName := Trim(Copy(wsa[i], 11, Min(1024, l - 10)));
            if (pos(string('CDDVDType='), wsa[i]) = 1) and (l > 10) then
               if Trim(Copy(wsa[i], 11, Min(100, l - 10))) = 'File' then
                  CDROMType := 1;

            if (pos(string('Memory='), wsa[i]) = 1) and (l > 7) then
               MemorySize := Min(Max(StrToIntDef(Trim(Copy(wsa[i], 8, Min(5, l - 7))), 512), 1), 65535);
            if (pos(string('Audio='), wsa[i]) = 1) and (l > 6) then
            begin
               st := Trim(Copy(wsa[i], 7, Min(1024, l - 6)));
               if st = 'Creative Sound Blaster 16' then
                  AudioCard := 1
               else if st = 'PC speaker' then
                  AudioCard := 2
               else if st = 'Intel HD Audio' then
                  AudioCard := 3
               else if st = 'Gravis Ultrasound GF1' then
                  AudioCard := 4
               else if st = 'ENSONIQ AudioPCI ES1370' then
                  AudioCard := 5
               else if st = 'CS4231A' then
                  AudioCard := 6
               else if st = 'Yamaha YM3812 (OPL2)' then
                  AudioCard := 7
               else if st = 'Intel 82801AA AC97 Audio' then
                  AudioCard := 8
               else
                  AudioCard := 0;
            end;
            if (pos(string('Run='), wsa[i]) = 1) and (l > 4) then
            begin
               st := Trim(Copy(wsa[i], 5, Min(1024, l - 4)));
               if st = 'Normal' then
                  RunAs := 0
               else if st = 'Minimized' then
                  RunAs := 1
               else if st = 'Maximized' then
                  RunAs := 2
               else if st = 'Fullscreen' then
                  RunAs := 3
               else
                  RunAs := 0;
            end;
            if (pos(string('Priority='), wsa[i]) = 1) and (l > 9) then
            begin
               st := Trim(Copy(wsa[i], 10, Min(1024, l - 9)));
               if st = 'BelowNormal' then
                  CPUPriority := 0
               else if st = 'Normal' then
                  CPUPriority := 1
               else if st = 'AboveNormal' then
                  CPUPriority := 2
               else if st = 'High' then
                  CPUPriority := 3
               else
                  CPUPriority := 1;
            end;
         end;
   end;
   Node := vstVMs.GetFirst;
   while Node <> nil do
   begin
      try
         Data := vstVMs.GetNodeData(Node);
         st := Data^.ExeParams;
         p := pos(string('-m '), st);
         if (p = 1) or ((p > 1) and (st[p - 1] = ' ')) then
         begin
            j := p + 3;
            l := Length(st);
            while j <= l do
            begin
               if (st[j] < '0') or (st[j] > '9') then
                  Break;
               Inc(j);
            end;
            Delete(st, Max(1, p - 1), j - Max(1, p - 1));
         end;
         p := pos(string('-soundhw '), st);
         if (p = 1) or ((p > 1) and (st[p - 1] = ' ')) then
         begin
            j := p + 9;
            l := Length(st);
            while j <= l do
            begin
               if (st[j] = '-') or (st[j] = ' ') then
                  Break;
               Inc(j);
            end;
            Delete(st, Max(1, p - 1), j - Max(1, p - 1));
         end;
         Data^.ExeParams := st;
      except
      end;
      Node := vstVMs.GetNext(Node);
   end;
end;

procedure TfrmMain.SaveVMentries(const FileName: string);
var
   l: Integer;
   t: TFileStream;
   s, sType, sMode, sRun, sPriority, sEnableCPUVirtualization, BaseFolder, sAudio, sCDROMType, strFirstDriveBusType, strSecDriveBusType, sUseHostCache: string;
   Node: PVirtualNode;
   Data: PData;
begin
   s := #65279;
   Node := vstVMs.GetFirst;
   while Node <> nil do
   begin
      Data := vstVMs.GetNodeData(Node);
      with Data^ do
      begin
         if Ptype = 0 then
            sType := 'VirtualBox'
         else
            sType := 'Qemu';
         case ModeLoadVM of
            1:
               sMode := 'PathToVM';
            2:
               sMode := 'ExeParameters';
            else
               sMode := 'VMName';
         end;
         case VBCPUVirtualization of
            1:
               sEnableCPUVirtualization := 'On';
            2:
               sEnableCPUVirtualization := 'Off';
            3:
               sEnableCPUVirtualization := 'Switch';
            else
               sEnableCPUVirtualization := 'Unchanged';
         end;
         if CDROMType = 0 then
            sCDROMType := 'Device'
         else
            sCDROMType := 'File';
         case AudioCard of
            1:
               sAudio := 'Creative Sound Blaster 16';
            2:
               sAudio := 'PC speaker';
            3:
               sAudio := 'Intel HD Audio';
            4:
               sAudio := 'Gravis Ultrasound GF1';
            5:
               sAudio := 'ENSONIQ AudioPCI ES1370';
            6:
               sAudio := 'CS4231A';
            7:
               sAudio := 'Yamaha YM3812 (OPL2)';
            8:
               sAudio := 'Intel 82801AA AC97 Audio';
            else
               sAudio := 'None';
         end;
         case RunAs of
            1:
               sRun := 'Minimized';
            2:
               sRun := 'Maximized';
            3:
               sRun := 'Fullscreen';
            else
               sRun := 'Normal';
         end;
         case CPUPriority of
            0:
               sPriority := 'BelowNormal';
            2:
               sPriority := 'AboveNormal';
            3:
               sPriority := 'High';
            else
               sPriority := 'Normal';
         end;
         strFirstDriveBusType := GetStrBusType(FirstDriveBusType);
         if strFirstDriveBusType = '' then
            strFirstDriveBusType := 'UNKNOWN';
         if UseHostIOCache then
            sUseHostCache := 'On'
         else
            sUseHostCache := 'Off';
         if AddSecondDrive then
         begin
            strSecDriveBusType := GetStrBusType(SecondDriveBusType);
            if strSecDriveBusType = '' then
               strSecDriveBusType := 'UNKNOWN';
            if Ptype = 0 then
               s := s + '[' + FId + ']'#13#10'Type=' + sType + #13#10'ModeToLoadVM=' + sMode + #13#10'ExeParams=' + ExeParams + #13#10'VMID=' + VMID + #13#10'VMName=' + VMName + #13#10'PathToVM=' + VMPath + #13#10'FirstDriveName=' + string(FirstDriveName) + #13#10'FirstDriveBusType=' + strFirstDriveBusType + #13#10'SecondDriveName=' + string(SecondDriveName) + #13#10'SecondDriveBusType=' + strSecDriveBusType + #13#10'UseHostIOCache=' + sUseHostCache + #13#10'EnableCPUVirtualization=' + sEnableCPUVirtualization + #13#10'Run=' + sRun + #13#10'Priority=' + sPriority + #13#10
            else
               s := s + '[' + FId + ']'#13#10'Type=' + sType + #13#10'ExeParams=' + ExeParams + #13#10'VMName=' + VMName + #13#10'FirstDriveName=' + string(FirstDriveName) + #13#10'FirstDriveBusType=' + strFirstDriveBusType + #13#10'SecondDriveName=' + string(SecondDriveName) + #13#10'SecondDriveBusType=' + strSecDriveBusType + #13#10'UseHostIOCache=' + sUseHostCache + #13#10'InternalHDD=' + InternalHDD + #13#10'CDDVDName=' + CDROMName + #13#10'CDDVDType=' + sCDROMType + #13#10'Memory=' + IntToStr(MemorySize) + #13#10'Audio=' + sAudio + #13#10'Run=' + sRun + #13#10'Priority=' + sPriority + #13#10;
         end
         else if Ptype = 0 then
            s := s + '[' + FId + ']'#13#10'Type=' + sType + #13#10'ModeToLoadVM=' + sMode + #13#10'ExeParams=' + ExeParams + #13#10'VMID=' + VMID + #13#10'VMName=' + VMName + #13#10'PathToVM=' + VMPath + #13#10'FirstDriveName=' + string(FirstDriveName) + #13#10'FirstDriveBusType=' + strFirstDriveBusType + #13#10'UseHostIOCache=' + sUseHostCache + #13#10'EnableCPUVirtualization=' + sEnableCPUVirtualization + #13#10'Run=' + sRun + #13#10'Priority=' + sPriority + #13#10
         else
            s := s + '[' + FId + ']'#13#10'Type=' + sType + #13#10'ExeParams=' + ExeParams + #13#10'VMName=' + VMName + #13#10'FirstDriveName=' + string(FirstDriveName) + #13#10'FirstDriveBusType=' + strFirstDriveBusType + #13#10'UseHostIOCache=' + sUseHostCache + #13#10'InternalHDD=' + InternalHDD + #13#10'CDDVDName=' + CDROMName + #13#10'CDDVDType=' + sCDROMType + #13#10'Memory=' + IntToStr(MemorySize) + #13#10'Audio=' + sAudio + #13#10'Run=' + sRun + #13#10'Priority=' + sPriority + #13#10;
      end;
      Node := vstVMs.GetNext(Node);
   end;
   if psEntries = s then
      Exit;
   if isInstalledVersion then
   begin
      while True do
      begin
         try
            BaseFolder := ExtractFilePath(FileName);
            if not DirectoryExists(BaseFolder) then
               ForceDirectories(BaseFolder);
         except
         end;
         if DirectoryExists(BaseFolder) then
            Break
         else
         begin
            if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CantCreate'], [BaseFolder], 'Could not create "%s" !')), GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error'), mtError, [mbRetry, mbIgnore], mbIgnore) = mrIgnore then
               Exit;
         end;
      end;
   end;
   t := nil;
   while True do
   try
      t := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
      Break;
   except
      on E: Exception do
      begin
         if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CantCreateOrOpen'], [FileName, E.Message], 'Could not create or open "%s" for writing !'#13#10#13#10'System message: %s')), GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error'), mtError, [mbRetry, mbIgnore], mbIgnore) = mrIgnore then
            Exit;
      end;
   end;
   while True do
   try
      l := Length(s);
      t.Size := 2 * l;
      t.Position := 0;
      t.WriteBuffer(Pointer(s)^, 2 * l);
      psEntries := s;
      Break;
   except
      on E: Exception do
         if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CantWrite'], [FileName, E.Message], 'Could not write into "%s" !'#13#10#13#10'System message: %s')), GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error'), mtError, [mbRetry, mbIgnore], mbIgnore) = mrIgnore then
            Exit;
   end;
   try
      t.Free;
   except
   end;
end;

function TfrmMain.LoadCFG(const FileName: string): Boolean;
var
   i, j, l, p: Integer;
   t: TFileStream;
   ws, wst: string;
   wsa: array of string;
begin
   Result := False;
   t := nil;
   while True do
   try
      t := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
      Break;
   except
      on E: Exception do
      begin
         if CustomMessageBox(Handle, WideFormat('Could not open "%s" for reading !'#13#10#13#10'System message:', [FileName]) + ' ' + E.Message, 'Error', mtError, [mbRetry, mbIgnore], mbIgnore) = mrIgnore then
            Exit;
      end;
   end;
   l := 0;
   while True do
   try
      l := Min(1048576, t.Size div 2);
      SetLength(psCFG, l);
      t.Position := 0;
      t.ReadBuffer(Pointer(psCFG)^, l * 2);
      Break;
   except
      on E: Exception do
         if CustomMessageBox(Handle, WideFormat('Could not read from "%s" !'#13#10#13#10'System message:', [FileName]) + ' ' + E.Message, 'Error', mtError, [mbRetry, mbIgnore], mbIgnore) = mrIgnore then
            Break;
   end;
   try
      t.Free;
   except
   end;

   if psCFG = '' then
      Exit;
   try
      SetLength(wsa, 0);
      p := 2;
      i := PosEx(#13, psCFG, 2);
      while i > 0 do
      begin
         SetLength(wsa, Length(wsa) + 1);
         wsa[High(wsa)] := Trim(Copy(psCFG, p, i - p));
         p := i + 1;
         if i < l then
            if psCFG[i + 1] = #10 then
               Inc(p);
         i := PosEx(#13, psCFG, p);
      end;
      if p <= l then
      begin
         SetLength(wsa, Length(wsa) + 1);
         wsa[High(wsa)] := Trim(Copy(psCFG, p, l - p + 1));
      end;
   except
   end;

   Result := Length(wsa) > 0;

   for i := 0 to High(wsa) do
   begin
      l := Length(wsa[i]);
      if l < 3 then
         Continue;
      if (pos(string('PreviousDPI='), wsa[i]) = 1) and (l > 12) then
      begin
         PreviousDPI := StrToIntDef(Trim(Copy(wsa[i], 13, Min(1000, l - 12))), Screen.PixelsPerInch);
         fDPI := 1.0 * Screen.PixelsPerInch / PreviousDPI;
         if fDPI > 1 then
            fDPI := (fDPI - 1) * (vstVMs.Width / Width) + 1
         else if fDPI < 1 then
            fDPI := 1 - (1 - fDPI) * (vstVMs.Width / Width);
         Constraints.MinWidth := Round(fDPI * Constraints.MinWidth);
         Constraints.MinHeight := Round(fDPI * Constraints.MinHeight);
         Continue;
      end;
      if (pos(string('DriveMessageShowed='), wsa[i]) = 1) and (l > 19) then
      begin
         DriveMessageShowed := StrToBoolDef(Trim(Copy(wsa[i], 20, Min(100, l - 19))), DriveMessageShowed);
         Continue;
      end;
      if (pos(string('StartMessageShowed='), wsa[i]) = 1) and (l > 14) then
      begin
         StartMessageShowed := StrToBoolDef(Trim(Copy(wsa[i], 20, Min(100, l - 19))), StartMessageShowed);
         Continue;
      end;
      if (pos(string('Width='), wsa[i]) = 1) and (l > 6) then
      begin
         MainWidth := StrToIntDef(Trim(Copy(wsa[i], 7, Min(100, l - 6))), MainWidth);
         Continue;
      end;
      if (pos(string('Height='), wsa[i]) = 1) and (l > 7) then
      begin
         MainHeight := StrToIntDef(Trim(Copy(wsa[i], 8, Min(100, l - 7))), MainHeight);
         Continue;
      end;
      if (pos(string('Left='), wsa[i]) = 1) and (l > 5) then
      begin
         MainLeft := StrToIntDef(Trim(Copy(wsa[i], 6, Min(100, l - 5))), Round(10000.0 * (MainLeft - Screen.WorkAreaLeft) / Screen.WorkAreaWidth)) + Screen.WorkAreaLeft;
         Continue;
      end;
      if (pos(string('Top='), wsa[i]) = 1) and (l > 4) then
      begin
         MainTop := StrToIntDef(Trim(Copy(wsa[i], 5, Min(100, l - 4))), Round(10000.0 * (MainTop - Screen.WorkAreaTop) / Screen.WorkAreaHeight)) + Screen.WorkAreaTop;
         Continue;
      end;
      if (pos(string('#ColumnWidth='), wsa[i]) = 1) and (l > 13) then
      begin
         pmHeaders.Items[0].Tag := Min(Max(Round(fDPI * StrToIntDef(Trim(Copy(wsa[i], 14, Min(100, l - 13))), pmHeaders.Items[0].Tag)), 10), MainWidth);
         Continue;
      end;
      if (pos(string('#ColumnShow='), wsa[i]) = 1) and (l > 11) then
      begin
         pmHeaders.Items[0].Checked := StrToBoolDef(Trim(Copy(wsa[i], 13, Min(100, l - 12))), pmHeaders.Items[0].Checked);
         Continue;
      end;
      j := 1;
      while j < pmHeaders.Items.Count do
      begin
         ws := Copy(pmHeaders.Items[j].Name, 3, Length(pmHeaders.Items[j].Name) - 2) + 'ColumnWidth=';
         if (pos(ws, wsa[i]) = 1) and (l > Length(ws)) then
         begin
            pmHeaders.Items[j].Tag := Min(Max(StrToIntDef(Trim(Copy(wsa[i], Length(ws) + 1, Min(100, l - Length(ws)))), pmHeaders.Items[j].Tag), 10), MainWidth);
            Break;
         end;
         ws := Copy(pmHeaders.Items[j].Name, 3, Length(pmHeaders.Items[j].Name) - 2) + 'ColumnShow=';
         if (pos(ws, wsa[i]) = 1) and (l > Length(ws)) then
         begin
            pmHeaders.Items[j].Checked := StrToBoolDef(Trim(Copy(wsa[i], Length(ws) + 1, Min(100, l - Length(ws)))), pmHeaders.Items[j].Checked);
            Break;
         end;
         Inc(j);
      end;
      if j < pmHeaders.Items.Count then
         Continue;
      if (pos(string('WaitTimeToFlush='), wsa[i]) = 1) and (l > 16) then
      begin
         FlushWaitTime := Min(Max(StrToIntDef(Trim(Copy(wsa[i], 17, Min(100, l - 16))), 500), 0), 20000);
         Continue;
      end;
      if (pos(string('LockTheVolumes='), wsa[i]) = 1) and (l > 15) then
      begin
         LockVolumes := StrToBoolDef(Trim(Copy(wsa[i], 16, Min(100, l - 15))), LockVolumes);
         Continue;
      end;
      if (pos(string('ShowSecondDriveOption='), wsa[i]) = 1) and (l > 22) then
      begin
         AddSecondDrive := StrToBoolDef(Trim(Copy(wsa[i], 23, Min(100, l - 22))), AddSecondDrive);
         Continue;
      end;
      if (pos(string('DefaultVMType='), wsa[i]) = 1) and (l > 14) then
      begin
         if Trim(Copy(wsa[i], 15, Min(100, l - 14))) = 'QEMU' then
            DefaultVMType := 1;
         Continue;
      end;
      if (pos(string('ListOnlyUSBDrives='), wsa[i]) = 1) and (l > 18) then
      begin
         ListOnlyUSBDrives := StrToBoolDef(Trim(Copy(wsa[i], 19, Min(100, l - 18))), ListOnlyUSBDrives);
         Continue;
      end;
      if (pos(string('AutomaticFont='), wsa[i]) = 1) and (l > 14) then
      begin
         AutomaticFont := StrToBoolDef(Trim(Copy(wsa[i], 15, Min(100, l - 14))), AutomaticFont);
         Continue;
      end;
      if (pos(string('FontName='), wsa[i]) = 1) and (l > 9) then
      begin
         FontName := AnsiString(Trim(Copy(wsa[i], 10, Min(100, l - 9))));
         if Screen.Fonts.IndexOf(string(FontName)) = -1 then
            FontName := AnsiString(vstVMs.Font.Name);
         Continue;
      end;
      if (pos(string('FontSize='), wsa[i]) = 1) and (l > 9) then
      begin
         FontSize := Min(Max(StrToIntDef(Trim(Copy(wsa[i], 10, Min(100, l - 9))), FontSize), 0), 256);
         Continue;
      end;
      if (pos(string('FontBold='), wsa[i]) = 1) and (l > 9) then
      begin
         FontBold := StrToBoolDef(Trim(Copy(wsa[i], 10, Min(100, l - 9))), FontBold);
         Continue;
      end;
      if (pos(string('FontItalic='), wsa[i]) = 1) and (l > 11) then
      begin
         FontItalic := StrToBoolDef(Trim(Copy(wsa[i], 12, Min(100, l - 11))), FontItalic);
         Continue;
      end;
      if (pos(string('FontUnderline='), wsa[i]) = 1) and (l > 14) then
      begin
         FontUnderline := StrToBoolDef(Trim(Copy(wsa[i], 15, Min(100, l - 14))), FontUnderline);
         Continue;
      end;
      if (pos(string('FontStrikeOut='), wsa[i]) = 1) and (l > 14) then
      begin
         FontStrikeOut := StrToBoolDef(Trim(Copy(wsa[i], 15, Min(100, l - 14))), FontStrikeOut);
         Continue;
      end;
      if (pos(string('FontColor='), wsa[i]) = 1) and (l > 10) then
      begin
         FontColor := Min(Max(StrToIntDef(Trim(Copy(wsa[i], 11, Min(100, l - 10))), FontColor), Low(TColor)), High(TColor));
         Continue;
      end;
      if (pos(string('FontScript='), wsa[i]) = 1) and (l > 11) then
      begin
         FontScript := Min(Max(StrToIntDef(Trim(Copy(wsa[i], 12, Min(100, l - 11))), FontScript), 0), 255);
         Continue;
      end;
      if (pos(string('ShowTrayIcon='), wsa[i]) = 1) and (l > 13) then
      begin
         ShowTrayIcon := StrToBoolDef(Trim(Copy(wsa[i], 14, Min(100, l - 13))), ShowTrayIcon);
         Continue;
      end;
      if (pos(string('EscapeKeyClosesMain='), wsa[i]) = 1) and (l > 20) then
      begin
         EscapeKeyClosesMain := StrToBoolDef(Trim(Copy(wsa[i], 21, Min(100, l - 20))), EscapeKeyClosesMain);
         Continue;
      end;
      if (pos(string('KeyCombStart='), wsa[i]) = 1) and (l > 13) then
      begin
         StartKeyComb := TextToShortcut(Trim(Copy(wsa[i], 14, Min(100, l - 13))));
         Continue;
      end;
      if (pos(string('CurrLanguageFile='), wsa[i]) = 1) and (l > 17) then
      begin
         wst := Trim(Copy(wsa[i], 18, Min(2048, l - 17)));
         if Length(wst) <= 64 then
            CurrLanguageFile := wst
         else
            CurrLanguageFile := Copy(wst, 1, 64);
         Continue;
      end;
      if (pos(string('VirtualBoxPath='), wsa[i]) = 1) and (l > 15) then
      begin
         wst := Trim(Copy(wsa[i], 16, Min(2048, l - 15)));
         if Length(wst) <= 512 then
            ExeVBPath := wst
         else
            ExeVBPath := Copy(wst, 1, 512);
         Continue;
      end;
      if (pos(string('MethodToUpdateTheVM='), wsa[i]) = 1) and (l > 20) then
      begin
         wst := Trim(Copy(wsa[i], 21, Min(1024, l - 20)));
         if wst = 'Use VBoxManage.exe command line (slower)' then
            UpdateVM := 1
         else if wst = 'Directly (faster, but VB Manager must be closed)' then
            UpdateVM := 2
         else if wst = 'Autodetect' then
            UpdateVM := 0
         else
            UpdateVM := 0;
         Continue;
      end;
      if (pos(string('useLoadedFromInstalled='), wsa[i]) = 1) and (l > 23) then
      begin
         useLoadedFromInstalled := StrToBoolDef(Trim(Copy(wsa[i], 24, Min(100, l - 23))), useLoadedFromInstalled);
         Continue;
      end;
      if (pos(string('LoadNetPortable='), wsa[i]) = 1) and (l > 16) then
      begin
         LoadNetPortable := StrToBoolDef(Trim(Copy(wsa[i], 17, Min(100, l - 16))), LoadNetPortable);
         Continue;
      end;
      if (pos(string('LoadUSBPortable='), wsa[i]) = 1) and (l > 16) then
      begin
         LoadUSBPortable := StrToBoolDef(Trim(Copy(wsa[i], 17, Min(100, l - 16))), LoadUSBPortable);
         Continue;
      end;
      if (pos(string('PrecacheVBFiles='), wsa[i]) = 1) and (l > 16) then
      begin
         PrecacheVBFiles := StrToBoolDef(Trim(Copy(wsa[i], 17, Min(100, l - 16))), PrecacheVBFiles);
         Continue;
      end;
      if (pos(string('PrestartVBExeFiles='), wsa[i]) = 1) and (l > 19) then
      begin
         PrestartVBExeFiles := StrToBoolDef(Trim(Copy(wsa[i], 20, Min(100, l - 19))), PrestartVBExeFiles);
         Continue;
      end;
      if (pos(string('RemoveDriveAfterClosing='), wsa[i]) = 1) and (l > 24) then
      begin
         RemoveDrive := StrToBoolDef(Trim(Copy(wsa[i], 25, Min(100, l - 24))), RemoveDrive);
         Continue;
      end;
      if (pos(string('QemuPath='), wsa[i]) = 1) and (l > 9) then
      begin
         wst := Trim(Copy(wsa[i], 10, Min(2048, l - 9)));
         if Length(wst) <= 512 then
            ExeQPath := wst
         else
            ExeQPath := Copy(wst, 1, 512);
         Continue;
      end;
      if (pos(string('HideConsoleWindow='), wsa[i]) = 1) and (l > 18) then
      begin
         HideConsoleWindow := StrToBoolDef(Trim(Copy(wsa[i], 19, Min(100, l - 18))), HideConsoleWindow);
         Continue;
      end;
      if (pos(string('EmulationBusType='), wsa[i]) = 1) and (l > 17) then
      begin
         EmulationBusType := Min(Max(StrToIntDef(Trim(Copy(wsa[i], 18, Min(100, l - 17))), EmulationBusType), 0), 1);
         Continue;
      end;
      if (pos(string('QemuDefaultParameters='), wsa[i]) = 1) and (l > 22) then
      begin
         wst := Trim(Copy(wsa[i], 23, Min(20480, l - 22)));
         if Length(wst) <= 10240 then
            QEMUDefaultParameters := wst
         else
            QEMUDefaultParameters := Copy(wst, 1, 10240);
         Continue;
      end;
      if (pos(string('LastSelected='), wsa[i]) = 1) and (l > 13) then
         LastSelected := Min(Max(StrToIntDef(Trim(Copy(wsa[i], 14, Min(10, l - 13))), 0), -1), 65535);
   end;
   MainWidth := Min(Max(Round(fDPI * MainWidth), Constraints.MinWidth), Screen.WorkAreaWidth);
   MainHeight := Min(Max(Round(fDPI * MainHeight), Constraints.MinHeight), Screen.WorkAreaHeight);
   MainLeft := Min(Max(Round(0.0001 * Screen.WorkAreaWidth * MainLeft), Screen.WorkAreaLeft), Screen.WorkAreaWidth - MainWidth);
   MainTop := Min(Max(Round(0.0001 * Screen.WorkAreaHeight * MainTop), Screen.WorkAreaTop), Screen.WorkAreaHeight - MainHeight);
end;

procedure TfrmMain.SaveCFG(const FileName: string);
var
   i, l: Integer;
   t: TFileStream;
   ws, wsVMUpdate: string;
   BaseFolder: string;
   sDefaultVMType: AnsiString;
begin
   ws := #65279;
   if WindowState <> wsNormal then
      ws := ws + 'Width=' + IntToStr(IntWidth) + #13#10'Height=' + IntToStr(IntHeight) + #13#10'Left=' + IntToStr(Round(10000.0 * (IntLeft - Screen.WorkAreaLeft) / Screen.WorkAreaWidth)) + #13#10'Top=' + IntToStr(Round(10000.0 * (IntTop - Screen.WorkAreaTop) / Screen.WorkAreaHeight))
   else
      ws := ws + 'Width=' + IntToStr(Width) + #13#10'Height=' + IntToStr(Height) + #13#10'Left=' + IntToStr(Round(10000.0 * (Left - Screen.WorkAreaLeft) / Screen.WorkAreaWidth)) + #13#10'Top=' + IntToStr(Round(10000.0 * (Top - Screen.WorkAreaTop) / Screen.WorkAreaHeight));
   ws := ws + #13#10'#ColumnWidth=' + IntToStr(vstVMs.Header.Columns[0].Width) + #13#10'#ColumnShow=' + IntToStr(Integer(mmCrt.Checked));
   for i := 1 to pmHeaders.Items.Count - 1 do
      ws := ws + #13#10 + Copy(pmHeaders.Items[i].Name, 3, Length(pmHeaders.Items[i].Name) - 2) + 'ColumnWidth=' + IntToStr(vstVMs.Header.Columns[i].Width) + #13#10 + Copy(pmHeaders.Items[i].Name, 3, Length(pmHeaders.Items[i].Name) - 2) + 'ColumnShow=' + IntToStr(Integer(pmHeaders.Items[i].Checked));
   case UpdateVM of
      1:
         wsVMUpdate := 'Use VBoxManage.exe command line (slower)';
      2:
         wsVMUpdate := 'Directly (faster, but VB Manager must be closed)';
      else
         wsVMUpdate := 'Autodetect';
   end;
   if DefaultVMType = 0 then
      sDefaultVMType := 'VirtualBox'
   else
      sDefaultVMType := 'QEMU';
   ws := ws + #13#10'WaitTimeToFlush=' + IntToStr(FlushWaitTime) + #13#10'LockTheVolumes=' + IntToStr(Integer(LockVolumes)) + #13#10'ShowSecondDriveOption=' + IntToStr(Integer(AddSecondDrive)) + #13#10'DefaultVMType=' + string(sDefaultVMType) + #13#10'ListOnlyUSBDrives=' + IntToStr(Integer(ListOnlyUSBDrives)) + #13#10'AutomaticFont=' + IntToStr(Integer(AutomaticFont)) + #13#10'FontName=' + string(FontName) + #13#10'FontSize=' + IntToStr(FontSize) + #13#10'FontBold=' + IntToStr(Integer(FontBold)) + #13#10'FontItalic=' + IntToStr(Integer(FontItalic)) + #13#10'FontUnderline=' + IntToStr(Integer(FontUnderline)) + #13#10'FontStrikeOut=' + IntToStr(Integer(FontStrikeOut)) + #13#10'FontColor=' + IntToStr(Integer(FontColor)) + #13#10'FontScript=' + IntToStr(Integer(FontScript)) + #13#10'ShowTrayIcon=' + IntToStr(Integer(ShowTrayIcon)) + #13#10'EscapeKeyClosesMain=' + IntToStr(Integer(EscapeKeyClosesMain)) +
      #13#10'KeyCombStart=' + ShortcutToText(StartKeyComb) + #13#10'CurrLanguageFile=' + CurrLanguageFile + #13#10'VirtualBoxPath=' + ExeVBPath + #13#10'MethodToUpdateTheVM=' + wsVMUpdate + #13#10'useLoadedFromInstalled=' + IntToStr(Integer(useLoadedFromInstalled)) + #13#10'LoadNetPortable=' + IntToStr(Integer(LoadNetPortable)) + #13#10'LoadUSBPortable=' + IntToStr(Integer(LoadUSBPortable)) + #13#10'PrecacheVBFiles=' + IntToStr(Integer(PrecacheVBFiles)) + #13#10'PrestartVBExeFiles=' + IntToStr(Integer(PrestartVBExeFiles)) + #13#10'RemoveDriveAfterClosing=' + IntToStr(Integer(RemoveDrive)) + #13#10'QemuPath=' + ExeQPath + #13#10'HideConsoleWindow=' + IntToStr(Integer(HideConsoleWindow)) + #13#10'EmulationBusType=' + IntToStr(EmulationBusType) + #13#10'QemuDefaultParameters=' + QEMUDefaultParameters + #13#10'LastSelected=' + IntToStr(GetItemIndex) + #13#10'DriveMessageShowed=' + IntToStr(Integer(DriveMessageShowed)) + #13#10'StartMessageShowed=' + IntToStr(Integer(StartMessageShowed));
   ws := ws + #13#10'PreviousDPI=' + IntToStr(Screen.PixelsPerInch);
   if isInstalledVersion then
   begin
      while True do
      begin
         try
            BaseFolder := ExtractFilePath(FileName);
            if not DirectoryExists(BaseFolder) then
               ForceDirectories(BaseFolder);
         except
         end;
         if DirectoryExists(BaseFolder) then
            Break
         else
         begin
            if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CantCreate'], [BaseFolder], 'Could not create "%s" !')), GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error'), mtError, [mbRetry, mbIgnore], mbIgnore) = mrIgnore then
               Exit;
         end;
      end;
   end;
   if ws = psCFG then
      Exit;
   t := nil;
   while True do
   try
      t := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
      Break;
   except
      on E: Exception do
      begin
         if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CantCreateOrOpen'], [FileName, E.Message], 'Could not create or open "%s" for writing !'#13#10#13#10'System message: %s')), GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error'), mtError, [mbRetry, mbIgnore], mbIgnore) = mrIgnore then
            Exit;
      end;
   end;
   while True do
   try
      l := Length(ws);
      t.Size := 2 * l;
      t.Position := 0;
      t.WriteBuffer(Pointer(ws)^, 2 * l);
      psCFG := ws;
      Break;
   except
      on E: Exception do
         if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CantWrite'], [FileName, E.Message], 'Could not write into "%s" !'#13#10#13#10'System message: %s')), GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error'), mtError, [mbRetry, mbIgnore], mbIgnore) = mrIgnore then
            Exit;
   end;
   try
      t.Free;
   except
   end;
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
   ReallyClose := True;
   try
      Close;
   finally
      ReallyClose := False;
   end;
   if Application.Terminated then
      Exit;
   if isBusyStartVM then
   begin
      btnStart.Down := True;
      if Assigned(Sender) and (Sender is TPngSpeedButton) and ((Sender as TPngSpeedButton).Name <> 'btnStart') then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if IsBusyManager then
   begin
      btnManager.Down := True;
      if Assigned(Sender) and (Sender is TPngSpeedButton) and ((Sender as TPngSpeedButton).Name <> 'btnStart') then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if IsBusyEjecting then
   begin
      if Assigned(Sender) and (Sender is TPngSpeedButton) and ((Sender as TPngSpeedButton).Name <> 'btnStart') then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
end;

procedure TfrmMain.btnManagerClick(Sender: TObject);
var
   Data: PData;
   button: TControl;
   lowerLeft: TPoint;
begin
   if isBusyStartVM then
   begin
      btnStart.Down := True;
      (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if IsBusyManager then
   begin
      btnStart.Down := False;
      (Sender as TPngSpeedButton).Down := True;
      Exit;
   end;
   if IsBusyEjecting then
   begin
      (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if vstVMs.GetFirstSelected = nil then
   begin
      button := TControl(Sender);
      lowerLeft := Point(0, button.Height);
      lowerLeft := button.ClientToScreen(lowerLeft);
      lowerLeft.X := lowerLeft.X + (Sender as TPngSpeedButton).Margin + ((Sender as TPngSpeedButton).PngImage.Width - 16) div 2;
      if FIsAeroEnabled and (TOsVersion.Major >= 6) then
         Dec(lowerLeft.X, 1 + DlgOffsPos);
      if TOsVersion.Major < 6 then
         Dec(lowerLeft.X, 4);
      pmManagers.Popup(lowerLeft.X, lowerLeft.Y - 3);
      btnManager.Down := False;
   end
   else
   begin
      Data := vstVMs.GetNodeData(vstVMs.GetFirstSelected);
      if Data^.Ptype = 0 then
         StartManagersClick(mmVirtualBoxManager)
      else
         StartManagersClick(mmQEMUManager);
   end;
end;

procedure TfrmMain.btnAddClick(Sender: TObject);
var
   i, p, cp, l, n1, n2, n3, a: Integer;
   strTemp: AnsiString;
   ws, wst, FolderName: string;
   Node: PVirtualNode;
   Data: PData;
begin
   if isBusyStartVM then
   begin
      btnStart.Down := True;
      if Sender is TPngSpeedButton then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if IsBusyManager then
   begin
      btnManager.Down := True;
      if Sender is TPngSpeedButton then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if IsBusyEjecting then
   begin
      if Sender is TPngSpeedButton then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   btnAdd.Down := True;
   try
      try
         ColWereAligned := vstVMs.Header.Columns.TotalWidth = vstVMs.ClientWidth;
         with frmAddEdit do
         begin
            if frmAddEdit = nil then
               Application.CreateForm(TfrmAddEdit, frmAddEdit)
            else
            begin
               cmbMode.ItemIndex := 0;
               if sbVirtualBox.Down then
                  cmbModeChange(cmbMode)
               else
                  sbVirtualBox.Click;
               edtExeParams.Text := '';
               cmbVMName.ItemIndex := 0;
               edtVMPath.Text := '';
               cmbFirstDrive.ItemIndex := 0;
               cmbSecondDrive.ItemIndex := 0;
               cmbCache.ItemIndex := 0;
               cmbEnableCPUVirtualization.ItemIndex := 0;
               edtHDD.Text := '';
               edtMemory.Text := '512';
               cmbAudio.ItemIndex := 1;
               cmbWS.ItemIndex := 0;
               cmbPriority.ItemIndex := 1;
            end;
            Caption := GetLangTextDef(idxAddEdit, ['Caption', 'Add'], 'Add');
            isEdit := False;
            if DefaultVMType = 1 then
               sbQEMU.Click;
            Left := frmMain.Left + ((frmMain.Width - Width) div 2) - DlgOffsPos;
            if Left < Screen.WorkAreaLeft then
               Left := Screen.WorkAreaLeft + DlgOffsPos
            else if Left + Width > Screen.WorkAreaRect.Right then
               Left := Screen.WorkAreaRect.Right - Width - DlgOffsPos;

            Top := frmMain.Top + ((frmMain.Height - Height) div 2) - DlgOffsPos;
            if Top < Screen.WorkAreaTop then
               Top := Screen.WorkAreaTop + DlgOffsPos
            else if Top + Height > Screen.WorkAreaRect.Bottom then
               Top := Screen.WorkAreaRect.Bottom - Height - DlgOffsPos;
            if ShowModal = mrOk then
            begin
               Node := vstVMs.AddChild(nil);
               Data := vstVMs.GetNodeData(Node);
               with Data^ do
               begin
                  Ptype := Byte(not sbVirtualBox.Down);
                  if sbVirtualBox.Down then
                  begin
                     ModeLoadVM := cmbMode.ItemIndex;
                     case ModeLoadVM of
                        0:
                           begin
                              VMName := VMIDs[cmbVMName.ItemIndex - 2].Name;
                              VMID := string(VMIDs[cmbVMName.ItemIndex - 2].ID);
                              FolderName := '';
                              with frmMain.xmlGen do
                              begin
                                 if Tag = 1 then
                                 try
                                    Active := True;
                                    n1 := ChildNodes.IndexOf('VirtualBox');
                                    if n1 > -1 then
                                    begin
                                       n2 := ChildNodes[n1].ChildNodes.IndexOf('Global');
                                       if n2 > -1 then
                                       begin
                                          n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('SystemProperties');
                                          if n3 > -1 then
                                          begin
                                             a := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes.IndexOf('defaultMachineFolder');
                                             if a > -1 then
                                             begin
                                                FolderName := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes[a].Text;
                                                l := Length(FolderName);
                                                Replacebks(FolderName, l);
                                             end;
                                          end;
                                       end;
                                    end;
                                 except
                                 end;
                                 Active := False;
                              end;

                              if DirectoryExists(FolderName) then
                                 VMPath := FolderName + '\' + VMName + '\' + VMName + '.vbox'
                              else
                                 VMPath := '';
                           end;
                        1:
                           begin
                              VMPath := Trim(edtVMPath.Text);
                              VMName := ChangeFileExt(ExtractFileName(VMPath), '');
                              i := 0;
                              while i <= High(VMIDs) do
                              begin
                                 if VMIDs[i].Name = VMName then
                                    Break;
                                 Inc(i);
                              end;
                              VMID := string(VMIDs[i].ID);
                           end;
                        2:
                           begin
                              ws := Trim(edtExeParams.Text);
                              p := pos(string('--startvm "'), ws);
                              l := Length(ws);
                              if (p > 0) and ((p + 11) < l) then
                              begin
                                 cp := PosEx('"', ws, p + 11);
                                 if cp > 0 then
                                    ws := Trim(Copy(ws, p + 11, cp - p - 11))
                                 else
                                    ws := '';
                              end
                              else
                                 ws := '';
                              if FileExists(ws) then
                              begin
                                 wst := ChangeFileExt(ExtractFileName(ws), '');
                                 GetNamesAndIDs;
                                 i := 0;
                                 while i <= High(VMIDs) do
                                 begin
                                    if VMIDs[i].Name = wst then
                                       Break;
                                    Inc(i);
                                 end;
                                 if i <= High(VMIDs) then
                                 begin
                                    VMName := VMIDs[i].Name;
                                    VMID := string(VMIDs[i].ID);
                                    VMPath := ws;
                                 end;
                              end
                              else
                              begin
                                 wst := '';
                                 with frmMain.xmlGen do
                                 begin
                                    if Tag = 1 then
                                    try
                                       Active := True;
                                       n1 := ChildNodes.IndexOf('VirtualBox');
                                       if n1 > -1 then
                                       begin
                                          n2 := ChildNodes[n1].ChildNodes.IndexOf('Global');
                                          if n2 > -1 then
                                          begin
                                             n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('SystemProperties');
                                             if n3 > -1 then
                                             begin
                                                a := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes.IndexOf('defaultMachineFolder');
                                                if a > -1 then
                                                begin
                                                   wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes[a].Text;
                                                   Replacebks(wst, Length(wst));
                                                end;
                                             end;
                                          end;
                                       end;
                                    except
                                    end;
                                    Active := False;
                                 end;

                                 if (ExtractFileName(ws) = ws) and (ExtractFileExt(ws) <> '') and FileExists(wst + '\' + ChangeFileExt(ws, '') + '\' + ws) then
                                 begin
                                    VMPath := wst + '\' + ChangeFileExt(ws, '') + '\' + ws;
                                    wst := ChangeFileExt(ExtractFileName(ws), '');
                                    GetNamesAndIDs;
                                    i := 0;
                                    while i <= High(VMIDs) do
                                    begin
                                       if VMIDs[i].Name = wst then
                                          Break;
                                       Inc(i);
                                    end;
                                    if i <= High(VMIDs) then
                                    begin
                                       VMName := VMIDs[i].Name;
                                       VMID := string(VMIDs[i].ID);
                                    end
                                    else
                                    begin
                                       VMName := '';
                                       VMID := '';
                                       VMPath := '';
                                    end;
                                 end
                                 else if (ExtractFileName(ws) = ws) and (ExtractFileExt(ws) = '') and FileExists(wst + '\' + ws + '\' + ws + '.vbox') then
                                 begin
                                    VMPath := wst + '\' + ws + '\' + ws + '.vbox';
                                    wst := ChangeFileExt(ExtractFileName(ws), '');
                                    GetNamesAndIDs;
                                    i := 0;
                                    while i <= High(VMIDs) do
                                    begin
                                       if VMIDs[i].Name = wst then
                                          Break;
                                       Inc(i);
                                    end;
                                    if i <= High(VMIDs) then
                                    begin
                                       VMName := VMIDs[i].Name;
                                       VMID := string(VMIDs[i].ID);
                                    end
                                    else
                                    begin
                                       VMName := '';
                                       VMPath := '';
                                       VMID := '';
                                    end;
                                 end
                                 else if isGUID(ws) then
                                 begin
                                    i := 0;
                                    while i <= High(VMIDs) do
                                    begin
                                       if string(VMIDs[i].ID) = ws then
                                          Break;
                                       Inc(i);
                                    end;
                                    if i <= High(VMIDs) then
                                    begin
                                       VMName := VMIDs[i].Name;
                                       VMID := string(VMIDs[i].ID);
                                       FolderName := '';
                                       with frmMain.xmlGen do
                                       begin
                                          if Tag = 1 then
                                          try
                                             Active := True;
                                             n1 := ChildNodes.IndexOf('VirtualBox');
                                             if n1 > -1 then
                                             begin
                                                n2 := ChildNodes[n1].ChildNodes.IndexOf('Global');
                                                if n2 > -1 then
                                                begin
                                                   n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('SystemProperties');
                                                   if n3 > -1 then
                                                   begin
                                                      a := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes.IndexOf('defaultMachineFolder');
                                                      if a > -1 then
                                                      begin
                                                         FolderName := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes[a].Text;
                                                         l := Length(FolderName);
                                                         Replacebks(FolderName, l);
                                                      end;
                                                   end;
                                                end;
                                             end;
                                          except
                                          end;
                                          Active := False;
                                       end;

                                       if DirectoryExists(FolderName) then
                                          VMPath := FolderName + '\' + VMName + '\' + VMName + '.vbox'
                                       else
                                          VMPath := '';
                                    end;
                                 end;
                              end;
                           end;
                     end;

                  end
                  else
                  begin
                     ModeLoadVM := 2;
                     VMID := '';
                     VMPath := '';
                     ws := Trim(edtExeParams.Text);
                     p := pos(string('-name "'), ws);
                     l := Length(ws);
                     if (p > 0) and ((p + 7) < l) then
                     begin
                        cp := PosEx('"', ws, p + 7);
                        if cp > 0 then
                           ws := Trim(Copy(ws, p + 7, cp - p - 7))
                        else
                           ws := '';
                     end
                     else
                        ws := '';
                     VMName := ws;
                  end;
                  ExeParams := Trim(edtExeParams.Text);
                  FirstDriveFound := True;
                  if cmbFirstDrive.ItemIndex > 0 then
                  begin
                     strTemp := AnsiString(cmbFirstDrive.Text);
                     i := pos(string(',  ['), string(strTemp));
                     if i = 0 then
                        FirstDriveName := strTemp
                     else
                        FirstDriveName := Copy(strTemp, 1, i - 1);
                     i := Length(GetStrBusType(aDL[cmbFirstDrive.ItemIndex].BusType));
                     if i > 0 then
                        FirstDriveName := Copy(FirstDriveName, i + 3, Length(FirstDriveName) - i - 2);
                  end
                  else
                     FirstDriveName := '';
                  FirstDriveBusType := aDL[cmbFirstDrive.ItemIndex].BusType;
                  FirstDriveNumber := aDL[cmbFirstDrive.ItemIndex].Number;
                  FDMountPointsStr := CBFirstDriveLetters[cmbFirstDrive.ItemIndex - 1];
                  SetLength(FDMountPointsArr, Length(aDL[cmbFirstDrive.ItemIndex].VolPaths));
                  for i := 0 to High(aDL[cmbFirstDrive.ItemIndex].VolPaths) do
                     FDMountPointsArr[i] := aDL[cmbFirstDrive.ItemIndex].VolPaths[i];
                  if AddSecondDrive then
                  begin
                     if cmbSecondDrive.ItemIndex > 0 then
                     begin
                        strTemp := AnsiString(cmbSecondDrive.Text);
                        i := pos(string(',  ['), string(strTemp));
                        if i = 0 then
                           SecondDriveName := strTemp
                        else
                           SecondDriveName := Copy(strTemp, 1, i - 1);
                        i := Length(GetStrBusType(aDL[cmbSecondDrive.ItemIndex].BusType));
                        if i > 0 then
                           SecondDriveName := Copy(SecondDriveName, i + 3, Length(SecondDriveName) - i - 2);
                        SecondDriveFound := True;
                        SDMountPointsStr := CBSecondDriveLetters[cmbSecondDrive.ItemIndex - 1];
                        SetLength(SDMountPointsArr, Length(aDL[cmbSecondDrive.ItemIndex].VolPaths));
                        for i := 0 to High(aDL[cmbSecondDrive.ItemIndex].VolPaths) do
                           SDMountPointsArr[i] := aDL[cmbSEcondDrive.ItemIndex].VolPaths[i];
                        SecondDriveBusType := aDL[cmbSecondDrive.ItemIndex].BusType;
                        SecondDriveNumber := aDL[cmbSecondDrive.ItemIndex].Number;
                     end
                     else
                     begin
                        SecondDriveName := '';
                        SecondDriveFound := False;
                        SecondDriveNumber := -1;
                        SDMountPointsStr := '[ ]';
                        SetLength(SDMountPointsArr, 0);
                     end;
                  end;
                  UseHostIOCache := cmbCache.ItemIndex = 1;
                  InternalHDD := Trim(edtHDD.Text);
                  if cmbCDROM.ItemIndex = 0 then
                  begin
                     CDROMName := '';
                     CDROMType := 0;
                  end
                  else if CDDVDType = 0 then
                  begin
                     CDROMName := Copy(cmbCDROM.Items[cmbCDROM.ItemIndex], 1, Length(cmbCDROM.Items[cmbCDROM.ItemIndex]) - 8);
                     CDROMType := 0;
                  end
                  else
                  begin
                     CDROMName := TMyObj(cmbCDROM.Items.Objects[cmbCDROM.Items.Count - 1]).Text;
                     CDROMType := 1;
                  end;
                  MemorySize := Min(Max(StrToIntDef(edtMemory.Text, 512), 1), 65535);
                  AudioCard := cmbAudio.ItemIndex;
                  RunAs := cmbWS.ItemIndex;
                  VBCPUVirtualization := cmbEnableCPUVirtualization.ItemIndex;
                  CPUPriority := cmbPriority.ItemIndex;
                  luIDS.fdCID := '';
                  luIDS.fdGUID := '';
                  luIDS.sdCID := '';
                  luIDS.sdGUID := '';
                  vstVMs.BeginUpdate; //
                  FVMImageIndex := Ptype;
                  FVName := VMName;
                  FDDisplayName := string(FirstDriveName);
                  l := Length(FDDisplayName);
                  i := l;
                  while i > 2 do
                  begin
                     if (FDDisplayName[i - 2] = ',') and (FDDisplayName[i - 1] = ' ') and CharInSet(FDDisplayName[i], ['0'..'9']) then
                     begin
                        Insert(' ', FDDisplayName, i - 1);
                        Inc(l);
                        Break;
                     end;
                     Dec(i);
                  end;
                  if l >= 3 then
                     if FDDisplayName[l] = 'B' then
                        if CharInSet(FDDisplayName[l - 1], ['G', 'M', 'T']) then
                           if FDDisplayName[l - 2] = ' ' then
                              FDDisplayName[l - 2] := HalfSpaceCharVST;
                  SDDisplayName := string(SecondDriveName);
                  l := Length(SDDisplayName);
                  i := l;
                  while i > 2 do
                  begin
                     if (SDDisplayName[i - 2] = ',') and (SDDisplayName[i - 1] = ' ') and CharInSet(SDDisplayName[i], ['0'..'9']) then
                     begin
                        Insert(' ', SDDisplayName, i - 1);
                        Inc(l);
                        Break;
                     end;
                     Dec(i);
                  end;
                  if l >= 3 then
                     if SDDisplayName[l] = 'B' then
                        if CharInSet(SDDisplayName[l - 1], ['G', 'M', 'T']) then
                           if SDDisplayName[l - 2] = ' ' then
                              SDDisplayName[l - 2] := HalfSpaceCharVST;
                  if FirstDriveName = '' then
                     FFDImageIndex := -1
                  else if FirstDriveFound then
                  begin
                     if ListOnlyUSBDrives then
                     begin
                        if FirstDriveBusType = 7 then
                           FFDImageIndex := 2
                        else
                           FFDImageIndex := 3;
                     end
                     else
                        case FirstDriveBusType of
                           1:
                              FFDImageIndex := 10;
                           4:
                              FFDImageIndex := 12;
                           7:
                              FFDImageIndex := 4;
                           8: FFDImageIndex := 14;
                           14, 15:
                              FFDImageIndex := 8;
                           else
                              FFDImageIndex := 6;
                        end;
                  end
                  else if ListOnlyUSBDrives then
                     FFDImageIndex := 3
                  else
                     case FirstDriveBusType of
                        1:
                           FFDImageIndex := 11;
                        4:
                           FFDImageIndex := 13;
                        7:
                           FFDImageIndex := 5;
                        8: FFDImageIndex := 15;
                        14, 15:
                           FFDImageIndex := 9;
                        else
                           FFDImageIndex := 7;
                     end;

                  if SecondDriveName = '' then
                     FSDImageIndex := -1
                  else if SecondDriveFound then
                  begin
                     if ListOnlyUSBDrives then
                     begin
                        if SecondDriveBusType = 7 then
                           FSDImageIndex := 2
                        else
                           FSDImageIndex := 3;
                     end
                     else
                        case SecondDriveBusType of
                           1:
                              FSDImageIndex := 10;
                           4:
                              FSDImageIndex := 12;
                           7:
                              FSDImageIndex := 4;
                           8: FSDImageIndex := 14;
                           14, 15:
                              FSDImageIndex := 8;
                           else
                              FSDImageIndex := 6;
                        end;
                  end
                  else if ListOnlyUSBDrives then
                     FSDImageIndex := 3
                  else
                     case SecondDriveBusType of
                        1:
                           FSDImageIndex := 11;
                        4:
                           FSDImageIndex := 13;
                        7:
                           FSDImageIndex := 5;
                        8: FSDImageIndex := 15;
                        14, 15:
                           FSDImageIndex := 9;
                        else
                           FSDImageIndex := 7;
                     end;
               end;
               vstVMs.Selected[Node] := True;
               vstVMs.FocusedNode := Node;
               vstVMs.ScrollIntoView(Node, False);
               if Length(IntToStr(vstVMs.RootNodeCount)) <> Length(IntToStr(vstVMs.RootNodeCount - 1)) then
               begin
                  mmCrt.Tag := Max(vstVMs.Header.Height, Round(2 * vstVMs.Margin + 2 + vstVMs.Canvas.TextWidth('H') * (0.5 + Length(IntToStr(vstVMs.RootNodeCount)))));
                  vstVMs.Header.Columns[0].MaxWidth := mmCrt.Tag;
                  vstVMs.Header.Columns[0].MinWidth := mmCrt.Tag;
                  vstVMs.Header.Columns[0].MaxWidth := mmCrt.Tag;
                  vstVMs.Header.Columns[0].Width := mmCrt.Tag;
                  Node := vstVMs.GetFirst;
                  while Node <> nil do
                  begin
                     Data := vstVMs.GetNodeData(Node);
                     if (vstVMs.RootNodeCount < 10) or (Node.Index > 8) then
                        Data^.FId := IntToStr(Node.Index + 1)
                     else
                        Data^.FId := '0' + IntToStr(Node.Index + 1);
                     Node := vstVMs.GetNext(Node);
                  end;
                  if ColWereAligned then
                     RealignColumns(False);
               end
               else if (vstVMs.RootNodeCount < 10) or (Node.Index > 8) then
                  Data^.FId := IntToStr(Node.Index + 1)
               else
                  Data^.FId := '0' + IntToStr(Node.Index + 1);
               vstVMs.EndUpdate; //
               vstVMs.Invalidate;
               SaveVMentries(VMentriesFile);
            end;
         end;
      finally
         frmAddEdit.Free;
         frmAddEdit := nil;
      end;
   except
   end;
   btnAdd.Down := False;
end;

function IsAeroEnabled: Boolean;
type
   TDwmIsCompositionEnabledFunc = function(out pfEnabled: BOOL): HRESULT; stdcall;
var
   IsEnabled: BOOL;
   ModuleHandle: HMODULE;
   DwmIsCompositionEnabledFunc: TDwmIsCompositionEnabledFunc;
begin
   Result := False;
   try
      if TOSversion.Major >= 6 then
      begin
         ModuleHandle := LoadLibrary('dwmapi.dll');
         if ModuleHandle <> 0 then
         try
            @DwmIsCompositionEnabledFunc := GetProcAddress(ModuleHandle, 'DwmIsCompositionEnabled');
            if Assigned(DwmIsCompositionEnabledFunc) then
               if DwmIsCompositionEnabledFunc(IsEnabled) = S_OK then
                  Result := IsEnabled;
         finally
            FreeLibrary(ModuleHandle);
         end;
      end;
   except
   end;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
   i, h, r, cm, cvm, p: Integer;
   dt, wt: Cardinal;
begin
   if isBusyClosing then
   begin
      CanClose := False;
      Exit;
   end;
   if TrayIcon.Visible and (not ReallyClose) then
   begin
      CanClose := False;
      if not IsIconic(Application.Handle) then
         SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
      Exit;
   end;
   if isBusyStartVM or isBusyManager or IsBusyEjecting then
      if CustomMessageBox(Handle, GetLangTextDef(idxMain, ['Messages', 'SureClose'], 'Are you sure you want to close the application?'), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbYes, mbNo], mbNo) <> mrYes then
         CanClose := False;
   if isVBPortable then
   begin
      while True do
      begin
         GetAllWindowsList(VBWinClass);
         h := High(AllWindowsList);
         i := 0;
         cm := 0;
         cvm := 0;
         while i <= h do
         begin
            if IsWindowVisible(AllWindowsList[i].Handle) then
            begin
               p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
               if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                  Inc(cm)
               else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                  Inc(cvm);
            end;
            Inc(i);
         end;
         if (cm + cvm) > 0 then
         begin
            r := CustomMessageBox(Handle, GetLangTextDef(idxMain, ['Messages', 'ProperRegUnreg'], 'In order to properly (un)register VirtualBox dlls, infs and services'#13#10'for the portable version, all the VirtualBox windows have to be closed!' +
               #13#10#13#10'You can choose to Abort, close all VirtualBox windows manually and click on Retry,'#13#10'click on Ignore to not unregister or click on Close all to automatically close them'), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbAbort, mbRetry, mbNoToAll, mbIgnore], mbAbort);
            case r of
               mrRetry: Continue;
               mrNoToAll:
                  begin
                     isBusyClosing := True;
                     try
                        GetAllWindowsList(VBWinClass);
                        h := High(AllWindowsList);
                        i := 0;
                        cm := 0;
                        cvm := 0;
                        while i <= h do
                        begin
                           if IsWindowVisible(AllWindowsList[i].Handle) then
                           begin
                              p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
                              if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                              begin
                                 PostMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
                                 Inc(cm);
                              end
                              else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                              begin
                                 PostMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
                                 Inc(cvm);
                              end;
                           end;
                           Inc(i);
                        end;
                        if (cm + cvm) > 0 then
                        begin
                           dt := GetTickCount;
                           wt := 2000 * cm + 5000 * cvm;
                           while True do
                           begin
                              Wait(100);
                              if (GetTickCount - dt) > wt then
                                 Break;
                              GetAllWindowsList(VBWinClass);
                              h := High(AllWindowsList);
                              i := 0;
                              cm := 0;
                              cvm := 0;
                              while i <= h do
                              begin
                                 if IsWindowVisible(AllWindowsList[i].Handle) then
                                 begin
                                    p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
                                    if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                       Inc(cm)
                                    else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                       Inc(cvm);
                                 end;
                                 Inc(i);
                              end;
                              if (cm + cvm) = 0 then
                              begin
                                 CanClose := True;
                                 Exit;
                              end;
                           end;
                        end;
                     finally
                        isBusyClosing := False;
                     end;
                  end;
               mrIgnore:
                  begin
                     DoNotUnregister := True;
                     CanClose := True;
                     Exit;
                  end;
               else
                  CanClose := False;
                  Exit;
            end;
         end
         else
         begin
            CanClose := True;
            Break;
         end;
      end;
   end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
   i, j, indmin, l: Integer;
   prc, prevprc: Double;
   ws: string;
   c: Char;
   hVolume: THandle;
   dwBytesReturned: DWORD;
   sdn: STORAGE_DEVICE_NUMBER;
   ErrorMode: Word;
   SysMenu: HMenu;
   Data: PData;
   Node: PVirtualNode;
   NCM: TNonClientMetrics;
   FontHeight: Integer;
   Path: array[0..MAX_PATH - 1] of Char;
   MySystem: TSystemInfo;
begin
   Application.OnException := AppException;
   DragAcceptFiles(WindowHandle, True);
   FIsAeroEnabled := IsAeroEnabled;
   DoubleBuffered := not FIsAeroEnabled;
   try
      if FIsAeroEnabled then
      begin
         NCM.cbSize := SizeOf(NCM);
         SystemParametersInfo(SPI_GETNONCLIENTMETRICS, SizeOf(NCM), @NCM, 0);
         DlgOffsPos := NCM.iBorderWidth + NCM.iPaddedBorderWidth;
      end
      else
         DlgOffsPos := 0;
   except
   end;

   GetSystemInfo(MySystem);
   NumberOfProcessors := Max(1, MySystem.dwNumberOfProcessors);

   vstVMs.DoubleBuffered := DoubleBuffered;
   vstVMs.NodeDataSize := SizeOf(TData);
   pnlBackground.DoubleBuffered := DoubleBuffered;

   SystemIconSize := GetSystemMetrics(SM_CXSMICON);
   SnapResize := Round(10.0 * Screen.PixelsPerInch / 96);

   mEvent := TEvent.Create(nil, True, False, '');

   if (TOSversion.Major < 6) or ((TOSversion.Major = 6) and (TOSversion.Minor < 2)) then
   begin
      vstVMs.Header.Options := vstVMs.Header.Options - [hoOwnerDraw];
      vstVMs.OnAdvancedHeaderDraw := nil;
      vstVMs.OnHeaderDrawQueryElements := nil;
   end;
   Application.Title := Application.Title + appVersion;
   Caption := Application.Title;
   fOldTWndMethod := WindowProc;
   WindowProc := WindProc;

   Canvas.Font.Assign(Font);
   i := 8192;
   l := Canvas.TextWidth('  ') div 2;
   prevprc := 50;
   indmin := -1;
   while i <= 8202 do
   begin
      prc := 100.0 * (Canvas.TextWidth(Char(i) + Char(i)) - l) / l;
      if prc < 0 then
         prc := -0.75 * prc;
      if prc < prevprc then
      begin
         prevprc := prc;
         indmin := i;
      end;
      Inc(i);
   end;
   if indmin > -1 then
      HalfSpaceCharMSG := Char(indmin)
   else
      HalfSpaceCharMSG := ' ';
   if (TOSversion.Architecture = arIntelX64) and (((TOSVersion.Major = 6) and (TOSVersion.Minor >= 1)) or (TOSVersion.Major >= 7)) then
   begin
      envProgramFiles := GetEnvVarValue('ProgramW6432');
      envProgramFilesx86 := GetEnvVarValue('ProgramFiles(x86)');
      if envProgramFiles = '' then
         envProgramFiles := 'c:\Program Files';
      if envProgramFilesx86 = '' then
         envProgramFilesx86 := 'c:\Program Files (x86)';
   end
   else
   begin
      envProgramFiles := GetEnvVarValue('ProgramFiles');
      if envProgramFiles = '' then
         envProgramFiles := 'c:\Program Files';
      envProgramFilesx86 := envProgramFiles;
   end;

   ExeVBPath := GetEnvVarValue('VBOX_MSI_INSTALL_PATH');
   if ExeVBPath = '' then
      ExeVBPath := GetEnvVarValue('VBOX_INSTALL_PATH');
   if ExeVBPath = '' then
      ExeVBPath := envProgramFiles + '\Oracle\VirtualBox\';
   ExeVBPath := ExeVBPath + 'VirtualBox.exe';
   if not FileExists(ExeVBPath) then
      ExeVBPath := '';

   ExeQPath := GetEnvVarValue('QEMU_INSTALL_PATH');
   if ExeQPath <> '' then
      if not DirectoryExists(ExeQPath) then
         ExeQPath := '';
   if ExeQPath = '' then
      if DirectoryExists(envProgramFiles + '\qemu\') then
         ExeQPath := envProgramFiles + '\QEMU\'
      else if DirectoryExists(envProgramFilesx86 + '\qemu\') then
         ExeQPath := envProgramFilesx86 + '\qemu\'
      else if DirectoryExists(envProgramFilesx86 + '\RMPrepUSB\QEMU\') then
         ExeQPath := envProgramFilesx86 + '\RMPrepUSB\QEMU\';
   if ExeQPath <> '' then
   begin
      if TOSversion.Architecture = arIntelX86 then
      begin
         if FileExists(ExeQPath + 'qemu.exe') then
            ExeQPath := ExeQPath + 'qemu.exe'
         else if FileExists(ExeQPath + 'qemu-system-i386.exe') then
            ExeQPath := ExeQPath + 'qemu-system-i386.exe'
         else if FileExists(ExeQPath + 'qemu-system-i386w.exe') then
            ExeQPath := ExeQPath + 'qemu-system-i386w.exe'
         else if FileExists(ExeQPath + 'qemu-system-x86_64.exe') then
            ExeQPath := ExeQPath + 'qemu-system-x86_64.exe'
         else if FileExists(ExeQPath + 'qemu-system-x86_64w.exe') then
            ExeQPath := ExeQPath + 'qemu-system-x86_64w.exe'
         else
            ExeQPath := '';
      end
      else
      begin
         if FileExists(ExeQPath + 'qemu-system-x86_64.exe') then
            ExeQPath := ExeQPath + 'qemu-system-x86_64.exe'
         else if FileExists(ExeQPath + 'qemu-system-x86_64w.exe') then
            ExeQPath := ExeQPath + 'qemu-system-x86_64w.exe'
         else if FileExists(ExeQPath + 'qemu.exe') then
            ExeQPath := ExeQPath + 'qemu.exe'
         else if FileExists(ExeQPath + 'qemu-system-i386.exe') then
            ExeQPath := ExeQPath + 'qemu-system-i386.exe'
         else if FileExists(ExeQPath + 'qemu-system-i386w.exe') then
            ExeQPath := ExeQPath + 'qemu-system-i386w.exe'
         else
            ExeQPath := '';
      end;
   end;

   ExeQManager := envProgramFilesx86 + '\QemuManager\QemuManager.exe';

   OSDrive := 0;
   ws := GetEnvVarValue('SystemDrive');
   ErrorMode := SetErrorMode(SEM_FailCriticalErrors);
   try
      if ws <> '' then
      begin
         c := Char(ws[1]);
         if (c >= 'A') and (c <= 'Z') then
         begin
            try
               hVolume := CreateFile(PChar('\\.\' + c + ':'), 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
            except
               hVolume := INVALID_HANDLE_VALUE;
            end;
            if hVolume <> INVALID_HANDLE_VALUE then
            begin
               dwBytesReturned := 0;
               try
                  if DeviceIoControl(hVolume, IOCTL_STORAGE_GET_DEVICE_NUMBER, nil, 0, @sdn, SizeOf(sdn), dwBytesReturned, nil) then
                     OSDrive := sdn.DeviceNumber;
               except
               end;
               try
                  CloseHandle(hVolume);
               except
               end;
            end
         end;
      end;
   finally
      SetErrorMode(ErrorMode);
   end;

   MainLeft := (Screen.WorkAreaWidth - Width) div 2 + Screen.WorkAreaLeft;
   MainTop := (Screen.WorkAreaHeight - Height) div 2 + Screen.WorkAreaTop;

   with vstVMs.Font do
   begin
      FontName := AnsiString(Name);
      FontSize := Size;
      FontBold := fsBold in Style;
      FontItalic := fsBold in Style;
      FontUnderline := fsUnderline in Style;
      FontStrikeOut := fsStrikeOut in Style;
      FontColor := Color;
      FontScript := Charset;
      DefaultFontName := AnsiString(Name);
      DefaultFontSize := Size;
      DefaultFontBold := fsBold in Style;
      DefaultFontItalic := fsBold in Style;
      DefaultFontUnderline := fsUnderline in Style;
      DefaultFontStrikeOut := fsStrikeOut in Style;
      DefaultFontColor := Color;
      DefaultFontScript := Charset;
   end;

   fDPI := 1.0 * Screen.PixelsPerInch / PreviousDPI;
   if fDPI > 1 then
      fDPI := (fDPI - 1) * (vstVMs.Width / Width) + 1
   else if fDPI < 1 then
      fDPI := 1 - (1 - fDPI) * (vstVMs.Width / Width);

   MainWidth := Round(1 / fDPI * Width);
   MainHeight := Round(1 / fDPI * Height);

   CFGFoundAndLoaded := FileExists(CfgFile) and LoadCFG(CfgFile);

   if not CFGFoundAndLoaded then
   begin
      MainWidth := Round(fDPI * MainWidth);
      MainHeight := Round(fDPI * MainHeight);
   end;

   if not FileExists(ExeQManager) then
      if FileExists(ExeQPath) then
      begin
         ExeQManager := ExcludeTrailingPathDelimiter(ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(ExeQPath)))) + '\QemuManager.exe';
         if not FileExists(ExeQManager) then
            ExeQManager := '';
      end;
   vstVMs.BeginUpdate;
   if CFGFoundAndLoaded and (not AutomaticFont) then
   begin
      with vstVMs.Font do
      begin
         Name := string(FontName);
         Size := FontSize;
         Style := [];
         if FontBold then
            Style := Style + [fsBold];
         if FontItalic then
            Style := Style + [fsItalic];
         if FontUnderline then
            Style := Style + [fsUnderline];
         if FontStrikeOut then
            Style := Style + [fsStrikeOut];
         Color := FontColor;
         Charset := FontScript;
      end;
   end;
   if not ShowTrayIcon then
   begin
      btnShowTrayIcon.Visible := True;
      btnShowTrayIcon.Left := btnStart.Left;
   end;
   with vstVMs.Header.Font do
   begin
      Name := string(FontName);
      if vstVMs.Font.Size <= 8 then
         Size := 8
      else
         Size := Round(sqrt(vstVMs.Font.Size - 8) + 8);
      Style := [];
      if FontBold then
         Style := Style + [fsBold];
      if FontItalic then
         Style := Style + [fsItalic];
      if FontUnderline then
         Style := Style + [fsUnderline];
      if FontStrikeOut then
         Style := Style + [fsStrikeOut];
      Charset := FontScript;
   end;
   btnStart.Font.Size := vstVMs.Header.Font.Size;
   btnAdd.Font.Size := vstVMs.Header.Font.Size;
   btnEdit.Font.Size := vstVMs.Header.Font.Size;
   btnDelete.Font.Size := vstVMs.Header.Font.Size;
   btnManager.Font.Size := vstVMs.Header.Font.Size;
   btnOptions.Font.Size := vstVMs.Header.Font.Size;
   btnExit.Font.Size := vstVMs.Header.Font.Size;
   btnShowTrayIcon.Font.Size := vstVMs.Header.Font.Size;
   vstVMs.Canvas.Font.Assign(vstVMs.Font);
   FontHeight := vstVMs.Canvas.TextHeight('Hg');
   case FontHeight of
      0..23:
         begin
            if imlVST_items.Width <> 24 then
            begin
               imlVST_items.BeginUpdate;
               imlVST_items.SetSize(24, 24);
               imlVST_items.PngImages.Assign(imlVST24.PngImages);
               for i := 1 to 3 do
                  imlVST_items.PngImages.Delete(0);
               imlVST_items.EndUpdate(True);
            end;
            if btnStart.PngImage.Height <> 16 then
            begin
               btnStart.PngImage := imlBtn16.PngImages[0].PngImage;
               btnAdd.PngImage := imlBtn16.PngImages[1].PngImage;
               btnEdit.PngImage := imlBtn16.PngImages[2].PngImage;
               btnDelete.PngImage := imlBtn16.PngImages[3].PngImage;
               btnManager.PngImage := imlBtn16.PngImages[4].PngImage;
               btnOptions.PngImage := imlBtn16.PngImages[5].PngImage;
               btnShowTrayIcon.PngImage := imlBtn16.PngImages[6].PngImage;
               btnExit.PngImage := imlBtn16.PngImages[7].PngImage;
            end;
            if imlVST_header.Width <> 16 then
            begin
               imlVST_header.BeginUpdate;
               imlVST_header.SetSize(16, 16);
               for i := 0 to 2 do
                  imlVST_header.AddPng(imlVST16.PngImages[i].PngImage);
               imlVST_header.EndUpdate(True);
            end;
         end;
      24..32:
         begin
            if imlVST_items.Width <> 28 then
            begin
               imlVST_items.BeginUpdate;
               imlVST_items.SetSize(28, 28);
               imlVST_items.PngImages.Assign(imlVST28.PngImages);
               for i := 1 to 3 do
                  imlVST_items.PngImages.Delete(0);
               imlVST_items.EndUpdate(True);
            end;
            if btnStart.PngImage.Height <> 20 then
            begin
               btnStart.PngImage := imlBtn20.PngImages[0].PngImage;
               btnAdd.PngImage := imlBtn20.PngImages[1].PngImage;
               btnEdit.PngImage := imlBtn20.PngImages[2].PngImage;
               btnDelete.PngImage := imlBtn20.PngImages[3].PngImage;
               btnManager.PngImage := imlBtn20.PngImages[4].PngImage;
               btnOptions.PngImage := imlBtn20.PngImages[5].PngImage;
               btnShowTrayIcon.PngImage := imlBtn20.PngImages[6].PngImage;
               btnExit.PngImage := imlBtn20.PngImages[7].PngImage;
            end;
            if imlVST_header.Width <> 20 then
            begin
               imlVST_header.BeginUpdate;
               imlVST_header.SetSize(20, 20);
               for i := 0 to 2 do
                  imlVST_header.AddPng(imlVST20.PngImages[i].PngImage);
               imlVST_header.EndUpdate(True);
            end;
         end;
      else
         begin
            if imlVST_items.Width <> 32 then
            begin
               imlVST_items.BeginUpdate;
               imlVST_items.SetSize(32, 32);
               imlVST_items.PngImages.Assign(imlVST32.PngImages);
               for i := 1 to 3 do
                  imlVST_items.PngImages.Delete(0);
               imlVST_items.EndUpdate(True);
            end;
            if btnStart.PngImage.Height <> 24 then
            begin
               btnStart.PngImage := imlBtn24.PngImages[0].PngImage;
               btnAdd.PngImage := imlBtn24.PngImages[1].PngImage;
               btnEdit.PngImage := imlBtn24.PngImages[2].PngImage;
               btnDelete.PngImage := imlBtn24.PngImages[3].PngImage;
               btnManager.PngImage := imlBtn24.PngImages[4].PngImage;
               btnOptions.PngImage := imlBtn24.PngImages[5].PngImage;
               btnShowTrayIcon.PngImage := imlBtn24.PngImages[6].PngImage;
               btnExit.PngImage := imlBtn24.PngImages[7].PngImage;
            end;
            if imlVST_header.Width <> 24 then
            begin
               imlVST_header.BeginUpdate;
               imlVST_header.SetSize(24, 24);
               for i := 0 to 2 do
                  imlVST_header.AddPng(imlVST24.PngImages[i].PngImage);
               imlVST_header.EndUpdate(True);
            end;
         end;
   end;
   vstVMs.DefaultNodeHeight := Round(1.1 * Max(imlVST_items.Height, FontHeight) + 1.6);
   SetThemeDependantParams;
   vstVMs.Canvas.Font.Assign(vstVMs.Header.Font);
   FontHeight := vstVMs.Canvas.TextHeight('Hg');
   vstVMs.Header.Height := Round(1.5 * Max(imlVST_header.Height, FontHeight));
   vstVMs.Canvas.Font.Assign(vstVMs.Font);
   vstVMs.Header.Columns[1].Margin := vstVMs.Margin + (imlVST_items.Width - imlVST_header.Width) div 2 - 1;
   vstVMs.Header.Columns[1].Spacing := vstVMs.Margin + imlVST_items.Width - vstVMs.Header.Columns[1].Margin - imlVST_header.Width + 5;
   vstVMs.Header.Columns[2].Margin := vstVMs.Margin + (imlVST_items.Width - imlVST_header.Width) div 2 - 1;
   vstVMs.Header.Columns[2].Spacing := vstVMs.Margin + imlVST_items.Width - vstVMs.Header.Columns[2].Margin - imlVST_header.Width + 5;
   vstVMs.Header.Columns[3].Margin := vstVMs.Margin + (imlVST_items.Width - imlVST_header.Width) div 2 - 1;
   vstVMs.Header.Columns[3].Spacing := vstVMs.Margin + imlVST_items.Width - vstVMs.Header.Columns[3].Margin - imlVST_header.Width + 5;
   vstVMs.Height := ClientHeight - 2 * vstVMs.Top;
   vstVMs.EndUpdate;
   case SystemIconSize of
      -2147483647..18:
         begin
            TrayIcon.Icon.SetSize(16, 16);
            imlVST16.GetIcon(imlVST16.Count - 1, TrayIcon.Icon);
            imlTray.BeginUpdate;
            imlTray.SetSize(16, 16);
            for i := AnimTrayStartCopyIndex to AnimTrayStartCopyIndex + 45 do
               imlTray.AddPng(imlVst16.PngImages[i].PngImage);
            imlTray.EndUpdate(True);
            pmTray.Images := imlBtn16;
            pmVMs.Images := imlBtn16;
            pmManagers.Images := imlBtn16;
         end;
      19..22:
         begin
            TrayIcon.Icon.SetSize(20, 20);
            imlVST20.GetIcon(imlVST20.Count - 1, TrayIcon.Icon);
            imlTray.BeginUpdate;
            imlTray.SetSize(20, 20);
            Inc(AnimTrayStartCopyIndex, 16);
            for i := AnimTrayStartCopyIndex to AnimTrayStartCopyIndex + 45 do
               imlTray.AddPng(imlVst20.PngImages[i].PngImage);
            imlTray.EndUpdate(True);
            pmTray.Images := imlBtn20;
            pmVMs.Images := imlBtn20;
            pmManagers.Images := imlBtn20;
         end;
      23..26:
         begin
            TrayIcon.Icon.SetSize(24, 24);
            imlVST24.GetIcon(imlVST24.Count - 1, TrayIcon.Icon);
            imlTray.BeginUpdate;
            imlTray.SetSize(24, 24);
            Inc(AnimTrayStartCopyIndex, 16);
            for i := AnimTrayStartCopyIndex to AnimTrayStartCopyIndex + 45 do
               imlTray.AddPng(imlVst24.PngImages[i].PngImage);
            imlTray.EndUpdate(True);
            pmTray.Images := imlBtn24;
            pmVMs.Images := imlBtn24;
            pmManagers.Images := imlBtn24;
         end;
      27..30:
         begin
            TrayIcon.Icon.SetSize(28, 28);
            imlVST28.GetIcon(imlVST28.Count - 1, TrayIcon.Icon);
            imlTray.BeginUpdate;
            imlTray.SetSize(28, 28);
            Inc(AnimTrayStartCopyIndex, 16);
            for i := AnimTrayStartCopyIndex to AnimTrayStartCopyIndex + 45 do
               imlTray.AddPng(imlVst28.PngImages[i].PngImage);
            imlTray.EndUpdate(True);
            pmTray.Images := imlBtn24;
            pmVMs.Images := imlBtn24;
            pmManagers.Images := imlBtn24;
         end;
      31..2147483647:
         begin
            TrayIcon.Icon.SetSize(32, 32);
            imlVST32.GetIcon(imlVST32.Count - 1, TrayIcon.Icon);
            imlTray.BeginUpdate;
            imlTray.SetSize(32, 32);
            Inc(AnimTrayStartCopyIndex, 16);
            for i := AnimTrayStartCopyIndex to AnimTrayStartCopyIndex + 45 do
               imlTray.AddPng(imlVst32.PngImages[i].PngImage);
            imlTray.EndUpdate(True);
            pmTray.Images := imlBtn24;
            pmVMs.Images := imlBtn24;
            pmManagers.Images := imlBtn24;
         end;
   end;
   btnStart.Top := vstVMs.Top;
   ChangeCompLang;
   if Application.Terminated then
   begin
      OnDestroy := nil;
      Exit;
   end;
   Constraints.MinHeight := 2 * vstVMs.Top + (7 + Integer(btnShowTrayIcon.Visible)) * btnStart.Height + Height - ClientHeight;
   btnExit.Top := vstVMs.Top + vstVMs.Height - btnExit.Height;
   frmMain.Canvas.Font.Assign(vstVMs.Font);
   i := 8192;
   l := Canvas.TextWidth('  ') div 2;
   prevprc := 50;
   indmin := -1;
   while i <= 8202 do
   begin
      prc := 100.0 * (Canvas.TextWidth(Char(i) + Char(i)) - l) / l;
      if prc < 0 then
         prc := -0.5 * prc;
      if prc < prevprc then
      begin
         prevprc := prc;
         indmin := i;
      end;
      Inc(i);
   end;
   if indmin > -1 then
      HalfSpaceCharVST := Char(indmin)
   else
      HalfSpaceCharVST := ' ';
   frmMain.Canvas.Font.Assign(frmMain.Font);
   if FileExists(VMentriesFile) then
   begin
      LoadVMentries(VMentriesFile);
      if vstVMs.RootNodeCount > 0 then
      begin
         LastSelected := Min(LastSelected, vstVMs.RootNodeCount - 1);
         FindDrives;
         vstVMs.BeginUpdate;
         Node := vstVMs.GetFirst;
         while Node <> nil do
         begin
            Data := vstVMs.GetNodeData(Node);
            i := Node.Index;
            with Data^ do
            begin
               FVMImageIndex := Ptype;
               if (vstVMs.RootNodeCount < 10) or (i > 8) then
                  FId := IntToStr(i + 1)
               else
                  FId := '0' + IntToStr(i + 1);
               FVName := VMName;
               FDDisplayName := string(FirstDriveName);
               l := Length(FDDisplayName);
               j := l;
               while j > 2 do
               begin
                  if (FDDisplayName[j - 2] = ',') and (FDDisplayName[j - 1] = ' ') and CharInSet(FDDisplayName[j], ['0'..'9']) then
                  begin
                     Insert(' ', FDDisplayName, j - 1);
                     Inc(l);
                     Break;
                  end;
                  Dec(j);
               end;
               if l >= 3 then
                  if FDDisplayName[l] = 'B' then
                     if CharInSet(FDDisplayName[l - 1], ['G', 'M', 'T']) then
                        if FDDisplayName[l - 2] = ' ' then
                           FDDisplayName[l - 2] := HalfSpaceCharVST;
               SDDisplayName := string(SecondDriveName);
               l := Length(SDDisplayName);
               j := l;
               while j > 2 do
               begin
                  if (SDDisplayName[j - 2] = ',') and (SDDisplayName[j - 1] = ' ') and CharInSet(SDDisplayName[j], ['0'..'9']) then
                  begin
                     Insert(' ', SDDisplayName, j - 1);
                     Inc(l);
                     Break;
                  end;
                  Dec(j);
               end;
               if l >= 3 then
                  if SDDisplayName[l] = 'B' then
                     if CharInSet(SDDisplayName[l - 1], ['G', 'M', 'T']) then
                        if SDDisplayName[l - 2] = ' ' then
                           SDDisplayName[l - 2] := HalfSpaceCharVST;
               if FirstDriveName = '' then
                  FFDImageIndex := -1
               else if FirstDriveFound then
               begin
                  if ListOnlyUSBDrives then
                  begin
                     if FirstDriveBusType = 7 then
                        FFDImageIndex := 2
                     else
                        FFDImageIndex := 3;
                  end
                  else
                     case FirstDriveBusType of
                        1:
                           FFDImageIndex := 10;
                        4:
                           FFDImageIndex := 12;
                        7:
                           FFDImageIndex := 4;
                        8: FFDImageIndex := 14;
                        14, 15:
                           FFDImageIndex := 8;
                        else
                           FFDImageIndex := 6;
                     end;
               end
               else if ListOnlyUSBDrives then
                  FFDImageIndex := 3
               else
                  case FirstDriveBusType of
                     1:
                        FFDImageIndex := 11;
                     4:
                        FFDImageIndex := 13;
                     7:
                        FFDImageIndex := 5;
                     8: FFDImageIndex := 15;
                     14, 15:
                        FFDImageIndex := 9;
                     else
                        FFDImageIndex := 7;
                  end;

               if SecondDriveName = '' then
                  FSDImageIndex := -1
               else if SecondDriveFound then
               begin
                  if ListOnlyUSBDrives then
                  begin
                     if SecondDriveBusType = 7 then
                        FSDImageIndex := 2
                     else
                        FSDImageIndex := 3;
                  end
                  else
                     case SecondDriveBusType of
                        1:
                           FSDImageIndex := 10;
                        4:
                           FSDImageIndex := 12;
                        7:
                           FSDImageIndex := 4;
                        8: FSDImageIndex := 14;
                        14, 15:
                           FSDImageIndex := 8;
                        else
                           FSDImageIndex := 6;
                     end;
               end
               else if ListOnlyUSBDrives then
                  FSDImageIndex := 3
               else
                  case SecondDriveBusType of
                     1:
                        FSDImageIndex := 11;
                     4:
                        FSDImageIndex := 13;
                     7:
                        FSDImageIndex := 5;
                     8: FSDImageIndex := 15;
                     14, 15:
                        FSDImageIndex := 9;
                     else
                        FSDImageIndex := 7;
                  end;
            end;
            if i = LastSelected then
            begin
               vstVMs.Selected[Node] := True;
               vstVMs.ScrollIntoView(Node, False);
               vstVMs.FocusedNode := Node;
            end;
            Node := vstVMs.GetNext(Node);
         end;
         vstVMs.EndUpdate;
      end;
   end;
   mmCrt.Tag := Max(vstVMs.Header.Height, Round(2 * vstVMs.Margin + 2 + vstVMs.Canvas.TextWidth('H') * (0.5 + Length(IntToStr(vstVMs.RootNodeCount)))));
   vstVMs.Header.Columns[0].MaxWidth := mmCrt.Tag;
   vstVMs.Header.Columns[0].MinWidth := mmCrt.Tag;
   vstVMs.Header.Columns[0].MaxWidth := mmCrt.Tag;
   vstVMs.Header.Columns[0].Width := mmCrt.Tag;
   xmlGen.Tag := 0;
   if FileExists(exeVBPath) then
   begin
      if PathIsRelative(PChar(ExeVBPath)) then
      begin
         FillMemory(@Path[0], Length(Path), 0);
         PathCanonicalize(@Path[0], PChar(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + ExeVBPath));
         if string(Path) <> '' then
            ws := Path
         else
            ws := exeVBPath;
      end
      else
         ws := exeVBPath;
      ws := ExcludeTrailingPathDelimiter(ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(ws)))) + '\data\.VirtualBox\VirtualBox.xml';
      if FileExists(ws) then
      begin
         try
            xmlGen.LoadFromFile(ws);
         except
            xmlGen.Active := False;
         end;
         xmlGen.Tag := Integer(xmlGen.Active);
         xmlGen.Active := False;
         isVBPortable := xmlGen.Tag = 1;
         if isVBPortable then
         begin
            VBOX_USER_HOME := ExcludeTrailingPathDelimiter(ExtractFilePath(ws));
            isVBInstalledToo := (ServiceStatus.dwCurrentState = SERVICE_RUNNING) and (ServiceDisplayName <> 'PortableVBoxDRV');
            ExeVBPathToo := GetEnvVarValue('VBOX_MSI_INSTALL_PATH');
            if ExeVBPathToo = '' then
               ExeVBPathToo := GetEnvVarValue('VBOX_INSTALL_PATH');
            if ExeVBPathToo = '' then
               ExeVBPathToo := envProgramFiles + '\Oracle\VirtualBox\';
            ExeVBPathToo := ExeVBPathToo + 'VirtualBox.exe';
            if not FileExists(ExeVBPathToo) then
               ExeVBPathToo := '';
         end;
      end;
   end;
   if xmlGen.Tag = 0 then
   begin
      ws := GetEnvVarValue('USERPROFILE');
      if ws <> '' then
      begin
         ws := ws + '\.VirtualBox\VirtualBox.xml';
         if FileExists(ws) then
         try
            xmlGen.LoadFromFile(ws);
         except
            xmlGen.Active := False;
         end;
         xmlGen.Tag := Integer(xmlGen.Active);
         xmlGen.Active := False;
      end;
   end;
   try
      SysMenu := GetSystemMenu(Handle, False);
      AppendMenu(SysMenu, MF_SEPARATOR, 0, '');
      AppendMenu(SysMenu, MF_STRING, WM_USER + 1, 'Designed by DavidB');
      AppendMenu(SysMenu, MF_STRING, WM_USER + 2, 'Testing and ideas: steve6375');
      AppendMenu(SysMenu, MF_SEPARATOR, 0, '');
      AppendMenu(SysMenu, MF_STRING, WM_USER + 3, 'Latest version and news');
      AppendMenu(SysMenu, MF_STRING, WM_USER + 4, 'Support forum');
   except
   end;
   VBVMWasClosed := Now - 1;
   DriveDetect := TComponentDrive.Create(frmMain);
   {        for i := 111 to 111 do
              imlVst20.PngImages[i].PngImage.SaveToFile('d:\ff\Icon ' + Format('%.3d', [i]) + '.png');}
end;

procedure TfrmMain.ChangeCompLang;
var
   i, abl, NewWidth, MaxBtnWidth, MaxBtnHeight, btnSpacing, btnMargin: Integer;
   DoAlign: Boolean;
   rs: TResourceStream;
   tms: TMemoryStream;
   tfs: TFileStream;
   diff: Double;
   Size: TSize;
   strTemp: AnsiString;
   wst: string;

   function CompNameToCaption(const strCompName: AnsiString): AnsiString;
   var
      i, j, l: Integer;
   begin
      Result := strCompName;
      i := 2;
      j := 2;
      l := Length(strCompName);
      while i < l do
      begin
         if CharInSet(strCompName[i], ['A'..'Z']) and ((not CharInSet(strCompName[i - 1], ['A'..'Z'])) or
            (not CharInSet(strCompName[i + 1], ['A'..'Z']))) then
         begin
            Result[j] := AnsiChar(Integer(strCompName[i]) + Ord('a') - Ord('A'));
            Insert(' ', Result, j);
            Inc(j);
         end;
         Inc(i);
         Inc(j);
      end;
   end;

   function areDifferent(const FirstXMLnode, SecondXMLnode: IXMLNode): Boolean;
   var
      i: Integer;
   begin
      Result := False;
      try
         if FirstXMLnode.LocalName <> SecondXMLnode.LocalName then
         begin
            //    ShowMessage(FirstXMLnode.LocalName + #13 + FirstXMLnode.LocalName);
            Result := True;
            Exit;
         end;
         if FirstXMLnode.ChildNodes.Count <> SecondXMLnode.ChildNodes.Count then
         begin
            //      ShowMessage(IntToStr(FirstXMLnode.ChildNodes.Count) + #13 + IntToStr(SecondXMLnode.ChildNodes.Count));
            Result := True;
            Exit;
         end;
         for i := 0 to FirstXMLnode.ChildNodes.Count - 1 do
            if areDifferent(FirstXMLnode.ChildNodes[i], SecondXMLnode.ChildNodes[i]) then
            begin
               //           ShowMessage(FirstXMLnode.ChildNodes[i].Text + #13 + SecondXMLnode.ChildNodes[i].Text);
               Result := True;
               Exit;
            end;
      except
         Result := True;
      end;
   end;

begin
   if CurrLanguageFile = 'ENGLISH' then
   begin
      rs := nil;
      try
         rs := TResourceStream.Create(0, 'ENGLISH', PChar('Languages'));
         xmlLanguage.LoadFromStream(rs);
      except
      end;
      if rs <> nil then
      try
         rs.Free;
      except
      end;
      if not xmlLanguage.Active then
      begin
         CustomMessageBox(Handle, 'Corrupt application exe file !'#13#10#13#10'The application will now be terminated...', 'Error', mtError, [mbOK], mbOK);
         Application.Terminate;
         Exit;
      end;
   end
   else if FileExists(LngFolder + '\' + CurrLanguageFile) then
   begin
      ResetLastError;
      tfs := nil;
      try
         tfs := TFileStream.Create(LngFolder + '\' + CurrLanguageFile, fmOpenRead or fmShareDenyNone);
         LastError := GetLastError;
         xmlLanguage.LoadFromStream(tfs);
         LastError := GetLastError;
      except
         on E: Exception do
            LastExceptionStr := E.Message;
      end;
      if tfs <> nil then
      try
         tfs.Free;
      except
      end;
      if xmlLanguage.Active then
      begin
         rs := nil;
         try
            rs := TResourceStream.Create(0, 'ENGLISH', PChar('Languages'));
            xmlVBoxCompare.LoadFromStream(rs);
         except
         end;
         if rs <> nil then
         try
            rs.Free;
         except
         end;
         if not xmlVBoxCompare.Active then
         begin
            CustomMessageBox(Handle, 'Corrupt application exe file !'#13#10#13#10'The application will now be terminated...', 'Error', mtError, [mbOK], mbOK);
            Application.Terminate;
            Exit;
         end
         else if areDifferent(xmlLanguage.DocumentElement, xmlVBoxCompare.DocumentElement) then
         begin
            tms := TMemoryStream.Create;
            xmlVBoxCompare.SaveToStream(tms);
            xmlLanguage.LoadFromStream(tms);
            tms.Free;
            CurrLanguageFile := 'ENGLISH';
            CustomMessageBox(Handle, 'Corrupt language file !'#13#10#13#10'The default language (english) was loaded...', 'Warning', mtWarning, [mbOK], mbOK);
         end;
         xmlVBoxCompare.Active := False;
      end
      else
      begin
         rs := nil;
         ResetLastError;
         try
            rs := TResourceStream.Create(0, 'ENGLISH', PChar('Languages'));
            LastError := GetLastError;
            xmlLanguage.LoadFromStream(rs);
            LastError := GetLastError;
         except
         end;
         if rs <> nil then
         try
            rs.Free;
         except
         end;
         if not xmlLanguage.Active then
         begin
            CustomMessageBox(Handle, 'Corrupt application exe file !'#13#10#13#10'The application will now be terminated...', 'Error', mtError, [mbOK], mbOK);
            Application.Terminate;
            Exit;
         end
         else
         begin
            CurrLanguageFile := 'ENGLISH';
            if LastError > 0 then
               wst := SysErrorMessage(LastError)
            else
            begin
               if LastExceptionStr <> '' then
                  wst := LastExceptionStr
               else
                  wst := 'Unknown error';
            end;
            CustomMessageBox(Handle, 'Corrupt language file !'#13#10#13#10'The default language (english) was loaded...'#13#10#13#10'System message: ' + wst, 'Warning', mtWarning, [mbOK], mbOK);
         end;
      end;
   end
   else
   begin
      if FindResource(hInstance, PChar(CurrLanguageFile), PChar('Languages')) <> 0 then
      begin
         rs := nil;
         try
            rs := TResourceStream.Create(0, CurrLanguageFile, PChar('Languages'));
            xmlLanguage.LoadFromStream(rs);
         except
         end;
         if rs <> nil then
         try
            rs.Free;
         except
         end;
      end;
      if not xmlLanguage.Active then
      begin
         rs := nil;
         try
            rs := TResourceStream.Create(0, 'ENGLISH', PChar('Languages'));
            xmlLanguage.LoadFromStream(rs);
         except
         end;
         if rs <> nil then
         try
            rs.Free;
         except
         end;
         if not xmlLanguage.Active then
         begin
            if Showing then
               CustomMessageBox(Handle, 'Corrupt application exe file !'#13#10#13#10'The application will now be terminated...', 'Error', mtError, [mbOK], mbOK);
            Application.Terminate;
            Exit;
         end
         else
         begin
            CurrLanguageFile := 'ENGLISH';
            CustomMessageBox(Handle, 'Corrupt language resource !'#13#10#13#10'The default language (english) was loaded...', 'Warning', mtWarning, [mbOK], mbOK);
         end;
      end;
   end;
   LockWindowUpdate(Handle);
   SendMessage(pnlBackground.Handle, WM_SETREDRAW, wParam(False), 0);
   idxInterface := xmlLanguage.ChildNodes.IndexOf('Interface');
   idxLanguage := xmlLanguage.ChildNodes[idxInterface].ChildNodes.IndexOf('Language');
   idxMain := xmlLanguage.ChildNodes[idxInterface].ChildNodes.IndexOf('Main');
   idxAddEdit := xmlLanguage.ChildNodes[idxInterface].ChildNodes.IndexOf('AddEdit');
   idxOptions := xmlLanguage.ChildNodes[idxInterface].ChildNodes.IndexOf('Options');
   idxMessages := xmlLanguage.ChildNodes[idxInterface].ChildNodes.IndexOf('Messages');
   MaxBtnWidth := 0;
   MaxBtnHeight := 0;
   frmMain.btnExit.Tag := 7;
   for i := 0 to ComponentCount - 1 do
      if Components[i].ClassNameIs('TPNGSpeedButton') then
      begin
         frmMain.Canvas.Font.Assign(TPNGSpeedButton(Components[i]).Font);
         strTemp := AnsiString(Copy(TPNGSpeedButton(Components[i]).Name, 4, Length(TPNGSpeedButton(Components[i]).Name) - 3));
         TPNGSpeedButton(Components[i]).Caption := GetLangTextDef(idxMain, ['Buttons', strTemp], strTemp);
         GetTextExtentPoint32W(frmMain.Canvas.Handle, PWideChar(TPNGSpeedButton(Components[i]).Caption), Length(TPNGSpeedButton(Components[i]).Caption), Size);
         MaxBtnWidth := Max(MaxBtnWidth, Size.Width);
         MaxBtnHeight := Max(MaxBtnHeight, Size.Height);
      end;
   frmMain.btnExit.Tag := 6 + Integer(btnShowTrayIcon.Visible);
   frmMain.Canvas.Font.Assign(frmMain.Font);
   btnMargin := Round(sqrt(MaxBtnWidth)) + 5;
   btnSpacing := Round(0.3 * (sqrt(MaxBtnWidth) + 5)) + 3;
   MaxBtnWidth := 2 * btnMargin + btnStart.PngImage.Width + btnSpacing + MaxBtnWidth;
   MaxBtnHeight := Max(btnStart.PngImage.Height, MaxBtnHeight) + 12;
   NewWidth := Round(ClientWidth - 11 / 9 * MaxBtnWidth - vstVMs.Left + ClientOrigin.X - Left);
   ColWereAligned := vstVMs.ClientWidth = vstVMs.Header.Columns.TotalWidth;
   DoAlign := ColWereAligned and (vstVMs.Width <> NewWidth);
   vstVMs.Width := NewWidth;
   abl := Round(ClientWidth - 10 / 9 * MaxBtnWidth + ClientOrigin.X - Left - Margins.Right);
   diff := 1.0 / (6 + Integer(btnShowTrayIcon.Visible)) * (vstVMs.Height - MaxBtnHeight);
   for i := 0 to ComponentCount - 1 do
      if Components[i].ClassNameIs('TPNGSpeedButton') then
      begin
         TPNGSpeedButton(Components[i]).SetBounds(abl, Round(diff * TPNGSpeedButton(Components[i]).Tag + btnStart.Top), MaxBtnWidth, MaxBtnHeight);
         TPNGSpeedButton(Components[i]).Spacing := btnSpacing;
         TPNGSpeedButton(Components[i]).Margin := btnMargin;
      end;
   Constraints.MaxHeight := Height - ClientHeight + 2 * vstVms.Top + vstVMs.Height - vstVMs.ClientHeight + (11 + Integer(btnShowTrayIcon.Visible)) * Integer(vstVMs.DefaultNodeHeight);
   for i := 0 to ComponentCount - 1 do
      if Components[i].ClassNameIs('TMenuItem') and TMenuItem(Components[i]).Visible and
         ((TPopupMenu(TMenuItem(Components[i]).GetParentMenu).Name = 'pmVMs') or
         (TPopupMenu(TMenuItem(Components[i]).GetParentMenu).Name = 'pmTray')) then
      begin
         strTemp := AnsiString(Copy(TMenuItem(Components[i]).Name, 3, Length(TMenuItem(Components[i]).Name) - 2));
         TMenuItem(Components[i]).Caption := GetLangTextDef(idxMain, ['List', 'Menu', strTemp], CompNameToCaption(strTemp));
      end;
   vstVMs.Header.Columns[1].Text := GetLangTextDef(idxMain, ['List', 'Header', 'VMName'], 'VM name');
   if not AddSecondDrive then
      vstVMs.Header.Columns[2].Text := GetLangTextDef(idxMain, ['List', 'Header', 'Drive'], 'Drive')
   else
      vstVMs.Header.Columns[2].Text := GetLangTextDef(idxMain, ['List', 'Header', 'FirstDrive'], 'First drive');
   vstVMs.Header.Columns[3].Text := GetLangTextDef(idxMain, ['List', 'Header', 'SecondDrive'], 'Second drive');
   mmVMName.Caption := GetLangTextDef(idxMain, ['List', 'Header', 'VMName'], 'VM Name');
   if not AddSecondDrive then
      mmDrive.Caption := GetLangTextDef(idxMain, ['List', 'Header', 'Drive'], 'Drive')
   else
      mmDrive.Caption := GetLangTextDef(idxMain, ['List', 'Header', 'FirstDrive'], 'First drive');
   if DoAlign then
      RealignColumns(False);
   SendMessage(pnlBackground.Handle, WM_SETREDRAW, wParam(True), 0);
   LockWindowUpdate(0);
end;

procedure TfrmMain.btnEditClick(Sender: TObject);
var
   i, p, l, cp, n1, n2, n3, a: Integer;
   ws, wst, FolderName: string;
   strTemp: AnsiString;
   Data: PData;
   Node: PVirtualNode;
begin
   if isBusyStartVM then
   begin
      btnStart.Down := True;
      if Sender is TPngSpeedButton then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if IsBusyManager then
   begin
      btnManager.Down := True;
      if Sender is TPngSpeedButton then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if IsBusyEjecting then
   begin
      if Sender is TPngSpeedButton then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if (vstVMs.RootNodeCount = 0) or (vstVMs.GetFirstSelected = nil) or (vstVMs.GetFirstSelected.Index >= vstVMs.RootNodeCount) then
   begin
      btnEdit.Down := False;
      Exit;
   end;
   try
      try
         vstVMs.ScrollIntoView(vstVMs.GetFirstSelected, False);
         if frmAddEdit = nil then
            Application.CreateForm(TfrmAddEdit, frmAddEdit);
         with frmAddEdit do
         begin
            Caption := GetLangTextDef(idxAddEdit, ['Caption', 'Edit'], 'Edit');
            isEdit := True;
            with PData(vstVMs.GetNodeData(vstVMs.GetFirstSelected))^ do
            begin
               cmbMode.ItemIndex := ModeLoadVM;
               if Ptype = 0 then
               begin
                  if sbVirtualBox.Down then
                     cmbModeChange(cmbMode)
                  else
                     sbVirtualBox.Click;
               end
               else
               begin
                  if sbQEMU.Down then
                     cmbModeChange(cmbMode)
                  else
                     sbQEMU.Click;
               end;
               edtExeParams.Text := ExeParams;

               GetNamesAndIDs;
               for i := 0 to High(VMIDs) do
               try
                  cmbVMName.Items.Add('"' + VMIDs[i].Name + '"');
               except
               end;

               i := 2;
               while i < cmbVMName.Items.Count do
               begin
                  if cmbVMName.Items[i] = '"' + VMName + '"' then
                     Break;
                  Inc(i);
               end;
               if i < cmbVMName.Items.Count then
                  cmbVMName.ItemIndex := i
               else
                  cmbVMName.ItemIndex := 0;
               edtVMPath.Text := VMPath;
               Refresh;
               if FirstDriveFound then
               begin
                  SetLength(CBFirstDriveName, cmbFirstDrive.Items.Count);
                  SetLength(CBFirstDriveSize, cmbFirstDrive.Items.Count);
                  SetLength(CBFirstDriveLetters, cmbFirstDrive.Items.Count);
                  ws := GetStrBusType(FirstDriveBusType);
                  if ws <> '' then
                     CBFirstDriveName[High(CBFirstDriveName)] := ws + '  '
                  else
                     CBFirstDriveName[High(CBFirstDriveName)] := '';
                  i := Length(FirstDriveName) - pos(string(' ,'), string(ReverseString(string(FirstDriveName))), 1);
                  CBFirstDriveName[High(CBFirstDriveName)] := CBFirstDriveName[High(CBFirstDriveName)] + Copy(string(FirstDriveName), 1, i - 1);
                  CBFirstDriveSize[High(CBFirstDriveSize)] := Copy(string(FirstDriveName), i + 2, Length(FirstDriveName) - i - 1);
                  CBFirstDriveLetters[High(CBFirstDriveLetters)] := '[ ]';
                  CBMaxLetSize := cmbFirstDrive.Canvas.TextWidth('  [ ]');
                  cmbFirstDrive.Items.Append(string(FirstDriveName + ',  [ ]'));
                  cmbFirstDrive.ItemIndex := 1;
               end
               else
                  cmbFirstDrive.ItemIndex := 0;
               if AddSecondDrive then
               begin
                  if SecondDriveFound and (SecondDriveName <> '') then
                  begin
                     SetLength(CBSecondDriveName, cmbSecondDrive.Items.Count);
                     SetLength(CBSecondDriveSize, cmbSecondDrive.Items.Count);
                     SetLength(CBSecondDriveLetters, cmbSecondDrive.Items.Count);
                     ws := GetStrBusType(SecondDriveBusType);
                     if ws <> '' then
                        CBSecondDriveName[High(CBSecondDriveName)] := ws + '  '
                     else
                        CBSecondDriveName[High(CBSecondDriveName)] := '';
                     i := Length(SecondDriveName) - pos(string(' ,'), string(ReverseString(string(SecondDriveName))));
                     CBSecondDriveName[High(CBSecondDriveName)] := CBSecondDriveName[High(CBSecondDriveName)] + Copy(string(SecondDriveName), 1, i - 1);
                     CBSecondDriveSize[High(CBSecondDriveSize)] := Copy(string(SecondDriveName), i + 2, Length(SecondDriveName) - i - 1);
                     CBSecondDriveLetters[High(CBSecondDriveLetters)] := '[ ]';
                     CBMaxLetSize := cmbSecondDrive.Canvas.TextWidth('  [ ]');
                     cmbSecondDrive.Items.Append(string(SecondDriveName + ',  [ ]'));
                     cmbSecondDrive.ItemIndex := 1;
                  end
                  else
                     cmbSecondDrive.ItemIndex := 0;
               end;
               cmbCache.ItemIndex := Integer(UseHostIOCache);
               cmbEnableCPUVirtualization.ItemIndex := VBCPUVirtualization;
               edtHDD.Text := InternalHDD;
               if Ptype = 1 then
                  if CDROMName <> '' then
                  begin
                     if CDROMType = 0 then
                        cmbCDROM.Items.Add(CDROMName)
                     else
                        cmbCDROM.Items.Add(ExtractFileName(CDROMName));
                     cmbCDROM.ItemIndex := cmbCDROM.Items.Count - 1;
                  end;
               edtMemory.Text := IntToStr(MemorySize);
               cmbAudio.ItemIndex := AudioCard;
               cmbWS.ItemIndex := RunAs;
               cmbPriority.ItemIndex := CPUPriority;
            end;
            Left := frmMain.Left + ((frmMain.Width - Width) div 2) - DlgOffsPos;
            if Left < Screen.WorkAreaLeft then
               Left := Screen.WorkAreaLeft + DlgOffsPos
            else if Left + Width > Screen.WorkAreaRect.Right then
               Left := Screen.WorkAreaRect.Right - Width - DlgOffsPos;

            Top := frmMain.Top + ((frmMain.Height - Height) div 2) - DlgOffsPos;
            if Top < Screen.WorkAreaTop then
               Top := Screen.WorkAreaTop + DlgOffsPos
            else if Top + Height > Screen.WorkAreaRect.Bottom then
               Top := Screen.WorkAreaRect.Bottom - Height - DlgOffsPos;
            EditModalResult := ShowModal;
            if EditModalResult = mrOk then
            begin
               Node := vstVMs.GetFirstSelected;
               Data := vstVMs.GetNodeData(Node);
               with Data^ do
               begin
                  Ptype := Byte(not sbVirtualBox.Down);
                  if sbVirtualBox.Down then
                  begin
                     ModeLoadVM := cmbMode.ItemIndex;
                     case ModeLoadVM of
                        0:
                           begin
                              VMName := VMIDs[cmbVMName.ItemIndex - 2].Name;
                              VMID := string(VMIDs[cmbVMName.ItemIndex - 2].ID);
                              FolderName := '';
                              with frmMain.xmlGen do
                              begin
                                 if Tag = 1 then
                                 try
                                    Active := True;
                                    n1 := ChildNodes.IndexOf('VirtualBox');
                                    if n1 > -1 then
                                    begin
                                       n2 := ChildNodes[n1].ChildNodes.IndexOf('Global');
                                       if n2 > -1 then
                                       begin
                                          n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('SystemProperties');
                                          if n3 > -1 then
                                          begin
                                             a := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes.IndexOf('defaultMachineFolder');
                                             if a > -1 then
                                             begin
                                                FolderName := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes[a].Text;
                                                l := Length(FolderName);
                                                Replacebks(FolderName, l);
                                             end;
                                          end;
                                       end;
                                    end;
                                 except
                                 end;
                                 Active := False;
                              end;

                              if DirectoryExists(FolderName) then
                                 VMPath := FolderName + '\' + VMName + '\' + VMName + '.vbox'
                              else
                                 VMPath := '';
                           end;
                        1:
                           begin
                              VMPath := Trim(edtVMPath.Text);
                              VMName := ChangeFileExt(ExtractFileName(VMPath), '');
                              i := 0;
                              while i <= High(VMIDs) do
                              begin
                                 if VMIDs[i].Name = VMName then
                                    Break;
                                 Inc(i);
                              end;
                              VMID := string(VMIDs[i].ID);
                           end;
                        2:
                           begin
                              ws := Trim(edtExeParams.Text);
                              p := pos(string('--startvm "'), ws);
                              l := Length(ws);
                              if (p > 0) and ((p + 11) < l) then
                              begin
                                 cp := PosEx('"', ws, p + 11);
                                 if cp > 0 then
                                    ws := Trim(Copy(ws, p + 11, cp - p - 11))
                                 else
                                    ws := '';
                              end
                              else
                                 ws := '';
                              if FileExists(ws) then
                              begin
                                 wst := ChangeFileExt(ExtractFileName(ws), '');
                                 GetNamesAndIDs;
                                 i := 0;
                                 while i <= High(VMIDs) do
                                 begin
                                    if VMIDs[i].Name = wst then
                                       Break;
                                    Inc(i);
                                 end;
                                 if i <= High(VMIDs) then
                                 begin
                                    VMName := VMIDs[i].Name;
                                    VMID := string(VMIDs[i].ID);
                                    VMPath := ws;
                                 end;
                              end
                              else
                              begin
                                 wst := '';
                                 with frmMain.xmlGen do
                                 begin
                                    if Tag = 1 then
                                    try
                                       Active := True;
                                       n1 := ChildNodes.IndexOf('VirtualBox');
                                       if n1 > -1 then
                                       begin
                                          n2 := ChildNodes[n1].ChildNodes.IndexOf('Global');
                                          if n2 > -1 then
                                          begin
                                             n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('SystemProperties');
                                             if n3 > -1 then
                                             begin
                                                a := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes.IndexOf('defaultMachineFolder');
                                                if a > -1 then
                                                begin
                                                   wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes[a].Text;
                                                   Replacebks(wst, Length(wst));
                                                end;
                                             end;
                                          end;
                                       end;
                                    except
                                    end;
                                    Active := False;
                                 end;

                                 if (ExtractFileName(ws) = ws) and (ExtractFileExt(ws) <> '') and FileExists(wst + '\' + ChangeFileExt(ws, '') + '\' + ws) then
                                 begin
                                    VMPath := wst + '\' + ChangeFileExt(ws, '') + '\' + ws;
                                    wst := ChangeFileExt(ExtractFileName(ws), '');
                                    GetNamesAndIDs;
                                    i := 0;
                                    while i <= High(VMIDs) do
                                    begin
                                       if VMIDs[i].Name = wst then
                                          Break;
                                       Inc(i);
                                    end;
                                    if i <= High(VMIDs) then
                                    begin
                                       VMName := VMIDs[i].Name;
                                       VMID := string(VMIDs[i].ID);
                                    end
                                    else
                                    begin
                                       VMName := '';
                                       VMID := '';
                                       VMPath := '';
                                    end;
                                 end
                                 else if (ExtractFileName(ws) = ws) and (ExtractFileExt(ws) = '') and FileExists(wst + '\' + ws + '\' + ws + '.vbox') then
                                 begin
                                    VMPath := wst + '\' + ws + '\' + ws + '.vbox';
                                    wst := ChangeFileExt(ExtractFileName(ws), '');
                                    GetNamesAndIDs;
                                    i := 0;
                                    while i <= High(VMIDs) do
                                    begin
                                       if VMIDs[i].Name = wst then
                                          Break;
                                       Inc(i);
                                    end;
                                    if i <= High(VMIDs) then
                                    begin
                                       VMName := VMIDs[i].Name;
                                       VMID := string(VMIDs[i].ID);
                                    end
                                    else
                                    begin
                                       VMName := '';
                                       VMPath := '';
                                       VMID := '';
                                    end;
                                 end
                                 else if isGUID(ws) then
                                 begin
                                    i := 0;
                                    while i <= High(VMIDs) do
                                    begin
                                       if string(VMIDs[i].ID) = ws then
                                          Break;
                                       Inc(i);
                                    end;
                                    if i <= High(VMIDs) then
                                    begin
                                       VMName := VMIDs[i].Name;
                                       VMID := string(VMIDs[i].ID);
                                       FolderName := '';
                                       with frmMain.xmlGen do
                                       begin
                                          if Tag = 1 then
                                          try
                                             Active := True;
                                             n1 := ChildNodes.IndexOf('VirtualBox');
                                             if n1 > -1 then
                                             begin
                                                n2 := ChildNodes[n1].ChildNodes.IndexOf('Global');
                                                if n2 > -1 then
                                                begin
                                                   n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('SystemProperties');
                                                   if n3 > -1 then
                                                   begin
                                                      a := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes.IndexOf('defaultMachineFolder');
                                                      if a > -1 then
                                                      begin
                                                         FolderName := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes[a].Text;
                                                         l := Length(FolderName);
                                                         Replacebks(FolderName, l);
                                                      end;
                                                   end;
                                                end;
                                             end;
                                          except
                                          end;
                                          Active := False;
                                       end;

                                       if DirectoryExists(FolderName) then
                                          VMPath := FolderName + '\' + VMName + '\' + VMName + '.vbox'
                                       else
                                          VMPath := '';
                                    end;
                                 end;
                              end;
                           end;
                     end;
                  end
                  else
                  begin
                     ModeLoadVM := 2;
                     VMID := '';
                     VMPath := '';
                     ws := Trim(edtExeParams.Text);
                     p := pos(string('-name "'), ws);
                     l := Length(ws);
                     if (p > 0) and ((p + 7) < l) then
                     begin
                        cp := PosEx('"', ws, p + 7);
                        if cp > 0 then
                           ws := Trim(Copy(ws, p + 7, cp - p - 7))
                        else
                           ws := '';
                     end
                     else
                        ws := '';
                     VMName := ws;
                  end;
                  ExeParams := Trim(edtExeParams.Text);
                  strTemp := FirstDriveName;
                  if cmbFirstDrive.ItemIndex > 0 then
                  begin
                     strTemp := AnsiString(cmbFirstDrive.Text);
                     i := pos(string(',  ['), string(strTemp));
                     if i = 0 then
                        FirstDriveName := strTemp
                     else
                        FirstDriveName := Copy(strTemp, 1, i - 1);
                     i := Length(GetStrBusType(aDL[cmbFirstDrive.ItemIndex].BusType));
                     if i > 0 then
                        FirstDriveName := Copy(FirstDriveName, i + 3, Length(FirstDriveName) - i - 2);
                  end
                  else
                     FirstDriveName := '';
                  FirstDriveBusType := aDL[cmbFirstDrive.ItemIndex].BusType;
                  FirstDriveNumber := aDL[cmbFirstDrive.ItemIndex].Number;
                  FDMountPointsStr := CBFirstDriveLetters[cmbFirstDrive.ItemIndex - 1];
                  SetLength(FDMountPointsArr, Length(aDL[cmbFirstDrive.ItemIndex].VolPaths));
                  for i := 0 to High(aDL[cmbFirstDrive.ItemIndex].VolPaths) do
                     FDMountPointsArr[i] := aDL[cmbFirstDrive.ItemIndex].VolPaths[i];
                  FirstDriveFound := True;
                  if AddSecondDrive then
                  begin
                     strTemp := SecondDriveName;
                     if cmbSecondDrive.ItemIndex > 0 then
                     begin
                        strTemp := AnsiString(cmbSecondDrive.Text);
                        i := pos(string(',  ['), string(strTemp));
                        if i = 0 then
                           SecondDriveName := strTemp
                        else
                           SecondDriveName := Copy(strTemp, 1, i - 1);
                        i := Length(GetStrBusType(aDL[cmbSecondDrive.ItemIndex].BusType));
                        if i > 0 then
                           SecondDriveName := Copy(SecondDriveName, i + 3, Length(SecondDriveName) - i - 2);
                        SecondDriveBusType := aDL[cmbSecondDrive.ItemIndex].BusType;
                        SecondDriveNumber := aDL[cmbSecondDrive.ItemIndex].Number;
                        SDMountPointsStr := CBSecondDriveLetters[cmbSecondDrive.ItemIndex - 1];
                        SetLength(SDMountPointsArr, Length(aDL[cmbSecondDrive.ItemIndex].VolPaths));
                        for i := 0 to High(aDL[cmbSecondDrive.ItemIndex].VolPaths) do
                           SDMountPointsArr[i] := aDL[cmbSEcondDrive.ItemIndex].VolPaths[i];
                        SecondDriveFound := True;
                     end
                     else
                     begin
                        SecondDriveName := '';
                        SecondDriveNumber := -1;
                        SDMountPointsStr := '[ ]';
                        SetLength(SDMountPointsArr, 0);
                        SecondDriveFound := False;
                     end;
                  end;
                  UseHostIOCache := cmbCache.ItemIndex = 1;
                  VBCPUVirtualization := cmbEnableCPUVirtualization.ItemIndex;
                  InternalHDD := Trim(edtHDD.Text);
                  if cmbCDROM.ItemIndex = 0 then
                  begin
                     CDROMName := '';
                     CDROMType := 0;
                  end
                  else if CDDVDType = 0 then
                  begin
                     CDROMName := Copy(cmbCDROM.Items[cmbCDROM.ItemIndex], 1, Length(cmbCDROM.Items[cmbCDROM.ItemIndex]) - 8);
                     CDROMType := 0;
                  end
                  else
                  begin
                     CDROMName := TMyObj(cmbCDROM.Items.Objects[cmbCDROM.Items.Count - 1]).Text;
                     CDROMType := 1;
                  end;
                  MemorySize := Min(Max(StrToIntDef(edtMemory.Text, 512), 1), 65535);
                  AudioCard := cmbAudio.ItemIndex;
                  RunAs := cmbWS.ItemIndex;
                  CPUPriority := cmbPriority.ItemIndex;
                  luIDS.fdCID := '';
                  luIDS.fdGUID := '';
                  luIDS.sdCID := '';
                  luIDS.sdGUID := '';
                  vstVMs.BeginUpdate;
                  FVMImageIndex := Ptype;
                  FVName := VMName;
                  FDDisplayName := string(FirstDriveName);
                  l := Length(FDDisplayName);
                  i := l;
                  while i > 2 do
                  begin
                     if (FDDisplayName[i - 2] = ',') and (FDDisplayName[i - 1] = ' ') and CharInSet(FDDisplayName[i], ['0'..'9']) then
                     begin
                        Insert(' ', FDDisplayName, i - 1);
                        Inc(l);
                        Break;
                     end;
                     Dec(i);
                  end;
                  if l >= 3 then
                     if FDDisplayName[l] = 'B' then
                        if CharInSet(FDDisplayName[l - 1], ['G', 'M', 'T']) then
                           if FDDisplayName[l - 2] = ' ' then
                              FDDisplayName[l - 2] := HalfSpaceCharVST;
                  SDDisplayName := string(SecondDriveName);
                  l := Length(SDDisplayName);
                  i := l;
                  while i > 2 do
                  begin
                     if (SDDisplayName[i - 2] = ',') and (SDDisplayName[i - 1] = ' ') and CharInSet(SDDisplayName[i], ['0'..'9']) then
                     begin
                        Insert(' ', SDDisplayName, i - 1);
                        Inc(l);
                        Break;
                     end;
                     Dec(i);
                  end;
                  if l >= 3 then
                     if SDDisplayName[l] = 'B' then
                        if CharInSet(SDDisplayName[l - 1], ['G', 'M', 'T']) then
                           if SDDisplayName[l - 2] = ' ' then
                              SDDisplayName[l - 2] := HalfSpaceCharVST;
                  if FirstDriveName = '' then
                     FFDImageIndex := -1
                  else if FirstDriveFound then
                  begin
                     if ListOnlyUSBDrives then
                     begin
                        if FirstDriveBusType = 7 then
                           FFDImageIndex := 2
                        else
                           FFDImageIndex := 3;
                     end
                     else
                        case FirstDriveBusType of
                           1:
                              FFDImageIndex := 10;
                           4:
                              FFDImageIndex := 12;
                           7:
                              FFDImageIndex := 4;
                           8: FFDImageIndex := 14;
                           14, 15:
                              FFDImageIndex := 8;
                           else
                              FFDImageIndex := 6;
                        end;
                  end
                  else if ListOnlyUSBDrives then
                     FFDImageIndex := 3
                  else
                     case FirstDriveBusType of
                        1:
                           FFDImageIndex := 11;
                        4:
                           FFDImageIndex := 13;
                        7:
                           FFDImageIndex := 5;
                        8: FFDImageIndex := 15;
                        14, 15:
                           FFDImageIndex := 9;
                        else
                           FFDImageIndex := 7;
                     end;

                  if SecondDriveName = '' then
                     FSDImageIndex := -1
                  else if SecondDriveFound then
                  begin
                     if ListOnlyUSBDrives then
                     begin
                        if SecondDriveBusType = 7 then
                           FSDImageIndex := 2
                        else
                           FSDImageIndex := 3;
                     end
                     else
                        case SecondDriveBusType of
                           1:
                              FSDImageIndex := 10;
                           4:
                              FSDImageIndex := 12;
                           7:
                              FSDImageIndex := 4;
                           8: FSDImageIndex := 14;
                           14, 15:
                              FSDImageIndex := 8;
                           else
                              FSDImageIndex := 6;
                        end;
                  end
                  else if ListOnlyUSBDrives then
                     FSDImageIndex := 3
                  else
                     case SecondDriveBusType of
                        1:
                           FSDImageIndex := 11;
                        4:
                           FSDImageIndex := 13;
                        7:
                           FSDImageIndex := 5;
                        8: FSDImageIndex := 15;
                        14, 15:
                           FSDImageIndex := 9;
                        else
                           FSDImageIndex := 7;
                     end;
                  vstVMs.EndUpdate;
                  vstVMs.InvalidateNode(Node);
                  vstVMsFocusChanged(nil, nil, 0);
               end;
               SaveVMentries(VMentriesFile);
            end;
         end;
      finally
         frmAddEdit.Free;
         frmAddEdit := nil;
      end;
   except
   end;
   btnEdit.Down := False;
end;

procedure TfrmMain.btnDeleteClick(Sender: TObject);
var
   li, mbResult: Integer;
   Data: PData;
   Node, ToBeSelected: PVirtualNode;
   p: TPoint;
begin
   if isBusyStartVM then
   begin
      btnStart.Down := True;
      if Sender is TPngSpeedButton then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if IsBusyManager then
   begin
      btnManager.Down := True;
      if Sender is TPngSpeedButton then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if IsBusyEjecting then
   begin
      if Sender is TPngSpeedButton then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   btnDelete.Down := True;
   try
      if vstVMs.GetFirstSelected = nil then
         Exit;
      if vstVMs.GetFirstSelected.Index >= vstVMs.RootNodeCount then
         Exit;
      if ConfirmationDeleteShow then
      begin
         vstVMs.ScrollIntoView(vstVMs.GetFirstSelected, False);
         cbConfirmationSt := not ConfirmationDeleteShow;
         CustomMessageTop := vstVMs.GetDisplayRect(vstVMs.GetFirstSelected, 0, False).Bottom;
         CustomMessageHorzCenter := vstVMs.ClientWidth div 2;
         p := vstVMs.ClientToScreen(Point(CustomMessageHorzCenter, CustomMessageTop));
         CustomMessageHorzCenter := p.X;
         CustomMessageTop := p.Y + 1;
         CustomMessageBottom := vstVMs.ClientToScreen(Point(0, vstVMs.GetDisplayRect(vstVMs.GetFirstSelected, 0, False).Top)).Y - 1;
         mbResult := CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'SureDeleteEntry'], 'Are you sure you want to delete this entry...?')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbYes, mbNo], mbNo, GetLangTextDef(idxMessages, ['Checkboxes', 'DontShow'], 'Don''t show this next time'));
         if mbResult <> mrYes then
         begin
            btnDelete.Down := False;
            Exit;
         end;
         ConfirmationDeleteShow := not cbConfirmationSt;
      end;
      ColWereAligned := vstVMs.Header.Columns.TotalWidth = vstVMs.ClientWidth;
      li := vstVMs.GetFirstSelected.Index;
      vstVMs.BeginUpdate;
      vstVMs.DeleteSelectedNodes;
      li := Min(li, vstVMs.RootNodeCount - 1);
      if Length(IntToStr(vstVMs.RootNodeCount)) <> Length(IntToStr(vstVMs.RootNodeCount + 1)) then
      begin
         mmCrt.Tag := Max(vstVMs.Header.Height, Round(2 * vstVMs.Margin + 2 + vstVMs.Canvas.TextWidth('H') * (0.5 + Length(IntToStr(vstVMs.RootNodeCount)))));
         vstVMs.Header.Columns[0].MaxWidth := mmCrt.Tag;
         vstVMs.Header.Columns[0].MinWidth := mmCrt.Tag;
         vstVMs.Header.Columns[0].MaxWidth := mmCrt.Tag;
         vstVMs.Header.Columns[0].Width := mmCrt.Tag;
         if ColWereAligned then
            RealignColumns(False);
      end;
      ToBeSelected := nil;
      if vstVMs.RootNodeCount > 0 then
      begin
         Node := vstVMs.GetFirst;
         while Node <> nil do
         begin
            Data := vstVMs.GetNodeData(Node);
            if (vstVMs.RootNodeCount < 10) or (Node.Index > 8) then
               Data^.FId := IntToStr(Node.Index + 1)
            else
               Data^.FId := '0' + IntToStr(Node.Index + 1);
            if Integer(Node.Index) = li then
               ToBeSelected := Node;
            Node := vstVMs.GetNext(Node);
         end;
         if ToBeSelected <> nil then
         begin
            vstVMs.Selected[ToBeSelected] := True;
            vstVMs.FocusedNode := ToBeSelected;
            vstVMs.ScrollIntoView(ToBeSelected, False);
         end;
      end;
      vstVMs.EndUpdate;
      vstVMs.Invalidate;
      SaveVMentries(VMentriesFile);
   finally
      btnDelete.Down := False;
   end;
end;

procedure TfrmMain.MoveUp(Sender: TObject);
var
   i: Integer;
   Node1, Node2, Node3: PVirtualNode;
   Data1, Data2, Data3: PData;
begin
   if isBusyStartVM or IsBusyManager or isBusyEjecting then
      Exit;
   if vstVMs.RootNodeCount <= 1 then
      Exit;
   if vstVMs.GetFirstSelected = nil then
      Exit;
   i := vstVMs.GetFirstSelected.Index;
   if i < 1 then
      Exit;
   if i >= Integer(vstVMs.RootNodeCount) then
      Exit;

   vstVMs.BeginUpdate;
   Node1 := vstVMs.GetFirstSelected;
   Data1 := vstVMs.GetNodeData(Node1);
   Node2 := vstVMs.GetFirst;
   while True do
   begin
      if Node2 = nil then
         Break;
      if Integer(Node2.Index) = (i - 1) then
         Break;
      Node2 := vstVMs.GetNext(Node2);
   end;
   Data2 := vstVMs.GetNodeData(Node2);
   Node3 := vstVMs.AddChild(nil);
   Data3 := vstVMs.GetNodeData(Node3);
   Data3^ := Data1^;
   Data1^ := Data2^;
   Data2^ := Data3^;
   Data3^.FId := Data1^.FId;
   Data1^.FId := Data2^.FId;
   Data2^.FId := Data3^.FId;
   vstVMs.DeleteNode(Node3);
   vstVMs.EndUpdate;
   if (coVisible in vstVMs.Header.Columns[2].Options) or (coVisible in vstVMs.Header.Columns[3].Options) then
      vstVMs.Invalidate;
   vstVMs.Selected[Node2] := True;
   vstVMs.FocusedNode := Node2;
   vstVMs.ScrollIntoView(Node2, False);
   SaveVMentries(VMentriesFile);
end;

procedure TfrmMain.MoveDown(Sender: TObject);
var
   i: Integer;
   Node1, Node2, Node3: PVirtualNode;
   Data1, Data2, Data3: PData;
begin
   if isBusyStartVM or isBusyManager or isBusyEjecting then
      Exit;
   if vstVMs.RootNodeCount <= 1 then
      Exit;
   if vstVMs.GetFirstSelected = nil then
      Exit;
   i := vstVMs.GetFirstSelected.Index;
   if i < 0 then
      Exit;
   if i >= (-1 + Integer(vstVMs.RootNodeCount)) then
      Exit;

   vstVMs.BeginUpdate;
   Node1 := vstVMs.GetFirstSelected;
   Data1 := vstVMs.GetNodeData(Node1);
   Node2 := vstVMs.GetFirst;
   while True do
   begin
      if Node2 = nil then
         Break;
      if Integer(Node2.Index) = (i + 1) then
         Break;
      Node2 := vstVMs.GetNext(Node2);
   end;
   Data2 := vstVMs.GetNodeData(Node2);
   Node3 := vstVMs.AddChild(nil);
   Data3 := vstVMs.GetNodeData(Node3);
   Data3^ := Data1^;
   Data1^ := Data2^;
   Data2^ := Data3^;
   Data3^.FId := Data1^.FId;
   Data1^.FId := Data2^.FId;
   Data2^.FId := Data3^.FId;
   vstVMs.DeleteNode(Node3);
   vstVMs.EndUpdate;
   if (coVisible in vstVMs.Header.Columns[2].Options) or (coVisible in vstVMs.Header.Columns[3].Options) then
      vstVMs.Invalidate;
   vstVMs.Selected[Node2] := True;
   vstVMs.FocusedNode := Node2;
   vstVMs.ScrollIntoView(Node2, False);
   SaveVMentries(VMentriesFile);
end;

procedure TfrmMain.btnShowTrayIconClick(Sender: TObject);
var
   t: Double;
begin
   ShowTrayIcon := True;
   ShowTray;
   btnShowTrayIcon.Visible := False;
   btnExit.Tag := 6;
   OnResize := nil;
   LockWindowUpdate(Handle);
   SendMessage(pnlBackground.Handle, WM_SETREDRAW, wParam(False), 0);
   Constraints.MinHeight := 2 * vstVMs.Top + 7 * btnStart.Height + Height - ClientHeight;
   Constraints.MaxHeight := Height - ClientHeight + 2 * vstVms.Top + vstVMs.Height - vstVMs.ClientHeight + 11 * Integer(vstVMs.DefaultNodeHeight);
   t := 1.0 / 6 * (btnExit.Top - btnStart.Top);
   btnAdd.Top := Round(t + btnStart.Top);
   btnEdit.Top := Round(2.0 * t + btnStart.Top);
   btnDelete.Top := Round(3.0 * t + btnStart.Top);
   btnManager.Top := Round(4.0 * t + btnStart.Top);
   btnOptions.Top := Round(5.0 * t + btnStart.Top);
   SendMessage(pnlBackground.Handle, WM_SETREDRAW, wParam(True), 0);
   LockWindowUpdate(0);
   OnResize := FormResize;
   if ShowVMAnim or ShowFirstDriveAnim or ShowSecDriveAnim then
      if not Visible then
         if not TrayIcon.Animate then
            TrayIcon.Animate := True;
   if IsIconic(Application.Handle) then
   begin
      if TrayIcon.BalloonHint <> '' then
      begin
         TrayIcon.BalloonHint := '';
         Application.ProcessMessages;
      end;
      TrayIcon.BalloonHint := 'Virtual Machine USB Boot tray icon';
      TrayIcon.ShowBalloonHint;
      tmCloseHint.Interval := 2500;
      tmCloseHint.Enabled := False;
      tmCloseHint.Enabled := True;
   end
   else
      SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

function CombinedProcessorMask(const nProcessors: Integer): DWORD_PTR;
var
   ProcessorIndex: Integer;
begin
   Result := 0;
   for ProcessorIndex := 0 to nProcessors - 1 do
      Result := Result or (1 shl ProcessorIndex);
end;

procedure TfrmMain.btnStartClick(Sender: TObject);

   function areDifferent(const FirstXMLnode, SecondXMLnode: IXMLNode): Boolean;
   var
      i: Integer;
   begin
      Result := False;
      try
         if FirstXMLnode.AttributeNodes.Count <> SecondXMLnode.AttributeNodes.Count then
         begin
            Result := True;
            Exit;
         end;
         for i := 0 to FirstXMLnode.AttributeNodes.Count - 1 do
            if FirstXMLnode.AttributeNodes[i].Text <> SecondXMLnode.AttributeNodes[i].Text then
            begin
               Result := True;
               Exit;
            end;
         if FirstXMLnode.ChildNodes.Count <> SecondXMLnode.ChildNodes.Count then
         begin
            Result := True;
            Exit;
         end;
         if FirstXMLnode.ChildNodes.Count = 0 then
            Exit;
         for i := 0 to FirstXMLnode.ChildNodes.Count - 1 do
            if areDifferent(FirstXMLnode.ChildNodes[i], SecondXMLnode.ChildNodes[i]) then
            begin
               Result := True;
               Exit;
            end;
      except
      end;
   end;

const
   ReadBuffer = 2400;
   IOCTL_STORAGE_CHECK_VERIFY2 = $002D0800;
var
   eStartupInfo, vbmStartupInfo, svcStartupInfo: TStartupInfo;
   eProcessInfo, vbmProcessInfo, svcProcessInfo: TProcessInformation;
   ExitCode: DWORD;
   i, j, k, p, cp, l, n1, n2, n3, n4, n5, a1, a2, a3, a4, sc, iSC: Integer;
   lv: Int64;
   hVolume, hVBoxSVC, hVmdk, hVbox, hDrive, hSrcVol: THandle;
   dwBytesReturned: DWORD;
   sdn: STORAGE_DEVICE_NUMBER;
   an, vbmPath, StartFolder, sf, wst, wp, floc, sloc, ComLine, errmsg, mPort, mDevice, mCName, svcPath, strMess, exeVBPath: string;
   strStdErr: AnsiString;
   fsStdErr: TFilestream;
   CDROMLetter: AnsiChar;
   PStartFolder: PChar;
   ErrorMode: Word;
   fu, su: ShortInt;
   AllOK, BreakCycles, isWin, isRightWin, isFUSet, isSUSet, isLastC, DoChange, useVBMU, svcAlreadyStarted, Result, AlreadyHidden: Boolean;
   vmdkids: array of array[1..2] of string;
   exvmdks: array of AnsiString;
   fv, sv, fuuid, suuid, sVbox, sVmdk: AnsiString;
   ds: Int64;
   ahs: array of array[0..5] of Smallint;
   ahsUUID: array of string;
   sr: TSearchRec;
   tres: array[0..255] of Char;
   attr: Cardinal;
   tms: TMemoryStream;
   wereDismounted, js, jc, VBHardwareVirtualization, AlreadyWaitedForVBSVC: Boolean;
   ProcessID: THandle;
   WarnAboutBoot: Byte;
   vbmComm: array of array[1..2] of string;
   dwBytesRead, dwBytesSize: DWORD;
   bSuccess: LongBool;
   soPowerOff: Boolean;
   Data: PData;
   Input: TInput;
   AlreadyLoaded: array of THandle;
   SecAttr: TSecurityAttributes;
   StdErrWrite, StdErrRead: THandle;
   BytesRead, BytesAvail: Cardinal;
   Buffer: array[0..1024] of AnsiChar;
   volName: array[0..MAX_PATH] of WideChar;
   VolPaths: PWideChar;
   PosDrv: Byte;
   WindowPlacement: TWindowPlacement;
   WindowState: Integer;
   Path: array[0..MAX_PATH - 1] of Char;
   dt: Cardinal;
   AllProcAffinityMask: DWORD_PTR;
   useHostIOCacheCurr: Boolean;
   arrCtrlBoot: array[0..4] of SmallInt;
   //  ts: array[1..4] of TTime;

   function DoVBoxManageJob(const nJob: Integer; nRetryTime: Cardinal = 0): Boolean;
   var
      nWait: Integer;
      dt: Cardinal;
      hProcess: THandle;
   label
      TryAgain;
   begin
      dt := GetTickCount;
      TryAgain:
      ComLine := vbmPath + ' ' + vbmComm[nJob][1];
      FillChar(vbmStartupInfo, SizeOf(vbmStartupInfo), #0);
      vbmStartupInfo.cb := SizeOf(vbmStartupInfo);
      vbmStartupInfo.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
      vbmStartupInfo.wShowWindow := SW_HIDE;
      StartFolder := ExtractFilePath(ExeVBPath);
      SecAttr.nlength := SizeOf(SecAttr);
      SecAttr.binherithandle := True;
      SecAttr.lpsecuritydescriptor := nil;
      CreatePipe(StdErrRead, StdErrWrite, @SecAttr, 0);
      vbmStartupInfo.hStdError := StdErrWrite;
      if StartFolder <> '' then
         PStartFolder := PChar(StartFolder)
      else
         PStartFolder := nil;
      UniqueString(ComLine);
      try
         Result := CreateProcess(nil, PChar(ComLine), nil, nil, True, DETACHED_PROCESS or HIGH_PRIORITY_CLASS, nil, PStartFolder, vbmStartupInfo, vbmProcessInfo);
      except
         on E: Exception do
         begin
            Result := False;
            LastExceptionStr := E.Message;
         end;
      end;
      if Result then
      begin
         PrestartVBFilesAgain := True;
         nWait := 0;
         while (WaitForSingleObject(vbmProcessInfo.hProcess, 20) = WAIT_TIMEOUT) and (nWait < 1000) do
         begin
            Application.ProcessMessages;
            if Application.Terminated then
               Exit;
            Inc(nWait);
         end;
         if nWait >= 1000 then
         begin
            errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorVBMan'], [vbmComm[nJob][2], vbmComm[nJob][1]], 'Out of time waiting for VBoxManage.exe to finish the current job (%s) !'#13#10#13#10'Job = %s'#13#10#13#10'This is a VirtualBox bug. My advice is to wait 20..30 seconds and try again...');
            try
               if vbmProcessInfo.hProcess <> 0 then
                  CloseHandle(vbmProcessInfo.hProcess);
            except
            end;
            try
               if vbmProcessInfo.hThread <> 0 then
                  CloseHandle(vbmProcessInfo.hThread);
            except
            end;
            try
               CloseHandle(StdErrRead);
            except
            end;
            try
               CloseHandle(StdErrWrite);
            except
            end;
            hProcess := OpenProcess(PROCESS_TERMINATE, False, vbmProcessInfo.dwProcessId);
            if hProcess <> 0 then
            try
               TerminateProcess(hProcess, 1);
            except
            end;
            AllOK := False;
            Result := False;
            Exit;
         end;
         try
            PeekNamedPipe(StdErrRead, @Buffer, 1024, @BytesRead, @BytesAvail, nil);
            if BytesRead <> 0 then
            begin
               Buffer[BytesRead] := #0;
               strStdErr := AnsiString(Buffer);
            end;
         except
         end;
         try
            if not GetExitCodeProcess(eProcessInfo.hProcess, ExitCode) then
               ExitCode := 1;
         except
            ExitCode := 1;
         end;

         ExitCode := 9999;
         try
            GetExitCodeProcess(vbmProcessInfo.hProcess, ExitCode);
         except
         end;
         try
            if vbmProcessInfo.hProcess <> 0 then
               CloseHandle(vbmProcessInfo.hProcess);
         except
         end;
         try
            CloseHandle(vbmProcessInfo.hThread);
         except
         end;
         try
            CloseHandle(StdErrRead);
         except
         end;
         try
            CloseHandle(StdErrWrite);
         except
         end;
         if ExitCode > 0 then
         begin
            AllOK := False;
            Result := False;
            if ExitCode <> 9999 then
            begin
               if (GetTickCount - dt) < nRetryTime then
               begin
                  Application.ProcessMessages;
                  if Application.Terminated then
                     Exit;
                  AllOK := True;
                  goto TryAgain;
               end;
               errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'VBManErrorCode'], [ExitCode, vbmComm[nJob][2], vbmComm[nJob][1]], 'VBoxManage.exe returned error code %d for the current job (%s) !'#13#10#13#10'Job = %s');
            end
            else
               errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'VBManExitError'], [vbmComm[nJob][2], vbmComm[nJob][1]], 'Error getting the exit code for the current VBoxManage job (%s) !'#13#10#13#10'Job = %s');
            if strStdErr <> '' then
               errmsg := errmsg + #13#10#13#10 + GetLangTextDef(idxMain, ['Messages', 'VBManOutput'], 'VBoxManage output:') + #13#10#13#10 + string(strStdErr);
            Exit;
         end;
      end
      else
      begin
         LastError := GetLastError;
         errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'VBManUnableLaunch'], [SysErrorMessage(LastError)], 'Unable to launch VBoxManage.exe !'#13#10#13#10'System message: %s');
         AllOK := False;
         Result := False;
         Exit;
      end;
   end;

label
   sid, srchvbm, srchvm, srchvbm2, juststart, justclose;
begin
   if isBusyStartVM then
   begin
      btnStart.Down := True;
      btnManager.Down := False;
      Exit;
   end;
   if IsBusyManager then
   begin
      btnManager.Down := True;
      btnStart.Down := False;
      Exit;
   end;
   if IsBusyEjecting then
   begin
      if Sender is TPngSpeedButton then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   ErrorMode := SetErrorMode(SEM_FailCriticalErrors);
   fu := -1;
   su := -1;
   wereDismounted := False;
   js := False;
   jc := False;
   AllOK := False;
   VBHardwareVirtualization := True;
   useVBMU := False;
   AlreadyWaitedForVBSVC := False;
   svcAlreadyStarted := False;
   FindDrivesScheduled := False;
   soPowerOff := False;
   WarnAboutBoot := 0;
   PrestartVBFilesAgain := False;
   AlreadyHidden := False;
   if PathIsRelative(PChar(Mainform.ExeVBPath)) then
   begin
      FillMemory(@Path[0], Length(Path), 0);
      PathCanonicalize(@Path[0], PChar(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + Mainform.ExeVBPath));
      if string(Path) <> '' then
         exeVBPath := Path
      else
         exeVBPath := Mainform.ExeVBPath;
   end
   else
      exeVBPath := Mainform.ExeVBPath;
   if frmMain.DoubleBuffered <> True then
      frmMain.DoubleBuffered := True;
   if vstVMS.DoubleBuffered <> True then
      vstVMs.DoubleBuffered := True;
   try
      if vstVMs.GetFirstSelected = nil then
         Exit;
      p := vstVMs.GetFirstSelected.Index;
      if p < 0 then
         Exit;
      if p >= Integer(vstVMs.RootNodeCount) then
         Exit;
      if (isVBPortable and ((not FRegJobDone)) or (not FUnregJobDone)) then
      begin
         Data := frmMain.vstVMs.GetNodeData(frmMain.vstVMs.GetFirstSelected);
         if Data^.Ptype = 0 then
            Exit;
      end;

      isBusyStartVm := True;
      vstVMs.ScrollIntoView(vstVMs.GetFirstSelected, True, True);
      vstVMs.SelectionLocked := True;
      CurSelNode := vstVMs.GetFirstSelected.Index;

      if Sender <> nil then
         DisableLockAndDismount := GetKeyState(VK_CONTROL) < 0;
      tmCheckCTRL.Enabled := False;

      if TrayIcon.BalloonHint <> '' then
      begin
         TrayIcon.BalloonHint := '';
         Application.ProcessMessages;
      end;

      Data := vstVMs.GetNodeData(vstVMs.GetFirstSelected);
      if (not StartMessageShowed) and (Data^.Ptype <> 1) then
      begin
         try
            cbConfirmationSt := True;
            CustomMessageBox(Handle, GetLangTextFormatDef(idxMain, ['Messages', 'InfoStart'], [ReplaceStr(GetLangTextDef(idxMessages, ['Buttons', 'OK'], 'OK'), '&', '')], 'It will take a few seconds to modify the VM configuration file'#13#10'and another few seconds to start it.'#13#10#13#10'So please be patient while I carry out these operations.'#13#10#13#10'Click on %s to continue...'), GetLangTextDef(idxMessages, ['Types', 'Information'], 'Information'), mtInformation, [mbOk], mbOk, GetLangTextDef(idxMessages, ['Checkboxes', 'DontShow'], 'Don''t show this next time'));
            StartMessageShowed := cbConfirmationSt;
         except
         end;
      end;

      with Data^ do
      begin
         SetLength(VolumesInfo, 0);

         if Ptype <> 1 then
         begin
            vbmPath := ExtractFilePath(ExeVBPath) + 'VBoxManage.exe';
            svcPath := ExtractFilePath(ExeVBPath) + 'VBoxSVC.exe';

            AllOK := True;
            errmsg := GetLangTextDef(idxMain, ['Messages', 'UnknownError'], 'unknown error, please report it to the author'#13#10'with a complete description of what you''re doing.');
            case ModeLoadVM of
               2:
                  begin
                     p := pos(string('--startvm "'), ExeParams);
                     l := Length(ExeParams);
                     if (p > 0) and ((p + 11) < l) then
                     begin
                        cp := PosEx('"', ExeParams, p + 11);
                        if cp > 0 then
                           sf := Trim(Copy(ExeParams, p + 11, cp - p - 11))
                        else
                           sf := '';
                     end
                     else
                        sf := '';
                     VMPath := '';
                     VMID := '';
                     if sf <> '' then
                        if FileExists(sf) then
                           VMPath := sf
                        else
                        begin

                           with frmMain.xmlGen do
                           begin
                              if Tag = 1 then
                              try
                                 Active := True;
                                 n1 := ChildNodes.IndexOf('VirtualBox');
                                 if n1 > -1 then
                                 begin
                                    n2 := ChildNodes[n1].ChildNodes.IndexOf('Global');
                                    if n2 > -1 then
                                    begin
                                       n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('SystemProperties');
                                       if n3 > -1 then
                                       begin
                                          a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes.IndexOf('defaultMachineFolder');
                                          if a1 > -1 then
                                          begin
                                             wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AttributeNodes[a1].Text;
                                             Replacebks(wst, Length(wst));
                                          end;
                                       end;
                                    end;
                                 end;
                              except
                              end;
                              Active := False;
                           end;

                           if (ExtractFileName(sf) = sf) and (ExtractFileExt(sf) <> '') and FileExists(wst + '\' + ChangeFileExt(sf, '') + '\' + sf) then
                              VMPath := wst + '\' + ChangeFileExt(sf, '') + '\' + sf
                           else if (ExtractFileName(sf) = sf) and (ExtractFileExt(sf) = '') and FileExists(wst + '\' + sf + '\' + sf + '.vbox') then
                              VMPath := wst + '\' + sf + '\' + sf + '.vbox'
                           else if isGUID(sf) then
                           begin
                              VMID := sf;
                              goto sid;
                           end
                           else
                              sf := '';
                        end;
                     if sf = '' then
                     begin
                        AllOK := False;
                        errmsg := GetLangTextDef(idxMain, ['Messages', 'ErrorRetrievingPathID'], 'error retrieving VM path/ID from the exe parameters,'#13#10'please fix the path/ID.');
                     end
                     else if VMPath <> '' then
                     begin
                        VMName := ChangeFileExt(ExtractFileName(VMPath), '');
                        with xmlGen do
                        begin
                           AllOK := False;
                           errmsg := GetLangTextDef(idxMain, ['Messages', 'ErrorRetrievingPath'], 'error retrieving VM path from Virtualbox.xml,'#13#10'please replace the file or allow reading.');
                           if Tag = 1 then
                           try
                              Active := True;
                              n1 := ChildNodes.IndexOf('VirtualBox');
                              if n1 > -1 then
                              begin
                                 n2 := ChildNodes[n1].ChildNodes.IndexOf('Global');
                                 if n2 > -1 then
                                 begin
                                    n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('MachineRegistry');
                                    if n3 > -1 then
                                    begin
                                       i := 0;
                                       while i < ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count do
                                       begin
                                          try
                                             a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes.IndexOf('src');
                                             if a1 > -1 then
                                             begin
                                                wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes[a1].Text;
                                                l := Length(wst);
                                                if l > 2 then
                                                begin
                                                   if LowerCase(wst) = LowerCase(VMPath) then
                                                   begin
                                                      a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes.IndexOf('uuid');
                                                      if a1 > -1 then
                                                      begin
                                                         wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes[a1].Text;
                                                         VMID := Copy(wst, 2, Length(wst) - 2);
                                                         AllOK := True;
                                                         Break;
                                                      end;
                                                   end;
                                                end;
                                             end;
                                          except
                                          end;
                                          Inc(i);
                                       end;
                                       if (not AllOK) and (i >= ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count) then
                                          errmsg := GetLangTextDef(idxMain, ['Messages', 'CouldNotFindVM'], 'could not find the VM in VirtualBox configuration files,'#13#10'please set a valid VM.');
                                    end;
                                 end;
                              end;
                           except
                           end;
                           Active := False;
                        end;

                     end;
                  end;
               else
                  begin

                     sid:
                     with xmlGen do
                     begin
                        AllOK := False;
                        errmsg := GetLangTextDef(idxMain, ['Messages', 'ErrorRetrievingPath'], 'error retrieving VM path from Virtualbox.xml,'#13#10'please replace the file or allow reading.');
                        if Tag = 1 then
                        try
                           Active := True;
                           n1 := ChildNodes.IndexOf('VirtualBox');
                           if n1 > -1 then
                           begin
                              n2 := ChildNodes[n1].ChildNodes.IndexOf('Global');
                              if n2 > -1 then
                              begin
                                 n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('MachineRegistry');
                                 if n3 > -1 then
                                 begin
                                    i := 0;
                                    while i < ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count do
                                    begin
                                       try
                                          a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes.IndexOf('uuid');
                                          if a1 > -1 then
                                          begin
                                             wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes[a1].Text;
                                             l := Length(wst);
                                             if l > 2 then
                                             begin
                                                wst := Copy(wst, 2, l - 2);
                                                if wst = VMID then
                                                begin
                                                   a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes.IndexOf('src');
                                                   if a1 > -1 then
                                                   begin
                                                      wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes[a1].Text;
                                                      l := Length(wst);
                                                      if l >= 9 then
                                                      begin
                                                         Replacebks(wst, l);
                                                         VMPath := wst;
                                                         VMName := ChangeFileExt(ExtractFileName(VMPath), '');
                                                         AllOK := True;
                                                      end;
                                                      Break;
                                                   end;
                                                end;
                                             end;
                                          end;
                                       except
                                       end;
                                       Inc(i);
                                    end;
                                    if (not AllOK) and (i >= ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count) then
                                       errmsg := GetLangTextDef(idxMain, ['Messages', 'CouldNotFindVM'], 'could not find the VM in VirtualBox configuration files,'#13#10'please set a valid VM.');
                                 end;
                              end;
                           end;
                        except
                        end;
                        Active := False;
                     end;
                  end;
            end;
            if TrayIcon.Visible and ((not frmMain.Visible) or IsIconic(Application.Handle)) then
            begin
               if TrayIcon.BalloonHint <> '' then
               begin
                  TrayIcon.BalloonHint := '';
                  Application.ProcessMessages;
               end;
               TrayIcon.BalloonHint := GetLangTextFormatDef(idxMain, ['Messages', 'VMStarting'], [VMName], 'Starting "%s" VM...');
               TrayIcon.ShowBalloonHint;
            end;
            StartVMAnimation;
            Application.ProcessMessages;
            l := 0;
            if UpdateVM = 0 then
            begin
               GetAllWindowsList(VBWinClass);
               l := Length(AllWindowsList);
               for i := 0 to l - 1 do
                  if IsWindowVisible(AllWindowsList[i].Handle) then
                     if not ((pos(VMName + ' [', AllWindowsList[i].WCaption) = 1) and (Pos(string('] - Oracle VM VirtualBox'), AllWindowsList[i].WCaption) > 1)) then
                        if GetFileNameFromHandle(AllWindowsList[i].Handle) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                        begin
                           useVBMU := True;
                           Break;
                        end;
            end;

            if (UpdateVM = 1) or ((UpdateVM = 0) and useVBMU) then
            begin
               if l = 0 then
               begin
                  GetAllWindowsList(VBWinClass);
                  l := Length(AllWindowsList);
               end;
               j := 0;
               k := 0;
               for i := 0 to l - 1 do
                  if IsWindowVisible(AllWindowsList[i].Handle) then
                     if not ((pos(VMName + ' [', AllWindowsList[i].WCaption) = 1) and (Pos(string('] - Oracle VM VirtualBox'), AllWindowsList[i].WCaption) > 1)) then
                        if GetFileNameAndThreadFromHandle(AllWindowsList[i].Handle, ProcessID) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                           if IsAppNotStartedByAdmin(ProcessID) then
                              Inc(j)
                           else
                              Inc(k);
               if ((j + k) > 0) and (k = 0) then
               begin
                  StopVMAnimation;
                  if UpdateVM = 1 then
                     an := GetLangTextDef(idxMain, ['Messages', 'VBManNoAdm1'], 'In order for VBoxManage.exe to be able to properly communicate with'#13#10'VirtualBox it needs a VirtualBox session started with "Run as administrator"!'#13#10#13#10'Are you sure you want to continue..?')
                  else
                     an := GetLangTextDef(idxMain, ['Messages', 'VBManNoAdm2'], 'In order for VBoxManage.exe to be able to properly communicate with'#13#10'VirtualBox it needs a VirtualBox session started with "Run as administrator"'#13#10'or all normal VirtualBox sessions to be closed!'#13#10#13#10'Are you sure you want to continue..?');
                  for i := 0 to l - 1 do
                     if IsWindowVisible(AllWindowsList[i].Handle) then
                        if not ((pos(VMName + ' [', AllWindowsList[i].WCaption) = 1) and (Pos(string('] - Oracle VM VirtualBox'), AllWindowsList[i].WCaption) > 1)) then
                           if GetFileNameAndThreadFromHandle(AllWindowsList[i].Handle, ProcessID) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                              if IsAppNotStartedByAdmin(ProcessID) then
                              begin
                                 if IsIconic(AllWindowsList[i].Handle) then
                                 begin
                                    SendMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                                    dt := GetTickCount;
                                    while isIconic(AllWindowsList[i].Handle) do
                                    begin
                                       mEvent.WaitFor(1);
                                       Application.ProcessMessages;
                                       if (GetTickCount - dt) > 3000 then
                                          Break;
                                    end;
                                    SetForegroundWindow(frmMain.Handle);
                                 end;
                                 SetWindowPos(AllWindowsList[i].Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                                 SetWindowPos(AllWindowsList[i].Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                              end;
                  case CustomMessageBox(Handle, an, (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry], mbAbort) of
                     mrRetry:
                        begin
                           TryAgain := True;
                           Exit;
                        end;
                     else
                        Exit;
                  end;
               end;
            end;

            try
               if l = 0 then
               begin
                  GetAllWindowsList(VBWinClass);
                  l := Length(AllWindowsList);
               end;
               if (UpdateVM = 2) or ((UpdateVM = 0) and (not useVBMU)) then
               begin
                  an := GetLangTextDef(idxMain, ['Messages', 'VBManDetected'], 'VirtualBox Manager was detected.'#13#10'It is highly recommended not to be used in the same time !'#13#10#13#10'Should I close it...? (it will take a few sec to fully close)');
                  srchvbm:
                  for i := 0 to l - 1 do
                     if Pos('Oracle VM VirtualBox ', AllWindowsList[i].WCaption) = 1 then
                        if GetFileNameFromHandle(AllWindowsList[i].Handle) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                           if IsWindowVisible(AllWindowsList[i].Handle) then
                           begin
                              if IsIconic(AllWindowsList[i].Handle) then
                              begin
                                 SendMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                                 dt := GetTickCount;
                                 while isIconic(AllWindowsList[i].Handle) do
                                 begin
                                    mEvent.WaitFor(1);
                                    Application.ProcessMessages;
                                    if (GetTickCount - dt) > 3000 then
                                       Break;
                                 end;
                                 SetForegroundWindow(frmMain.Handle);
                              end;
                              SetWindowPos(AllWindowsList[i].Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                              SetWindowPos(AllWindowsList[i].Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                              StopVMAnimation;
                              TrayIcon.BalloonHint := '';
                              if CustomMessageBox(Handle, an, (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbOk, mbCancel], mbOk) <> mrOk then
                                 Exit
                              else
                              begin
                                 StartVMAnimation;
                                 if IsWindowVisible(AllWindowsList[i].Handle) then
                                    SendMessage(AllWindowsList[i].Handle, WM_CLOSE, 0, 0);
                                 j := 1;
                                 while j <= 20 do
                                 begin
                                    Wait(100);
                                    if Application.Terminated then
                                       Exit;
                                    isRightWin := True;
                                    isWin := isWindow(AllWindowsList[i].Handle);
                                    if isWin then
                                    begin
                                       GetWindowText(AllWindowsList[i].Handle, tres, 255);
                                       if Pos('Oracle VM VirtualBox ', tres) <> 1 then
                                          isRightWin := False
                                       else
                                       begin
                                          GetClassName(AllWindowsList[i].Handle, tres, 255);
                                          if tres <> VBWinClass then
                                             isRightWin := False;
                                       end;
                                    end;
                                    if (not isWin) or (not isRightWin) then
                                       Break;
                                    Inc(j);
                                 end;
                                 if j > 20 then
                                 begin
                                    if IsIconic(AllWindowsList[i].Handle) then
                                    begin
                                       SendMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                                       dt := GetTickCount;
                                       while isIconic(AllWindowsList[i].Handle) do
                                       begin
                                          mEvent.WaitFor(1);
                                          Application.ProcessMessages;
                                          if (GetTickCount - dt) > 3000 then
                                             Break;
                                       end;
                                       SetForegroundWindow(frmMain.Handle);
                                    end;
                                    SetWindowPos(AllWindowsList[i].Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                                    SetWindowPos(AllWindowsList[i].Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                                    StopVMAnimation;
                                    TrayIcon.BalloonHint := '';
                                    if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CouldNotCloseVBMan'], [ReplaceStr(GetLangTextDef(idxMessages, ['Buttons', 'OK'], 'OK'), '&', '')], 'Could not close VirtualBox Manager automatically !'#13#10#13#10'Please close it manually and click on %s...  (it will take a few sec to fully close)')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtWarning, [mbOk, mbCancel], mbOk) <> mrOk then
                                       Exit
                                    else
                                    begin
                                       StartVMAnimation;
                                       j := 1;
                                       while j <= 20 do
                                       begin
                                          Wait(100);
                                          if Application.Terminated then
                                             Exit;
                                          isRightWin := True;
                                          isWin := isWindow(AllWindowsList[i].Handle);
                                          if isWin then
                                          begin
                                             GetWindowText(AllWindowsList[i].Handle, tres, 255);
                                             if Pos('Oracle VM VirtualBox ', tres) <> 1 then
                                                isRightWin := False
                                             else
                                             begin
                                                GetClassName(AllWindowsList[i].Handle, tres, 255);
                                                if tres <> VBWinClass then
                                                   isRightWin := False;
                                             end;
                                          end;
                                          if (not isWin) or (not isRightWin) then
                                             Break;
                                          Inc(j);
                                       end;
                                       if j > 20 then
                                       begin
                                          CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'ErrorVBManNotClosed'], 'Error: VirtualBox Manager not closed !')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
                                          Exit;
                                       end;
                                    end;
                                 end;
                              end;
                              an := GetLangTextDef(idxMain, ['Messages', 'AnotherVBManSession'], 'Another VirtualBox Manager was detected.'#13#10'It is highly recommended not to be used in the same time !'#13#10#13#10'Should I close it...? (it will take a few sec to fully close)') + ' ';
                              goto srchvbm;
                           end;
               end;

               an := GetLangTextDef(idxMain, ['Messages', 'VBVMDetected'], 'A VirtualBox VM was detected.'#13#10'It is highly recommended not to be used in the same time !'#13#10#13#10'Please close it and click on %s... (it will take a few sec to fully close)');
               srchvm:
               if (UpdateVM = 2) or ((UpdateVM = 0) and (not useVBMU)) then
               begin
                  for i := 0 to l - 1 do
                     if Pos(string('] - Oracle VM VirtualBox'), AllWindowsList[i].WCaption) > 0 then
                        if GetFileNameFromHandle(AllWindowsList[i].Handle) = LowerCase(ExtractFileName(ExeVBPath)) then
                           if IsWindowVisible(AllWindowsList[i].Handle) then
                           begin
                              if IsIconic(AllWindowsList[i].Handle) then
                              begin
                                 SendMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                                 dt := GetTickCount;
                                 while isIconic(AllWindowsList[i].Handle) do
                                 begin
                                    mEvent.WaitFor(1);
                                    Application.ProcessMessages;
                                    if (GetTickCount - dt) > 3000 then
                                       Break;
                                 end;
                                 SetForegroundWindow(frmMain.Handle);
                              end;
                              SetWindowPos(AllWindowsList[i].Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                              SetWindowPos(AllWindowsList[i].Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                              StopVMAnimation;
                              TrayIcon.BalloonHint := '';
                              if CustomMessageBox(Handle, Format(an, [ReplaceStr(GetLangTextDef(idxMessages, ['Buttons', 'OK'], 'OK'), '&', '')]), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbOk, mbCancel], mbOk) <> mrOk then
                                 Exit
                              else
                              begin
                                 StartVMAnimation;
                                 j := 1;
                                 while j <= 20 do
                                 begin
                                    Wait(100);
                                    if Application.Terminated then
                                       Exit;
                                    isRightWin := True;
                                    isWin := isWindow(AllWindowsList[i].Handle);
                                    if isWin then
                                    begin
                                       GetWindowText(AllWindowsList[i].Handle, tres, 255);
                                       if pos(string('] - Oracle VM VirtualBox'), string(tres)) = 0 then
                                          isRightWin := False
                                       else
                                       begin
                                          GetClassName(AllWindowsList[i].Handle, tres, 255);
                                          if tres <> VBWinClass then
                                             isRightWin := False;
                                       end;
                                    end;
                                    if (not isWin) or (not isRightWin) then
                                       Break;
                                    Inc(j);
                                 end;
                                 if j > 20 then
                                 begin
                                    StopVMAnimation;
                                    TrayIcon.BalloonHint := '';
                                    CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'ErrorVBVMNotClosed'], 'Error: VirtualBox VM not closed !')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
                                    Exit;
                                 end;
                              end;
                              an := GetLangTextDef(idxMain, ['Messages', 'AnotherVBVMDetected'], 'Another VirtualBox VM was detected.'#13#10'It is highly recommended not to be used in the same time !'#13#10#13#10'Please close it and click on %s... (it will take a few sec to fully close)');
                              GetAllWindowsList(VBWinClass);
                              l := Length(AllWindowsList);
                              goto srchvm;
                           end;
               end
               else
               begin
                  for i := 0 to l - 1 do
                     if (pos(VMName + ' [', AllWindowsList[i].WCaption) = 1) and (Pos(string('] - Oracle VM VirtualBox'), AllWindowsList[i].WCaption) > 1) then
                        if GetFileNameFromHandle(AllWindowsList[i].Handle) = LowerCase(ExtractFileName(ExeVBPath)) then
                           if IsWindowVisible(AllWindowsList[i].Handle) then
                           begin
                              if IsIconic(AllWindowsList[i].Handle) then
                              begin
                                 SendMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                                 dt := GetTickCount;
                                 while isIconic(AllWindowsList[i].Handle) do
                                 begin
                                    mEvent.WaitFor(1);
                                    Application.ProcessMessages;
                                    if (GetTickCount - dt) > 3000 then
                                       Break;
                                 end;
                                 SetForegroundWindow(frmMain.Handle);
                              end;
                              SetWindowPos(AllWindowsList[i].Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                              SetWindowPos(AllWindowsList[i].Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                              StopVMAnimation;
                              TrayIcon.BalloonHint := '';
                              if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'ErrorVBVMAlready'], [AnsiString(ReplaceStr(GetLangTextDef(idxMessages, ['Buttons', 'OK'], 'OK'), '&', ''))], 'The VirtualBox VM is already started so its configuration cannot be updated.'#13#10#13#10'Please close it and click on %s... (it will take a few sec to fully close)')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbOk, mbCancel], mbOk) <> mrOk then
                                 Exit
                              else
                              begin
                                 StartVMAnimation;
                                 j := 1;
                                 while j <= 20 do
                                 begin
                                    Wait(100);
                                    if Application.Terminated then
                                       Exit;
                                    isRightWin := True;
                                    isWin := isWindow(AllWindowsList[i].Handle);
                                    if isWin then
                                    begin
                                       GetWindowText(AllWindowsList[i].Handle, tres, 255);
                                       if pos(string('] - Oracle VM VirtualBox'), string(tres)) = 0 then
                                          isRightWin := False
                                       else
                                       begin
                                          GetClassName(AllWindowsList[i].Handle, tres, 255);
                                          if tres <> VBWinClass then
                                             isRightWin := False;
                                       end;
                                    end;
                                    if (not isWin) or (not isRightWin) then
                                       Break;
                                    Inc(j);
                                 end;
                                 if j > 20 then
                                 begin
                                    StopVMAnimation;
                                    TrayIcon.BalloonHint := '';
                                    CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'ErrorVBVMNotClosed'], 'Error: VirtualBox VM not closed !')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
                                    Exit;
                                 end
                                 else
                                    VBVMWasClosed := Now;
                              end;
                              GetAllWindowsList(VBWinClass);
                              l := Length(AllWindowsList);
                              goto srchvm;
                           end;
               end;
            except
            end;

            if WaitForVBSVC then
               if (UpdateVM = 2) or ((UpdateVM = 0) and (not useVBMU)) then
               begin
                  try
                     GetAllWindowsList('VBoxPowerNotifyClass');
                     j := 0;
                     l := Length(AllWindowsList);
                     while j < l do
                     begin
                        if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                           if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                              Break;
                        Inc(j);
                     end;
                     if j < l then
                     begin
                        StartVMAnimation;
                        hVBoxSVC := AllWindowsList[j].Handle;
                        i := 1;
                        while i <= (200 + 200 * Integer(VBSVC2x)) do
                        begin
                           Wait(35);
                           if Application.Terminated then
                              Exit;
                           isRightWin := True;
                           isWin := isWindow(hVBoxSVC);
                           if isWin then
                           begin
                              GetWindowText(hVBoxSVC, tres, 255);
                              if tres <> 'VBoxPowerNotifyClass' then
                                 isRightWin := False
                              else
                              begin
                                 GetClassName(hVBoxSVC, tres, 255);
                                 if tres <> 'VBoxPowerNotifyClass' then
                                    isRightWin := False;
                              end;
                           end;
                           if (not isWin) or (not isRightWin) then
                           begin
                              GetAllWindowsList('VBoxPowerNotifyClass');
                              j := 0;
                              l := Length(AllWindowsList);
                              while j < l do
                              begin
                                 if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                    if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                                       Break;
                                 Inc(j);
                              end;
                              if j < l then
                                 hVBoxSVC := AllWindowsList[j].Handle
                              else
                              begin
                                 Wait(100);
                                 if Application.Terminated then
                                    Exit;
                                 Break;
                              end;
                           end;
                           Inc(i);
                        end;
                        if i > (200 + 200 * Integer(VBSVC2x)) then
                        begin
                           StopVMAnimation;
                           TrayIcon.BalloonHint := '';
                           if CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'OutOfTimeVBSVC'], 'Out of time waiting for "VBoxSVC.exe" (a VirtualBox component) to close...!'#13#10#13#10'Should I forcibly close it...?')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtWarning, [mbOk, mbCancel], mbOk) <> mrOk then
                              Exit
                           else
                           begin
                              StartVMAnimation;
                              j := 0;
                              GetAllWindowsList('VBoxPowerNotifyClass');
                              l := Length(AllWindowsList);
                              while j < l do
                              begin
                                 if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                    if GetFileNameAndThreadFromHandle(AllWindowsList[j].Handle, ProcessID) = 'vboxsvc.exe' then
                                    try
                                       TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), ProcessID), 0);
                                    except
                                    end;
                                 Inc(j);
                              end;
                              for i := 1 to 10 do
                              begin
                                 Wait(200);
                                 if Application.Terminated then
                                    Exit;
                                 j := 0;
                                 GetAllWindowsList('VBoxPowerNotifyClass');
                                 l := Length(AllWindowsList);
                                 while j < l do
                                 begin
                                    if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                       if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                                          Break;
                                    Inc(j);
                                 end;
                                 if j >= l then
                                    Break;
                              end;
                              if i <= 10 then
                              begin
                                 StopVMAnimation;
                                 TrayIcon.BalloonHint := '';
                                 CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'VBSVCStillOpened'], '"VBoxSVC.exe" is still opened !'#13#10#13#10'Exiting...')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
                                 Exit;
                              end;
                           end;
                        end;
                     end;

                  except
                  end;
               end
               else
               begin
                  GetAllWindowsList(VBWinClass);
                  l := Length(AllWindowsList);
                  if VBSVC2x then
                     sc := 11000 - Min(11000, Max(0, Round(86400000 * (Now - VBVMWasClosed))))
                  else
                     sc := 6000 - Min(6000, Max(0, Round(86400000 * (Now - VBVMWasClosed))));
                  for i := 0 to l - 1 do
                     if IsWindowVisible(AllWindowsList[i].Handle) then
                        if GetFileNameFromHandle(AllWindowsList[i].Handle) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                           sc := 0;
                  if sc > 0 then
                     StartVMAnimation;
                  if sc < 1500 then
                  begin
                     for j := 1 to Ceil(sc / 50) do
                     begin
                        Wait(50);
                        if Application.Terminated then
                           Exit;
                     end;
                  end
                  else
                  begin
                     j := 1;
                     while j <= 150 do
                     begin
                        Wait(100);
                        if Application.Terminated then
                           Exit;
                        GetAllWindowsList('VBoxPowerNotifyClass', VBWinClass);
                        l := Length(AllWindowsList);
                        i := 0;
                        while i < l do
                        begin
                           if AllWindowsList[i].WClass = VBWinClass then
                              if IsWindowVisible(AllWindowsList[i].Handle) then
                                 if GetFileNameFromHandle(AllWindowsList[i].Handle) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                                    Break;
                           if AllWindowsList[i].WClass = 'VBoxPowerNotifyClass' then
                              if AllWindowsList[i].WCaption = 'VBoxPowerNotifyClass' then
                                 if GetFileNameFromHandle(AllWindowsList[i].Handle) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                                    Break;
                           Inc(i);
                        end;
                        if i >= l then
                        begin
                           Wait(100);
                           Break;
                        end;
                        Wait(sc div 100);
                        if Application.Terminated then
                           Exit;
                        Inc(j);
                     end;
                  end;
               end;
            StopVMAnimation;
         end
         else
            while True do
            begin
               GetAllWindowsList('gdkWindowToplevel', 'SDL_app');
               l := Length(AllWindowsList);
               i := 0;
               while i < l do
               begin
                  if IsWindowVisible(AllWindowsList[i].Handle) or IsIconic(AllWindowsList[i].Handle) then
                     if Pos('QEMU', AllWindowsList[i].WCaption) = 1 then
                        if GetFileNameFromHandle(AllWindowsList[i].Handle) = WideLowerCase(ExtractFileName(ExeQPath)) then
                           Break;
                  Inc(i);
               end;
               if i >= l then
                  Break;
               if IsIconic(AllWindowsList[i].Handle) then
               begin
                  SendMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                  dt := GetTickCount;
                  while isIconic(AllWindowsList[i].Handle) do
                  begin
                     mEvent.WaitFor(1);
                     Application.ProcessMessages;
                     if (GetTickCount - dt) > 3000 then
                        Break;
                  end;
                  SetForeGroundWindow(frmMain.Handle);
               end;
               SetWindowPos(AllWindowsList[i].Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
               SetWindowPos(AllWindowsList[i].Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
               StopVMAnimation;
               TrayIcon.BalloonHint := '';
               case CustomMessageBox(frmMain.Handle, (GetLangTextDef(idxMain, ['Messages', 'WarningQEMUAlready'], 'QEMU seems to be already loaded. It''s advisable to be closed'#13#10'so it wouldn''t interfere with the current QEMU session.'#13#10#13#10'Are you sure you want to continue?')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry, mbIgnore], mbAbort) of
                  mrIgnore: Break;
                  mrAbort, mrNone, mrCancel: Exit;
               end;
            end;

         StopVMAnimation;
         StartFirstDriveAnimation;
         Application.ProcessMessages;
         while True do
         begin
            fu := FindDriveWithVendorProductSize(FirstDriveName);
            if fu = -1 then
            begin
               wst := string(FirstDriveName);
               l := Length(FirstDriveName);
               if l >= 3 then
                  if FirstDriveName[l] = 'B' then
                     if CharInSet(FirstDriveName[l - 1], ['G', 'M', 'T']) then
                        if FirstDriveName[l - 2] = ' ' then
                           wst[l - 2] := HalfSpaceCharMSG;
               j := l;
               while j > 2 do
               begin
                  if (FirstDriveName[j - 2] = ',') and (FirstDriveName[j - 1] = ' ') and CharInSet(FirstDriveName[j], ['0'..'9']) then
                  begin
                     Insert(' ', wst, j - 1);
                     Break;
                  end;
                  Dec(j);
               end;
               if AddSecondDrive then
               begin
                  if ListOnlyUSBDrives then
                     strMess := GetLangTextFormatDef(idxMain, ['Messages', 'FirstDriveWUsb'], [wst], 'The first drive (%s) doesn''t seem to exist on this system,'#13#10'it isn''t accessible or is not a USB drive !'#13#10#13#10'You can choose to abort the VM startup,'#13#10'try again or choose another drive...')
                  else
                     strMess := GetLangTextFormatDef(idxMain, ['Messages', 'FirstDrive'], [wst], 'The first drive (%s) doesn''t seem'#13#10'to exist on this system or it isn''t accessible !'#13#10#13#10'You can choose to abort the VM startup,'#13#10'try again or choose another drive...');
               end
               else
               begin
                  if ListOnlyUSBDrives then
                     strMess := GetLangTextFormatDef(idxMain, ['Messages', 'DriveWUsb'], [wst], 'The drive (%s) doesn''t seem to exist on this system,'#13#10'it isn''t accessible or is not a USB drive !'#13#10#13#10'You can choose to abort the VM startup,'#13#10'try again or choose another drive...')
                  else
                     strMess := GetLangTextFormatDef(idxMain, ['Messages', 'Drive'], [wst], 'The drive (%s) doesn''t seem'#13#10'to exist on this system or it isn''t accessible !'#13#10#13#10'You can choose to abort the VM startup,'#13#10'try again or choose another drive...');
               end;
               StopFirstDriveAnimation;
               TrayIcon.BalloonHint := '';
               case CustomMessageBox(Handle, strMess, GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbAbort, mbRetry, mbYesToAll], mbAbort) of
                  mrYesToAll:
                     begin
                        isBusyStartVM := False;
                        FocusFirstDrive := True;
                        btnStart.Down := False;
                        btnEdit.Down := True;
                        try
                           btnEditClick(frmMain);
                        finally
                           FocusFirstDrive := False;
                        end;
                        if EditModalResult = mrOK then
                        begin
                           isBusyStartVM := True;
                           btnStart.Down := True;
                           btnEdit.Down := False;
                           TryAgain := True;
                        end;
                        Exit;
                     end;
                  mrAbort, mrNone, mrCancel: Exit;
               end;
               StartFirstDriveAnimation;
            end
            else
               Break;
         end;

         if AddSecondDrive and (SecondDriveName <> '') then
         begin
            StartSecDriveAnimation;
            Application.ProcessMessages;
            while True do
            begin
               su := FindDriveWithVendorProductSize(SecondDriveName);
               if su = -1 then
               begin
                  wst := string(SecondDriveName);
                  l := Length(SecondDriveName);
                  if l >= 3 then
                     if SecondDriveName[l] = 'B' then
                        if CharInSet(SecondDriveName[l - 1], ['G', 'M', 'T']) then
                           if SecondDriveName[l - 2] = ' ' then
                              wst[l - 2] := HalfSpaceCharMSG;
                  j := l;
                  while j > 2 do
                  begin
                     if (SecondDriveName[j - 2] = ',') and (SecondDriveName[j - 1] = ' ') and CharInSet(SecondDriveName[j], ['0'..'9']) then
                     begin
                        Insert(' ', wst, j - 1);
                        Break;
                     end;
                     Dec(j);
                  end;
                  if ListOnlyUSBDrives then
                     strMess := GetLangTextFormatDef(idxMain, ['Messages', 'SecDriveWUsb'], [wst], 'The second drive (%s) doesn''t seem to exist on this system,'#13#10'it isn''t accessible or is not a USB drive !'#13#10#13#10'You can choose to abort the VM startup,'#13#10'try again or choose another drive...')
                  else
                     strMess := GetLangTextFormatDef(idxMain, ['Messages', 'SecDrive'], [wst], 'The second drive (%s) doesn''t seem'#13#10'to exist on this system or it isn''t accessible !'#13#10#13#10'You can choose to abort the VM startup,'#13#10'try again or choose another drive...');
                  StopFirstDriveAnimation;
                  TrayIcon.BalloonHint := '';
                  StopSecDriveAnimation;
                  case CustomMessageBox(Handle, strMess, GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbAbort, mbRetry, mbYesToAll], mbAbort) of
                     mrYesToAll:
                        begin
                           isBusyStartVM := False;
                           FocusSecDrive := True;
                           btnStart.Down := False;
                           btnEdit.Down := True;
                           try
                              btnEditClick(frmMain);
                           finally
                              FocusSecDrive := False;
                           end;
                           if EditModalResult = mrOK then
                           begin
                              isBusyStartVM := True;
                              btnStart.Down := True;
                              btnEdit.Down := False;
                              TryAgain := True;
                           end;
                           Exit;
                        end;
                     mrAbort, mrNone, mrCancel: Exit;
                  end;
                  StartFirstDriveAnimation;
                  StartSecDriveAnimation;
               end
               else
                  Break;
            end;
         end
         else
            su := -1;

         SetLength(VolumesInfo, 0);
         try
            hSrcVol := FindFirstVolumeW(@volName, SizeOf(volName));
            LastError := GetLastError;
         except
            hSrcVol := INVALID_HANDLE_VALUE;
         end;
         if hSrcVol <> INVALID_HANDLE_VALUE then
         begin
            repeat
               if Copy(volName, 1, 4) = '\\?\' then
               begin
                  try
                     GetVolumePathNamesForVolumeNameW(volName, nil, 0, dwBytesRead);
                     LastError := GetLastError;
                  except
                     on E: Exception do
                        LastError := 33333;
                  end;
                  if (LastError = ERROR_MORE_DATA) and (dwBytesRead >= 5) then
                  begin
                     dwBytesSize := 2 * dwBytesRead;
                     VolPaths := AllocMem(dwBytesSize);
                     try
                        bSuccess := GetVolumePathNamesForVolumeNameW(volName, VolPaths, dwBytesSize, dwBytesRead);
                        LastError := GetLastError;
                     except
                        bSuccess := False;
                     end;
                     if bSuccess then
                     begin
                        while VolName[StrLen(VolName) - 1] = '\' do
                           VolName[StrLen(VolName) - 1] := #0;
                        try
                           case GetDriveType(VolPaths) of
                              DRIVE_REMOVABLE, DRIVE_FIXED:
                                 begin
                                    try
                                       hVolume := CreateFile(VolName, 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                                    except
                                       hVolume := INVALID_HANDLE_VALUE;
                                    end;
                                    if hVolume <> INVALID_HANDLE_VALUE then
                                    begin
                                       l := strlen(VolPaths);
                                       while l > 0 do
                                          if CharInSet(VolPaths[l - 1], ['\', ':']) then
                                          begin
                                             VolPaths[l - 1] := #0;
                                             Dec(l);
                                          end
                                          else
                                             Break;
                                       dwBytesReturned := 0;
                                       try
                                          if DeviceIoControl(hVolume, IOCTL_STORAGE_GET_DEVICE_NUMBER, nil, 0, @sdn, SizeOf(sdn), dwBytesReturned, nil) then
                                          begin
                                             if Integer(sdn.DeviceNumber) = fu then
                                             begin
                                                SetLength(VolumesInfo, Length(VolumesInfo) + 1);
                                                StrPCopy(VolumesInfo[High(VolumesInfo)].Name, volName);
                                                StrPCopy(VolumesInfo[High(VolumesInfo)].Path, VolPaths);
                                                VolumesInfo[High(VolumesInfo)].DriveProp := string(FirstDriveName);
                                                l := Length(FirstDriveName);
                                                if l >= 3 then
                                                   if FirstDriveName[l] = 'B' then
                                                      if CharInSet(FirstDriveName[l - 1], ['G', 'M', 'T']) then
                                                         if FirstDriveName[l - 2] = ' ' then
                                                            VolumesInfo[High(VolumesInfo)].DriveProp[l - 2] := HalfSpaceCharMSG;
                                                j := l;
                                                while j > 2 do
                                                begin
                                                   if (FirstDriveName[j - 2] = ',') and (FirstDriveName[j - 1] = ' ') and CharInSet(FirstDriveName[j], ['0'..'9']) then
                                                   begin
                                                      Insert(' ', VolumesInfo[High(VolumesInfo)].DriveProp, j - 1);
                                                      Break;
                                                   end;
                                                   Dec(j);
                                                end;
                                                VolumesInfo[High(VolumesInfo)].FirstDrv := True;
                                             end
                                             else if Integer(sdn.DeviceNumber) = su then
                                             begin
                                                SetLength(VolumesInfo, Length(VolumesInfo) + 1);
                                                StrPCopy(VolumesInfo[High(VolumesInfo)].Name, volName);
                                                StrPCopy(VolumesInfo[High(VolumesInfo)].Path, VolPaths);
                                                VolumesInfo[High(VolumesInfo)].DriveProp := string(SecondDriveName);
                                                l := Length(SecondDriveName);
                                                if l >= 3 then
                                                   if SecondDriveName[l] = 'B' then
                                                      if CharInSet(SecondDriveName[l - 1], ['G', 'M', 'T']) then
                                                         if SecondDriveName[l - 2] = ' ' then
                                                            VolumesInfo[High(VolumesInfo)].DriveProp[l - 2] := HalfSpaceCharMSG;
                                                j := l;
                                                while j > 2 do
                                                begin
                                                   if (SecondDriveName[j - 2] = ',') and (SecondDriveName[j - 1] = ' ') and CharInSet(SecondDriveName[j], ['0'..'9']) then
                                                   begin
                                                      Insert(' ', VolumesInfo[High(VolumesInfo)].DriveProp, j - 1);
                                                      Break;
                                                   end;
                                                   Dec(j);
                                                end;
                                                VolumesInfo[High(VolumesInfo)].FirstDrv := False;
                                             end;
                                          end
                                          else
                                       except
                                       end;
                                    end;
                                    try
                                       CloseHandle(hVolume);
                                    except
                                    end;
                                 end
                              else
                                 Continue;
                           end;
                        except
                        end
                     end;
                     FreeMem(VolPaths);
                  end;
               end;
               try
                  bSuccess := FindNextVolumeW(hSrcVol, @volName, SizeOf(volName));
               except
                  bSuccess := False;
               end;
            until not bSuccess;
            FindVolumeClose(hSrcVol);
         end;

         //ts[1] := Now;
         Application.ProcessMessages;
         if Application.Terminated then
            Exit;
         DoFDThread := False;
         PosDrv := 0;
         while True do
         begin
            Inc(PosDrv);
            if PosDrv = 1 then
               DoFDThread := True
            else if PosDrv = 2 then
            begin
               if AddSecondDrive and (SecondDriveName <> '') then
                  DoFDThread := False
               else
                  Break;
            end
            else
               Break;
            if DoFDThread then
            begin
               StopSecDriveAnimation;
               StartFirstDriveAnimation;
            end
            else
            begin
               StopFirstDriveAnimation;
               StartSecDriveAnimation;
            end;
            FLDIndStart := 0;
            FDLSkipTo := -1;
            while True do
            begin
               FLDJobDone := False;
               FLDFailedInd := -1;
               FLDThread := TFLDThread.Create;
               while not FLDJobDone do
               begin
                  mEvent.WaitFor(1);
                  Application.ProcessMessages;
                  if Application.Terminated then
                  begin
                     FLDThread.Terminate;
                     FLDThread.Free;
                     FLDThread := nil;
                     Exit;
                  end;
               end;
               FLDThread.Free;
               FLDThread := nil;
               if FLDFailedInd = -1 then
                  Break
               else
               begin
                  if DoFDThread then
                     StopFirstDriveAnimation
                  else
                     StopSecDriveAnimation;
                  TrayIcon.BalloonHint := '';
                  case FLDAreaProblem of
                     0:
                        begin
                           wst := string(VolumesInfo[FLDFailedInd].Path);
                           if Length(wst) = 1 then
                              if CharInSet(wst[1], ['A'..'Z']) then
                                 wst := wst + ':';
                           case CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CantAccessVolume'], [wst, VolumesInfo[FLDFailedInd].DriveProp, SysErrorMessage(LastError)], 'Unable to access volume ''%s'' on "%s" !'#13#10#13#10'System message: %s'#13#10#13#10'Are you sure you want to continue...?')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry], mbAbort) of
                              mrRetry:
                                 begin
                                    FDLSkipTo := -1;
                                    FLDIndStart := FLDFailedInd;
                                    if DoFDThread then
                                       StartFirstDriveAnimation
                                    else
                                       StartSecDriveAnimation;
                                    Continue;
                                 end;
                              else
                                 Exit;
                           end;
                        end;
                     1:
                        begin
                           wst := string(VolumesInfo[FLDFailedInd].Path);
                           if Length(wst) = 1 then
                              if CharInSet(wst[1], ['A'..'Z']) then
                                 wst := wst + ':';
                           case CustomMessageBox(Handle, GetLangTextFormatDef(idxMain, ['Messages', 'UnableLockVolume'], [wst, VolumesInfo[FLDFailedInd].DriveProp, SysErrorMessage(LastError)], AnsiString('Unable to lock volume ''') + AnsiString(VolumesInfo[FLDFailedInd].Path) + AnsiString(''' on "') + AnsiString(VolumesInfo[FLDFailedInd].DriveProp) + AnsiString('" !'#13#10#13#10'System message: ') + AnsiString(SysErrorMessage(LastError)) + AnsiString(#13#10#13#10'Are you sure you want to continue...?')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbAbort, mbRetry, mbIgnore], mbAbort) of
                              mrRetry:
                                 begin
                                    FDLSkipTo := 0;
                                    FLDIndStart := FLDFailedInd;
                                    if DoFDThread then
                                       StartFirstDriveAnimation
                                    else
                                       StartSecDriveAnimation;
                                    Continue;
                                 end;
                              mrIgnore:
                                 begin
                                    FDLSkipTo := 1;
                                    FLDIndStart := FLDFailedInd;
                                    if DoFDThread then
                                       StartFirstDriveAnimation
                                    else
                                       StartSecDriveAnimation;
                                    Continue;
                                 end;
                              else
                                 Exit;
                           end;
                        end;
                     2:
                        begin
                           wst := string(VolumesInfo[FLDFailedInd].Path);
                           if Length(wst) = 1 then
                              if CharInSet(wst[1], ['A'..'Z']) then
                                 wst := wst + ':';
                           case CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'UnableDismVolume'], [wst, VolumesInfo[FLDFailedInd].DriveProp, SysErrorMessage(LastError)], 'Unable to dismount volume ''%s'' on "%s" !'#13#10#13#10'System message: %s'#13#10#13#10'Are you sure you want to continue...?')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry, mbIgnore], mbAbort) of
                              mrRetry:
                                 begin
                                    FDLSkipTo := 1;
                                    FLDIndStart := FLDFailedInd;
                                    if DoFDThread then
                                       StartFirstDriveAnimation
                                    else
                                       StartSecDriveAnimation;
                                    Continue;
                                 end;
                              mrIgnore:
                                 begin
                                    FDLSkipTo := -1;
                                    FLDIndStart := FLDFailedInd + 1;
                                    if FLDIndStart >= High(VolumesInfo) then
                                       Break;
                                    if DoFDThread then
                                       StartFirstDriveAnimation
                                    else
                                       StartSecDriveAnimation;
                                    Continue;
                                 end;
                              else
                                 Exit;
                           end;
                        end;
                  end;
               end;
            end;
         end;
         //ts[1] := Now - ts[1];
         //ts[2] := Now;
         wereDismounted := True;
         StopFirstDriveAnimation;
         StopSecDriveAnimation;
         StartVMAnimation;
         Application.ProcessMessages;
         if Application.Terminated then
            Exit;
         if Ptype = 1 then
         begin
            wp := Trim(ExeParams);
            p := pos(string('-name "'), wp);
            l := Length(wp);
            if (p > 0) and ((p + 7) < l) then
            begin
               cp := PosEx('"', wp, p + 7);
               if cp > 0 then
                  wp := Trim(Copy(wp, p + 7, cp - p - 7))
               else
                  wp := '';
            end
            else
               wp := '';
            VMName := wp;
            if TrayIcon.Visible and ((not frmMain.Visible) or IsIconic(Application.Handle)) then
            begin
               if TrayIcon.BalloonHint <> '' then
               begin
                  TrayIcon.BalloonHint := '';
                  Application.ProcessMessages;
               end;
               TrayIcon.BalloonHint := GetLangTextFormatDef(idxMain, ['Messages', 'VMStarting'], [VMName], 'Starting "%s" VM...');
               TrayIcon.ShowBalloonHint;
            end;
            StartVMAnimation;
            StartFolder := ExtractFilePath(ExeQPath);
            if EmulationBusType = 0 then
            begin
               if SecondDriveName = '' then
               begin
                  if UseHostIOCache then
                     ComLine := '"' + ExeQPath + '" ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(fu) + ',if=ide,index=0,media=disk,format=raw,snapshot=off,cache=writeback ' + ExeParams
                  else
                     ComLine := '"' + ExeQPath + '" ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(fu) + ',if=ide,index=0,media=disk,format=raw,snapshot=off,cache=none ' + ExeParams
               end
               else if UseHostIOCache then
                  ComLine := '"' + ExeQPath + '" ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(fu) + ',if=ide,index=0,media=disk,format=raw,snapshot=off,cache=writeback ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(su) + ',if=ide,index=1,media=disk,format=raw,snapshot=off,cache=writeback ' + ExeParams
               else
                  ComLine := '"' + ExeQPath + '" ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(fu) + ',if=ide,index=0,media=disk,format=raw,snapshot=off,cache=none ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(su) + ',if=ide,index=1,media=disk,format=raw,snapshot=off,cache=none ' + ExeParams;
            end
            else
            begin
               if SecondDriveName = '' then
               begin
                  if UseHostIOCache then
                     ComLine := '"' + ExeQPath + '" ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(fu) + ',if=scsi,index=0,media=disk,format=raw,snapshot=off,cache=writeback ' + ExeParams
                  else
                     ComLine := '"' + ExeQPath + '" ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(fu) + ',if=scsi,index=0,media=disk,format=raw,snapshot=off,cache=none ' + ExeParams
               end
               else if UseHostIOCache then
                  ComLine := '"' + ExeQPath + '" ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(fu) + ',if=scsi,index=0,media=disk,format=raw,snapshot=off,cache=writeback ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(su) + ',if=ide,index=1,media=disk,format=raw,snapshot=off,cache=writeback ' + ExeParams
               else
                  ComLine := '"' + ExeQPath + '" ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(fu) + ',if=scsi,index=0,media=disk,format=raw,snapshot=off,cache=none ' + ' -drive file=\\.\PhysicalDrive' + IntToStr(su) + ',if=ide,index=1,media=disk,format=raw,snapshot=off,cache=none ' + ExeParams;
            end;

            if InternalHDD <> '' then
               while True do
               begin
                  if FileExists(InternalHDD) then
                  begin
                     if SecondDriveName = '' then
                        ComLine := ComLine + ' -hdb "' + InternalHDD + '"'
                     else if CDROMName = '' then
                        ComLine := ComLine + ' -hdc "' + InternalHDD + '"'
                     else
                        ComLine := ComLine + ' -hdd "' + InternalHDD + '"';
                     Break;
                  end
                  else
                  begin
                     StopVMAnimation;
                     TrayIcon.BalloonHint := '';
                     case CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'UnableFindDevice'], [InternalHDD], 'Unable to find "%s" !'#13#10#13#10'Are you sure you want to continue...?')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry, mbIgnore], mbAbort) of
                        mrRetry:
                           begin
                              StartVMAnimation;
                              Continue;
                           end;
                        mrIgnore:
                           begin
                              StartVMAnimation;
                              Break;
                           end;
                        else
                           Exit;
                     end;
                  end;
               end;
            if CDROMName <> '' then
               while True do
               begin
                  if CDROMType = 0 then
                  begin
                     while True do
                     begin
                        CDROMLetter := AnsiChar(CharLower(PChar(Char(FindCDROMLetter(AnsiString(CDROMName))))));
                        if CDROMLetter <> '0' then
                        begin
                           while True do
                           begin
                              try
                                 hVolume := CreateFile(PChar('\\.\' + CDROMLetter + ':'), 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                              except
                                 hVolume := INVALID_HANDLE_VALUE;
                              end;
                              if hVolume = INVALID_HANDLE_VALUE then
                              begin
                                 StopVMAnimation;
                                 TrayIcon.BalloonHint := '';
                                 case CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CannotAccessCDROM'], [CDROMName], 'Cannot access the "%s" !'#13#10#13#10'Are you sure you want to continue...?')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry, mbIgnore], mbNo) of
                                    mrRetry:
                                       begin
                                          StartVMAnimation;
                                          Continue;
                                       end;
                                    mrIgnore:
                                       begin
                                          StartVMAnimation;
                                          Break;
                                       end;
                                    else
                                       Exit;
                                 end;
                              end
                              else
                              begin
                                 while True do
                                 begin
                                    try
                                       bSuccess := DeviceIoControl(hVolume, IOCTL_STORAGE_CHECK_VERIFY2, nil, 0, nil, 0, dwBytesRead, nil);
                                    except
                                       bSuccess := False;
                                    end;
                                    if bSuccess then
                                    begin
                                       try
                                          CloseHandle(hVolume);
                                       except
                                       end;
                                       Break;
                                    end
                                    else
                                    begin
                                       StopVMAnimation;
                                       TrayIcon.BalloonHint := '';
                                       case CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CannotAccessMedium'], [CDROMName + ',   [' + Char(UpCase(CDROMLetter)) + ':]'], 'Cannot access the medium from "%s" !'#13#10#13#10'Are you sure you want to continue...?')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry, mbIgnore], mbAbort) of
                                          mrRetry:
                                             begin
                                                StartVMAnimation;
                                                Continue;
                                             end;
                                          mrIgnore:
                                             begin
                                                StartVMAnimation;
                                                try
                                                   CloseHandle(hVolume);
                                                except
                                                end;
                                                Break;
                                             end;
                                          else
                                             begin
                                                try
                                                   CloseHandle(hVolume);
                                                except
                                                end;
                                                Exit;
                                             end;
                                       end;
                                    end;
                                 end;
                              end;
                              ComLine := ComLine + string(' -cdrom ' + CDROMLetter + ':');
                              Break;
                           end;
                        end
                        else
                        begin
                           StopVMAnimation;
                           TrayIcon.BalloonHint := '';
                           case CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CDROMDoesntExist'], [CDROMName], '"%s" doesn''t exist on this system, it is not mounted or it is not accessible !'#13#10#13#10'Are you sure you want to continue...?')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry, mbIgnore], mbAbort) of
                              mrRetry:
                                 begin
                                    StartVMAnimation;
                                    Continue;
                                 end;
                              mrIgnore:
                                 begin
                                    StartVMAnimation;
                                    Break;
                                 end;
                              else
                                 Exit;
                           end;
                        end;
                        Break;
                     end;
                  end
                  else if FileExists(CDROMName) then
                     ComLine := ComLine + ' -cdrom "' + CDROMName + '"'
                  else
                  begin
                     StopVMAnimation;
                     TrayIcon.BalloonHint := '';
                     case CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'UnableFindDevice'], [CDROMName], 'Unable to find "%s" !'#13#10#13#10'Are you sure you want to continue...?')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry, mbIgnore], mbAbort) of
                        mrRetry:
                           begin
                              StartVMAnimation;
                              Continue;
                           end;
                        mrIgnore:
                           begin
                              StartVMAnimation;
                              Break;
                           end;
                        else
                           Exit;
                     end;
                  end;
                  Break;
               end;
            ComLine := ComLine + ' -m ' + IntToStr(MemorySize);
            case AudioCard of
               1:
                  ComLine := ComLine + ' -soundhw sb16';
               2:
                  ComLine := ComLine + ' -soundhw pcspk';
               3:
                  ComLine := ComLine + ' -soundhw hda';
               4:
                  ComLine := ComLine + ' -soundhw gus';
               5:
                  ComLine := ComLine + ' -soundhw es1370';
               6:
                  ComLine := ComLine + ' -soundhw cs4231a';
               7:
                  ComLine := ComLine + ' -soundhw adlib';
               8:
                  ComLine := ComLine + ' -soundhw ac97';
            end;
         end
         else
         begin
            StartFolder := ExtractFilePath(ExeVBPath);
            if (fu >= 0) or (su >= 0) then
            begin
               if AllOK then
               begin
                  errmsg := GetLangTextDef(idxMain, ['Messages', 'UnknownError'], 'unknown error, please report it to the author'#13#10'with a complete description of what you''re doing.');
                  if isVBPortable then
                     VMPath := VBOX_USER_HOME + '\' + VMPath;
                  try
                     xmlVBox.LoadFromFile(VMPath);
                  except
                     on E: Exception do
                     begin
                        AllOK := False;
                        errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'PleaseAllowAccess'], [VMPath, E.Message], 'error accessing "%s",'#13#10'please allow access.'#13#10'System message: %s');
                        xmlVBox.Active := False;
                     end;
                  end;
                  xmlVBox.Tag := Integer(xmlVBox.Active);

                  if xmlVBox.Active then
                  begin
                     tms := TMemoryStream.Create;
                     try
                        xmlVBox.SaveToStream(tms);
                        xmlVBoxCompare.LoadFromStream(tms);
                     except
                     end;
                     xmlVBoxCompare.Tag := Integer(xmlVBoxCompare.Active);
                     tms.Free;

                     SetLength(vmdkids, 0);
                     SetLength(exvmdks, 0);

                     WarnAboutBoot := 1;

                     with xmlVBox do
                     begin
                        if Tag = 1 then
                        try
                           n1 := ChildNodes.IndexOf('VirtualBox');
                           if n1 = -1 then
                           begin
                              errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'SectionNotFound'], ['VirtualBox'], '"%s" section not found in the vbox file !'#13#10#13#10'It seems Oracle changed the file format or you have a corrupted file.');
                              Abort;
                           end
                           else
                           begin
                              n2 := ChildNodes[n1].ChildNodes.IndexOf('Machine');
                              if n2 = -1 then
                              begin
                                 errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'SectionNotFound'], ['Machine'], '"%s" section not found in the vbox file !'#13#10#13#10'It seems Oracle changed the file format or you have a corrupted file.');
                                 Abort;
                              end
                              else
                              begin
                                 a1 := ChildNodes[n1].ChildNodes[n2].AttributeNodes.IndexOf('stateFile');
                                 if a1 > -1 then
                                 begin
                                    CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'SavedStateOpen'], 'It appears this VM is in a saved state so it will not be modified, only started...'#13#10#13#10'Just so you know, it is not a good idea to save the state of a VM with a real drive,'#13#10'because it will increase the risk of corrupting the data from that drive...')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbOk], mbOk);
                                    js := True;
                                    Abort;
                                 end;
                                 n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('ExtraData');
                                 if n3 > -1 then
                                 begin
                                    n4 := 0;
                                    while n4 < ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count do
                                    begin
                                       a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].AttributeNodes.IndexOf('name');
                                       if (a1 > -1) and (ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].AttributeNodes[a1].NodeValue = 'GUI/LastCloseAction') then
                                       begin
                                          a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].AttributeNodes.IndexOf('value');
                                          if a2 > -1 then
                                             soPowerOff := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].AttributeNodes[a2].NodeValue = 'PowerOff';
                                          Break;
                                       end;
                                       Inc(n4);
                                    end;
                                 end;
                                 if not soPowerOff then
                                 begin
                                    SetLength(vbmComm, Length(vbmComm) + 1);
                                    vbmComm[High(vbmComm)][1] := 'setextradata ' + VMID + ' "GUI/LastCloseAction" PowerOff';
                                    vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'PowerOffDef'], 'setting Power Off as the default close action');
                                 end;
                                 n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('MediaRegistry');
                                 if n3 = -1 then
                                 begin
                                    errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'SectionNotFound'], ['MediaRegistry'], '"%s" section not found in the vbox file !'#13#10#13#10'It seems Oracle changed the file format or you have a corrupted file.');
                                    Abort;
                                 end
                                 else
                                 begin
                                    n4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.IndexOf('HardDisks');
                                    if n4 > -1 then
                                    begin
                                       for i := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes.Count - 1 downto 0 do
                                       begin
                                          a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes.IndexOf('format');
                                          if a1 = -1 then
                                             Continue;
                                          if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes[a1].Text = 'VMDK' then
                                          begin
                                             a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes.IndexOf('location');
                                             if a2 > -1 then
                                             begin
                                                wp := WideLowerCase(ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes[a2].Text);
                                                l := Length(wp);
                                                if l <> 17 then
                                                   Continue;
                                                if pos(string('vmubdrive'), wp) <> 1 then
                                                   Continue;
                                                if StrToIntDef('$' + Copy(wp, 10, 3), -1) = -1 then
                                                   Continue;
                                                if pos(string('.vmdk'), wp) <> 13 then
                                                   Continue;
                                                a3 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes.IndexOf('uuid');
                                                if a3 > -1 then
                                                begin
                                                   if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].ChildNodes.Count > 0 then
                                                   begin
                                                      errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'DividedSnapshots'], [ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes[a2].Text, ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].ChildNodes.Count], 'the content of "%s" is divided into %d snapshot(s).'#13#10'It is not a good idea using snapshots with real drives. But if you really want to at least do this:' + #13#10'If you created a snapshot or linked clone this VM you should of manually detached any'#13#10'VMUBDrive***.vmdk drive from the storage controller(s) before the snapshoting/cloning operation.');
                                                      Abort;
                                                   end;
                                                   wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes[a3].Text;
                                                   wst := Copy(wst, 2, Length(wst) - 2);
                                                   SetLength(vmdkids, Length(vmdkids) + 1);
                                                   vmdkids[High(vmdkids)][1] := wst;
                                                   ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes.Delete(i);
                                                   SetLength(vbmComm, Length(vbmComm) + 1);
                                                   vbmComm[High(vbmComm)][1] := 'closemedium disk ' + wst;
                                                   vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'RemoveDriveOp'], 'removing the drive');
                                                end;
                                             end;
                                          end;
                                       end;
                                       for i := 0 to ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes.Count - 1 do
                                       begin
                                          a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes.IndexOf('uuid');
                                          if a1 > -1 then
                                          begin
                                             wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes[a1].Text;
                                             SetLength(exvmdks, Length(exvmdks) + 1);
                                             exvmdks[High(exvmdks)] := AnsiString(Copy(wst, 2, Length(wst) - 2));
                                          end;
                                       end;
                                    end;
                                 end;
                                 if Length(vmdkids) > 0 then
                                 begin
                                    n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('StorageControllers');
                                    if n3 > -1 then
                                       for i := 0 to ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count - 1 do
                                          for j := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes.Count - 1 downto 0 do
                                          begin
                                             a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes.IndexOf('name');
                                             if a1 > -1 then
                                                mCName := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes[a1].Text
                                             else
                                                mCName := 'IDE';
                                             a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].AttributeNodes.IndexOf('port');
                                             if a2 > -1 then
                                                mPort := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].AttributeNodes[a2].Text
                                             else
                                                mPort := '0';
                                             a3 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].AttributeNodes.IndexOf('device');
                                             if a3 > -1 then
                                                mDevice := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].AttributeNodes[a3].Text
                                             else
                                                mDevice := '0';
                                             n4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].ChildNodes.IndexOf('Image');
                                             if n4 > -1 then
                                             begin
                                                a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].ChildNodes[n4].AttributeNodes.IndexOf('uuid');
                                                if a1 > -1 then
                                                begin
                                                   wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].ChildNodes[n4].AttributeNodes[a1].Text;
                                                   wst := Copy(wst, 2, Length(wst) - 2);
                                                   k := 0;
                                                   while k < Length(vmdkids) do
                                                   begin
                                                      if vmdkids[k][1] = wst then
                                                      begin
                                                         WarnAboutBoot := 0;
                                                         ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes.Delete(j);
                                                         SetLength(vbmComm, Length(vbmComm) + 1);
                                                         for p := High(vbmComm) downto 1 do
                                                            vbmComm[p] := vbmComm[p - 1];

                                                         if (a1 > -1) and (a2 > -1) and (a3 > -1) then
                                                         begin
                                                            vbmComm[0][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port ' + mPort + ' --device ' + mDevice + ' --medium none';
                                                            vbmComm[0][2] := GetLangTextDef(idxMain, ['Messages', 'DetachDriveOp'], 'detaching the drive');
                                                         end;
                                                         Break;
                                                      end;
                                                      Inc(k);
                                                   end;
                                                end;
                                             end;
                                          end;

                                 end;
                                 if VBCPUVirtualization <> 0 then
                                 begin
                                    n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('Hardware');
                                    if n3 > -1 then
                                    begin
                                       VBHardwareVirtualization := False;
                                       n4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.IndexOf('CPU');
                                       if n4 > -1 then
                                       begin
                                          n5 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes.IndexOf('HardwareVirtEx');
                                          if n5 > -1 then
                                          begin
                                             a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[n5].AttributeNodes.IndexOf('enabled');
                                             VBHardwareVirtualization := (a1 > -1) and (ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[n5].AttributeNodes[a1].Text = 'true');
                                          end
                                          else
                                             VBHardwareVirtualization := True;
                                       end;
                                    end;
                                 end;
                              end;
                           end;
                           AllOK := True;
                        except
                           if errmsg = GetLangTextDef(idxMain, ['Messages', 'UnknownError'], 'unknown error, please report it to the author'#13#10'with a complete description of what you''re doing.') then
                              errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'BrokenXML'], [VMPath], 'error accessing xml structure from "%s",'#13#10'please repair the file or replace it with a backup copy.');
                           AllOK := False;
                        end;

                        if not AllOK then
                           Active := False;
                        if js then
                           goto juststart;
                     end;

                  end;

                  if AllOK then
                  begin
                     if fu >= 0 then
                     begin
                        if luIDS.fdCID = '' then
                           luIDS.fdCID := GenID;
                        fv := defvmdk[1] + luIDS.fdCID + defvmdk[2];
                        try
                           hDrive := CreateFile(PChar('\\.\PHYSICALDRIVE' + IntToStr(fu)), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                        except
                           hDrive := INVALID_HANDLE_VALUE;
                        end;
                        ds := GetDriveSize(hDrive);
                        try
                           CloseHandle(hDrive);
                        except
                        end;
                        if ds = -1 then
                           ds := 4294967296
                        else
                           ds := ds div 512;
                        fuuid := '';
                        if luIDS.fdGUID <> '' then
                           fuuid := luIDS.fdGUID
                        else
                           fuuid := GenGuid;
                        while True do
                        begin
                           i := 0;
                           while i < Length(exvmdks) do
                           begin
                              if exvmdks[i] = fuuid then
                                 Break;
                              Inc(i);
                           end;
                           if i >= Length(exvmdks) then
                              Break;
                           fuuid := GenGuid;
                        end;
                        luIDS.fdGUID := fuuid;
                        SetLength(exvmdks, Length(exvmdks) + 1);
                        exvmdks[High(exvmdks)] := fuuid;
                        fv := fv + AnsiString(IntToStr(ds)) + defvmdk[3] + AnsiString(IntToStr(fu)) + defvmdk[4] + AnsiString(IntToStr(Min(16383, ds div 1008))) + defvmdk[5] + fuuid + defvmdk[6];
                     end
                     else
                        fv := '';

                     if su >= 0 then
                     begin
                        if luIDS.sdCID = '' then
                           while True do
                           begin
                              luIDS.sdCID := GenID;
                              if luIDS.sdCID <> luIDS.fdCID then
                                 Break;
                           end;
                        sv := defvmdk[1] + luIDS.sdCID + defvmdk[2];
                        try
                           hDrive := CreateFile(PChar('\\.\PHYSICALDRIVE' + IntToStr(su)), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                        except
                           hDrive := INVALID_HANDLE_VALUE;
                        end;
                        ds := GetDriveSize(hDrive);
                        try
                           CloseHandle(hDrive);
                        except
                        end;
                        if ds = -1 then
                           ds := 4294967296
                        else
                           ds := ds div 512;
                        suuid := '';
                        if luIDS.sdGUID <> '' then
                           suuid := luIDS.sdGUID
                        else
                           suuid := GenGuid;
                        while True do
                        begin
                           i := 0;
                           while i < Length(exvmdks) do
                           begin
                              if exvmdks[i] = suuid then
                                 Break;
                              Inc(i);
                           end;
                           if i >= Length(exvmdks) then
                              Break;
                           suuid := GenGuid;
                        end;
                        luIDS.sdGUID := suuid;
                        sv := sv + AnsiString(IntToStr(ds)) + defvmdk[3] + AnsiString(IntToStr(su)) + defvmdk[4] + AnsiString(IntToStr(Min(16383, ds div 1008))) + defvmdk[5] + suuid + defvmdk[6];
                     end
                     else
                        sv := '';

                     isFUSet := fu < 0;
                     isSUSet := su < 0;

                     sf := ExtractFilePath(VMPath);
                     try
                        if FindFirst(sf + 'VMUBDrive???.vmdk', faAnyFile, sr) = 0 then
                        begin
                           repeat
                              try
                                 if StrToIntDef('$' + Copy(sr.Name, 9, 3), -1) <> -1 then
                                 begin
                                    if not isFUSet then
                                    begin
                                       floc := sf + sr.Name;
                                       sVmdk := '';
                                       try
                                          hVmdk := CreateFile(PChar(floc), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                                       except
                                          hVmdk := INVALID_HANDLE_VALUE;
                                       end;
                                       if hVmdk <> INVALID_HANDLE_VALUE then
                                       begin
                                          try
                                             lv := GetFileSize(hVmdk, nil);
                                          except
                                             lv := $FFFFFFFF;
                                          end;
                                          if lv <> $FFFFFFFF then
                                          begin
                                             SetLength(sVmdk, lv);
                                             try
                                                ReadFile(hVmdk, Pointer(sVmdk)^, lv, dwBytesReturned, nil);
                                             except
                                                dwBytesReturned := 0;
                                             end;
                                             if lv = dwBytesReturned then
                                                if pos(fv, sVmdk) = 1 then
                                                   isFUSet := True;
                                          end;
                                          try
                                             CloseHandle(hVmdk);
                                          except
                                          end;
                                          if not isFUSet then
                                             DeleteFile(sf + sr.Name);
                                       end;
                                    end
                                    else if not isSUSet then
                                    begin
                                       sloc := sf + sr.Name;
                                       sVmdk := '';
                                       try
                                          hVmdk := CreateFile(PChar(sloc), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                                       except
                                          hVmdk := INVALID_HANDLE_VALUE;
                                       end;
                                       if hVmdk <> INVALID_HANDLE_VALUE then
                                       begin
                                          try
                                             lv := GetFileSize(hVmdk, nil);
                                          except
                                             lv := $FFFFFFFF;
                                          end;
                                          if lv <> $FFFFFFFF then
                                          begin
                                             SetLength(sVmdk, lv);
                                             try
                                                ReadFile(hVmdk, Pointer(sVmdk)^, lv, dwBytesReturned, nil);
                                             except
                                                dwBytesReturned := 0;
                                             end;
                                             if lv = dwBytesReturned then
                                                if pos(sv, sVmdk) = 1 then
                                                   isSUSet := True;
                                          end;
                                          try
                                             CloseHandle(hVmdk);
                                          except
                                          end;
                                          if not isSUSet then
                                             DeleteFile(sf + sr.Name);
                                       end;
                                    end
                                    else
                                       DeleteFile(sf + sr.Name);

                                 end;
                              except
                              end;
                           until FindNext(sr) <> 0;
                           FindClose(sr);
                        end;
                     except
                     end;
                     if not isFUSet then
                     begin
                        i := 0;
                        while i < 4096 do
                        begin
                           floc := sf + 'VMUBDrive' + IntToHex(i, 3) + '.vmdk';
                           if not FileExists(floc) then
                              Break;
                           Inc(i);
                        end;
                        if i < 4096 then
                        begin
                           hVmdk := INVALID_HANDLE_VALUE;
                           try
                              hVmdk := CreateFile(PChar(floc), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_FLAG_WRITE_THROUGH, 0);
                              if hVmdk <> INVALID_HANDLE_VALUE then
                              begin
                                 lv := Length(fv);
                                 if not WriteFile(hVmdk, Pointer(fv)^, lv, dwBytesReturned, nil) then
                                 begin
                                    LastError := GetLastError;
                                    errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteProtection'], [floc, SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please remove the write protection.'#13#10#13#10'System message: %s');
                                 end
                                 else
                                 begin
                                    try
                                       FlushFileBuffers(hVmdk);
                                    except
                                    end;
                                    if Cardinal(lv) <> dwBytesReturned then
                                    begin
                                       LastError := GetLastError;
                                       errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorSpaceVolume'], [floc, ExtractFileDrive(floc), SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please free some space or check the volume ''%s'' for errors.'#13#10#13#10'System message: %s');
                                    end
                                    else
                                       isFUSet := True;
                                 end;
                              end
                              else
                              begin
                                 LastError := GetLastError;
                                 errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteProtection'], [floc, SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please remove the write protection.'#13#10#13#10'System message: %s');
                              end;
                           except
                              on E: Exception do
                                 errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteVolume'], [floc, ExtractFileDrive(floc), E.Message], 'error writing in "%s",'#13#10'please remove the write protection or check the volume ''%s'' for errors.'#13#10'System message: %s');
                           end;
                           try
                              if hVmdk <> INVALID_HANDLE_VALUE then
                                 CloseHandle(hVmdk);
                           except
                           end;
                           Wait(200);
                        end
                        else
                           errmsg := GetLangTextDef(idxMain, ['Messages', 'UnableFreeInfo'], 'unable to find an unused vmdk file name in'#13#10'"VMUBDrive000..VMUBDriveFFF" range. Please detach and delete the unused ones.'#13#10'You can do that by starting the VirtualBox Manager, then the VirtualBox Media Manager'#13#10#13#10'and deleting one or more VMUBDrive***.vmdk.');
                     end;

                     if not isSUSet then
                     begin
                        i := 0;
                        while i < 4096 do
                        begin
                           sloc := sf + 'VMUBDrive' + IntToHex(i, 3) + '.vmdk';
                           if not FileExists(sloc) then
                              Break;
                           Inc(i);
                        end;
                        if i < 4096 then
                        begin
                           hVmdk := INVALID_HANDLE_VALUE;
                           try
                              hVmdk := CreateFile(PChar(sloc), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_FLAG_WRITE_THROUGH, 0);
                              if hVmdk <> INVALID_HANDLE_VALUE then
                              begin
                                 lv := Length(sv);
                                 if not WriteFile(hVmdk, Pointer(sv)^, lv, dwBytesReturned, nil) then
                                 begin
                                    LastError := GetLastError;
                                    errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteProtection'], [sloc, SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please remove the write protection.'#13#10#13#10'System message: %s');
                                 end
                                 else
                                 begin
                                    try
                                       FlushFileBuffers(hVmdk);
                                    except
                                    end;
                                    if Cardinal(lv) <> dwBytesReturned then
                                    begin
                                       LastError := GetLastError;
                                       errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorSpaceVolume'], [sloc, ExtractFileDrive(sloc), SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please free some space or check the volume ''%s'' for errors.'#13#10#13#10'System message: %s');
                                    end
                                    else
                                       isSUSet := True;
                                 end;
                              end
                              else
                              begin
                                 LastError := GetLastError;
                                 errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteProtection'], [sloc, SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please remove the write protection.'#13#10#13#10'System message: %s');
                              end;
                           except
                              on E: Exception do
                                 errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteVolume'], [sloc, ExtractFileDrive(sloc), E.Message], 'error writing in "%s",'#13#10'please remove the write protection or check the volume ''%s'' for errors.'#13#10'System message: %s');
                           end;
                           try
                              if hVmdk <> INVALID_HANDLE_VALUE then
                                 CloseHandle(hVmdk);
                           except
                           end;
                           Wait(200);
                           if Application.Terminated then
                              Exit;
                        end
                        else
                           errmsg := GetLangTextDef(idxMain, ['Messages', 'UnableFreeInfo'], 'unable to find an unused vmdk file name in'#13#10'"VMUBDrive000..VMUBDriveFFF" range. Please detach and delete the unused ones.'#13#10'You can do that by starting the VirtualBox Manager, then the VirtualBox Media Manager'#13#10#13#10'and deleting one or more VMUBDrive***.vmdk.');
                     end;

                     AllOK := isFUSet and isSUSet;

                     if AllOK then
                     begin
                        errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'BrokenXML'], [VMPath], 'error accessing xml structure from "%s",'#13#10'please repair the file or replace it with a backup copy.');
                        with xmlVBox do
                        begin
                           if Tag = 1 then
                           try
                              n1 := ChildNodes.IndexOf('VirtualBox');
                              if n1 = -1 then
                              begin
                                 errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'SectionNotFound'], ['VirtualBox'], '"%s" section not found in the vbox file !'#13#10#13#10'It seems Oracle changed the file format or you have a corrupted file.');
                                 Abort;
                              end
                              else
                              begin
                                 n2 := ChildNodes[n1].ChildNodes.IndexOf('Machine');
                                 if n2 = -1 then
                                 begin
                                    errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'SectionNotFound'], ['Machine'], '"%s" section not found in the vbox file !'#13#10#13#10'It seems Oracle changed the file format or you have a corrupted file.');
                                    Abort;
                                 end
                                 else
                                 begin
                                    n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('ExtraData');
                                    if n3 = -1 then
                                    begin
                                       ChildNodes[n1].ChildNodes[n2].AddChild('ExtraData', 1);
                                       n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('ExtraData');
                                    end;
                                    if n3 > -1 then
                                    begin
                                       n4 := 0;
                                       while n4 < ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count do
                                       begin
                                          a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].AttributeNodes.IndexOf('name');
                                          if (a1 > -1) and (ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].AttributeNodes[a1].NodeValue = 'GUI/LastCloseAction') then
                                          begin
                                             a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].AttributeNodes.IndexOf('value');
                                             if a2 = -1 then
                                                ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].SetAttribute('value', 'PowerOff')
                                             else
                                                ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].AttributeNodes[a2].NodeValue := 'PowerOff';
                                             Break;
                                          end;
                                          Inc(n4);
                                       end;
                                       if n4 = ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count then
                                          with ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AddChild('ExtraDataItem', 0) do
                                          begin
                                             SetAttribute('name', 'GUI/LastCloseAction');
                                             SetAttribute('value', 'PowerOff');
                                          end;
                                    end;
                                    n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('MediaRegistry');
                                    if n3 = -1 then
                                    begin
                                       errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'SectionNotFound'], ['MediaRegistry'], '"%s" section not found in the vbox file !'#13#10#13#10'It seems Oracle changed the file format or you have a corrupted file.');
                                       Abort;
                                    end
                                    else
                                    begin
                                       n4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.IndexOf('HardDisks');
                                       if n4 > -1 then
                                       begin
                                          if fu >= 0 then
                                             with ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].AddChild('HardDisk') do
                                             begin
                                                SetAttribute('uuid', '{' + fuuid + '}');
                                                SetAttribute('location', ExtractFileName(floc));
                                                SetAttribute('format', 'VMDK');
                                                SetAttribute('type', 'Normal');
                                             end;
                                          if su >= 0 then
                                             with ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].AddChild('HardDisk') do
                                             begin
                                                SetAttribute('uuid', '{' + suuid + '}');
                                                SetAttribute('location', ExtractFileName(sloc));
                                                SetAttribute('format', 'VMDK');
                                                SetAttribute('type', 'Normal');
                                             end;
                                       end;
                                    end;
                                    n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('StorageControllers');
                                    isFUSet := fu < 0;
                                    isSUSet := su < 0;
                                    if n3 > -1 then
                                       if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count > 0 then
                                       begin
                                          for i := 0 to High(arrCtrlBoot) do
                                             arrCtrlBoot[i] := -1;
                                          for sc := 0 to ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count - 1 do
                                          begin
                                             a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes.IndexOf('name');
                                             if a2 > -1 then
                                                mCName := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes[a2].Text
                                             else
                                                mCName := 'IDE';
                                             if mCName = 'IDE' then
                                                arrCtrlBoot[0] := sc
                                             else if mCName = 'NVMe' then
                                                arrCtrlBoot[1] := sc
                                             else if mCName = 'SAS' then
                                                arrCtrlBoot[2] := sc
                                             else if mCName = 'SATA' then
                                                arrCtrlBoot[3] := sc
                                             else if mCName = 'SCSI' then
                                                arrCtrlBoot[4] := sc;
                                          end;
                                          for iSC := 0 to High(arrCtrlBoot) do
                                             if arrCtrlBoot[iSC] > -1 then
                                             begin
                                                if isFUSet and isSUSet then
                                                   Break;
                                                sc := arrCtrlBoot[iSC];
                                                a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes.IndexOf('name');
                                                if a2 > -1 then
                                                   mCName := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes[a2].Text
                                                else
                                                   mCName := 'IDE';
                                                a3 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes.IndexOf('useHostIOCache');
                                                if a3 > -1 then
                                                   useHostIOCacheCurr := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes[a3].Text = 'true'
                                                else
                                                begin
                                                   useHostIOCacheCurr := False;
                                                   ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].SetAttribute('useHostIOCache', 'false');
                                                   a3 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes.IndexOf('useHostIOCache');
                                                end;
                                                if useHostIOCacheCurr <> useHostIOCache then
                                                begin
                                                   SetLength(vbmComm, Length(vbmComm) + 1);
                                                   vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'AttachDriveOp'], 'setting "use host I/O cache"');
                                                   if useHostIOCache then
                                                   begin
                                                      ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes[a3].Text := 'true';
                                                      vbmComm[High(vbmComm)][1] := 'storagectl ' + VMID + ' --name ' + mCName + ' --hostiocache on';
                                                   end
                                                   else
                                                   begin
                                                      ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes[a3].Text := 'false';
                                                      vbmComm[High(vbmComm)][1] := 'storagectl ' + VMID + ' --name ' + mCName + ' --hostiocache off';
                                                   end;
                                                end;
                                                i := iSC + 1;
                                                isLastC := True;
                                                while i <= High(arrCtrlBoot) do
                                                begin
                                                   if arrCtrlBoot[i] > -1 then
                                                   begin
                                                      isLastC := False;
                                                      Break;
                                                   end;
                                                   Inc(i);
                                                end;
                                                if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes.Count = 0 then
                                                begin
                                                   a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes.IndexOf('PortCount');
                                                   p := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes[a1].NodeValue;
                                                   if (fu >= 0) and (not isFUSet) then
                                                      if (ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes.Count + 1) > p then
                                                      begin
                                                         if isLastC then
                                                         begin
                                                            if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count = 1 then
                                                               errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePortAdvice'], 'unable to find a free port in the storage controller in the VirtualBox VM,'#13#10'please free one and try again.'#13#10'You can do that by starting the VirtualBox Manager, editing the VM''s storage options'#13#10'and increasing the Port Count of the storage controller.')
                                                            else
                                                               errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePort'], 'unable to find a free port in the storage controllers in the VirtualBox VM,'#13#10'please free one and try again.');
                                                            Abort;
                                                         end
                                                         else
                                                            Continue;
                                                      end
                                                      else
                                                      begin
                                                         a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes.Count;
                                                         with xmlVBox.ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AddChild('AttachedDevice') do
                                                         begin
                                                            SetAttribute('type', 'HardDisk');
                                                            SetAttribute('port', IntToStr(a2));
                                                            SetAttribute('device', '0');
                                                            with AddChild('Image') do
                                                               SetAttribute('uuid', '{' + fuuid + '}');
                                                         end;
                                                         SetLength(vbmComm, Length(vbmComm) + 1);
                                                         vbmComm[High(vbmComm)][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port ' + IntToStr(a2) + ' --device 0 --type hdd --medium "' + floc + '" --mtype normal';
                                                         vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'AttachDriveOp'], 'attaching the drive');
                                                      end;
                                                   if (su >= 0) and (not isSUSet) then
                                                      if (ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes.Count + 1) > p then
                                                      begin
                                                         if isLastC then
                                                         begin
                                                            if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count = 1 then
                                                               errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePortAdvice'], 'unable to find a free port in the storage controller in the VirtualBox VM,'#13#10'please free one and try again.'#13#10'You can do that by starting the VirtualBox Manager, editing the VM''s storage options'#13#10'and increasing the Port Count of the storage controller.')
                                                            else
                                                               errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePort'], 'unable to find a free port in the storage controllers in the VirtualBox VM,'#13#10'please free one and try again.');
                                                            Abort;
                                                         end
                                                         else
                                                            Continue;
                                                      end
                                                      else
                                                      begin
                                                         a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes.Count;
                                                         with ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AddChild('AttachedDevice') do
                                                         begin
                                                            SetAttribute('type', 'HardDisk');
                                                            SetAttribute('port', IntToStr(a2));
                                                            SetAttribute('device', '0');
                                                            with AddChild('Image') do
                                                               SetAttribute('uuid', '{' + suuid + '}');
                                                         end;
                                                         SetLength(vbmComm, Length(vbmComm) + 1);
                                                         vbmComm[High(vbmComm)][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port ' + IntToStr(a2) + ' --device 0 --type hdd --medium "' + sloc + '" --mtype normal';
                                                         vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'AttachDriveOp'], 'attaching the drive');
                                                      end;
                                                   Break;
                                                end
                                                else
                                                begin
                                                   SetLength(ahs, 0);
                                                   SetLength(ahsUUID, 0);
                                                   for i := 0 to ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes.Count - 1 do
                                                   begin
                                                      a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes.IndexOf('port');
                                                      a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes.IndexOf('device');
                                                      a3 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes.IndexOf('type');
                                                      if (a1 > -1) and (a2 > -1) and (a3 > -1) then
                                                      begin
                                                         j := 0;
                                                         a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes[a1].NodeValue;
                                                         a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes[a2].NodeValue;
                                                         while j <= High(ahs) do
                                                         begin
                                                            if ahs[j][0] > a1 then
                                                               Break
                                                            else if ahs[j][0] = a1 then
                                                               if ahs[j][1] > a2 then
                                                                  Break;
                                                            Inc(j);
                                                         end;
                                                         SetLength(ahs, Length(ahs) + 1);
                                                         SetLength(ahsUUID, Length(ahsUUID) + 1);
                                                         for k := High(ahs) downto j + 1 do
                                                         begin
                                                            ahs[k] := ahs[k - 1];
                                                            ahsUUID[k] := ahsUUID[k - 1];
                                                         end;
                                                         ahs[j][0] := a1;
                                                         ahs[j][1] := a2;
                                                         ahs[j][2] := Integer(ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes[a3].Text = 'HardDisk');
                                                         a4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes.IndexOf('passthrough');
                                                         if a4 > -1 then
                                                            ahs[j][3] := Integer(ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes[a4].Text = 'true')
                                                         else
                                                            ahs[j][3] := 0;
                                                         a4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes.IndexOf('nonrotational');
                                                         if a4 > -1 then
                                                            ahs[j][4] := Integer(ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes[a4].Text = 'true')
                                                         else
                                                            ahs[j][4] := 0;
                                                         a4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes.IndexOf('hotpluggable');
                                                         if a4 > -1 then
                                                            ahs[j][5] := Integer(ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].AttributeNodes[a4].Text = 'true')
                                                         else
                                                            ahs[j][5] := 0;
                                                         ahsUUID[j] := '';
                                                         if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].ChildNodes.Count = 1 then
                                                            if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].ChildNodes[0].NodeName = 'Image' then
                                                            begin
                                                               a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].ChildNodes[0].AttributeNodes.IndexOf('uuid');
                                                               if a1 >= 0 then
                                                                  ahsUUID[j] := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].ChildNodes[0].AttributeNodes[a1].Text;
                                                            end
                                                            else if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].ChildNodes[0].NodeName = 'HostDrive' then
                                                            begin
                                                               a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].ChildNodes[0].AttributeNodes.IndexOf('src');
                                                               if a1 >= 0 then
                                                                  ahsUUID[j] := 'host:' + ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[i].ChildNodes[0].AttributeNodes[a1].Text;
                                                            end;
                                                      end;
                                                   end;
                                                   a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes.IndexOf('type');
                                                   if a1 > -1 then
                                                   begin
                                                      wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes[a1].Text;
                                                      if (wst = 'PIIX3') or (wst = 'PIIX4') or (wst = 'ICH6') then
                                                      begin
                                                         a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes.IndexOf('PortCount');
                                                         p := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes[a1].NodeValue;
                                                         if (fu >= 0) and (not isFUSet) then
                                                         begin
                                                            if Length(ahs) < (2 * p) then
                                                            begin
                                                               i := 0;
                                                               j := 0;
                                                               BreakCycles := False;
                                                               while i < p do
                                                               begin
                                                                  j := 0;
                                                                  while j < p do
                                                                  begin
                                                                     k := 0;
                                                                     while k < Length(ahs) do
                                                                     begin
                                                                        if (ahs[k][0] = i) and (ahs[k][1] = j) then
                                                                           Break;
                                                                        Inc(k);
                                                                     end;
                                                                     if k >= Length(ahs) then
                                                                     begin
                                                                        BreakCycles := True;
                                                                        Break;
                                                                     end
                                                                     else if WarnAboutBoot = 1 then
                                                                        WarnAboutBoot := 2;
                                                                     Inc(j);
                                                                  end;
                                                                  if BreakCycles then
                                                                     Break;
                                                                  Inc(i);
                                                               end;
                                                               if (WarnAboutBoot <> 2) or (sc <> 0) then
                                                               begin
                                                                  with ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AddChild('AttachedDevice') do
                                                                  begin
                                                                     SetAttribute('type', 'HardDisk');
                                                                     SetAttribute('port', IntToStr(i));
                                                                     SetAttribute('device', IntToStr(j));
                                                                     with AddChild('Image') do
                                                                        SetAttribute('uuid', '{' + fuuid + '}');
                                                                     SetLength(ahs, Length(ahs) + 1);
                                                                     ahs[High(ahs)][0] := i;
                                                                     ahs[High(ahs)][1] := j;
                                                                     isFUSet := True;
                                                                  end;
                                                                  SetLength(vbmComm, Length(vbmComm) + 1);
                                                                  vbmComm[High(vbmComm)][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port ' + IntToStr(i) + ' --device ' + IntToStr(j) + ' --type hdd --medium "' + floc + '" --mtype normal';
                                                                  vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'AttachDriveOp'], 'attaching the drive');
                                                               end
                                                               else
                                                               begin
                                                                  WarnAboutBoot := 1;
                                                                  i := 0;
                                                                  while i <= High(ahs) do
                                                                  begin
                                                                     if (ahs[i][0] <> (i div 2)) or (ahs[i][1] <> (i mod 2)) then
                                                                        Break;
                                                                     Inc(i);
                                                                  end;
                                                                  Dec(i);
                                                                  StopVMAnimation;
                                                                  TrayIcon.BalloonHint := '';
                                                                  case CustomMessageBox(Handle, GetLangTextFormatDef(idxMain, ['Messages',
                                                                     'WarnChangeBootDriveAndOther'], [FirstDriveName], 'In order to boot the VM from the "%s" drive,'#13#10 +
                                                                        'it must be set as the first internal hard disk, but the first position is currently taken by another drive.' +
                                                                     #13#10#13#10'Click on Yes to automatically shift up the other drives in subsequent positions'#13#10'or do it manually and click on Retry'), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbYes, mbRetry, mbCancel], mbYes) of
                                                                     mrNone, mrCancel:
                                                                        Exit;
                                                                     mrRetry:
                                                                        begin
                                                                           TryAgain := True;
                                                                           Exit;
                                                                        end;
                                                                  end;
                                                                  StartVMANimation;
                                                                  j := 0;
                                                                  while j < ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes.Count do
                                                                  begin
                                                                     a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes.IndexOf('port');
                                                                     a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes.IndexOf('device');
                                                                     a3 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes[a1].NodeValue;
                                                                     a4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes[a2].NodeValue;
                                                                     if (a3 <> 1) or (a4 <> 1) then
                                                                        if (a3 < ahs[i][0]) or ((a3 = ahs[i][0]) and (a4 <= ahs[i][1])) then
                                                                        begin
                                                                           if a3 = 0 then
                                                                           begin
                                                                              if a4 = 0 then
                                                                              begin
                                                                                 ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes[a2].NodeValue := 1;
                                                                              end
                                                                              else
                                                                              begin
                                                                                 ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes[a1].NodeValue := 1;
                                                                                 ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes[a2].NodeValue := 0;
                                                                              end;
                                                                           end
                                                                           else
                                                                           begin
                                                                              ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes[a2].NodeValue := 1;
                                                                           end;
                                                                        end;
                                                                     Inc(j);
                                                                  end;
                                                                  j := Length(vbmComm);
                                                                  SetLength(vbmComm, 2 * (i + 1) + j + 1);
                                                                  while i >= 0 do
                                                                  begin
                                                                     if (ahs[i][0] <> 1) or (ahs[i][1] <> 1) then
                                                                     begin
                                                                        vbmComm[j][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port ' + IntToStr(ahs[i][0]) + ' --device ' + IntToStr(ahs[i][1]) + ' --medium none';
                                                                        vbmComm[j][2] := GetLangTextDef(idxMain, ['Messages', 'DetachDriveOp'], 'detaching the drive');
                                                                        Inc(j);
                                                                        vbmComm[j][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName;
                                                                        if ahs[i][0] = 0 then
                                                                        begin
                                                                           if ahs[i][1] = 0 then
                                                                              vbmComm[j][1] := vbmComm[j][1] + ' --port 0 --device 1'
                                                                           else
                                                                              vbmComm[j][1] := vbmComm[j][1] + ' --port 1 --device 0';
                                                                        end
                                                                        else
                                                                        begin
                                                                           vbmComm[j][1] := vbmComm[j][1] + ' --port 1 --device 1';
                                                                        end;
                                                                        if ahs[i][2] = 1 then
                                                                        begin
                                                                           vbmComm[j][1] := vbmComm[j][1] + ' --type hdd';
                                                                           if ahs[i][4] = 1 then
                                                                              vbmComm[j][1] := vbmComm[j][1] + ' --nonrotational on'
                                                                           else
                                                                              vbmComm[j][1] := vbmComm[j][1] + ' --nonrotational off';
                                                                           {                            if ahs[i][5] = 1 then
                                                                                                          vbmComm[j][1] := vbmComm[j][1] + ' --hotpluggable on'
                                                                                                       else
                                                                                                          vbmComm[j][1] := vbmComm[j][1] + ' --hotpluggable off';}
                                                                        end
                                                                        else
                                                                        begin
                                                                           vbmComm[j][1] := vbmComm[j][1] + ' --type dvddrive';
                                                                           if ahs[i][3] = 1 then
                                                                              vbmComm[j][1] := vbmComm[j][1] + ' --passthrough on'
                                                                           else
                                                                              vbmComm[j][1] := vbmComm[j][1] + ' --passthrough off';
                                                                           { if ahs[i][5] = 1 then
                                                                               vbmComm[j][1] := vbmComm[j][1] + ' --hotpluggable on'
                                                                            else
                                                                               vbmComm[j][1] := vbmComm[j][1] + ' --hotpluggable off';}
                                                                        end;
                                                                        if ahsUUID[i] <> '' then
                                                                           vbmComm[j][1] := vbmComm[j][1] + ' --medium "' + ahsUUId[i] + '"'
                                                                        else
                                                                           vbmComm[j][1] := vbmComm[j][1] + ' --medium emptydrive';
                                                                        vbmComm[j][2] := GetLangTextDef(idxMain, ['Messages', 'AttachDriveOp'], 'attaching the drive');
                                                                     end;
                                                                     Inc(j);
                                                                     Dec(i);
                                                                  end;
                                                                  with ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AddChild('AttachedDevice') do
                                                                  begin
                                                                     SetAttribute('type', 'HardDisk');
                                                                     SetAttribute('port', 0);
                                                                     SetAttribute('device', 0);
                                                                     with AddChild('Image') do
                                                                        SetAttribute('uuid', '{' + fuuid + '}');
                                                                     SetLength(ahs, Length(ahs) + 1);
                                                                     ahs[High(ahs)][0] := 0;
                                                                     ahs[High(ahs)][1] := 0;
                                                                     SetLength(ahsUUID, Length(ahsUUID) + 1);
                                                                     ahsUUID[High(ahsUUID)] := string(fuuid);
                                                                     isFUSet := True;
                                                                  end;
                                                                  vbmComm[High(vbmComm)][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port 0 --device 0 --type hdd --medium "' + floc + '" --mtype normal';
                                                                  vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'AttachDriveOp'], 'attaching the drive');
                                                               end;
                                                            end
                                                            else
                                                            begin
                                                               if isLastC then
                                                               begin
                                                                  if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count = 1 then
                                                                     errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePortAdviceIde'], 'unable to find a free port in the storage controller in the VirtualBox VM,'#13#10'please free one and try again.'#13#10'You can do that by starting the VirtualBox Manager, editing the VM''s storage options'#13#10'and deleting one or more drives from the IDE controller.')
                                                                  else
                                                                     errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePort'], 'unable to find a free port in the storage controllers in the VirtualBox VM,'#13#10'please free one and try again.');
                                                                  Abort;
                                                               end
                                                               else
                                                                  Continue;
                                                            end;
                                                         end;
                                                         if (su >= 0) and (not isSUSet) then
                                                         begin
                                                            if Length(ahs) < (2 * p) then
                                                            begin
                                                               i := 0;
                                                               j := 0;
                                                               BreakCycles := False;
                                                               while i < p do
                                                               begin
                                                                  j := 0;
                                                                  while j < p do
                                                                  begin
                                                                     k := 0;
                                                                     while k < Length(ahs) do
                                                                     begin
                                                                        if (ahs[k][0] = i) and (ahs[k][1] = j) then
                                                                           Break;
                                                                        Inc(k);
                                                                     end;
                                                                     if k >= Length(ahs) then
                                                                     begin
                                                                        BreakCycles := True;
                                                                        Break;
                                                                     end;
                                                                     Inc(j);
                                                                  end;
                                                                  if BreakCycles then
                                                                     Break;
                                                                  Inc(i);
                                                               end;
                                                               with ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AddChild('AttachedDevice') do
                                                               begin
                                                                  SetAttribute('type', 'HardDisk');
                                                                  SetAttribute('port', IntToStr(i));
                                                                  SetAttribute('device', IntToStr(j));
                                                                  with AddChild('Image') do
                                                                     SetAttribute('uuid', '{' + suuid + '}');
                                                                  isSUSet := True;
                                                               end;
                                                               SetLength(vbmComm, Length(vbmComm) + 1);
                                                               vbmComm[High(vbmComm)][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port ' + IntToStr(i) + ' --device ' + IntToStr(j) + ' --type hdd --medium "' + sloc + '" --mtype normal';
                                                               vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'AttachDriveOp'], 'attaching the drive');
                                                            end
                                                            else
                                                            begin
                                                               if isLastC then
                                                               begin
                                                                  if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count = 1 then
                                                                     errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePortAdviceIde'], 'unable to find a free port in the storage controller in the VirtualBox VM,'#13#10'please free one and try again.'#13#10'You can do that by starting the VirtualBox Manager, editing the VM''s storage options'#13#10'and deleting one or more drives from the IDE controller.')
                                                                  else
                                                                     errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePort'], 'unable to find a free port in the storage controllers in the VirtualBox VM,'#13#10'please free one and try again.');
                                                                  Abort;
                                                               end
                                                               else
                                                                  Continue;
                                                            end;
                                                         end;
                                                      end
                                                      else if mCName <> 'Floppy' then
                                                      begin
                                                         a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes.IndexOf('PortCount');
                                                         p := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes[a1].NodeValue;

                                                         if (fu >= 0) and (not isFUSet) then
                                                         begin
                                                            i := 0;
                                                            BreakCycles := False;
                                                            while i < p do
                                                            begin
                                                               j := 0;
                                                               while j < Length(ahs) do
                                                               begin
                                                                  if ahs[j][0] = i then
                                                                     Break;
                                                                  Inc(j);
                                                               end;
                                                               if j >= Length(ahs) then
                                                               begin
                                                                  BreakCycles := True;
                                                                  Break;
                                                               end
                                                               else if WarnAboutBoot = 1 then
                                                                  WarnAboutBoot := 2;
                                                               Inc(i);
                                                            end;
                                                            if (not BreakCycles) and (sc <> 0) then
                                                            begin
                                                               if isLastC then
                                                               begin
                                                                  if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count = 1 then
                                                                     errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePortAdvice'], 'unable to find a free port in the storage controller in the VirtualBox VM,'#13#10'please free one and try again.'#13#10'You can do that by starting the VirtualBox Manager, editing the VM''s storage options'#13#10'and increasing the Port Count of the storage controller.')
                                                                  else
                                                                     errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePort'], 'unable to find a free port in the storage controllers in the VirtualBox VM,'#13#10'please free one and try again.');
                                                                  Abort;
                                                               end
                                                               else
                                                                  Continue;
                                                            end
                                                            else
                                                            begin
                                                               if (WarnAboutBoot <> 2) or (sc <> 0) then
                                                               begin
                                                                  with ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AddChild('AttachedDevice') do
                                                                  begin
                                                                     SetAttribute('type', 'HardDisk');
                                                                     SetAttribute('port', IntToStr(i));
                                                                     SetAttribute('device', '0');
                                                                     with AddChild('Image') do
                                                                        SetAttribute('uuid', '{' + fuuid + '}');
                                                                     SetLength(ahs, Length(ahs) + 1);
                                                                     SetLength(ahsUUID, Length(ahsUUID) + 1);
                                                                     ahs[High(ahs)][0] := i;
                                                                     ahs[High(ahs)][1] := 0;
                                                                     ahsUUID[High(ahsUUID)] := string(fuuid);
                                                                     isFUSet := True;
                                                                  end;
                                                                  SetLength(vbmComm, Length(vbmComm) + 1);
                                                                  vbmComm[High(vbmComm)][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port ' + IntToStr(i) + ' --device 0 --type hdd --medium "' + floc + '" --mtype normal';
                                                                  vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'AttachDriveOp'], 'attaching the drive');
                                                               end
                                                               else
                                                               begin
                                                                  WarnAboutBoot := 1;
                                                                  if not BreakCycles then
                                                                  begin
                                                                     a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes.IndexOf('PortCount');
                                                                     ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes[a1].NodeValue :=
                                                                        ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AttributeNodes[a1].NodeValue + 1;
                                                                  end;
                                                                  i := 0;
                                                                  while i <= High(ahs) do
                                                                  begin
                                                                     if ahs[i][0] <> i then
                                                                        Break;
                                                                     Inc(i);
                                                                  end;
                                                                  Dec(i);

                                                                  StopVMAnimation;
                                                                  TrayIcon.BalloonHint := '';
                                                                  case CustomMessageBox(Handle, GetLangTextFormatDef(idxMain, ['Messages',
                                                                     'WarnChangeBootDriveAndOther'], [FirstDriveName], 'In order to boot the VM from the "%s" drive,'#13#10 +
                                                                        'it must be set as the first internal hard disk, but the first position is currently taken by another drive.' +
                                                                     #13#10#13#10'Click on Yes to automatically shift up the other drives in subsequent positions'#13#10'or do it manually and click on Retry'), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbYes, mbRetry, mbCancel], mbYes) of
                                                                     mrNone, mrCancel:
                                                                        Exit;
                                                                     mrRetry:
                                                                        begin
                                                                           TryAgain := True;
                                                                           Exit;
                                                                        end;
                                                                  end;
                                                                  StartVMANimation;
                                                                  j := 0;
                                                                  while j < ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes.Count do
                                                                  begin
                                                                     a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes.IndexOf('port');
                                                                     if (a1 > -1) and (ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes[a1].NodeValue <= ahs[i][0]) then
                                                                        ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes[a1].NodeValue :=
                                                                           ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].ChildNodes[j].AttributeNodes[a1].NodeValue + 1;
                                                                     Inc(j);
                                                                  end;
                                                                  j := Length(vbmComm);
                                                                  SetLength(vbmComm, 2 * (i + 1) + j + 1);
                                                                  while i >= 0 do
                                                                  begin
                                                                     vbmComm[j][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port ' + IntToStr(ahs[i][0]) + ' --device 0 --medium none';
                                                                     vbmComm[j][2] := GetLangTextDef(idxMain, ['Messages', 'DetachDriveOp'], 'detaching the drive');
                                                                     Inc(j);
                                                                     vbmComm[j][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port ' + IntToStr(ahs[i][0] + 1) + ' --device 0';
                                                                     if ahs[i][2] = 1 then
                                                                     begin
                                                                        vbmComm[j][1] := vbmComm[j][1] + ' --type hdd';
                                                                        if ahs[i][4] = 1 then
                                                                           vbmComm[j][1] := vbmComm[j][1] + ' --nonrotational on'
                                                                        else
                                                                           vbmComm[j][1] := vbmComm[j][1] + ' --nonrotational off';
                                                                        if mCName = 'SATA' then
                                                                           if ahs[i][5] = 1 then
                                                                              vbmComm[j][1] := vbmComm[j][1] + ' --hotpluggable on'
                                                                           else
                                                                              vbmComm[j][1] := vbmComm[j][1] + ' --hotpluggable off';
                                                                     end
                                                                     else
                                                                     begin
                                                                        vbmComm[j][1] := vbmComm[j][1] + ' --type dvddrive';
                                                                        if ahs[i][3] = 1 then
                                                                           vbmComm[j][1] := vbmComm[j][1] + ' --passthrough on'
                                                                        else
                                                                           vbmComm[j][1] := vbmComm[j][1] + ' --passthrough off';
                                                                        if mCName = 'SATA' then
                                                                           if ahs[i][5] = 1 then
                                                                              vbmComm[j][1] := vbmComm[j][1] + ' --hotpluggable on'
                                                                           else
                                                                              vbmComm[j][1] := vbmComm[j][1] + ' --hotpluggable off';
                                                                     end;
                                                                     if ahsUUID[i] <> '' then
                                                                        vbmComm[j][1] := vbmComm[j][1] + ' --medium "' + ahsUUId[i] + '"'
                                                                     else
                                                                        vbmComm[j][1] := vbmComm[j][1] + ' --medium emptydrive';
                                                                     Inc(j);
                                                                     Dec(i);
                                                                  end;
                                                                  with ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AddChild('AttachedDevice') do
                                                                  begin
                                                                     SetAttribute('type', 'HardDisk');
                                                                     SetAttribute('port', 0);
                                                                     SetAttribute('device', '0');
                                                                     with AddChild('Image') do
                                                                        SetAttribute('uuid', '{' + fuuid + '}');
                                                                     SetLength(ahs, Length(ahs) + 1);
                                                                     SetLength(ahsUUID, Length(ahsUUID) + 1);
                                                                     ahs[High(ahs)][0] := 0;
                                                                     ahs[High(ahs)][1] := 0;
                                                                     ahsUUID[High(ahsUUID)] := string(fuuid);
                                                                     isFUSet := True;
                                                                  end;
                                                                  vbmComm[High(vbmComm)][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port 0 --device 0 --type hdd --medium "' + floc + '" --mtype normal';
                                                                  vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'AttachDriveOp'], 'attaching the drive');
                                                               end;
                                                            end;
                                                         end;

                                                         if (su >= 0) and (not isSUSet) then
                                                         begin
                                                            i := 0;
                                                            BreakCycles := False;
                                                            while i < p do
                                                            begin
                                                               j := 0;
                                                               while j < Length(ahs) do
                                                               begin
                                                                  if ahs[j][0] = i then
                                                                     Break;
                                                                  Inc(j);
                                                               end;
                                                               if j >= Length(ahs) then
                                                               begin
                                                                  BreakCycles := True;
                                                                  Break;
                                                               end;
                                                               Inc(i);
                                                            end;
                                                            if not BreakCycles then
                                                            begin
                                                               if isLastC then
                                                               begin
                                                                  if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count = 1 then
                                                                     errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePortAdvice'], 'unable to find a free port in the storage controller in the VirtualBox VM,'#13#10'please free one and try again.'#13#10'You can do that by starting the VirtualBox Manager, editing the VM''s storage options'#13#10'and increasing the Port Count of the storage controller.')
                                                                  else
                                                                     errmsg := GetLangTextDef(idxMain, ['Messages', 'FreePort'], 'unable to find a free port in the storage controllers in the VirtualBox VM,'#13#10'please free one and try again.');
                                                                  Abort;
                                                               end
                                                               else
                                                                  Continue;
                                                            end
                                                            else
                                                            begin
                                                               with ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[sc].AddChild('AttachedDevice') do
                                                               begin
                                                                  SetAttribute('type', 'HardDisk');
                                                                  SetAttribute('port', IntToStr(i));
                                                                  SetAttribute('device', '0');
                                                                  with AddChild('Image') do
                                                                     SetAttribute('uuid', '{' + suuid + '}');
                                                                  isSUSet := True;
                                                               end;
                                                               SetLength(vbmComm, Length(vbmComm) + 1);
                                                               vbmComm[High(vbmComm)][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port ' + IntToStr(i) + ' --device 0 --type hdd --medium "' + sloc + '" --mtype normal';
                                                               vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'AttachDriveOp'], 'attaching the drive');
                                                            end;
                                                         end;
                                                      end;
                                                   end;
                                                end;

                                             end;
                                       end
                                       else
                                       begin
                                          errmsg := GetLangTextDef(idxMain, ['Messages', 'NoStorageAdvice'], 'unable to find a storage controller in the VirtualBox VM,'#13#10'please add one and try again.'#13#10'You can do that by starting the VirtualBox Manager, editing the VM''s storage options'#13#10'and adding a storage controller.');
                                          Abort;
                                       end;
                                    if (VBCPUVirtualization <> 0) and ((UpdateVM = 2) or ((UpdateVM = 0) and (not useVBMU))) then
                                    begin
                                       n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('Hardware');
                                       if n3 > -1 then
                                       begin
                                          n4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.IndexOf('CPU');
                                          if n4 = -1 then
                                          begin
                                             ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].AddChild('CPU');
                                             n4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count - 1;
                                          end;
                                          n5 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes.IndexOf('HardwareVirtEx');
                                          if n5 = -1 then
                                          begin
                                             ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].AddChild('HardwareVirtEx');
                                             n5 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes.Count - 1;
                                          end;
                                          if ((VBCPUVirtualization = 1) and (not VBHardwareVirtualization)) or ((VBCPUVirtualization = 3) and (not VBHardwareVirtualization)) then
                                             ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[n5].SetAttribute('enabled', 'true')
                                          else if ((VBCPUVirtualization = 2) and VBHardwareVirtualization) or ((VBCPUVirtualization = 3) and VBHardwareVirtualization) then
                                             ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[n5].SetAttribute('enabled', 'false');
                                       end;
                                    end;
                                 end;
                              end;

                              AllOK := True;
                           except
                              AllOK := False;
                           end;

                           if AllOK then
                              if WarnAboutBoot = 2 then
                                 if AddSecondDrive then
                                 begin
                                    case CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'WarnBootFirstDrive'], [FirstDriveName], 'It seems this VM won''t be able to boot from the first drive (%s)'#13#10'because other drive(s) is/are attached to the storage controller in prior position(s).'#13#10#13#10'My advice is to free a port in the storage controller before the other drive(s).' + #13#10'You can do that by starting the VirtualBox Manager, editing the VM''s storage options'#13#10'and moving the other drive(s) into subsequent port(s) in the storage controller.'#13#10#13#10'Are you sure you want to continue...?')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry, mbIgnore], mbAbort) of
                                       mrAbort, mrNone, mrCancel:
                                          Exit;
                                       mrRetry:
                                          begin
                                             TryAgain := True;
                                             Exit;
                                          end;
                                    end;
                                 end
                                 else
                                 begin
                                    case CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'WarnBootDrive'], [FirstDriveName], 'It seems this VM won''t be able to boot from the drive (%s)'#13#10'because other drive(s) is/are attached to the storage controller in prior position(s).'#13#10#13#10'My advice is to free a port in the storage controller before the other drive(s).' + #13#10'You can do that by starting the VirtualBox Manager, editing the VM''s storage options'#13#10'and moving the other drive(s) into subsequent port(s) in the storage controller.'#13#10#13#10'Are you sure you want to continue...?')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry, mbIgnore], mbAbort) of
                                       mrAbort, mrNone, mrCancel:
                                          Exit;
                                       mrRetry:
                                          begin
                                             TryAgain := True;
                                             Exit;
                                          end;
                                    end;
                                 end;

                           if not AllOK then
                              Active := False
                           else
                           begin
                              if (VBCPUVirtualization <> 0) and (UpdateVM = 1) or ((UpdateVM = 0) and useVBMU) then
                              begin
                                 DoChange := False;
                                 if ((VBCPUVirtualization = 1) and (not VBHardwareVirtualization)) or ((VBCPUVirtualization = 3) and (not VBHardwareVirtualization)) then
                                 begin
                                    DoChange := True;
                                    VBHardwareVirtualization := True;
                                 end
                                 else if ((VBCPUVirtualization = 2) and VBHardwareVirtualization) or ((VBCPUVirtualization = 3) and VBHardwareVirtualization) then
                                 begin
                                    DoChange := True;
                                    VBHardwareVirtualization := False;
                                 end;
                                 if DoChange then
                                 begin
                                    if WaitForVBSVC then
                                    begin
                                       try
                                          GetAllWindowsList('VBoxPowerNotifyClass', VBWinClass);
                                          j := 0;
                                          l := Length(AllWindowsList);
                                          while j < l do
                                          begin
                                             if AllWindowsList[j].WClass = 'VBoxPowerNotifyClass' then
                                                if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                                   if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                                                      Break;
                                             Inc(j);
                                          end;
                                          if j < l then
                                          begin
                                             j := 0;
                                             while j < l do
                                             begin
                                                if AllWindowsList[j].WClass = VBWinClass then
                                                   if IsWindowVisible(AllWindowsList[j].Handle) then
                                                      if GetFileNameFromHandle(AllWindowsList[j].Handle) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                                                         Break;
                                                Inc(j);
                                             end;
                                             StartVMAnimation;
                                             if j >= l then
                                             begin
                                                hVBoxSVC := AllWindowsList[j].Handle;
                                                i := 1;
                                                while i <= (200 + 200 * Integer(VBSVC2x)) do
                                                begin
                                                   Application.ProcessMessages;
                                                   if Application.Terminated then
                                                      Exit;
                                                   isRightWin := True;
                                                   isWin := isWindow(hVBoxSVC);
                                                   if isWin then
                                                   begin
                                                      GetWindowText(hVBoxSVC, tres, 255);
                                                      if tres <> 'VBoxPowerNotifyClass' then
                                                         isRightWin := False
                                                      else
                                                      begin
                                                         GetClassName(hVBoxSVC, tres, 255);
                                                         if tres <> 'VBoxPowerNotifyClass' then
                                                            isRightWin := False;
                                                      end;
                                                   end;
                                                   if (not isWin) or (not isRightWin) then
                                                   begin
                                                      GetAllWindowsList('VBoxPowerNotifyClass');
                                                      j := 0;
                                                      l := Length(AllWindowsList);
                                                      while j < l do
                                                      begin
                                                         if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                                            if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                                                               Break;
                                                         Inc(j);
                                                      end;
                                                      if j < l then
                                                         hVBoxSVC := AllWindowsList[j].Handle
                                                      else
                                                      begin
                                                         Wait(100);
                                                         if Application.Terminated then
                                                            Exit;
                                                         Break;
                                                      end;
                                                   end;
                                                   Inc(i);
                                                end;
                                             end;
                                          end;
                                       except
                                       end;
                                       AlreadyWaitedForVBSVC := True;
                                       if FileExists(svcPath) then
                                       try
                                          GetAllWindowsList('VBoxPowerNotifyClass', VBWinClass);
                                          j := 0;
                                          l := Length(AllWindowsList);
                                          while j < l do
                                          begin
                                             if AllWindowsList[j].WClass = 'VBoxPowerNotifyClass' then
                                                if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                                   if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                                                      Break;
                                             if AllWindowsList[j].WClass = VBWinClass then
                                                if IsWindowVisible(AllWindowsList[j].Handle) then
                                                   if GetFileNameFromHandle(AllWindowsList[j].Handle) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                                                      Break;
                                             Inc(j);
                                          end;
                                          if j >= l then
                                          begin
                                             FillChar(svcStartupInfo, SizeOf(svcStartupInfo), #0);
                                             svcStartupInfo.cb := SizeOf(svcStartupInfo);
                                             svcStartupInfo.dwFlags := STARTF_USESHOWWINDOW;
                                             svcStartupInfo.wShowWindow := SW_HIDE;
                                             StartFolder := ExtractFilePath(ExeVBPath);
                                             if StartFolder <> '' then
                                                PStartFolder := PChar(StartFolder)
                                             else
                                                PStartFolder := nil;
                                             UniqueString(svcPath);
                                             if CreateProcess(nil, PChar(svcPath), nil, nil, False, DETACHED_PROCESS or NORMAL_PRIORITY_CLASS, nil, PStartFolder, svcStartupInfo, svcProcessInfo) then
                                                svcAlreadyStarted := True;
                                          end;
                                       except
                                       end;
                                    end;
                                    SetLength(vbmComm, Length(vbmComm) + 1);
                                    vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'HardwareVirtOp'], 'changing hardware virtualization');
                                    if VBHardwareVirtualization then
                                       vbmComm[High(vbmComm)][1] := 'modifyvm ' + VMID + ' --hwvirtex on'
                                    else
                                       vbmComm[High(vbmComm)][1] := 'modifyvm ' + VMID + ' --hwvirtex off';
                                    DoVBoxManageJob(High(vbmComm));
                                    if not AllOK then
                                    begin
                                       StopVMAnimation;
                                       TrayIcon.BalloonHint := '';
                                       l := Length(errmsg);
                                       i := l;
                                       while i > 0 do
                                       begin
                                          if (errmsg[i] <> #13) and (errmsg[i] <> #10) then
                                             Break;
                                          Dec(i);
                                       end;
                                       Delete(errmsg, i + 1, l - i);
                                       if CustomMessageBox(Handle, errmsg + #13#10#13#10 + GetLangTextDef(idxMain, ['Messages', 'AreYouSureCont'], 'Are you sure you want to continue (not recommended)...?'), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry], mbAbort) <> mrRetry then
                                          Exit
                                       else
                                       begin
                                          TryAgain := True;
                                          Exit;
                                       end;
                                    end;
                                    SetLength(vbmComm, Length(vbmComm) - 1);
                                 end;
                              end;

                              if AllOK and ((xmlVBoxCompare.Tag = 0) or areDifferent(xmlVBox.DocumentElement, xmlVBoxCompare.DocumentElement)) then
                              begin
                                 if (UpdateVM = 2) or ((UpdateVM = 0) and (not useVBMU)) then
                                 begin
                                    try
                                       if FileExists(VMPath + '-prev') then
                                       begin
                                          attr := GetFileAttributes(PChar(VMPath + '-prev'));
                                          if attr <> $FFFFFFFF then
                                          begin
                                             if SetFileAttributes(PChar(VMPath + '-prev'), attr - FILE_ATTRIBUTE_READONLY) then
                                                if DeleteFile(VMPath + '-prev') then
                                                   if RenameFile(VMPath, VMPath + '-prev') then
                                                      SetFileAttributes(PChar(VMPath + '-prev'), attr);
                                          end;
                                       end
                                       else
                                       begin
                                          if RenameFile(VMPath, VMPath + '-prev') then
                                             SetFileAttributes(PChar(VMPath + '-prev'), FILE_ATTRIBUTE_READONLY);
                                       end;
                                    except
                                    end;
                                    hVbox := 0;
                                    try
                                       sVbox := AnsiString(Xml.Text);
                                       try
                                          hVbox := CreateFile(PChar(FileName), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_FLAG_WRITE_THROUGH, 0);
                                       except
                                          hVbox := INVALID_HANDLE_VALUE;
                                       end;
                                       if hVbox <> INVALID_HANDLE_VALUE then
                                       begin
                                          if not WriteFile(hVbox, Pointer(sVbox)^, Length(sVbox), dwBytesReturned, nil) then
                                          begin
                                             LastError := GetLastError;
                                             errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteProtection'], [FileName, SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please remove the write protection.'#13#10#13#10'System message: %s');
                                             AllOK := False;
                                          end
                                          else
                                          begin
                                             if Cardinal(Length(sVbox)) <> dwBytesReturned then
                                             begin
                                                LastError := GetLastError;
                                                errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorSpaceVolume'], [FileName, ExtractFileDrive(FileName), SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please free some space or check the volume ''%s'' for errors.'#13#10#13#10'System message: %s');
                                                AllOK := False;
                                             end
                                             else
                                                AllOK := True;
                                          end;
                                       end
                                       else
                                       begin
                                          LastError := GetLastError;
                                          GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteProtection'], [FileName, SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please remove the write protection.'#13#10#13#10'System message: %s');
                                          AllOK := False;
                                       end;
                                    except
                                       on E: Exception do
                                       begin
                                          AllOK := False;
                                          errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteVolume'], [FileName, ExtractFileDrive(FileName), E.Message], 'error writing in "%s",'#13#10'please remove the write protection or check the volume ''%s'' for errors.'#13#10'System message: %s');
                                       end;
                                    end;
                                    try
                                       if hVbox <> INVALID_HANDLE_VALUE then
                                          CloseHandle(hVbox);
                                    except
                                    end;
                                    Wait(200);
                                    if Application.Terminated then
                                       Exit;
                                    Active := False;
                                 end
                                 else
                                 begin
                                    if Active then
                                       Active := False;
                                    if WaitForVBSVC then
                                    begin
                                       if not AlreadyWaitedForVBSVC then
                                       begin
                                          try
                                             GetAllWindowsList('VBoxPowerNotifyClass', VBWinClass);
                                             j := 0;
                                             l := Length(AllWindowsList);
                                             while j < l do
                                             begin
                                                if AllWindowsList[j].WClass = 'VBoxPowerNotifyClass' then
                                                   if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                                      if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                                                         Break;
                                                Inc(j);
                                             end;
                                             if j < l then
                                             begin
                                                k := 0;
                                                while k < l do
                                                begin
                                                   if AllWindowsList[k].WClass = VBWinClass then
                                                      if IsWindowVisible(AllWindowsList[k].Handle) then
                                                         if GetFileNameFromHandle(AllWindowsList[k].Handle) = LowerCase(ExtractFileName(ExeVBPath)) then
                                                            Break;
                                                   Inc(j);
                                                end;
                                                if k >= l then
                                                begin
                                                   StartVMAnimation;
                                                   hVBoxSVC := AllWindowsList[j].Handle;
                                                   i := 1;
                                                   while i <= (200 + 200 * Integer(VBSVC2x)) do
                                                   begin
                                                      Wait(35);
                                                      if Application.Terminated then
                                                         Exit;
                                                      isRightWin := True;
                                                      isWin := isWindow(hVBoxSVC);
                                                      if isWin then
                                                      begin
                                                         GetWindowText(hVBoxSVC, tres, 255);
                                                         if tres <> 'VBoxPowerNotifyClass' then
                                                            isRightWin := False
                                                         else
                                                         begin
                                                            GetClassName(hVBoxSVC, tres, 255);
                                                            if tres <> 'VBoxPowerNotifyClass' then
                                                               isRightWin := False;
                                                         end;
                                                      end;
                                                      if (not isWin) or (not isRightWin) then
                                                      begin
                                                         GetAllWindowsList('VBoxPowerNotifyClass');
                                                         j := 0;
                                                         l := Length(AllWindowsList);
                                                         while j < l do
                                                         begin
                                                            if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                                               if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                                                                  Break;
                                                            Inc(j);
                                                         end;
                                                         if j < l then
                                                            hVBoxSVC := AllWindowsList[j].Handle
                                                         else
                                                         begin
                                                            Wait(100);
                                                            if Application.Terminated then
                                                               Exit;
                                                            Break;
                                                         end;
                                                      end;
                                                      Inc(i);
                                                   end;
                                                end;
                                             end;
                                          except
                                          end;
                                       end;
                                       if (Length(vbmComm) > 0) and FileExists(svcPath) and (not svcAlreadyStarted) then
                                       try
                                          GetAllWindowsList('VBoxPowerNotifyClass', VBWinClass);
                                          j := 0;
                                          l := Length(AllWindowsList);
                                          while j < l do
                                          begin
                                             if AllWindowsList[j].WClass = 'VBoxPowerNotifyClass' then
                                                if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                                   if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                                                      Break;
                                             if AllWindowsList[j].WClass = VBWinClass then
                                                if IsWindowVisible(AllWindowsList[j].Handle) then
                                                   if GetFileNameFromHandle(AllWindowsList[j].Handle) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                                                      Break;
                                             Inc(j);
                                          end;
                                          if j >= l then
                                          begin
                                             FillChar(svcStartupInfo, SizeOf(svcStartupInfo), #0);
                                             svcStartupInfo.cb := SizeOf(svcStartupInfo);
                                             svcStartupInfo.dwFlags := STARTF_USESHOWWINDOW;
                                             svcStartupInfo.wShowWindow := SW_HIDE;
                                             StartFolder := ExtractFilePath(ExeVBPath);
                                             if StartFolder <> '' then
                                                PStartFolder := PChar(StartFolder)
                                             else
                                                PStartFolder := nil;
                                             UniqueString(svcPath);
                                             CreateProcess(nil, PChar(svcPath), nil, nil, False, DETACHED_PROCESS or NORMAL_PRIORITY_CLASS, nil, PStartFolder, svcStartupInfo, svcProcessInfo);
                                          end;
                                       except
                                       end;
                                    end;
                                    i := 0;
                                    StartVMAnimation;
                                    while i <= High(vbmComm) do
                                    begin
                                       if not DoVBoxManageJob(i) then
                                          Break;
                                       Inc(i);
                                    end;

                                 end;
                              end;
                           end;
                        end;
                     end;
                     if xmlVBoxCompare.Tag = 1 then
                        xmlVBoxCompare.Active := False;
                  end;
               end;

               if not AllOK then
               begin
                  StopVMAnimation;
                  TrayIcon.BalloonHint := '';
                  l := Length(errmsg);
                  i := l;
                  while i > 0 do
                  begin
                     if (errmsg[i] <> #13) and (errmsg[i] <> #10) then
                        Break;
                     Dec(i);
                  end;
                  Delete(errmsg, i + 1, l - i);
                  if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CantAddDrives'], [errmsg], 'Could not automatically add the drive(s) to the VirtualBox VM.'#13#10#13#10'Possible reason: %s'#13#10#13#10'Are you sure you want to continue (not recommended)...?')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbAbort, mbRetry], mbAbort) <> mrRetry then
                     Exit
                  else
                  begin
                     TryAgain := True;
                     Exit;
                  end;
               end;
            end;

            juststart:

            if RunAs = 3 then
               sf := ' --fullscreen'
            else
               sf := '';
            case ModeLoadVM of
               1:
                  ComLine := ExeVBPath + ' --startvm "' + VMPath + '"' + sf;
               2:
                  ComLine := ExeVBPath + ' ' + ExeParams + sf;
               else
                  ComLine := ExeVBPath + ' --startvm "' + VMID + '"' + sf;
            end;
         end;
         FillChar(eStartupInfo, SizeOf(eStartupInfo), #0);
         eStartupInfo.dwFlags := STARTF_USESHOWWINDOW;
         eStartupInfo.cb := SizeOf(eStartupInfo);
         eStartupInfo.wShowWindow := SW_SHOWNORMAL;
         case RunAs of
            1:
               eStartupInfo.wShowWindow := SW_MINIMIZE;
            2:
               if PType = 0 then
                  eStartupInfo.wShowWindow := SW_MAXIMIZE;
            3:
               if PType = 0 then
                  eStartupInfo.wShowWindow := SW_SHOWNORMAL;
         end;
         case CPUPriority of
            0:
               cp := $000004000;
            2:
               cp := $000008000;
            3:
               cp := $000000080;
            else
               cp := $000000020;
         end;
         if StartFolder <> '' then
            PStartFolder := PChar(StartFolder)
         else
            PStartFolder := nil;
         if Ptype <> 1 then
         begin
            SetLength(AlreadyLoaded, 0);
            GetAllWindowsList(VBWinClass);
            l := Length(AllWindowsList);
            j := 0;
            while j < l do
            begin
               if IsWindowVisible(AllWindowsList[j].Handle) then
                  if (pos(VMName + ' [', AllWindowsList[j].WCaption) = 1) and (Pos(string('] - Oracle VM VirtualBox'), AllWindowsList[j].WCaption) > 1) then
                     if GetFileNameFromHandle(AllWindowsList[j].Handle) = LowerCase(ExtractFileName(ExeVBPath)) then
                     begin
                        SetLength(AlreadyLoaded, Length(AlreadyLoaded) + 1);
                        AlreadyLoaded[High(AlreadyLoaded)] := AllWindowsList[j].Handle;
                     end;
               Inc(j);
            end;
            if FPCThread <> nil then
            begin
               FPCThread.Terminate;
               FPCThread.Free;
               FPCThread := nil;
            end;
            an := '';
            //ts[2] := Now - ts[2];
            //ts[3] := Now;
            ResetLastError;
            UniqueString(ComLIne);
            try
               Result := CreateProcess(nil, PChar(ComLine), nil, nil, False, CREATE_NEW_CONSOLE or cp, nil, PStartFolder, eStartupInfo, eProcessInfo);
            except
               on E: Exception do
               begin
                  Result := False;
                  LastExceptionStr := E.Message;
               end;
            end;
            if Result then
            begin
               PrestartVBFilesAgain := True;
               while True do
               begin
                  Application.ProcessMessages;
                  if Application.Terminated then
                     Exit;
                  if WaitForSingleObject(eProcessInfo.hProcess, 20) <> WAIT_TIMEOUT then
                     Break;
                  GetAllWindowsList(VBWinClass);
                  l := Length(AllWindowsList);
                  j := 0;
                  while j < l do
                  begin
                     if IsWindowVisible(AllWindowsList[j].Handle) then
                        if (pos(VMName + ' [', AllWindowsList[j].WCaption) = 1) and (Pos(string('] - Oracle VM VirtualBox'), AllWindowsList[j].WCaption) > 1) then
                           if GetFileNameFromHandle(AllWindowsList[j].Handle) = LowerCase(ExtractFileName(ExeVBPath)) then
                           begin
                              k := 0;
                              while k < Length(AlreadyLoaded) do
                              begin
                                 if AlreadyLoaded[k] = AllWindowsList[j].Handle then
                                    Break;
                                 Inc(k);
                              end;
                              if k < Length(AlreadyLoaded) then
                                 Continue;
                              if IsIconic(frmMain.Handle) then
                              begin
                                 Application.Restore;
                                 dt := GetTickCount;
                                 while isIconic(Application.Handle) do
                                 begin
                                    mEvent.WaitFor(1);
                                    Application.ProcessMessages;
                                    if (GetTickCount - dt) > 3000 then
                                       Break;
                                 end;
                              end;
                              //ts[3] := Now - ts[3];
                              VMisOff := False;
                              if TrayIcon.Visible then
                                 TrayIcon.Hint := VMName + ' [' + GetLangTextDef(idxMain, ['Messages', 'VMStateRunning'], 'Running') + '] - Virtual Machine USB Boot';
                              StopVMAnimation;
                              TrayIcon.BalloonHint := '';
                              if frmMain.Visible and (not IsIconic(Application.Handle)) then
                                 frmMain.Hide
                              else
                                 AlreadyHidden := True;
                              while WaitForSingleObject(eProcessInfo.hProcess, 100) = WAIT_TIMEOUT do
                              begin
                                 mEvent.WaitFor(1);
                                 Application.ProcessMessages;
                                 if Application.Terminated then
                                    Exit;
                              end;
                              Break;
                           end;
                     Inc(j);
                  end;
                  if j < l then
                     Break;
               end;
               VBVMWasClosed := Now;
               try
                  if not GetExitCodeProcess(eProcessInfo.hProcess, ExitCode) then
                     ExitCode := 1;
               except
                  ExitCode := 1;
               end;
               try
                  CloseHandle(eProcessInfo.hProcess);
                  CloseHandle(eProcessInfo.hThread);
               except
               end;
               Wait(200);
               if Application.Terminated then
                  Exit;
            end
            else
            begin
               LastError := GetLastError;
               if frmMain.Showing or TrayIcon.Visible then
               begin
                  StopVMAnimation;
                  TrayIcon.BalloonHint := '';
                  Application.ProcessMessages;
               end;
               Application.ProcessMessages;
               if LastError > 0 then
                  an := SysErrorMessage(LastError)
               else if LastExceptionStr <> '' then
                  an := LastExceptionStr
               else
                  an := 'Unknown error';
               CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'VBUnableLaunch'], [an], 'Unable to launch VirtualBox.exe !'#13#10#13#10'System message: %s')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
            end;

            VMisOff := True;
            if TrayIcon.Visible then
               TrayIcon.Hint := 'Virtual Machine USB Boot';
            if frmMain.Showing or TrayIcon.Visible then
            begin
               StopVMAnimation;
               TrayIcon.BalloonHint := '';
            end;
            if (not frmMain.Showing) and (not AlreadyHidden) then
            begin
               frmMain.Show;
               if GetForegroundWindow <> frmMain.Handle then
               begin
                  ZeroMemory(@Input, SizeOf(Input));
                  SendInput(1, Input, SizeOf(Input));
                  SetForegroundWindow(frmMain.Handle);
               end;
               frmMain.Refresh;
            end;
            Application.ProcessMessages;
            if Application.Terminated then
               Exit;
            //ts[4] := Now;
            // removes the drive(s)
            if RemoveDrive then
            begin
               useVBMU := False;
               if UpdateVM = 0 then
               begin
                  if not WaitForVBSVC then
                     useVBMU := True
                  else
                  begin
                     GetAllWindowsList('VBoxPowerNotifyClass', VBWinClass);
                     l := Length(AllWindowsList);
                     i := 0;
                     while i < l do
                     begin
                        if AllWindowsList[i].WClass = VBWinClass then
                           if IsWindowVisible(AllWindowsList[i].Handle) then
                              if GetFileNameFromHandle(AllWindowsList[i].Handle) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                              begin
                                 useVBMU := True;
                                 Break;
                              end;
                        Inc(i);
                     end;
                     if (not useVBMU) and ((Now - VBVMWasClosed) < (5 / 86400)) then
                     begin
                        i := 0;
                        while i < l do
                        begin
                           if AllWindowsList[i].WClass = 'VBoxPowerNotifyClass' then
                              if AllWindowsList[i].WCaption = 'VBoxPowerNotifyClass' then
                                 if GetFileNameFromHandle(AllWindowsList[i].Handle) = 'vboxsvc.exe' then
                                 begin
                                    useVBMU := True;
                                    Break;
                                 end;
                           Inc(i);
                        end;
                     end;
                  end;
               end;
               AllOK := True;
               if (UpdateVM = 2) or ((UpdateVM = 0) and (not useVBMU)) then
               begin
                  an := GetLangTextDef(idxMain, ['Messages', 'VBManDetected'], 'VirtualBox Manager was detected.'#13#10'It is highly recommended not to be used in the same time !'#13#10#13#10'Should I close it...? (it will take a few sec to fully close)');
                  srchvbm2:
                  GetAllWindowsList('VBoxPowerNotifyClass', VBWinClass);
                  l := Length(AllWindowsList);
                  for i := 0 to l - 1 do
                     if AllWindowsList[i].WClass = VBWinClass then
                        if Pos('Oracle VM VirtualBox ', AllWindowsList[i].WCaption) = 1 then
                           if GetFileNameFromHandle(AllWindowsList[i].Handle) = WideLowerCase(ExtractFileName(ExeVBPath)) then
                              if IsWindowVisible(AllWindowsList[i].Handle) then
                              begin
                                 if IsIconic(AllWindowsList[i].Handle) then
                                 begin
                                    SendMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                                    dt := GetTickCount;
                                    while isIconic(AllWindowsList[i].Handle) do
                                    begin
                                       mEvent.WaitFor(1);
                                       Application.ProcessMessages;
                                       if (GetTickCount - dt) > 3000 then
                                          Break;
                                    end;
                                 end;
                                 SetWindowPos(AllWindowsList[i].Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                                 SetWindowPos(AllWindowsList[i].Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                                 if CustomMessageBox(Handle, an, (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbOk, mbCancel], mbOk) <> mrOk then
                                    Exit
                                 else
                                 begin
                                    if IsWindowVisible(AllWindowsList[i].Handle) then
                                       SendMessage(AllWindowsList[i].Handle, WM_CLOSE, 0, 0);
                                    StartVMAnimation;
                                    j := 1;
                                    while j <= 20 do
                                    begin
                                       Wait(100);
                                       if Application.Terminated then
                                          Exit;
                                       isRightWin := True;
                                       isWin := isWindow(AllWindowsList[i].Handle);
                                       if isWin then
                                       begin
                                          GetWindowText(AllWindowsList[i].Handle, tres, 255);
                                          if Pos('Oracle VM VirtualBox ', tres) <> 1 then
                                             isRightWin := False
                                          else
                                          begin
                                             GetClassName(AllWindowsList[i].Handle, tres, 255);
                                             if tres <> VBWinClass then
                                                isRightWin := False;
                                          end;
                                       end;
                                       if (not isWin) or (not isRightWin) then
                                          Break;
                                       Inc(j);
                                    end;
                                    if j > 20 then
                                    begin
                                       if IsIconic(AllWindowsList[i].Handle) then
                                       begin
                                          SendMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                                          dt := GetTickCount;
                                          while isIconic(AllWindowsList[i].Handle) do
                                          begin
                                             mEvent.WaitFor(1);
                                             Application.ProcessMessages;
                                             if (GetTickCount - dt) > 3000 then
                                                Break;
                                          end;
                                       end;
                                       SetWindowPos(AllWindowsList[i].Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                                       SetWindowPos(AllWindowsList[i].Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
                                       if CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'CouldNotCloseVBMan'], [ReplaceStr(GetLangTextDef(idxMessages, ['Buttons', 'OK'], 'OK'), '&', '')], 'Could not close VirtualBox Manager automatically !'#13#10#13#10'Please close it manually and click on %s...  (it will take a few sec to fully close)')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtWarning, [mbOk, mbCancel], mbOk) <> mrOk then
                                          Exit
                                       else
                                       begin
                                          j := 1;
                                          while j <= 20 do
                                          begin
                                             Wait(100);
                                             if Application.Terminated then
                                                Exit;
                                             isRightWin := True;
                                             isWin := isWindow(AllWindowsList[i].Handle);
                                             if isWin then
                                             begin
                                                GetWindowText(AllWindowsList[i].Handle, tres, 255);
                                                if Pos('Oracle VM VirtualBox ', tres) <> 1 then
                                                   isRightWin := False
                                                else
                                                begin
                                                   GetClassName(AllWindowsList[i].Handle, tres, 255);
                                                   if tres <> VBWinClass then
                                                      isRightWin := False;
                                                end;
                                             end;
                                             if (not isWin) or (not isRightWin) then
                                                Break;
                                             Inc(j);
                                          end;
                                          if j > 20 then
                                          begin
                                             CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'ErrorVBManNotClosed'], 'Error: VirtualBox Manager not closed !')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
                                             Exit;
                                          end;
                                       end;
                                    end;
                                 end;
                                 an := GetLangTextDef(idxMain, ['Messages', 'AnotherVBManSession'], 'Another VirtualBox Manager was detected.'#13#10'It is highly recommended not to be used in the same time !'#13#10#13#10'Should I close it...? (it will take a few sec to fully close)') + ' ';
                                 goto srchvbm2;
                              end;
                  if WaitForVBSVC then
                  try
                     GetAllWindowsList('VBoxPowerNotifyClass', VBWinClass);
                     j := 0;
                     l := Length(AllWindowsList);
                     while j < l do
                     begin
                        if AllWindowsList[j].WClass = 'VBoxPowerNotifyClass' then
                           if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                              if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                                 Break;
                        Inc(j);
                     end;
                     if j < l then
                     begin
                        hVBoxSVC := AllWindowsList[j].Handle;
                        StartVMAnimation;
                        i := 1;
                        while i <= (200 + 200 * Integer(VBSVC2x)) do
                        begin
                           Wait(35);
                           if Application.Terminated then
                              Exit;
                           isRightWin := True;
                           isWin := isWindow(hVBoxSVC);
                           if isWin then
                           begin
                              GetWindowText(hVBoxSVC, tres, 255);
                              if tres <> 'VBoxPowerNotifyClass' then
                                 isRightWin := False
                              else
                              begin
                                 GetClassName(hVBoxSVC, tres, 255);
                                 if tres <> 'VBoxPowerNotifyClass' then
                                    isRightWin := False;
                              end;
                           end;
                           if (not isWin) or (not isRightWin) then
                           begin
                              GetAllWindowsList('VBoxPowerNotifyClass', VBWinClass);
                              j := 0;
                              l := Length(AllWindowsList);
                              while j < l do
                              begin
                                 if AllWindowsList[j].WClass = 'VBoxPowerNotifyClass' then
                                    if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                       if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                                          Break;
                                 Inc(j);
                              end;
                              if j < l then
                                 hVBoxSVC := AllWindowsList[j].Handle
                              else
                              begin
                                 Wait(100);
                                 if Application.Terminated then
                                    Exit;
                                 Break;
                              end;
                           end;
                           Inc(i);
                        end;
                        if i > (200 + 200 * Integer(VBSVC2x)) then
                        begin
                           if CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'OutOfTimeVBSVC'], 'Out of time waiting for "VBoxSVC.exe" (a VirtualBox component) to close...!'#13#10#13#10'Should I forcibly close it...?')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtWarning, [mbOk, mbCancel], mbOk) <> mrOk then
                              Exit
                           else
                           begin
                              j := 0;
                              GetAllWindowsList('VBoxPowerNotifyClass', VBWinClass);
                              l := Length(AllWindowsList);
                              while j < l do
                              begin
                                 if AllWindowsList[j].WClass = 'VBoxPowerNotifyClass' then
                                    if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                       if GetFileNameAndThreadFromHandle(AllWindowsList[j].Handle, ProcessID) = 'vboxsvc.exe' then
                                       try
                                          TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), ProcessID), 0);
                                       except
                                       end;
                                 Inc(j);
                              end;
                              StartVMAnimation;
                              for i := 1 to 10 do
                              begin
                                 Wait(200);
                                 if Application.Terminated then
                                    Exit;
                                 j := 0;
                                 GetAllWindowsList('VBoxPowerNotifyClass', VBWinClass);
                                 l := Length(AllWindowsList);
                                 while j < l do
                                 begin
                                    if AllWindowsList[j].WClass = 'VBoxPowerNotifyClass' then
                                       if AllWindowsList[j].WCaption = 'VBoxPowerNotifyClass' then
                                          if GetFileNameFromHandle(AllWindowsList[j].Handle) = 'vboxsvc.exe' then
                                             Break;
                                    Inc(j);
                                 end;
                                 if j >= l then
                                    Break;
                              end;
                              if i <= 10 then
                              begin
                                 CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'VBSVCStillOpened'], '"VBoxSVC.exe" is still opened !'#13#10#13#10'Exiting...')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
                                 Exit;
                              end;
                           end;
                        end;
                     end;

                  except
                  end;
               end;

               try
                  xmlVBox.Active := True;
               except
                  on E: Exception do
                  begin
                     AllOK := False;
                     errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'PleaseAllowAccess'], [VMPath, E.Message], 'error accessing "%s",'#13#10'please allow access.'#13#10'System message: %s');
                     xmlVBox.Active := False;
                  end;
               end;

               if xmlVBox.Active then
               begin
                  SetLength(vmdkids, 0);
                  SetLength(exvmdks, 0);
                  SetLength(vbmComm, 0);

                  with xmlVBox do
                  begin
                     if Tag = 1 then
                     try
                        n1 := ChildNodes.IndexOf('VirtualBox');
                        if n1 = -1 then
                        begin
                           errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'SectionNotFound'], ['VirtualBox'], '"%s" section not found in the vbox file !'#13#10#13#10'It seems Oracle changed the file format or you have a corrupted file.');
                           Abort;
                        end
                        else
                        begin
                           n2 := ChildNodes[n1].ChildNodes.IndexOf('Machine');
                           if n2 = -1 then
                           begin
                              errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'SectionNotFound'], ['Machine'], '"%s" section not found in the vbox file !'#13#10#13#10'It seems Oracle changed the file format or you have a corrupted file.');
                              Abort;
                           end
                           else
                           begin
                              a1 := ChildNodes[n1].ChildNodes[n2].AttributeNodes.IndexOf('stateFile');
                              if a1 > -1 then
                              begin
                                 CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'SavedStateClose'], 'It appears this VM is in a saved state so it will not be modified, only closed...'#13#10#13#10'Just so you know, it is not a good idea to save the state of a VM with a real drive,'#13#10'because it will increase the risk of corrupting the data from that drive...')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbOk], mbOk);
                                 jc := True;
                                 Abort;
                              end;
                              n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('MediaRegistry');
                              if n3 = -1 then
                              begin
                                 errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'SectionNotFound'], ['MediaRegistry'], '"%s" section not found in the vbox file !'#13#10#13#10'It seems Oracle changed the file format or you have a corrupted file.');
                                 Abort;
                              end
                              else
                              begin
                                 n4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.IndexOf('HardDisks');
                                 if n4 > -1 then
                                 begin
                                    for i := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes.Count - 1 downto 0 do
                                    begin
                                       a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes.IndexOf('format');
                                       if a1 = -1 then
                                          Continue;
                                       if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes[a1].Text = 'VMDK' then
                                       begin
                                          a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes.IndexOf('location');
                                          if a2 > -1 then
                                          begin
                                             wp := LowerCase(ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes[a2].Text);
                                             l := Length(wp);
                                             if l <> 17 then
                                                Continue;
                                             if pos(string('vmubdrive'), wp) <> 1 then
                                                Continue;
                                             if StrToIntDef('$' + Copy(wp, 10, 3), -1) = -1 then
                                                Continue;
                                             if pos(string('.vmdk'), wp) <> 13 then
                                                Continue;
                                             a3 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes.IndexOf('uuid');
                                             if a3 > -1 then
                                             begin
                                                if ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].ChildNodes.Count > 0 then
                                                begin
                                                   errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'DividedSnapshots'], [ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes[a2].Text, ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].ChildNodes.Count], 'the content of "%s" is divided into %d snapshot(s).'#13#10'It is not a good idea using snapshots with real drives. But if you really want to at least do this:' + #13#10'If you created a snapshot or linked clone this VM you should of manually detached any'#13#10'VMUBDrive***.vmdk drive from the storage controller(s) before the snapshoting/cloning operation.');
                                                   Abort;
                                                end;
                                                wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes[a3].Text;
                                                SetLength(vmdkids, Length(vmdkids) + 1);
                                                vmdkids[High(vmdkids)][1] := Copy(wst, 2, Length(wst) - 2);
                                                vmdkids[High(vmdkids)][2] := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes[a2].Text;
                                                ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes.Delete(i);
                                                SetLength(vbmComm, Length(vbmComm) + 1);
                                                vbmComm[High(vbmComm)][1] := 'closemedium disk ' + Copy(wst, 2, Length(wst) - 2);
                                                vbmComm[High(vbmComm)][2] := GetLangTextDef(idxMain, ['Messages', 'RemoveDriveOp'], 'removing the drive');
                                             end;
                                          end;
                                       end;
                                    end;
                                    for i := 0 to ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes.Count - 1 do
                                    begin
                                       a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes.IndexOf('uuid');
                                       if a1 > -1 then
                                       begin
                                          wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[n4].ChildNodes[i].AttributeNodes[a1].Text;
                                          SetLength(exvmdks, Length(exvmdks) + 1);
                                          exvmdks[High(exvmdks)] := AnsiString(Copy(wst, 2, Length(wst) - 2));
                                       end;
                                    end;
                                 end;
                              end;
                              if Length(vmdkids) > 0 then
                              begin
                                 n3 := ChildNodes[n1].ChildNodes[n2].ChildNodes.IndexOf('StorageControllers');
                                 if n3 > -1 then
                                    for i := 0 to ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes.Count - 1 do
                                       for j := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes.Count - 1 downto 0 do
                                       begin
                                          a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes.IndexOf('name');
                                          if a1 > -1 then
                                             mCName := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].AttributeNodes[a1].Text
                                          else
                                             mCName := 'IDE';
                                          a2 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].AttributeNodes.IndexOf('port');
                                          if a2 > -1 then
                                             mPort := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].AttributeNodes[a2].Text
                                          else
                                             mPort := '0';
                                          a3 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].AttributeNodes.IndexOf('device');
                                          if a3 > -1 then
                                             mDevice := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].AttributeNodes[a3].Text
                                          else
                                             mDevice := '0';
                                          n4 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].ChildNodes.IndexOf('Image');
                                          if n4 > -1 then
                                          begin
                                             a1 := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].ChildNodes[n4].AttributeNodes.IndexOf('uuid');
                                             if a1 > -1 then
                                             begin
                                                wst := ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes[j].ChildNodes[n4].AttributeNodes[a1].Text;
                                                wst := Copy(wst, 2, Length(wst) - 2);
                                                k := 0;
                                                while k < Length(vmdkids) do
                                                begin
                                                   if vmdkids[k][1] = wst then
                                                   begin
                                                      ChildNodes[n1].ChildNodes[n2].ChildNodes[n3].ChildNodes[i].ChildNodes.Delete(j);
                                                      SetLength(vbmComm, Length(vbmComm) + 1);
                                                      for p := High(vbmComm) downto 1 do
                                                         vbmComm[p] := vbmComm[p - 1];

                                                      if (a1 > -1) and (a2 > -1) and (a3 > -1) then
                                                      begin
                                                         vbmComm[0][1] := 'storageattach ' + VMID + ' --storagectl ' + mCName + ' --port ' + mPort + ' --device ' + mDevice + ' --medium none';
                                                         vbmComm[0][2] := GetLangTextDef(idxMain, ['Messages', 'DetachDriveOp'], 'detaching the drive');
                                                      end;
                                                      Break;
                                                   end;
                                                   Inc(k);
                                                end;
                                             end;
                                          end;
                                       end;

                              end;
                           end;
                        end;
                        AllOK := True;
                     except
                        if errmsg = GetLangTextDef(idxMain, ['Messages', 'UnknownError'], 'unknown error, please report it to the author'#13#10'with a complete description of what you''re doing.') then
                           errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'BrokenXML'], [VMPath], 'error accessing xml structure from "%s",'#13#10'please repair the file or replace it with a backup copy.');
                        AllOK := False;
                     end;

                     if jc then
                        goto justclose;

                     if (UpdateVM = 2) or ((UpdateVM = 0) and (not useVBMU)) then
                     begin
                        hVbox := 0;
                        if AllOK then
                        try
                           sVbox := AnsiString(Xml.Text);
                           hVbox := CreateFile(PChar(FileName), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_FLAG_WRITE_THROUGH, 0);
                           if hVbox <> INVALID_HANDLE_VALUE then
                           begin
                              if not WriteFile(hVbox, Pointer(sVbox)^, Length(sVbox), dwBytesReturned, nil) then
                              begin
                                 LastError := GetLastError;
                                 errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteProtection'], [FileName, SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please remove the write protection.'#13#10#13#10'System message: %s');
                                 AllOK := False;
                              end
                              else
                              begin
                                 try
                                    FlushFileBuffers(hVbox);
                                 except
                                 end;
                                 if Cardinal(Length(sVbox)) <> dwBytesReturned then
                                 begin
                                    LastError := GetLastError;
                                    errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorSpaceVolume'], [FileName, ExtractFileDrive(FileName), SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please free some space or check the volume ''%s'' for errors.'#13#10#13#10'System message: %s');
                                    AllOK := False;
                                 end
                                 else
                                    AllOK := True;
                              end;
                           end
                           else
                           begin
                              LastError := GetLastError;
                              errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteProtection'], [FileName, SysErrorMessage(LastError)], 'error writing in "%s",'#13#10'please remove the write protection.'#13#10#13#10'System message: %s');
                              AllOK := False;
                           end;
                        except
                           on E: Exception do
                           begin
                              AllOK := False;
                              errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorWriteVolume'], [FileName, ExtractFileDrive(FileName), E.Message], 'error writing in "%s",'#13#10'please remove the write protection or check the volume ''%s'' for errors.'#13#10'System message: %s');
                           end;
                        end;
                        try
                           if hVbox <> INVALID_HANDLE_VALUE then
                              CloseHandle(hVbox);
                        except
                        end;
                        Active := False;
                     end
                     else
                     begin
                        Active := False;
                        i := 0;
                        StartVMAnimation;
                        while i <= High(vbmComm) do
                        begin
                           if not DoVboxManageJob(i, 5000) then
                              Break;
                           Inc(i);
                        end;
                     end;

                     if AllOK then
                        for i := 0 to High(vmdkids) do
                        begin
                           if (pos(string('/'), vmdkids[i][2]) = 0) and (pos(string('\'), vmdkids[i][2]) = 0) then
                              vmdkids[i][2] := ExtractFilePath(VMPath) + vmdkids[i][2];
                           if not DeleteFile(PChar(vmdkids[i][2])) then
                           begin
                              errmsg := GetLangTextFormatDef(idxMain, ['Messages', 'CantDeleteFile'], [ExtractFilePath(vmdkids[i][2]), SysErrorMessage(LastError)], 'Could not delete the file "%s" !'#13#10'System message: %s');
                              AllOK := False;
                           end;
                        end;
                  end;

               end;
               StopVMAnimation;
               TrayIcon.BalloonHint := '';
               if not AllOK then
               begin
                  l := Length(errmsg);
                  i := l;
                  while i > 0 do
                  begin
                     if (errmsg[i] <> #13) and (errmsg[i] <> #10) then
                        Break;
                     Dec(i);
                  end;
                  Delete(errmsg, i + 1, l - i);
                  CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'CantRemoveDrives'], 'Could not automatically remove the drive(s) from the VirtualBox VM.'#13#10#13#10'Possible reason: ') + errmsg), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbOk], mbOk);
               end;
            end;
         end
         else
         begin
            //qemu
            if RunAs = 3 then
               ComLine := ComLine + ' -full-screen';
            strStdErr := '';
            SecAttr.nlength := SizeOf(SecAttr);
            SecAttr.binherithandle := True;
            SecAttr.lpsecuritydescriptor := nil;
            CreatePipe(StdErrRead, StdErrWrite, @SecAttr, 0);
            eStartupInfo.hStdError := StdErrWrite;
            eStartupInfo.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;

            ResetLastError;
            UniqueString(ComLine);
            try
               if HideConsoleWindow then
                  Result := CreateProcess(nil, PChar(ComLine), nil, nil, True, CREATE_NO_WINDOW or cp, nil, PStartFolder, eStartupInfo, eProcessInfo)
               else
                  Result := CreateProcess(nil, PChar(ComLine), nil, nil, True, cp, nil, PStartFolder, eStartupInfo, eProcessInfo);
               LastError := GetLastError;
            except
               on E: Exception do
               begin
                  Result := False;
                  LastExceptionStr := E.Message;
               end;
            end;
            if TrayIcon.BalloonHint <> '' then
            begin
               TrayIcon.BalloonHint := '';
               Application.ProcessMessages;
            end;

            if Result then
            begin
               AllProcAffinityMask := CombinedProcessorMask(NumberOfProcessors);
               while WaitForInputIdle(eProcessInfo.hProcess, 20) = WAIT_TIMEOUT do
               begin
                  Application.ProcessMessages;
                  if Application.Terminated then
                     Exit;
               end;
               while True do
               begin
                  Application.ProcessMessages;
                  if Application.Terminated then
                     Exit;
                  if WaitForSingleObject(eProcessInfo.hProcess, 20) <> WAIT_TIMEOUT then
                     Break;
                  GetWndThrList(eProcessInfo.dwThreadId);
                  l := Length(AllWindowsList);
                  j := 0;
                  while j < l do
                  begin
                     if (AllWindowsList[j].WClass = 'gdkWindowToplevel') or (AllWindowsList[j].WClass = 'SDL_app') then
                        if IsWindowVisible(AllWindowsList[j].Handle) or IsIconic(AllWindowsList[j].Handle) then
                           if ((VMName <> '') and (Pos('QEMU (' + VMName + ')', AllWindowsList[j].WCaption) = 1)) or ((VMName = '') and (Pos('QEMU', AllWindowsList[j].WCaption) = 1)) then
                              if GetFileNameFromHandle(AllWindowsList[j].Handle) = WideLowerCase(ExtractFileName(ExeQPath)) then
                              begin
                                 WindowState := RunAs;
                                 if IsIconic(AllWindowsList[j].Handle) then
                                    WindowState := 1
                                 else
                                 begin
                                    WindowPlacement.Length := SizeOf(WindowPlacement);
                                    GetWindowPlacement(AllWindowsList[j].Handle, @WindowPlacement);
                                    case WindowPlacement.showCmd of
                                       SW_SHOWNORMAL: WindowState := 0;
                                       SW_SHOWMAXIMIZED: WindowState := 2;
                                    end;
                                 end;
                                 if IsIconic(frmMain.Handle) then
                                 begin
                                    Application.Restore;
                                    dt := GetTickCount;
                                    while isIconic(Application.Handle) do
                                    begin
                                       mEvent.WaitFor(1);
                                       Application.ProcessMessages;
                                       if (GetTickCount - dt) > 3000 then
                                          Break;
                                    end;
                                 end;
                                 VMisOff := False;
                                 if TrayIcon.Visible then
                                    TrayIcon.Hint := VMName + ' [' + GetLangTextDef(idxMain, ['Messages', 'VMStateRunning'], 'Running') + '] - Virtual Machine USB Boot';
                                 SetProcessAffinityMask(eProcessInfo.hProcess, AllProcAffinityMask);
                                 StopVMAnimation;
                                 if frmMain.Visible and (not IsIconic(Application.Handle)) then
                                    frmMain.Hide
                                 else
                                    AlreadyHidden := True;
                                 if RunAs <> WindowState then
                                    case WindowState of
                                       1:
                                          begin
                                             SendMessage(AllWindowsList[j].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                                             if RunAs = 2 then
                                                SendMessage(AllWindowsList[j].Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
                                          end;
                                       2: if RunAs = 0 then
                                             SendMessage(AllWindowsList[j].Handle, WM_SYSCOMMAND, SC_RESTORE, 0)
                                          else if RunAs = 1 then
                                             SendMessage(AllWindowsList[j].Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
                                       3:
                                       else
                                          if RunAs = 1 then
                                             SendMessage(AllWindowsList[j].Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0)
                                          else if RunAs = 2 then
                                          begin
                                             mEvent.WaitFor(500);
                                             PostMessage(AllWindowsList[j].Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
                                          end;
                                    end;
                                 while WaitForSingleObject(eProcessInfo.hProcess, 100) = WAIT_TIMEOUT do
                                 begin
                                    Application.ProcessMessages;
                                    if Application.Terminated then
                                       Exit;
                                 end;
                                 Break;
                              end;
                     Inc(j);
                  end;
                  if j < l then
                     Break;
               end;
               VMisOff := True;
               if TrayIcon.Visible then
                  TrayIcon.Hint := 'Virtual Machine USB Boot';
               try
                  PeekNamedPipe(StdErrRead, @Buffer, 1024, @BytesRead, @BytesAvail, nil);
                  if BytesRead <> 0 then
                  begin
                     Buffer[BytesRead] := #0;
                     strStdErr := AnsiString(Buffer);
                  end;
               except
               end;
               try
                  if not GetExitCodeProcess(eProcessInfo.hProcess, ExitCode) then
                     ExitCode := 1;
               except
                  ExitCode := 1;
               end;
               try
                  CloseHandle(eProcessInfo.hProcess);
                  CloseHandle(eProcessInfo.hThread);
                  CloseHandle(StdErrRead);
                  CloseHandle(StdErrWrite);
               except
               end;
               if ExitCode >= 1 then
               begin
                  if strStdErr = '' then
                  begin
                     if FileExists(ExtractFilePath(ExeQPath) + 'stderr.txt') then
                     begin
                        fsStdErr := nil;
                        try
                           fsStdErr := TFileStream.Create(ExtractFilePath(ExeQPath) + 'stderr.txt', fmOpenRead or fmShareDenyNone);
                           SetLength(strStDErr, Min(fsStdErr.Size, 1024));
                           fsStdErr.read(strStdErr[1], Min(fsStdErr.Size, 1024));
                        except
                        end;
                        if fsStdErr <> nil then
                        try
                           fsStdErr.Free;
                        except
                        end;
                     end;
                  end;
                  if strStdErr <> '' then
                  begin
                     l := Length(strStdErr);
                     i := l;
                     while i > 0 do
                     begin
                        if (strStdErr[i] <> #13) and (strStdErr[i] <> #10) then
                           Break;
                        Dec(i);
                     end;
                     Delete(strStdErr, i + 1, l - i);
                     strStdErr := '<< ' + AnsiString(Wraptext(string(strStdErr), 55)) + ' >>';
                  end;
                  if (ExitCode <> 3221225786) or (strStdErr <> '') then
                  begin
                     Clipboard.AsText := ComLine + #13#10'pause';
                     if frmMain.Showing or TrayIcon.Visible then
                     begin
                        TrayIcon.BalloonHint := '';
                        StopVMAnimation;
                     end;
                     if frmMain.Showing then
                        CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'QEMUError'], [strStdErr], 'QEMU returned error !'#13#10#13#10'StdErr output: %s'#13#10#13#10'Tip: you should check the command line parameters'#13#10'to see if any are missing or spelled wrong.' + #13#10'If you are using the default parameters'#13#10'you should adapt them to your QEMU version.'#13#10#13#10'To get more informations the command line was copied into clipboard.' + #13#10'Create a new bat/cmd file, paste from clipboard and start it (as an administrator).')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbOk], mbOk)
                     else
                        CustomMessageBox(0, (GetLangTextFormatDef(idxMain, ['Messages', 'QEMUError'], [strStdErr], 'QEMU returned error !'#13#10#13#10'StdErr output: %s'#13#10#13#10'Tip: you should check the command line parameters'#13#10'to see if any are missing or spelled wrong.' + #13#10'If you are using the default parameters'#13#10'you should adapt them to your QEMU version.'#13#10#13#10'To get more informations the command line was copied into clipboard.' + #13#10'Create a new bat/cmd file, paste from clipboard and start it (as an administrator).')), (GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning')), mtWarning, [mbOk], mbOk);
                  end;
               end
               else
                  Wait(200);
            end
            else
            begin
               if frmMain.Showing or TrayIcon.Visible then
               begin
                  StopVMAnimation;
                  TrayIcon.BalloonHint := '';
                  Application.ProcessMessages;
               end;
               if LastError > 0 then
                  an := SysErrorMessage(LastError)
               else if LastExceptionStr <> '' then
                  an := LastExceptionStr
               else
                  an := 'Unknown error';
               CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'QEMUStartError'], [an], 'Unable to launch QEMU !'#13#10#13#10'System message: %s')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
            end;
            if frmMain.Showing or TrayIcon.Visible then
            begin
               StopVMAnimation;
               TrayIcon.BalloonHint := '';
            end;
            if (not frmMain.Showing) and (not AlreadyHidden) then
            begin
               frmMain.Show;
               if GetForegroundWindow <> frmMain.Handle then
               begin
                  ZeroMemory(@Input, SizeOf(Input));
                  SendInput(1, Input, SizeOf(Input));
                  SetForegroundWindow(frmMain.Handle);
               end;
               frmMain.Refresh;
            end;
            Application.ProcessMessages;
            if Application.Terminated then
               Exit;
         end;
      end;
      justclose:
   finally
      VMisOff := True;
      TrayIcon.Hint := 'Virtual Machine USB Boot';
      StopVMAnimation;
      TrayIcon.BalloonHint := '';
      StartFirstDriveAnimation;
      StartSecDriveAnimation;
      for i := 0 to High(VolumesInfo) do
      try
         if VolumesInfo[i].Handle <> INVALID_HANDLE_VALUE then
            CloseHandle(VolumesInfo[i].Handle);
      except
      end;
      if wereDismounted then
      begin
         if fu > 0 then
            UpdateDrive(fu);
         if su > 0 then
            UpdateDrive(su);
      end;
      StopFirstDriveAnimation;
      StopSecDriveAnimation;
      TrayIcon.BalloonHint := '';
      SetErrorMode(ErrorMode);
      if (not frmMain.Showing) and (not AlreadyHidden) then
      begin
         frmMain.Show;
         if GetForegroundWindow <> frmMain.Handle then
         begin
            ZeroMemory(@Input, SizeOf(Input));
            SendInput(1, Input, SizeOf(Input));
            SetForegroundWindow(frmMain.Handle);
         end;
         frmMain.Refresh;
         Application.ProcessMessages;
      end;
      if not Application.Terminated then
         if FindDrivesScheduled then
         begin
            FindDrivesScheduled := False;
            mmRefresh.Click;
         end;
      btnStart.Down := False;
      isBusyStartVm := False;
      vstVMs.SelectionLocked := False;
      if frmMain.DoubleBuffered <> not FIsAeroEnabled then
         frmMain.DoubleBuffered := not FIsAeroEnabled;
      if vstVMS.DoubleBuffered <> not FIsAeroEnabled then
         vstVMs.DoubleBuffered := not FIsAeroEnabled;
      if not Application.Terminated then
         if TryAgain then
         begin
            TryAgain := False;
            btnStartClick(nil);
         end;
      case btnStart.PngImage.Width of
         16:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn16.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn16.PngImages[0].PngImage;
            end;
         20:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn20.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn20.PngImages[0].PngImage;
            end;
         24:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn24.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn24.PngImages[0].PngImage;
            end;
      end;
      if PrestartVBFilesAgain then
      begin
         PrestartVBFilesAgain := False;
         if PrestartVBExeFiles then
         begin
            if FPSThread <> nil then
            begin
               FPSThread.Terminate;
               FPSThread.Free;
               FPSThread := nil;
            end;
            CloseHandle(svcThrProcessInfo.hProcess);
            CloseHandle(svcThrProcessInfo.hThread);
            FPSJobDone := False;
            FPSThread := TPrestartThread.Create;
         end;
      end;
      {ts[4] := Now - ts[4];
      ShowMessage('Locking and dismounting = ' + FormatDateTime('ss.zzz', ts[1]) + #13 +
         'Modify VM configuration = ' + FormatDateTime('ss.zzz', ts[2]) + #13 +
         'Starting the VM = ' + FormatDateTime('ss.zzz', ts[3]) + #13 +
         'Removing the drives = ' + FormatDateTime('ss.zzz', ts[4]));}
   end;
end;

function GetProcessHandleFromID(ID: DWORD): THandle;
begin
   Result := OpenProcess(PROCESS_CREATE_THREAD or PROCESS_QUERY_INFORMATION or
      PROCESS_VM_OPERATION or PROCESS_VM_WRITE or PROCESS_VM_READ, False, ID);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
   ExitCode, dwTID: DWORD;
   hProcessDup, RemoteProcHandle: Cardinal;
   bDup: BOOL;
   dwCode: DWORD;
   hrt: Cardinal;
   hKernel: HMODULE;
   FARPROC: Pointer;
   uExitCode: Cardinal;
   dt, wt: Cardinal;
begin
   if FPCThread <> nil then
   begin
      if not FPCJobDone then
         FPCThread.Terminate;
      if FPSJobDone then
      begin
         try
            FPCThread.Free;
            FPCThread := nil;
         except
         end;
      end
      else
      try
         TerminateThread(FPCThread.Handle, 0);
         FPCThread := nil;
      except
      end;
   end;
   if FPSThread <> nil then
   begin
      if not FPSJobDone then
         FPSThread.Terminate;
      if FPSJobDone then
      begin
         try
            FPSThread.Free;
            FPSThread := nil;
         except
         end;
      end
      else
      try
         TerminateThread(FPSThread.Handle, 0);
         FPSThread := nil;
      except
      end;
   end;
   if FRegThread <> nil then
   begin
      if not FRegJobDone then
         FRegThread.Terminate;
      if FRegJobDone then
      begin
         try
            FRegThread.Free;
            FRegThread := nil;
         except
         end;
      end
      else
      try
         TerminateThread(FRegThread.Handle, 0);
         FRegThread := nil;
      except
      end;
   end;
   DragAcceptFiles(WindowHandle, False);
   SaveVMentries(VMentriesFile);
   SaveCFG(CfgFile);
   UnregisterHotKey(frmMain.Handle, Hotkey_id);
   GlobalDeleteAtom(Hotkey_id);
   if PrestartVBExeFiles and FPSJobDone then
   begin
      try
         GetExitCodeProcess(svcThrProcessInfo.hProcess, ExitCode);
         if ExitCode = Still_Active then
         begin
            uExitCode := 0;
            RemoteProcHandle := GetProcessHandleFromID(svcThrProcessInfo.dwProcessId);
            bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
            if GetExitCodeProcess(hProcessDup, dwCode) then
            begin
               hKernel := GetModuleHandle('Kernel32');
               FARPROC := GetProcAddress(hKernel, 'ExitProcess');
               hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
               if hrt = 0 then
                  TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), svcThrProcessInfo.dwProcessId), 0)
               else
                  CloseHandle(hRT);
            end
            else
               TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), svcThrProcessInfo.dwProcessId), 0);
            if (bDup) then
               CloseHandle(hProcessDup);
         end;
         CloseHandle(svcThrProcessInfo.hProcess);
         CloseHandle(svcThrProcessInfo.hThread);
      except
      end;
   end;
   if DoNotUnregister then
   begin
      DoNotUnregister := False;
      Exit;
   end;
   if isVBPortable then
   begin
      if isVBinstalledToo and FileExists(exeVBPathToo) and useLoadedFromInstalled then
         wt := 3000
      else
         wt := Round((25000 + Integer(LoadUSBPortable) * 10000 + Integer(LoadNetPortable) * 10000) * (1 + 0.5 * Integer((isVBinstalledToo and FileExists(exeVBPathToo) and (not useLoadedFromInstalled)))));
      FUnregJobDone := False;
      FUnregThread := TUnregisterThread.Create;
      dt := GetTickCount;
      while (not FUnregJobDone) and ((GetTickCount - dt) <= wt) do
      begin
         mEvent.WaitFor(1);
         Application.ProcessMessages;
      end;
      if not FUnregJobDone then
         FUnregThread.Terminate;
      if FUnregJobDone then
      begin
         try
            FUnregThread.Free;
            FUnregThread := nil;
         except
         end;
      end
      else
      try
         TerminateThread(FUnregThread.Handle, 0);
         FUnregThread := nil;
      except
      end;
   end;
   mEvent.Free;
end;

procedure TfrmMain.vstVMsDblClick(Sender: TObject);
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;
   if vstVMs.GetFirstSelected = nil then
      Exit;
   btnStart.Down := True;
   btnStart.Click;
end;

procedure TfrmMain.vstVMsDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
   Allowed := (not isBusyStartVM) and (not isBusyManager) and (not IsBusyEjecting);
end;

procedure TfrmMain.vstVMsDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
   pSource, pTarget, Node: PVirtualNode;
   attMode: TVTNodeAttachMode;
   Data: PData;
begin
   pSource := TVirtualStringTree(Source).FocusedNode;
   pTarget := Sender.DropTargetNode;

   case Mode of
      dmAbove:
         attMode := amInsertBefore;
      dmOnNode, dmBelow:
         attMode := amInsertAfter;
      else
         attMode := amNoWhere;
   end;

   if pTarget = nil then
   begin
      pTarget := vstVMs.GetFirst;
      attMode := amInsertBefore;
      if Pt.Y > vstVMs.GetDisplayRect(pTarget, 0, False, False, False).Top then
      begin
         pTarget := vstVMs.GetLast;
         attMode := amInsertAfter;
         if Pt.Y < vstVMs.GetDisplayRect(pTarget, 0, False, False, False).Bottom then
         begin
            pTarget := nil;
            attMode := amNoWhere;
         end;
      end;
   end;
   if (pSource = nil) or (pTarget = nil) or (pSource = pTarget) or (attMode = amNoWhere) then
      Exit;
   vstVMs.BeginUpdate;
   Sender.MoveTo(pSource, pTarget, attMode, False);
   Node := vstVMs.GetFirst;
   while Node <> nil do
   begin
      Data := vstVMs.GetNodeData(Node);
      if (vstVMs.RootNodeCount < 10) or (Node.Index > 8) then
         Data^.FId := IntToStr(Node.Index + 1)
      else
         Data^.FId := '0' + IntToStr(Node.Index + 1);
      Node := vstVMs.GetNext(Node);
   end;
   vstVMs.EndUpdate;
   vstVMs.Invalidate;
   SaveVMentries(VMentriesFile);
end;

procedure TfrmMain.vstVMsDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
var
   dropItem: PVirtualNode;
begin
   try
      Accept := False;
      if Sender <> Source then
         Exit;
      dropItem := (Sender as TVirtualStringTree).GetNodeAt(Pt.X, Pt.Y);
      if (dropItem <> nil) and vstVMs.Selected[dropItem] then
         Exit;
      Accept := True;
   except
   end;
end;

procedure TfrmMain.vstVMsDrawText(Sender: TBaseVirtualTree;
   TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
   const Text: string; const CellRect: TRect; var DefaultDraw: Boolean);
var
   r: TRect;
   Data: PData;
begin
   case Column of
      0:
         begin
            r := CellRect;
            Data := Node.GetData;
            r.Left := Sender.Header.Columns[0].Left;
            r.Right := Sender.Header.Columns[0].GetRect.Right;
            DrawText(TargetCanvas.Handle, PChar(Data^.FId), Length(Data^.FId), r, DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_NOCLIP);
            DefaultDraw := False;
         end;
   end;
end;

procedure TfrmMain.vstVMsFocusChanged(Sender: TBaseVirtualTree;
   Node: PVirtualNode; Column: TColumnIndex);
var
   i: Integer;
   strTemp: string;
   Data: PData;
   mmOpen: TMenuItem;
begin
   try
      for i := pmVMs.Items.Count - 1 downto 0 do
         if System.Pos('OpenInExplorer', pmVMs.Items[i].Name) = 1 then
         begin
            mmOpen := pmVMs.Items[i];
            mmOPen.Free;
         end;
      if vstVMs.GetFirstSelected <> nil then
      begin
         strTemp := GetLangTextDef(idxMain, ['List', 'Menu', 'FileExplorer'], 'Open %s in Explorer');
         Data := vstVMs.GetNodeData(vstVMs.GetFirstSelected);
         SetLength(PathsToOpen, 0);
         if AddSecondDrive then
            if Data^.SecondDriveFound then
               for i := High(Data^.SDMountPointsArr) downto 0 do
               begin
                  SetLength(PathsToOpen, Length(PathsToOpen) + 1);
                  PathsToOpen[High(PathsToOpen)] := Data^.SDMountPointsArr[i];
               end;
         if Data^.FirstDriveFound then
            for i := High(Data^.FDMountPointsArr) downto 0 do
            begin
               SetLength(PathsToOpen, Length(PathsToOpen) + 1);
               PathsToOpen[High(PathsToOpen)] := Data^.FDMountPointsArr[i];
            end;
         for i := 0 to High(PathsToOpen) do
         begin
            mmOpen := TMenuItem.Create(pmVMs);
            try
               mmOpen.Name := 'OpenInExplorer' + IntToStr(i);
            except
               mmOpen.Name := 'OpenInExplorer0' + IntToStr(i);
            end;
            if Length(PathsToOpen[i]) = 2 then
            begin
               mmOpen.Caption := Format(strTemp, ['''' + PathsToOpen[i] + '''']);
               mmOpen.ShortCut := ShortCut(Word(PathsToOpen[i][1]), [ssAlt]);
               PathsToOpen[i] := PathsToOpen[i] + '\';
            end
            else
               mmOpen.Caption := Format(strTemp, ['''' + PathsToOpen[i] + '''']);
            mmOpen.ImageIndex := 11;
            mmOpen.OnClick := mmOpenInEXplorerClick;
            pmVMs.Items.Insert(4, mmOpen);
         end;
         if isVBPortable and ((not FRegJobDone) or (not FUnregJobDone)) then
         begin
            Data := frmMain.vstVMs.GetNodeData(frmMain.vstVMs.GetFirstSelected());
            if (Data^.Ptype = 0) and (imlBtn16.PngImages[0].PngImage.Pixels[8, 8] <> imlReg16.PngImages[2].PngImage.Pixels[8, 8]) then
            begin
               imlBtn16.PngImages[0].PngImage := imlReg16.PngImages[2].PngImage;
               imlBtn16.PngImages[10].PngImage := imlReg16.PngImages[2].PngImage;
               imlBtn20.PngImages[0].PngImage := imlReg20.PngImages[2].PngImage;
               imlBtn20.PngImages[10].PngImage := imlReg20.PngImages[2].PngImage;
               imlBtn24.PngImages[0].PngImage := imlReg24.PngImages[2].PngImage;
               imlBtn24.PngImages[10].PngImage := imlReg24.PngImages[2].PngImage;
               case frmMain.btnStart.PngImage.Width of
                  16: btnStart.PngImage := imlReg16.PngImages[2].PngImage;
                  20: btnStart.PngImage := imlReg20.PngImages[2].PngImage;
                  24: btnStart.PngImage := imlReg24.PngImages[2].PngImage;
               end;
            end
            else if (Data^.Ptype = 1) and (imlBtn16.PngImages[0].PngImage.Pixels[8, 8] <> imlReg16.PngImages[0].PngImage.Pixels[8, 8]) then
            begin
               imlBtn16.PngImages[0].PngImage := imlReg16.PngImages[0].PngImage;
               imlBtn16.PngImages[10].PngImage := imlReg16.PngImages[1].PngImage;
               imlBtn20.PngImages[0].PngImage := imlReg20.PngImages[0].PngImage;
               imlBtn20.PngImages[10].PngImage := imlReg20.PngImages[1].PngImage;
               imlBtn24.PngImages[0].PngImage := imlReg24.PngImages[0].PngImage;
               imlBtn24.PngImages[10].PngImage := imlReg24.PngImages[1].PngImage;
               case frmMain.btnStart.PngImage.Width of
                  16: btnStart.PngImage := imlReg16.PngImages[2].PngImage;
                  20: btnStart.PngImage := imlReg20.PngImages[2].PngImage;
                  24: btnStart.PngImage := imlReg24.PngImages[2].PngImage;
               end;
            end;
         end;
      end;
   except
   end;
   try
      if vstVMs.GetFirstSelected = nil then
      begin
         case btnManager.PngImage.Width of
            16:
               begin
                  if btnManager.PngImage.Canvas.Pixels[8, 8] <> imlVST16.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                     btnManager.PngImage := imlVST16.PngImages[0].PngImage;
               end;
            20:
               begin
                  if btnManager.PngImage.Canvas.Pixels[12, 12] <> imlVST20.PngImages[0].PngImage.Canvas.Pixels[12, 12] then
                     btnManager.PngImage := imlVST20.PngImages[0].PngImage;
               end;
            24:
               begin
                  if btnManager.PngImage.Canvas.Pixels[12, 12] <> imlVST24.PngImages[0].PngImage.Canvas.Pixels[12, 12] then
                     btnManager.PngImage := imlVST24.PngImages[0].PngImage;
               end;
         end;
         if isVBPortable and ((not FRegJobDone) or (not FUnregJobDone)) then
         begin
            if imlBtn16.PngImages[0].PngImage.Pixels[8, 8] <> imlReg16.PngImages[2].PngImage.Pixels[8, 8] then
            begin
               imlBtn16.PngImages[0].PngImage := imlReg16.PngImages[2].PngImage;
               imlBtn16.PngImages[10].PngImage := imlReg16.PngImages[2].PngImage;
               imlBtn20.PngImages[0].PngImage := imlReg20.PngImages[2].PngImage;
               imlBtn20.PngImages[10].PngImage := imlReg20.PngImages[2].PngImage;
               imlBtn24.PngImages[0].PngImage := imlReg24.PngImages[2].PngImage;
               imlBtn24.PngImages[10].PngImage := imlReg24.PngImages[2].PngImage;
               case frmMain.btnStart.PngImage.Width of
                  16: btnStart.PngImage := imlReg16.PngImages[2].PngImage;
                  20: btnStart.PngImage := imlReg20.PngImages[2].PngImage;
                  24: btnStart.PngImage := imlReg24.PngImages[2].PngImage;
               end;
            end;
         end;
      end
      else
      begin
         Data := vstVMs.GetNodeData(vstVMs.GetFirstSelected);
         if Data^.Ptype = 0 then
         begin
            case btnManager.PngImage.Width of
               16:
                  begin
                     if btnManager.PngImage.Canvas.Pixels[8, 8] <> imlBtn16.PngImages[8].PngImage.Canvas.Pixels[8, 8] then
                        btnManager.PngImage := imlBtn16.PngImages[8].PngImage;
                  end;
               20:
                  begin
                     if btnManager.PngImage.Canvas.Pixels[12, 12] <> imlBtn20.PngImages[8].PngImage.Canvas.Pixels[12, 12] then
                        btnManager.PngImage := imlBtn20.PngImages[8].PngImage;
                  end;
               24:
                  begin
                     if btnManager.PngImage.Canvas.Pixels[12, 12] <> imlBtn24.PngImages[8].PngImage.Canvas.Pixels[12, 12] then
                        btnManager.PngImage := imlBtn24.PngImages[8].PngImage;
                  end;
            end;
         end
         else
         begin
            case btnManager.PngImage.Width of
               16:
                  begin
                     if btnManager.PngImage.Canvas.Pixels[8, 8] <> imlBtn16.PngImages[12].PngImage.Canvas.Pixels[8, 8] then
                        btnManager.PngImage := imlBtn16.PngImages[12].PngImage;
                  end;
               20:
                  begin
                     if btnManager.PngImage.Canvas.Pixels[12, 12] <> imlBtn20.PngImages[12].PngImage.Canvas.Pixels[12, 12] then
                        btnManager.PngImage := imlBtn20.PngImages[12].PngImage;
                  end;
               24:
                  begin
                     if btnManager.PngImage.Canvas.Pixels[12, 12] <> imlBtn24.PngImages[12].PngImage.Canvas.Pixels[12, 12] then
                        btnManager.PngImage := imlBtn24.PngImages[12].PngImage;
                  end;
            end;
         end;
      end;
   except
   end;
end;

procedure TfrmMain.vstVMsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
   Data: PData;
begin
   Data := Sender.GetNodeData(Node);
   Finalize(Data^);
end;

procedure TfrmMain.vstVMsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
var
   Data: PData;
begin
   Data := vstVMs.GetNodeData(Node);
   case Column of
      1:
         if ShowVMAnim and (vsSelected in Node.States) then
            ImageIndex := VMAnimImageIndex
         else
            ImageIndex := Data.FVMImageIndex;
      2:
         if ShowFirstDriveAnim and (vsSelected in Node.States) then
            ImageIndex := FirstDriveAnimImageIndex
         else
            ImageIndex := Data.FFDImageIndex;
      3:
         if ShowSecDriveAnim and (vsSelected in Node.States) then
            ImageIndex := SecDriveAnimImageIndex
         else
            ImageIndex := Data.FSDImageIndex;
   end;
end;

procedure TfrmMain.vstVMsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
   Data: PData;
begin
   Data := vstVMs.GetNodeData(Node);
   case Column of
      0:
         CellText := Data^.FId;
      1:
         CellText := Data^.FVName;
      2:
         begin
            if not Data^.FirstDriveFound then
               CellText := Data^.FDDisplayName
            else
            begin
               CellText := Data^.FDDisplayName + '   ' + Data^.FDMountPointsStr;
            end;
         end;
      3:
         begin
            if not Data^.SecondDriveFound then
               CellText := Data^.SDDisplayName
            else
               CellText := Data^.SDDisplayName + '   ' + Data^.SDMountPointsStr;
         end;
   end;
end;

procedure TfrmMain.vstVMsMeasureItem(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
   var NodeHeight: Integer);
begin
   NodeHeight := Round(1.1 * Max(imlVST_items.Height, TargetCanvas.TextHeight('Hg')) + 1.6);
end;

procedure TfrmMain.vstVMsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   Node: PVirtualNode;
   p: TPoint;
   lvc: Integer;
begin
   if (Button <> mbLeft) and (Button <> mbRight) then
      Exit;
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;
   p.X := X;
   p.Y := Y;
   Node := vstVMs.GetNodeAt(p);
   if Node <> nil then
   begin
      lvc := vstVMs.Header.Columns.GetLastVisibleColumn;
      if lvc > -1 then
         if vstVMs.Header.Columns[lvc].GetRect.Right >= X then
            Exit;
   end;
   Node := vstVMs.GetFirstSelected;
   if Node <> nil then
   begin
      vstVMs.Selected[Node] := False;
      vstVMs.FocusedNode := nil;
   end;
end;

procedure TfrmMain.vstVMsShowScrollBar(Sender: TBaseVirtualTree; Bar: Integer;
   Show: Boolean);
var
   VertSBWidth: Integer;
begin
   try
      if DoNothingOnScrollBarShow then
         Exit;
      if Bar = SB_VERT then
         if Show <> VertScrollBarVisible then
         begin
            VertSBWidth := GetSystemMetrics(SM_CYVSCROLL);
            if (Show and (vstVMs.Header.Columns.TotalWidth = (vstVMs.ClientWidth + VertSBWidth))) or
               ((not Show) and (vstVMs.Header.Columns.TotalWidth = (vstVMs.ClientWidth - VertSBWidth))) then
               RealignColumns;
         end;
   finally
      if Bar = SB_VERT then
         VertScrollBarVisible := Show;
      if Bar = SB_HORZ then
         HorzScrollBarVisible := Show;
   end;
end;

procedure TfrmMain.WindProc(var Message: TMessage);
var
   l: Integer;
begin
   try
      case Message.Msg of
         WM_SYSCOMMAND:
            begin
               case Message.wParam of
                  SC_MINIMIZE:
                     if WindowState = wsNormal then
                     begin
                        IntLeft := Left;
                        IntTop := Top;
                        IntWidth := Width;
                        IntHeight := Height;
                     end;
                  SC_MAXIMIZE:
                     begin
                        if WindowState = wsNormal then
                        begin
                           IntLeft := Left;
                           IntTop := Top;
                           IntWidth := Width;
                           IntHeight := Height;
                        end;
                        Message.Result := 0;
                        Exit;
                     end;
                  {                  WM_USER + 1:
                                       OpenInternetHelp(Self.Handle, ['http://reboot.pro/user/61891-davidb/', 'http://reboot.pro/index.php?showuser=61891']);
                                    WM_USER + 2:
                                       OpenInternetHelp(Self.Handle, ['http://reboot.pro/user/17818-steve6375/', 'http://reboot.pro/index.php?showuser=17818']);}
                  WM_USER + 3:
                     OpenInternetHelp(Self.Handle, ['https://github.com/DavidBrenner3/VMUB', 'http://reboot.pro/index.php?s=e6a62f6faf7bc2a4ed6d16b703166a34&app=downloads&showfile=339']);
                  WM_USER + 4:
                     OpenInternetHelp(Self.Handle, DefSiteHelp);
               end;
            end;
         WM_USER + 333:
            if Message.wParam = 3 then
               if Message.lParam = 3 then
               begin
                  l := Length(strRegErrMsg);
                  while (l > 0) and ((strRegErrMsg[1] = #13) or (strRegErrMsg[1] = #10)) do
                  begin
                     Delete(strRegErrMsg, 1, 1);
                     Dec(l);
                  end;
                  while (l > 0) and ((strRegErrMsg[l] = #13) or (strRegErrMsg[l] = #10)) do
                  begin
                     Delete(strRegErrMsg, l, 1);
                     Dec(l);
                  end;
                  if CustomMessageBox(frmMain.Handle, GetLangTextFormatDef(idxMain, ['Messages', 'CouldNotReg'], [''], 'Could not automatically register the VirtualBox%s dlls, infs and services !'#13#10#13#10'Reason:') + ' ' + strRegErrMsg,
                     GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbRetry, mbIgnore], mbRetry) = mrRetry then
                  begin
                     if FRegThread <> nil then
                     begin
                        if not FRegJobDone then
                           FRegThread.Terminate;
                        if FRegJobDone then
                        begin
                           try
                              FRegThread.Free;
                              FRegThread := nil;
                           except
                           end;
                        end
                        else
                        try
                           TerminateThread(FRegThread.Handle, 0);
                           FRegThread := nil;
                        except
                        end;
                     end;
                     FRegJobDone := False;
                     FRegThread := TRegisterThread.Create;
                  end;
               end;
      end;
   except
   end;
   fOldTWndMethod(Message);
end;

procedure TfrmMain.FormResize(Sender: TObject);
var
   t: Double;
begin
   LockWindowUpdate(Handle);
   SendMessage(pnlBackground.Handle, WM_SETREDRAW, wParam(False), 0);
   if ColWereAligned then
      RealignColumns;
   if not btnShowTrayIcon.Visible then
   begin
      t := 1.0 / 6 * (btnExit.Top - btnStart.Top);
      btnAdd.Top := Round(t + btnStart.Top);
      btnEdit.Top := Round(2.0 * t + btnStart.Top);
      btnDelete.Top := Round(3.0 * t + btnStart.Top);
      btnManager.Top := Round(4.0 * t + btnStart.Top);
      btnOptions.Top := Round(5.0 * t + btnStart.Top);
   end
   else
   begin
      t := 1.0 / 7 * (btnExit.Top - btnStart.Top);
      btnAdd.Top := Round(t + btnStart.Top);
      btnEdit.Top := Round(2.0 * t + btnStart.Top);
      btnDelete.Top := Round(3.0 * t + btnStart.Top);
      btnManager.Top := Round(4.0 * t + btnStart.Top);
      btnOptions.Top := Round(5.0 * t + btnStart.Top);
      btnShowTrayIcon.Top := Round(6.0 * t + btnStart.Top);
   end;
   SendMessage(pnlBackground.Handle, WM_SETREDRAW, wParam(True), 0);
   LockWindowUpdate(0);
end;

procedure TfrmMain.RealignColumns(const NoRedraw: Boolean = True);
var
   i, l, pl, ivmname, ifirst, isec, nres, lvc: Integer;
   diff: Double;
begin
   try
      i := 0;
      l := 0;
      ivmname := -1;
      ifirst := -1;
      isec := -1;
      lvc := -1;
      nres := 0;
      while i < vstVMs.Header.Columns.Count do
      begin
         if coVisible in vstVMs.Header.Columns[i].Options then
            case i of
               1:
                  begin
                     ivmname := i;
                     Inc(nres);
                     lvc := i;
                  end;
               2:
                  begin
                     ifirst := i;
                     Inc(nres);
                     lvc := i;
                  end;
               3:
                  begin
                     isec := i;
                     Inc(nres);
                     lvc := i;
                  end;
               else
                  Inc(l, vstVMs.Header.Columns[i].Width);
            end;
         Inc(i);
      end;
      if NoRedraw then
      begin
         SendMessage(vstVMs.Handle, WM_SETREDRAW, wParam(False), 0);
         vstVMs.Header.Columns.BeginUpdate;
      end;
      if nres > 0 then
      begin
         l := vstVMs.ClientWidth - l;
         pl := 0;
         if ivmname > -1 then
            Inc(pl, vstVMs.Header.Columns[ivmname].Width);
         if ifirst > -1 then
            Inc(pl, vstVMs.Header.Columns[ifirst].Width);
         if isec > -1 then
            Inc(pl, vstVMs.Header.Columns[isec].Width);
         diff := 1.0 * (l - pl) / nres;
         if ivmname > -1 then
            if lvc = ivmname then
               vstVMs.Header.Columns[ivmname].Width := vstVMs.ClientWidth - Integer(coVisible in vstVMs.Header.Columns[0].Options) * vstVMs.Header.Columns[0].Width
            else
               vstVMs.Header.Columns[ivmname].Width := Round(diff + vstVMs.Header.Columns[ivmname].Width);
         if ifirst > -1 then
            if lvc = ifirst then
               vstVMs.Header.Columns[ifirst].Width := vstVMs.ClientWidth - Integer(coVisible in vstVMs.Header.Columns[0].Options) * vstVMs.Header.Columns[0].Width - Integer(coVisible in vstVMs.Header.Columns[1].Options) * vstVMs.Header.Columns[1].Width
            else
               vstVMs.Header.Columns[ifirst].Width := Round(diff + vstVMs.Header.Columns[ifirst].Width);
         if isec > -1 then
            vstVMs.Header.Columns[isec].Width := vstVMs.ClientWidth - Integer(coVisible in vstVMs.Header.Columns[0].Options) * vstVMs.Header.Columns[0].Width - Integer(coVisible in vstVMs.Header.Columns[1].Options) * vstVMs.Header.Columns[1].Width - Integer(coVisible in vstVMs.Header.Columns[2].Options) * vstVMs.Header.Columns[2].Width;
      end;
   finally
      if NoRedraw then
      begin
         vstVMs.Header.Columns.EndUpdate;
         SendMessage(vstVMs.Handle, WM_SETREDRAW, wParam(True), 0);
      end;
   end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
   StartupInfo: TStartupInfo;
   i, h, r, cm, cvm, p: Integer;
   dt, wt: Cardinal;
   DoNotRegister: Boolean;
   Key: Word;
   Modifiers: Uint;
begin
   if AlreadyRuned then
      Exit;
   AlreadyRuned := True;
   GetStartUpInfo(StartupInfo);
   if (STARTF_USESHOWWINDOW and StartupInfo.dwFlags) = STARTF_USESHOWWINDOW then
      if StartupInfo.wShowWindow in [SW_MAXIMIZE, SW_SHOWMAXIMIZED] then
         SendMessage(Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
   HideAutoSustainScrollbars;
   if ShowTrayIcon then
   begin
      ShowTray;
      tmCloseHint.Interval := 7000;
      tmCloseHint.Enabled := False;
      tmCloseHint.Enabled := True;
      TrayIcon.BalloonHint := GetLangTextFormatDef(idxMain, ['Messages', 'AppStartedWithTray'], ['Virtual Machine USB Boot'],
         '%s tray icon is now active...');
      TrayIcon.ShowBalloonHint;
   end;
   if PrecacheVBFiles then
   begin
      FPCJobDone := False;
      FPCThread := TPrecacheThread.Create;
   end;
   if isVBPortable then
   begin
      DoNotRegister := False;
      while True do
      begin
         GetAllWindowsList(VBWinClass);
         h := High(AllWindowsList);
         i := 0;
         cm := 0;
         cvm := 0;
         while i <= h do
         begin
            if IsWindowVisible(AllWindowsList[i].Handle) then
            begin
               p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
               if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                  Inc(cm)
               else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                  Inc(cvm);
            end;
            Inc(i);
         end;
         if (cm + cvm) > 0 then
         begin
            r := CustomMessageBox(Handle, GetLangTextDef(idxMain, ['Messages', 'ProperRegUnreg'], 'In order to properly (un)register VirtualBox dlls, infs and services'#13#10'for the portable version, all the VirtualBox windows have to be closed!' +
               #13#10#13#10'You can choose to Abort, close all VirtualBox windows manually and click on Retry,'#13#10'click on Ignore to not unregister or click on Close all to automatically close them'),
               GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbAbort, mbRetry, mbNoToAll, mbIgnore], mbAbort);
            case r of
               mrRetry: Continue;
               mrNoToAll:
                  begin
                     isBusyClosing := True;
                     try
                        GetAllWindowsList(VBWinClass);
                        h := High(AllWindowsList);
                        i := 0;
                        cm := 0;
                        cvm := 0;
                        while i <= h do
                        begin
                           if IsWindowVisible(AllWindowsList[i].Handle) then
                           begin
                              p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
                              if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                              begin
                                 PostMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
                                 Inc(cm);
                              end
                              else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                              begin
                                 PostMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
                                 Inc(cvm);
                              end;
                           end;
                           Inc(i);
                        end;
                        if (cm + cvm) > 0 then
                        begin
                           dt := GetTickCount;
                           wt := 2000 * cm + 5000 * cvm;
                           while True do
                           begin
                              Wait(100);
                              if (GetTickCount - dt) > wt then
                                 Break;
                              GetAllWindowsList(VBWinClass);
                              h := High(AllWindowsList);
                              i := 0;
                              cm := 0;
                              cvm := 0;
                              while i <= h do
                              begin
                                 if IsWindowVisible(AllWindowsList[i].Handle) then
                                 begin
                                    p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
                                    if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                       Inc(cm)
                                    else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                       Inc(cvm);
                                 end;
                                 Inc(i);
                              end;
                              if (cm + cvm) = 0 then
                                 Break;
                           end;
                        end;
                     finally
                        isBusyClosing := False;
                     end;
                  end;
               mrIgnore:
                  begin
                     DoNotRegister := True;
                     Break;
                  end;
               else
                  OnCloseQuery := nil;
                  DoNotUnregister := True;
                  Application.ShowMainForm := False;
                  Application.Terminate;
                  Close;
                  Exit;
            end;
         end;
         if (cm + cvm) = 0 then
            Break;
      end;
      if not DoNotRegister then
      begin
         FRegJobDone := False;
         FRegThread := TRegisterThread.Create;
      end;
   end;
   if PrestartVBExeFiles then
   begin
      if isVBPortable then
         if not FRegJobDone then
            StartSvcToo := True
         else if FRegJobDone then
            StartSvcToo := False;

      if not StartSvcToo then
      begin
         FPSJobDone := False;
         FPSThread := TPrestartThread.Create;
      end;
   end;
   ShortCutToHotKey(StartKeyComb, Key, Modifiers);
   Hotkey_id := GlobalAddAtom('hkVMUbStart');
   RegisterHotKey(frmMain.Handle, Hotkey_id, Modifiers, Key);
end;

procedure TfrmMain.HideAutoSustainScrollbars;
var
   lvc: Integer;
begin
   if not VertScrollBarVisible then
      Exit;
   if not HorzScrollBarVisible then
      Exit;
   lvc := vstVMs.Header.Columns.GetLastVisibleColumn;
   if lvc < 0 then
      Exit;
   DoNothingOnScrollBarShow := True;
   vstVMs.Header.Options := vstVMs.Header.Options + [hoAutoResize];
   vstVMs.Header.AutoSizeIndex := lvc;
   vstVMs.Header.Columns[lvc].Options := vstVMs.Header.Columns[lvc].Options + [coSmartResize];
   vstVMs.Header.Options := vstVMs.Header.Options - [hoAutoResize];
   vstVMs.Header.AutoSizeIndex := -1;
   vstVMs.Header.Columns[lvc].Options := vstVMs.Header.Columns[lvc].Options - [coSmartResize];
   DoNothingOnScrollBarShow := False;
end;

procedure TfrmMain.pmHeadersPopup(Sender: TObject);
var
   i: Integer;
begin
   for i := 0 to vstVMs.Header.Columns.Count - 1 do
   try
      if pmHeaders.Items[i].Visible then
         pmHeaders.Items[i].Checked := coVisible in vstVMs.Header.Columns[i].Options;
   except
   end;
end;

procedure TfrmMain.pmTrayPopup(Sender: TObject);
var
   strTemp: string;
   p1, p2, l: Integer;
begin
   strTemp := GetLangTextDef(idxMain, ['List', 'Menu', 'ShowHideMainWindow'], 'Show hide main window');
   l := Length(strTemp);
   p1 := PosEx(' ', strTemp, 2);
   p2 := PosEx(' ', strTemp, p1 + 2);
   if (p1 = 0) or (p2 = 0) then
   begin
      if Showing and (not IsIconic(Application.Handle)) then
      begin
         mmShowHideMainWindow.Caption := 'Hide main window';
         mmShowHideMainWindow.Enabled := not ((Assigned(frmOptions) and frmOptions.Showing) or
            (Assigned(frmAddEdit) and frmAddEdit.Showing));
         mmShowHideMainWindow.ImageIndex := 22;
      end
      else
      begin
         mmShowHideMainWindow.Caption := 'Show main window';
         mmShowHideMainWindow.ImageIndex := 21;
      end;
   end
   else
   begin
      if Showing and (not IsIconic(Application.Handle)) then
      begin
         strTemp := Copy(strTemp, p1 + 1, l - p1);
         strTemp[1] := UpCase(strTemp[1]);
         mmShowHideMainWindow.Caption := strTemp;
         mmShowHideMainWindow.Enabled := not ((Assigned(frmOptions) and frmOptions.Showing) or
            (Assigned(frmAddEdit) and frmAddEdit.Showing));
         mmShowHideMainWindow.ImageIndex := 22;
      end
      else
      begin
         mmShowHideMainWindow.Caption := Copy(strTemp, 1, p1 - 1) + Copy(strTemp, p2, l - p2 + 1);
         mmShowHideMainWindow.ImageIndex := 21;
      end;
   end;
end;

procedure TfrmMain.pnlBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   ReleaseCapture;
   SendMessage(Handle, WM_SYSCOMMAND, 61458, 0);
end;

procedure TfrmMain.mmHeadersClick(Sender: TObject);
var
   i, CrtWidth, NrRes: Integer;
begin
   ColWereAligned := vstVMs.Header.Columns.TotalWidth = vstVMs.ClientWidth;
   if coVisible in vstVMs.Header.Columns[0].Options then
      CrtWidth := vstVMs.Header.Columns[0].Width
   else
      CrtWidth := 0;
   NrRes := 0;
   for i := 1 to vstVMs.Header.Columns.Count - 1 do
      if coVisible in vstVMs.Header.Columns[i].Options then
         Inc(NrRes);
   if not ColWereAligned then
      ColWereAligned := NrRes = 0;
   (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
   if (Sender as TMenuItem).Checked then
   begin
      if ColWereAligned then
      begin
         if (Sender as TMenuItem).MenuIndex <> 0 then
         begin
            if NrRes > 0 then
               vstVMs.Header.Columns[(Sender as TMenuItem).MenuIndex].Width := (vstVMs.Header.Columns.TotalWidth - CrtWidth) div NrRes
            else
               vstVMs.Header.Columns[(Sender as TMenuItem).MenuIndex].Width := vstVMs.Header.Columns.TotalWidth - CrtWidth;
         end;
      end;
      if not (coVisible in vstVMs.Header.Columns[(Sender as TMenuItem).MenuIndex].Options) then
         vstVMs.Header.Columns[(Sender as TMenuItem).MenuIndex].Options := vstVMs.Header.Columns[(Sender as TMenuItem).MenuIndex].Options + [coVisible];
      vstVMs.ScrollIntoView((Sender as TMenuItem).MenuIndex, False);
   end
   else if coVisible in vstVMs.Header.Columns[(Sender as TMenuItem).MenuIndex].Options then
      vstVMs.Header.Columns[(Sender as TMenuItem).MenuIndex].Options := vstVMs.Header.Columns[(Sender as TMenuItem).MenuIndex].Options - [coVisible];
   if ColWereAligned then
   begin
      RealignColumns;
      vstVMs.Invalidate;
   end;
   SaveCFG(CfgFile);
end;

procedure TfrmMain.SortAfterColumn(const ColumnIndex: Integer);
var
   i, p, lv: Integer;
   Changed, WasSorted: Boolean;
   Node, firstNode, secNode, tempNode: PVirtualNode;
   firstData, secData, tempData: PData;
   firstStr, secStr: string;
begin
   p := GetItemIndex;
   WasSorted := False;
   vstVMs.BeginUpdate;
   lv := vstVMs.RootNodeCount;
   try
      tempNode := vstVMs.AddChild(nil);
      tempData := vstVMs.GetNodeData(tempNode);
      WasSorted := False;
      repeat
         Changed := False;
         for i := 0 to lv - 2 do
         begin
            firstNode := nil;
            secNode := nil;
            Node := vstVMs.GetFirst;
            while Node <> nil do
            begin
               if Integer(Node.Index) = i then
                  firstNode := Node;
               if Integer(Node.Index) = (i + 1) then
                  secNode := Node;
               Node := vstVMs.GetNext(Node);
            end;
            if firstNode = nil then
               Continue;
            if secNode = nil then
               Continue;
            firstData := vstVMs.GetNodeData(firstNode);
            secData := vstVMs.GetNodeData(secNode);
            case ColumnIndex of
               0:
                  begin
                     firstStr := firstData^.FId;
                     secStr := secData^.FId;
                  end;
               1:
                  begin
                     firstStr := firstData^.FVName;
                     secStr := secData^.FVName;
                  end;
               2:
                  begin
                     firstStr := firstData^.FDDisplayName;
                     secStr := secData^.FDDisplayName;
                  end;
               3:
                  begin
                     firstStr := firstData^.SDDisplayName;
                     secStr := secData^.SDDisplayName;
                  end;
               else
                  Continue;
            end;

            case CompareString((LOCALE_USER_DEFAULT or (SUBLANG_DEFAULT shl 10)) or (SORT_DEFAULT shl 16), NORM_IGNORECASE, PChar(firstStr), Length(firstStr), PChar(secStr), Length(secStr)) - 2 of
               1:
                  begin
                     if p = i then
                        p := i + 1
                     else if p = (i + 1) then
                        p := i;
                     firstData := vstVMs.GetNodeData(firstNode);
                     secData := vstVMs.GetNodeData(secNode);
                     tempData^ := firstData^;
                     firstData^ := secData^;
                     secData^ := tempData^;
                     tempData^.FId := firstData^.FId;
                     firstData^.FId := secData^.FId;
                     secData^.FId := tempData^.FId;
                     Changed := True;
                     WasSorted := True;
                  end;
               0, -1:
            end;
         end;
      until not Changed;
      vstVMs.DeleteNode(tempNode);
      if WasSorted then
      begin
         Node := vstVMs.GetFirst;
         while Node <> nil do
         begin
            tempData := vstVMs.GetNodeData(Node);
            with tempData^ do
            begin
               if FirstDriveName = '' then
                  FFDImageIndex := -1
               else if FirstDriveFound then
               begin
                  if ListOnlyUSBDrives then
                  begin
                     if FirstDriveBusType = 7 then
                        FFDImageIndex := 2
                     else
                        FFDImageIndex := 3;
                  end
                  else
                     case FirstDriveBusType of
                        1:
                           FFDImageIndex := 10;
                        4:
                           FFDImageIndex := 12;
                        7:
                           FFDImageIndex := 4;
                        8: FFDImageIndex := 14;
                        14, 15:
                           FFDImageIndex := 8;
                        else
                           FFDImageIndex := 6;
                     end;
               end
               else if ListOnlyUSBDrives then
                  FFDImageIndex := 3
               else
                  case FirstDriveBusType of
                     1:
                        FFDImageIndex := 11;
                     4:
                        FFDImageIndex := 13;
                     7:
                        FFDImageIndex := 5;
                     8: FFDImageIndex := 15;
                     14, 15:
                        FFDImageIndex := 9;
                     else
                        FFDImageIndex := 7;
                  end;

               if SecondDriveName = '' then
                  FSDImageIndex := -1
               else if SecondDriveFound then
               begin
                  if ListOnlyUSBDrives then
                  begin
                     if SecondDriveBusType = 7 then
                        FSDImageIndex := 2
                     else
                        FSDImageIndex := 3;
                  end
                  else
                     case SecondDriveBusType of
                        1:
                           FSDImageIndex := 10;
                        4:
                           FSDImageIndex := 12;
                        7:
                           FSDImageIndex := 4;
                        8: FSDImageIndex := 14;
                        14, 15:
                           FSDImageIndex := 8;
                        else
                           FSDImageIndex := 6;
                     end;
               end
               else if ListOnlyUSBDrives then
                  FSDImageIndex := 3
               else
                  case SecondDriveBusType of
                     1:
                        FSDImageIndex := 11;
                     4:
                        FSDImageIndex := 13;
                     7:
                        FSDImageIndex := 5;
                     8: FSDImageIndex := 15;
                     14, 15:
                        FSDImageIndex := 9;
                     else
                        FSDImageIndex := 7;
                  end;
            end;

            Node := frmMain.vstVMs.GetNext(Node);
         end;
      end;
   except
   end;
   vstVMs.EndUpdate;
   if p > -1 then
   begin
      Node := vstVMs.GetFirst;
      while Node <> nil do
      begin
         tempData := vstVMs.GetNodeData(Node);
         if (vstVMs.RootNodeCount < 10) or (Node.Index > 8) then
            tempData^.FId := IntToStr(Node.Index + 1)
         else
            tempData^.FId := '0' + IntToStr(Node.Index + 1);
         if Integer(Node.Index) = p then
         begin
            vstVMs.Selected[Node] := True;
            vstVMs.FocusedNode := Node;
            vstVMs.ScrollIntoView(Node, False);
            Break;
         end;
         Node := vstVMs.GetNext(Node);
      end;
   end;
   if WasSorted then
   begin
      vstVMs.Invalidate;
      SaveVMentries(VMentriesFile);
   end;
end;

procedure TfrmMain.tmAnimationTimer(Sender: TObject);
var
   R: TRect;
begin
   if ShowVMAnim and (coVisible in vstVMs.Header.Columns[1].Options) then
   begin
      Inc(VMAnimImageIndex);
      if VMAnimImageIndex > AnimationEndIndex then
         VMAnimImageIndex := AnimationStartIndex;
      R := vstVMs.GetDisplayRect(vstVMs.GetFirstSelected, 1, False, False, False);
      R.Left := R.Left + vstVMs.Margin - 1;
      R.Right := R.Left + imlVST_items.Width;
      if Visible then
         InvalidateRect(vstVms.Handle, &R, False);
   end;
   if ShowFirstDriveAnim and (coVisible in vstVMs.Header.Columns[2].Options) then
   begin
      Inc(FirstDriveAnimImageIndex);
      if FirstDriveAnimImageIndex > AnimationEndIndex then
         FirstDriveAnimImageIndex := AnimationStartIndex;
      R := vstVMs.GetDisplayRect(vstVMs.GetFirstSelected, 2, False, False, False);
      R.Left := R.Left + vstVMs.Margin - 1;
      R.Right := R.Left + imlVST_items.Width;
      if Visible then
         InvalidateRect(vstVms.Handle, &R, False);
   end;
   if ShowSecDriveAnim and (coVisible in vstVMs.Header.Columns[3].Options) then
   begin
      Inc(SecDriveAnimImageIndex);
      if SecDriveAnimImageIndex > AnimationEndIndex then
         SecDriveAnimImageIndex := AnimationStartIndex;
      R := vstVMs.GetDisplayRect(vstVMs.GetFirstSelected, 3, False, False, False);
      R.Left := R.Left + vstVMs.Margin - 1;
      R.Right := R.Left + imlVST_items.Width;
      if Visible then
         InvalidateRect(vstVms.Handle, &R, False);
   end;
end;

procedure TfrmMain.tmCheckCTRLTimer(Sender: TObject);
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
   begin
      tmCheckCTRL.Enabled := False;
      Exit;
   end;
   if GetKeyState(VK_CONTROL) >= 0 then
   begin
      tmCheckCTRL.Enabled := False;
      case btnStart.PngImage.Width of
         16:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn16.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn16.PngImages[0].PngImage;
            end;
         20:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn20.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn20.PngImages[0].PngImage;
            end;
         24:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn24.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn24.PngImages[0].PngImage;
            end;
      end;
   end;
end;

procedure TfrmMain.tmCloseHintTimer(Sender: TObject);
begin
   tmCloseHint.Enabled := False;
   TrayIcon.BalloonHint := '';
end;

procedure TfrmMain.TrayIconBalloonClick(Sender: TObject);
begin
   tmCloseHintTimer(Self);
end;

procedure TfrmMain.TrayIconMouseDown(Sender: TObject; Button: TMouseButton;
   Shift: TShiftState; X, Y: Integer);
var
   dt: Cardinal;
begin
   if (Button = mbLeft) and (Shift = [ssLeft]) then
   begin
      if IsIconic(Application.Handle) then
      begin
         SendMessage(Application.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
         dt := GetTickCount;
         while isIconic(Application.Handle) do
         begin
            mEvent.WaitFor(1);
            Application.ProcessMessages;
            if (GetTickCount - dt) > 3000 then
               Break;
         end;
         if isOnModal then
            SetForegroundWindow(Application.Handle)
         else
            SetForegroundWindow(Handle);
      end
      else if not Showing then
         Show
      else if isOnModal then
         SetForegroundWindow(Application.Handle)
      else
         SetForegroundWindow(Handle);
   end;
end;

procedure TfrmMain.vstVMsBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
var
   r: TRect;
begin
   if vstVMs.RootNodeCount < 5 then
      Exit;
   if (Node = Sender.FocusedNode) and (not isBusyStartVm) and (not isBusyManager) and (not IsBusyEjecting) then
      Exit;
   if (not (isBusyStartVM or IsBusyManager or IsBusyEjecting)) and (vsSelected in Node.States) then
      Exit
   else if (isBusyStartVm or IsBusyManager or IsBusyEjecting) and (Node.Index = CurSelNode) then
      Exit;
   if Node.Index mod 2 = 0 then
      TargetCanvas.Brush.Color := DarkenBckColor
   else
      TargetCanvas.Brush.Color := BrightenBckColor;
   IntersectRect(r, CellRect, vstVMs.ClientRect);
   TargetCanvas.FillRect(r);
end;

procedure TfrmMain.vstVMsBeforeColumnWidthTracking(Sender: TVTHeader; Column: TColumnIndex; Shift: TShiftState);
begin
   if Column = Sender.Columns.GetLastVisibleColumn then
      Exit;
   if Column = 0 then
      Exit;
   if Sender.Columns.TotalWidth <> vstVMS.ClientWidth then
      Exit;
   if not (hoAutoResize in vstVMs.Header.Options) then
      vstVMs.Header.Options := vstVMs.Header.Options + [hoAutoResize];
   vstVMS.Header.AutoSizeIndex := Column;
   DoNothingOnScrollBarShow := True;
   vstVMs.ScrollBarOptions.ScrollBars := ssVertical;
   DoNothingOnScrollBarShow := False;
   DoColumnShift := True;
end;

procedure TfrmMain.vstVMsBeforeItemErase(Sender: TBaseVirtualTree;
   TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
   var ItemColor: TColor; var EraseAction: TItemEraseAction);
begin
   if vstVMs.RootNodeCount < 5 then
      Exit;
   if (Node = Sender.FocusedNode) and (not (isBusyStartVM or IsBusyManager or IsBusyEjecting)) then
      Exit;
   if (not (isBusyStartVM or IsBusyManager or IsBusyEjecting)) and (vsSelected in Node.States) then
      Exit
   else if (isBusyStartVM or IsBusyManager or IsBusyEjecting) and (Node.Index = CurSelNode) then
      Exit;
   EraseAction := eaNone;
end;

procedure TfrmMain.vstVMsColumnResize(Sender: TVTHeader; Column: TColumnIndex);
var
   DiffWidth, ColTotalWidth: Integer;
begin
   if DoColumnShift then
      Exit;
   ColTotalWidth := Sender.Columns.TotalWidth;
   ColumnResized := True;
   if ColTotalWidth = vstVMs.ClientWidth then
      Exit;
   DiffWidth := vstVMs.ClientWidth - ColTotalWidth;
   if Abs(DiffWidth) > SnapResize then
      Exit;
   Sender.Columns[Column].Width := Sender.Columns[Column].Width + DiffWidth;
end;

procedure TfrmMain.vstVMsContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
   Node: PVirtualNode;
   p: TPoint;
   R: TRect;
   lvc: Integer;
   Data: PData;
   strTemp: string;
   i: Integer;
   AreaClicked: Byte;
   mmOpen: TMenuItem;
begin
   Handled := True;
   for i := pmVMs.Items.Count - 1 downto 0 do
      if System.Pos('OpenInExplorer', pmVMs.Items[i].Name) = 1 then
      begin
         mmOpen := pmVMs.Items[i];
         mmOPen.Free;
      end;
   mmEject.Visible := False;
   if (MousePos.X = -1) and (MousePos.Y = -1) and (vstVMs.GetFirstSelected <> nil) then
   begin
      R := vstVMs.GetDisplayRect(vstVMs.GetFirstSelected, -1, False, False, False);
      MousePos.X := R.Left + R.Width div 2;
      MousePos.Y := R.Top + R.Height div 2;
   end;
   p := vstVMs.ClientToScreen(MousePos);
   if PtInRect(vstVMs.ClientRect, MousePos) then
   begin
      try
         Node := vstVMs.GetNodeAt(MousePos.X, MousePos.Y);
         lvc := vstVMs.Header.Columns.GetLastVisibleColumn;
         if (Node <> nil) and (lvc > -1) and (vstVMs.Header.Columns[lvc].GetRect.Right >= MousePos.X) then
         begin
            if vstVMs.GetFirstSelected <> Node then
            begin
               vstVMs.Selected[Node] := True;
               vstVMs.FocusedNode := Node;
            end;
            if mmEditH.Enabled then
            begin
               mmEditH.Enabled := False;
               mmEdit.ShortCut := mmEditH.ShortCut;
               mmEditH.ShortCut := 0;
               mmEdit.Enabled := True;
            end;
            if mmCloneH.Enabled then
            begin
               mmCloneH.Enabled := False;
               mmClone.Enabled := True;
            end;
            if mmDeleteH.Enabled then
            begin
               mmDelete.ShortCut := mmDeleteH.ShortCut;
               mmDeleteH.Enabled := False;
               mmDeleteH.ShortCut := 0;
               mmDelete.Enabled := True;
            end;
            if mmMoveUpH.Enabled then
            begin
               mmMoveUpH.Enabled := False;
               mmMoveUp.ShortCut := mmMoveUpH.ShortCut;
               mmMoveUpH.ShortCut := 0;
               mmMoveUp.Enabled := True;
            end;
            if mmMoveDownH.Enabled then
            begin
               mmMoveDown.ShortCut := mmMoveDownH.ShortCut;
               mmMoveDownH.Enabled := False;
               mmMoveDownH.ShortCut := 0;
               mmMoveDown.Enabled := True;
            end;
         end
         else
         begin
            if mmEdit.Enabled then
            begin
               mmEdit.Enabled := False;
               mmEditH.ShortCut := mmEdit.ShortCut;
               mmEdit.ShortCut := 0;
               mmEditH.Enabled := True;
            end;
            if mmClone.Enabled then
            begin
               mmClone.Enabled := False;
               mmCloneH.Enabled := True;
            end;
            if mmDelete.Enabled then
            begin
               mmDeleteH.ShortCut := mmDelete.ShortCut;
               mmDelete.Enabled := False;
               mmDelete.ShortCut := 0;
               mmDeleteH.Enabled := True;
            end;
            if mmMoveUp.Enabled then
            begin
               mmMoveUp.Enabled := False;
               mmMoveUpH.ShortCut := mmMoveUp.ShortCut;
               mmMoveUp.ShortCut := 0;
               mmMoveUpH.Enabled := True;
            end;
            if mmMoveDown.Enabled then
            begin
               mmMoveDownH.ShortCut := mmMoveDown.ShortCut;
               mmMoveDown.Enabled := False;
               mmMoveDown.ShortCut := 0;
               mmMoveDownH.Enabled := True;
            end;
         end;
      except
         if mmEdit.Enabled then
         begin
            mmEdit.Enabled := False;
            mmEditH.ShortCut := mmEdit.ShortCut;
            mmEdit.ShortCut := 0;
            mmEditH.Enabled := True;
         end;
         if mmClone.Enabled then
         begin
            mmClone.Enabled := False;
            mmCloneH.Enabled := True;
         end;
         if mmDelete.Enabled then
         begin
            mmDeleteH.ShortCut := mmDelete.ShortCut;
            mmDelete.Enabled := False;
            mmDelete.ShortCut := 0;
            mmDeleteH.Enabled := True;
         end;
         if mmMoveUp.Enabled then
         begin
            mmMoveUp.Enabled := False;
            mmMoveUpH.ShortCut := mmMoveUp.ShortCut;
            mmMoveUp.ShortCut := 0;
            mmMoveUpH.Enabled := True;
         end;
         if mmMoveDown.Enabled then
         begin
            mmMoveDownH.ShortCut := mmMoveDown.ShortCut;
            mmMoveDown.Enabled := False;
            mmMoveDown.ShortCut := 0;
            mmMoveDownH.Enabled := True;
         end;
      end;
      AreaClicked := 0;
      if vstVMs.GetFirstSelected <> nil then
         if vstVMs.GetNodeAt(MousePos) = vstVMs.GetFirstSelected then
         begin
            i := 0;
            while i < vstVMs.Header.Columns.Count do
            begin
               if coVisible in vstVMs.Header.Columns[i].Options then
                  if (MousePos.X >= vstVMs.Header.Columns[i].GetRect.Left) and (MousePos.X <= vstVMs.Header.Columns[i].GetRect.Right) then
                  begin
                     case i of
                        2: AreaClicked := 1;
                        3: AreaClicked := 2;
                     end;
                     Break;
                  end;
               Inc(i);
            end;
         end;
      if AreaClicked > 0 then
      begin
         for i := pmVMs.Items.Count - 1 downto 0 do
            if System.Pos('OpenInExplorer', pmVMs.Items[i].Name) = 1 then
            begin
               mmOpen := pmVMs.Items[i];
               mmOPen.Free;
            end;
         strTemp := GetLangTextDef(idxMain, ['List', 'Menu', 'FileExplorer'], 'Open %s in Explorer');
         Data := vstVMs.GetNodeData(vstVMs.GetFirstSelected);
         SetLength(PathsToOpen, 0);
         if AddSecondDrive then
            if AreaClicked = 2 then
               if Data^.SecondDriveFound then
               begin
                  for i := High(Data^.SDMountPointsArr) downto 0 do
                  begin
                     SetLength(PathsToOpen, Length(PathsToOpen) + 1);
                     PathsToOpen[High(PathsToOpen)] := Data^.SDMountPointsArr[i];
                  end;
                  if (Data^.SecondDriveNumber > -1) and (not IsBusyEjecting) then
                  begin
                     mmEject.Visible := True;
                     mmEject.Tag := 256 + Data^.SecondDriveNumber;
                  end;
               end;
         if AreaClicked = 1 then
            if Data^.FirstDriveFound then
            begin
               for i := High(Data^.FDMountPointsArr) downto 0 do
               begin
                  SetLength(PathsToOpen, Length(PathsToOpen) + 1);
                  PathsToOpen[High(PathsToOpen)] := Data^.FDMountPointsArr[i];
               end;
               if (Data^.FirstDriveNumber > -1) and (not IsBusyEjecting) then
               begin
                  mmEject.Visible := True;
                  mmEject.Tag := Data^.FirstDriveNumber;
               end;
            end;
         for i := 0 to High(PathsToOpen) do
         begin
            mmOpen := TMenuItem.Create(pmVMs);
            try
               mmOpen.Name := 'OpenInExplorer' + IntToStr(i);
            except
               mmOpen.Name := 'OpenInExplorer ' + IntToStr(i);
            end;
            if Length(PathsToOpen[i]) = 2 then
            begin
               mmOpen.Caption := Format(strTemp, ['''' + PathsToOpen[i] + '''']);
               mmOpen.ShortCut := ShortCut(Word(PathsToOpen[i][1]), [ssAlt]);
               PathsToOpen[i] := PathsToOpen[i] + '\';
            end
            else
               mmOpen.Caption := Format(strTemp, ['''' + PathsToOpen[i] + '''']);
            mmOpen.OnClick := mmOpenInEXplorerClick;
            mmOpen.ImageIndex := 11;
            pmVMs.Items.Insert(4, mmOpen);
         end;
      end;
      pmVMs.Popup(p.X, p.Y);
   end
   else if (MousePos.X = -1) and (MousePos.Y = -1) then
   begin
      if mmEdit.Enabled then
      begin
         mmEdit.Enabled := False;
         mmEditH.ShortCut := mmEdit.ShortCut;
         mmEdit.ShortCut := 0;
         mmEditH.Enabled := True;
      end;
      if mmClone.Enabled then
      begin
         mmClone.Enabled := False;
         mmCloneH.ShortCut := mmEdit.ShortCut;
         mmClone.ShortCut := 0;
         mmCloneH.Enabled := True;
      end;
      if mmDelete.Enabled then
      begin
         mmDeleteH.ShortCut := mmDelete.ShortCut;
         mmDelete.Enabled := False;
         mmDelete.ShortCut := 0;
         mmDeleteH.Enabled := True;
      end;
      if mmMoveUp.Enabled then
      begin
         mmMoveUp.Enabled := False;
         mmMoveUpH.ShortCut := mmMoveUp.ShortCut;
         mmMoveUp.ShortCut := 0;
         mmMoveUpH.Enabled := True;
      end;
      if mmMoveDown.Enabled then
      begin
         mmMoveDownH.ShortCut := mmMoveDown.ShortCut;
         mmMoveDown.Enabled := False;
         mmMoveDown.ShortCut := 0;
         mmMoveDownH.Enabled := True;
      end;
      p := Point(vstVMs.ClientOrigin.X + vstVMs.ClientWidth div 2, vstVMs.ClientOrigin.Y + vstVMs.ClientHeight div 2);
      pmVMs.Popup(p.X, p.Y);
   end;
end;

procedure TfrmMain.ModEnd(Sender: TObject);
begin
   try
      if not Showing then
         Exit;
      if not (toHideFocusRect in vstVMs.TreeOptions.PaintOptions) then
         vstVMs.TreeOptions.PaintOptions := vstVMs.TreeOptions.PaintOptions + [toHideFocusRect];
      vstVMs.Invalidate;
      Application.OnActivate := AppAct;
      Application.OnDeactivate := AppDeact;
   finally
      isOnModal := False;
   end;
end;

procedure TfrmMain.ModBeg(Sender: TObject);
begin
   isOnModal := True;
   if not Showing then
      Exit;
   if vstVMs.GetFirstSelected <> nil then
      vstVMs.FocusedNode := vstVMs.GetFirstSelected;
   if toHideFocusRect in vstVMs.TreeOptions.PaintOptions then
      vstVMs.TreeOptions.PaintOptions := vstVMs.TreeOptions.PaintOptions - [toHideFocusRect];
   vstVMs.Invalidate;
   Application.OnActivate := nil;
   Application.OnDeactivate := nil;
end;

procedure TfrmMain.AppAct(Sender: TObject);
begin
   if not Showing then
      Exit;
   if not (toHideFocusRect in vstVMs.TreeOptions.PaintOptions) then
      vstVMs.TreeOptions.PaintOptions := vstVMs.TreeOptions.PaintOptions + [toHideFocusRect];
   vstVMs.Invalidate;
   inherited;
end;

procedure TfrmMain.AppDeact(Sender: TObject);
begin
   if not Showing then
      Exit;
   if vstVMs.GetFirstSelected <> nil then
      vstVMs.FocusedNode := vstVMs.GetFirstSelected;
   if toHideFocusRect in vstVMs.TreeOptions.PaintOptions then
      vstVMs.TreeOptions.PaintOptions := vstVMs.TreeOptions.PaintOptions - [toHideFocusRect];
   vstVMs.Invalidate;
   inherited;
end;

procedure TfrmMain.mmCloneClick(Sender: TObject);
var
   SelNode, ClNode: PVirtualNode;
   SelData, ClData: PData;
   DoAlign: Boolean;
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;
   if (vstVMs.RootNodeCount = 0) or (vstVMs.GetFirstSelected = nil) or (vstVMs.GetFirstSelected.Index >= vstVMs.RootNodeCount) then
      Exit;
   ColWereAligned := vstVMs.Header.Columns.TotalWidth = vstVMs.ClientWidth;
   DoAlign := False;
   SelNode := vstVMs.GetFirstSelected;
   SelData := vstVMs.GetNodeData(SelNode);
   vstVMs.BeginUpdate;
   ClNode := vstVMs.InsertNode(SelNode, amInsertAfter);
   ClData := vstVMs.GetNodeData(ClNode);
   ClData^.FVMImageIndex := SelDatA^.FVMImageIndex;
   ClData^.FVName := SelDatA^.FVName;
   ClData^.FDDisplayName := SelDatA^.FDDisplayName;
   ClData^.SDDisplayName := SelDatA^.SDDisplayName;
   ClData^.FFDImageIndex := SelDatA^.FFDImageIndex;
   ClData^.FSDImageIndex := SelDatA^.FSDImageIndex;
   ClData^.Ptype := SelDatA^.Ptype;
   ClData^.ModeLoadVM := SelDatA^.ModeLoadVM;
   ClData^.VMID := SelDatA^.VMID;
   ClData^.VMName := SelDatA^.VMName;
   ClData^.VMPath := SelDatA^.VMPath;
   ClData^.ExeParams := SelDatA^.ExeParams;
   ClData^.FirstDriveName := SelDatA^.FirstDriveName;
   ClData^.FirstDriveFound := SelDatA^.FirstDriveFound;
   ClData^.FirstDriveNumber := SelDatA^.FirstDriveNumber;
   ClData^.FDMountPointsStr := SelDatA^.FDMountPointsStr;
   ClData^.FDMountPointsArr := Copy(SelData^.FDMountPointsArr);
   ClData^.FirstDriveBusType := SelDatA^.FirstDriveBusType;
   ClData^.SecondDriveName := SelDatA^.SecondDriveName;
   ClData^.SecondDriveFound := SelDatA^.SecondDriveFound;
   ClData^.SecondDriveNumber := SelDatA^.SecondDriveNumber;
   ClData^.SDMountPointsArr := Copy(SelData^.SDMountPointsArr);
   ClData^.SDMountPointsStr := SelDatA^.SDMountPointsStr;
   ClData^.SecondDriveBusType := SelDatA^.SecondDriveBusType;
   ClData^.InternalHDD := SelDatA^.InternalHDD;
   ClData^.CDROMName := SelDatA^.CDROMName;
   ClData^.CDROMType := SelDatA^.CDROMType;
   ClData^.MemorySize := SelDatA^.MemorySize;
   ClData^.AudioCard := SelDatA^.AudioCard;
   ClData^.RunAs := SelDatA^.RunAs;
   ClData^.CPUPriority := SelDatA^.CPUPriority;
   ClData^.luIDS := SelDatA^.luIDS;
   ClData^.VBCPUVirtualization := SelDatA^.VBCPUVirtualization;
   vstVMs.Selected[ClNode] := True;
   vstVMs.FocusedNode := ClNode;
   vstVMs.ScrollIntoView(ClNode, False);
   if Length(IntToStr(vstVMs.RootNodeCount - 1)) <> Length(IntToStr(vstVMs.RootNodeCount)) then
   begin
      DoAlign := ColWereAligned;
      mmCrt.Tag := Max(vstVMs.Header.Height, Round(2 * vstVMs.Margin + 2 + vstVMs.Canvas.TextWidth('H') * (0.5 + Length(IntToStr(vstVMs.RootNodeCount)))));
      vstVMs.Header.Columns[0].MaxWidth := mmCrt.Tag;
      vstVMs.Header.Columns[0].MinWidth := mmCrt.Tag;
      vstVMs.Header.Columns[0].MaxWidth := mmCrt.Tag;
      vstVMs.Header.Columns[0].Width := mmCrt.Tag;
      SelNode := vstVMs.GetFirst;
   end
   else
      SelNode := ClNode;
   while SelNode <> nil do
   begin
      SelData := vstVMs.GetNodeData(SelNode);
      if (vstVMs.RootNodeCount < 10) or (SelNode.Index > 8) then
         SelData^.FId := IntToStr(SelNode.Index + 1)
      else
         SelData^.FId := '0' + IntToStr(SelNode.Index + 1);
      SelNode := vstVMs.GetNext(SelNode);
   end;
   if DoAlign then
      RealignColumns(False);
   vstVMs.EndUpdate; //
   vstVMs.Invalidate;
   SaveVMentries(VMentriesFile);
end;

procedure TfrmMain.mmDownClick(Sender: TObject);
var
   Node: PVirtualNode;
   SelectedIndex: Integer;
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;
   if vstVMs.RootNodeCount = 0 then
      Exit;
   if (vstVMs.GetFirstSelected <> nil) and (vstVMs.GetFirstSelected.Index < (vstVMs.RootNodeCount - 1)) then
      SelectedIndex := vstVMs.GetFirstSelected.Index + 1
   else
      SelectedIndex := 0;
   Node := vstVMs.GetFirst;
   while Node <> nil do
   begin
      if Integer(Node.Index) = SelectedIndex then
      begin
         vstVMs.Selected[Node] := True;
         vstVMs.FocusedNode := Node;
         vstVMs.ScrollIntoView(Node, False);
         Break;
      end;
      Node := vstVMs.GetNext(Node);
   end;
end;

procedure TfrmMain.mmUpClick(Sender: TObject);
var
   Node: PVirtualNode;
   SelectedIndex: Integer;
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;
   if vstVMs.RootNodeCount = 0 then
      Exit;
   if (vstVMs.GetFirstSelected <> nil) and (vstVMs.GetFirstSelected.Index > 0) then
      SelectedIndex := vstVMs.GetFirstSelected.Index - 1
   else
      SelectedIndex := vstVMs.RootNodeCount - 1;
   Node := vstVMs.GetFirst;
   while Node <> nil do
   begin
      if Integer(Node.Index) = SelectedIndex then
      begin
         vstVMs.Selected[Node] := True;
         vstVMs.FocusedNode := Node;
         vstVMs.ScrollIntoView(Node, False);
         Break;
      end;
      Node := vstVMs.GetNext(Node);
   end;
end;

procedure TfrmMain.mmEjectClick(Sender: TObject);
var
   DevInst: MainForm.DEVINST;
   strMess: string;
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;
   try
      IsBusyEjecting := True;
      vstVMs.SelectionLocked := True;
      CurSelNode := vstVMs.GetFirstSelected.Index;
      tmCheckCTRL.Enabled := False;
      case btnStart.PngImage.Width of
         16:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn16.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn16.PngImages[0].PngImage;
            end;
         20:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn20.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn20.PngImages[0].PngImage;
            end;
         24:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn24.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn24.PngImages[0].PngImage;
            end;
      end;
      DevInst := GetDrivesDevInstByDeviceNumber(mmEject.Tag mod 256);
      if DevInst = 0 then
      begin
         if LastError > 0 then
            strMess := SysErrorMessage(LastError)
         else
         begin
            if LastExceptionStr <> '' then
               strMess := LastExceptionStr
            else
               strMess := '';
         end;
         strMess := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorGetInfEject'], [strMess], 'Could not retrieve the informations necessary to eject the drive !'#13#10#13#10'System message: %s');
         CustomMessageBox(Handle, strMess, GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOK], mbOK);
         Exit;
      end;
      FDevInstParent := 0;
      CM_Get_Parent(FDevInstParent, DevInst, 0);

      while True do
      begin
         if mmEject.Tag <= 255 then
            StartFirstDriveAnimation
         else
            StartSecDriveAnimation;
         mEvent.WaitFor(1);
         Application.ProcessMessages;
         EjectResult := False;
         FEjectJobDone := False;
         FEjectThread := TEjectThread.Create;
         while not FEjectJobDone do
         begin
            mEvent.WaitFor(1);
            Application.ProcessMessages;
            if Application.Terminated then
            begin
               FEjectThread.Terminate;
               FEjectThread.Free;
               FEjectThread := nil;
               Exit;
            end;
         end;
         FEjectThread.Free;
         FEjectThread := nil;
         if mmEject.Tag <= 255 then
            StopFirstDriveAnimation
         else
            StopSecDriveAnimation;
         Application.ProcessMessages;
         if Application.Terminated then
            Break;
         if EjectResult then
         begin
            if ((TOSVersion.Major = 6) and (TOSVersion.Minor >= 2)) or (TOSVersion.Major > 6) then
               PlaySound('Notification.Default', 0, SND_ASYNC)
            else
               PlaySound('SystemNotification', 0, SND_ASYNC);
            Break;
         end
         else if CustomMessageBox(Handle, GetLangTextDef(idxMain, ['Messages', 'ErrorEject'], 'Could not automatically eject the drive !'#13#10#13#10'Close the application(s) who access this drive and try again...'), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbAbort, mbRetry], mbAbort) <> mrRetry then
            Break;
      end;
   finally
      vstVMs.SelectionLocked := False;
      IsBusyEjecting := False;
   end;
end;

procedure TfrmMain.mmEnterClick(Sender: TObject);
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;
   if vstVMs.GetFirstSelected = nil then
      Exit;
   btnStart.Down := True;
   btnStart.Click;
end;

procedure TfrmMain.mmEscClick(Sender: TObject);
begin
   if TrayIcon.Visible then
   begin
      if not IsIconic(Application.Handle) then
         SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
   end
   else
      btnExit.Click;
end;

procedure TfrmMain.mmNumPlusClick(Sender: TObject);
begin
   btnAdd.Click;
end;

function enumResNamesProc(module: HMODULE; restype, resname: PChar): Integer; stdcall;
var
   rs: TResourceStream;
   ws: string;
   Obj: TMyObj;
begin
   rs := nil;
   try
      rs := TResourceStream.Create(0, resname, PChar('Languages'));
      frmOptions.xmlTemp.LoadFromStream(rs);
   except
   end;
   if rs <> nil then
   try
      rs.Free;
   except
   end;
   if frmOptions.xmlTemp.Active then
   begin
      try
         ws := frmOptions.xmlTemp.ChildNodes[idxInterface].ChildNodes.FindNode('Language').ChildNodes.FindNode('Name').Text + ', translated by ' + frmOptions.xmlTemp.ChildNodes[idxInterface].ChildNodes.FindNode('Language').ChildNodes.FindNode('Author').Text;
         if frmOptions.cmbLanguage.Items.IndexOf(ws) = -1 then
         begin
            Obj := TMyObj.Create();
            Obj.Text := string(resname);
            frmOptions.cmbLanguage.Items.AddObject(ws, Obj);
         end;
      finally
         frmOptions.xmlTemp.Active := False;
      end;
   end;
   Result := 1;
end;

function enumResTypesProc: Integer; stdcall;
begin
   EnumResourceNames(0, PChar('Languages'), @enumResNamesProc, 0);
   Result := 1;
end;

procedure TfrmMain.btnOptionsClick(Sender: TObject);
var
   i, l, btnMargin, btnSpacing, NrRes, indmin, cm, cvm, h, p, r: Integer;
   prc, prevprc: Double;
   ws, exeVBPathAbs, drvSysPath{$IFDEF WIN32}, exeDevConPath{$ENDIF}, strNetAdp, strNetBrdg1, strNetBrdg2, strNetBrdg3, curDir, exeRegSvr32Path, exeSnetCfgPath, strTemp: string;
   CommLine: TByteDynArray;
   Buffer: array[0..MAX_PATH] of Char;
   sr: TSearchRec;
   Obj: TMyObj;
   Node: PVirtualNode;
   Data: PData;
   diff: Double;
   Size: TSize;
   FontHeight, MaxBtnWidth, MaxBtnHeight, abl, CrtWidth: Integer;
   DoAlign: Boolean;
   PrevHalfSpaceChar: Char;
   ExitCode, dwTID: DWORD;
   hProcessDup, RemoteProcHandle: Cardinal;
   bDup: BOOL;
   dwCode: DWORD;
   hrt, wt: Cardinal;
   hKernel: HMODULE;
   FARPROC: Pointer;
   uExitCode: Cardinal;
   hFind: THandle;
   wfa: ^WIN32_FIND_DATAW;
   Path: array[0..MAX_PATH - 1] of Char;
   eStartupInfo: TStartupInfo;
   eProcessInfo: TProcessInformation;
   {$IFDEF WIN32}PexeDevCon, PexeDevConPath: PChar;
   {$ENDIF}
   PexeSnetCfgPath, PexeRegSvr32, PexeRegSvr32Path: PChar;
   dt: Cardinal;
   ssStatus: TServiceStatus;
   resCP, Result, DoNotRegister: Boolean;
   Key: Word;
   Modifiers: Uint;
begin
   if isBusyStartVM then
   begin
      (Sender as TPngSpeedButton).Down := False;
      btnStart.Down := True;
      Exit;
   end;
   if IsBusyManager then
   begin
      btnManager.Down := True;
      (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if IsBusyEjecting then
   begin
      if Sender is TPngSpeedButton then
         (Sender as TPngSpeedButton).Down := False;
      Exit;
   end;
   if (isVBPortable and ((not FRegJobDone)) or (not FUnregJobDone)) then
      Exit;
   btnOptions.Down := True;
   try
      try
         if frmOptions = nil then
            Application.CreateForm(TfrmOptions, frmOptions);
         with frmOptions do
         begin
            cbLock.Checked := LockVolumes;
            cbSecondDrive.Checked := AddSecondDrive;
            edtWaitTime.Text := IntToStr(FlushWaitTime);
            if DefaultVMType = 1 then
               sbQEMU.Click;
            cbListOnlyUSBDrives.Checked := ListOnlyUSBDrives;
            cbAutomaticFont.Checked := AutomaticFont;
            btnChooseFont.Enabled := not AutomaticFont;
            with fdListViewFont.Font do
            begin
               Name := string(FontName);
               Size := FontSize;
               Style := [];
               if FontBold then
                  Style := Style + [fsBold];
               if FontItalic then
                  Style := Style + [fsItalic];
               if FontUnderline then
                  Style := Style + [fsUnderline];
               if FontStrikeOut then
                  Style := Style + [fsStrikeOut];
               Color := FontColor;
               Charset := FontScript;
            end;
            hkStart.HotKey := StartKeyComb;
            UnregisterHotKey(frmMain.Handle, Hotkey_id);
            GlobalDeleteAtom(Hotkey_id);
            if FindFirst(LngFolder + '\*.lng', faAnyFile - faDirectory, sr) = 0 then
            begin
               repeat
                  try
                     frmOptions.xmlTemp.LoadFromFile(LngFolder + '\' + sr.Name);
                     if frmOptions.xmlTemp.Active then
                     begin
                        try
                           ws := frmOptions.xmlTemp.ChildNodes[idxInterface].ChildNodes.FindNode('Language').ChildNodes.FindNode('Name').Text + ', translated by ' + frmOptions.xmlTemp.ChildNodes[idxInterface].ChildNodes.FindNode('Language').ChildNodes.FindNode('Author').Text;
                           if frmOptions.cmbLanguage.Items.IndexOf(ws) = -1 then
                           begin
                              Obj := TMyObj.Create();
                              Obj.Text := sr.Name;
                              frmOptions.cmbLanguage.Items.AddObject(ws, Obj);
                           end;
                        except
                        end;
                        frmOptions.xmlTemp.Active := False;
                     end;
                  except
                  end;
               until FindNext(sr) <> 0;
               FindClose(sr);
            end;
            enumResTypesProc;
            frmOptions.cmbLanguage.ItemIndex := frmOptions.cmbLanguage.Items.IndexOf(xmlLanguage.ChildNodes[idxInterface].ChildNodes.FindNode('Language').ChildNodes.FindNode('Name').Text + ', translated by ' + xmlLanguage.ChildNodes[idxInterface].ChildNodes.FindNode('Language').ChildNodes.FindNode('Author').Text);
            edtVBExePath.Text := ExeVBPath;
            case UpdateVM of
               1:
                  begin
                     cbUseVboxmanage.Checked := True;
                     cbAutoDetect.Checked := False;
                  end;
               2:
                  begin
                     cbDirectly.Checked := True;
                     cbAutoDetect.Checked := False;
                  end;
            end;
            cbuseLoadedFromInstalled.Checked := useLoadedFromInstalled;
            cbLoadNetPortable.Enabled := not (isVBInstalledToo and FileExists(exeVBPathToo) and useLoadedFromInstalled);
            cbLoadUSBPortable.Enabled := not (isVBInstalledToo and FileExists(exeVBPathToo) and useLoadedFromInstalled);
            cbLoadNetPortable.Checked := LoadNetPortable;
            cbLoadUSBPortable.Checked := LoadUSBPortable;
            cbPrecacheVBFiles.Checked := PrecacheVBFiles;
            cbPrestartVBExeFiles.Checked := PrestartVBExeFiles;
            edtQExePath.Text := ExtractFilePath(ExeQPath);
            cbRemoveDrive.Checked := RemoveDrive;
            if DirectoryExists(edtQExePath.Text) then
            begin
               cmbExeVersion.Items.BeginUpdate;
               New(wfa);
               hFind := FindFirstFile(PChar(edtQExePath.Text + 'qemu*.exe'), wfa^);
               if hFind <> INVALID_HANDLE_VALUE then
               begin
                  repeat
                     if wfa.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
                        cmbExeVersion.Items.Append(wfa.cFileName);
                  until not Windows.FindNextFile(hFind, wfa^);
                  Windows.FindClose(hFind);
               end;
               if FileExists(ExeQPath) then
               begin
                  ws := ExtractFileName(ExeQPath);
                  i := cmbExeVersion.Items.IndexOf(ws);
                  if i > -1 then
                     cmbExeVersion.ItemIndex := i
                  else
                     cmbExeVersion.ItemIndex := -1;
               end
               else
                  cmbExeVersion.ItemIndex := -1;
               cmbExeVersion.Items.EndUpdate;
            end
            else
            begin
               cmbExeVersion.Items.Append(ExtractFileName(ExeQPath));
               cmbExeVersion.ItemIndex := 0;
            end;
            cbHideConsoleWindow.Checked := HideConsoleWindow;
            if EmulationBusType = 0 then
            begin
               rbIDE.Checked := True;
               rbSCSI.Checked := False;
            end
            else
            begin
               rbIDE.Checked := False;
               rbSCSI.Checked := True;
            end;
            edtDefaultParameters.Text := QEMUDefaultParameters;
            ColWereAligned := frmMain.vstVMs.Header.Columns.TotalWidth = frmMain.vstVMs.ClientWidth;
            NrRes := 0;
            for i := 1 to vstVMs.Header.Columns.Count - 1 do
               if coVisible in vstVMs.Header.Columns[i].Options then
                  Inc(NrRes);
            if not ColWereAligned then
               ColWereAligned := NrRes = 0;
            DoAlign := False;
            if ShowModal = mrOk then
            begin
               frmMain.Canvas.Font.Assign(frmMain.Font);
               vstVMs.BeginUpdate;
               vstVMs.Header.Columns.BeginUpdate;
               LockVolumes := cbLock.Checked;
               if AddSecondDrive <> cbSecondDrive.Checked then
               begin
                  if cbSecondDrive.Checked then
                  begin
                     if coVisible in vstVMs.Header.Columns[0].Options then
                        CrtWidth := vstVMs.Header.Columns[0].Width
                     else
                        CrtWidth := 0;
                     pmHeaders.Items[3].Visible := True;
                     pmHeaders.Items[3].Checked := True;
                     pmHeaders.Items[2].Caption := GetLangTextDef(idxMain, ['List', 'Header', 'FirstDrive'], 'First drive');
                     vstVMs.Header.Columns[2].Text := pmHeaders.Items[2].Caption;
                     pmHeaders.Items[3].Caption := GetLangTextDef(idxMain, ['List', 'Header', 'SecondDrive'], 'Second drive');
                     if not (coVisible in vstVMs.Header.Columns[3].Options) then
                        vstVMs.Header.Columns[3].Options := vstVMs.Header.Columns[3].Options + [coVisible];
                     vstVMs.Header.Columns[3].Text := pmHeaders.Items[3].Caption;
                     if ColWereAligned then
                     begin
                        if NrRes > 0 then
                           vstVMs.Header.Columns[3].Width := (vstVMs.Header.Columns.TotalWidth - CrtWidth) div NrRes
                        else
                           vstVMs.Header.Columns[3].Width := vstVMs.Header.Columns.TotalWidth - CrtWidth;
                     end
                     else
                        vstVMs.Header.Columns[3].Width := pmHeaders.Items[3].Tag;
                     if cbListOnlyUSBDrives.Checked = ListOnlyUSBDrives then
                        if cbListOnlyUSBDrives.Checked then
                           vstVMs.Header.Columns[3].ImageIndex := 1
                        else
                           vstVMs.Header.Columns[3].ImageIndex := 2;
                     Node := vstVMs.GetFirst;
                     while Node <> nil do
                     begin
                        Data := vstVMs.GetNodeData(Node);
                        Data^.FSDImageIndex := -1;
                        Node := vstVMs.GetNext(Node);
                     end;
                  end
                  else
                  begin
                     Node := vstVMs.GetFirst;
                     while Node <> nil do
                     begin
                        Data := vstVMs.GetNodeData(Node);
                        Data^.SecondDriveName := '';
                        Data^.SDDisplayName := '';
                        Data^.SDMountPointsStr := '';
                        SetLength(Data^.SDMountPointsArr, 0);
                        Data^.SecondDriveFound := False;
                        Node := vstVMs.GetNext(Node);
                     end;
                     SaveVMentries(VMentriesFile);
                     pmHeaders.Items[2].Caption := GetLangTextDef(idxMain, ['List', 'Header', 'Drive'], 'Drive');
                     vstVMs.Header.Columns[2].Text := pmHeaders.Items[2].Caption;
                     if coVisible in vstVMs.Header.Columns[3].Options then
                        vstVMs.Header.Columns[3].Options := vstVMs.Header.Columns[3].Options - [coVisible];
                     pmHeaders.Items[3].Visible := False;
                  end;
                  DoAlign := ColWereAligned;
               end;
               AddSecondDrive := cbSecondDrive.Checked;
               FlushWaitTime := Min(Max(StrToIntDef(Trim(edtWaitTime.Text), 500), 0), 20000);
               DefaultVMType := Integer(sbQEMU.Down);
               if cbListOnlyUSBDrives.Checked <> ListOnlyUSBDrives then
               begin
                  ListOnlyUSBDrives := cbListOnlyUSBDrives.Checked;
                  if ListOnlyUSBDrives then
                  begin
                     vstVMs.Header.Columns[2].ImageIndex := 1;
                     vstVMs.Header.Columns[3].ImageIndex := 1;
                  end
                  else
                  begin
                     vstVMs.Header.Columns[2].ImageIndex := 2;
                     vstVMs.Header.Columns[3].ImageIndex := 2;
                  end;
                  FindDrives;
                  Node := vstVMs.GetFirst;
                  while Node <> nil do
                  begin
                     Data := vstVMs.GetNodeData(Node);
                     with Data^ do
                     begin
                        if FirstDriveName = '' then
                           FFDImageIndex := -1
                        else if FirstDriveFound then
                        begin
                           if ListOnlyUSBDrives then
                           begin
                              if FirstDriveBusType = 7 then
                                 FFDImageIndex := 2
                              else
                                 FFDImageIndex := 3;
                           end
                           else
                              case FirstDriveBusType of
                                 1:
                                    FFDImageIndex := 10;
                                 4:
                                    FFDImageIndex := 12;
                                 7:
                                    FFDImageIndex := 4;
                                 8: FFDImageIndex := 14;
                                 14, 15:
                                    FFDImageIndex := 8;
                                 else
                                    FFDImageIndex := 6;
                              end;
                        end
                        else if ListOnlyUSBDrives then
                           FFDImageIndex := 3
                        else
                           case FirstDriveBusType of
                              1:
                                 FFDImageIndex := 11;
                              4:
                                 FFDImageIndex := 13;
                              7:
                                 FFDImageIndex := 5;
                              8: FFDImageIndex := 15;
                              14, 15:
                                 FFDImageIndex := 9;
                              else
                                 FFDImageIndex := 7;
                           end;

                        if SecondDriveName = '' then
                           FSDImageIndex := -1
                        else if SecondDriveFound then
                        begin
                           if ListOnlyUSBDrives then
                           begin
                              if SecondDriveBusType = 7 then
                                 FSDImageIndex := 2
                              else
                                 FSDImageIndex := 3;
                           end
                           else
                              case SecondDriveBusType of
                                 1:
                                    FSDImageIndex := 10;
                                 4:
                                    FSDImageIndex := 12;
                                 7:
                                    FSDImageIndex := 4;
                                 8: FSDImageIndex := 14;
                                 14, 15:
                                    FSDImageIndex := 8;
                                 else
                                    FSDImageIndex := 6;
                              end;
                        end
                        else if ListOnlyUSBDrives then
                           FSDImageIndex := 3
                        else
                           case SecondDriveBusType of
                              1:
                                 FSDImageIndex := 11;
                              4:
                                 FSDImageIndex := 13;
                              7:
                                 FSDImageIndex := 5;
                              8: FSDImageIndex := 15;
                              14, 15:
                                 FSDImageIndex := 9;
                              else
                                 FSDImageIndex := 7;
                           end;
                     end;
                     Node := vstVMs.GetNext(Node);
                  end;
               end;
               if (AutomaticFont <> cbAutomaticFont.Checked) or ((not cbAutomaticFont.Checked) and
                  ((FontName <> AnsiString(fdListViewFont.Font.Name)) or (FontSize <> fdListViewFont.Font.Size) or
                  (FontBold <> (fsBold in fdListViewFont.Font.Style)) or (FontItalic <> (fsItalic in fdListViewFont.Font.Style)) or
                  (FontUnderline <> (fsUnderline in fdListViewFont.Font.Style)) or (FontStrikeout <> (fsStrikeout in fdListViewFont.Font.Style)) or
                  (FontColor <> fdListViewFont.Font.Color) or (FontScript <> fdListViewFont.Font.Charset))) then
               begin
                  DoAlign := ColWereAligned;
                  AutomaticFont := cbAutomaticFont.Checked;
                  with fdListViewFont.Font do
                  begin
                     FontName := AnsiString(Name);
                     FontSize := Size;
                     FontBold := fsBold in Style;
                     FontItalic := fsItalic in Style;
                     FontUnderline := fsUnderline in Style;
                     FontStrikeOut := fsStrikeOut in Style;
                     FontColor := Color;
                     FontScript := Charset;
                  end;
                  with vstVMs.Font do
                  begin
                     if not AutomaticFont then
                     begin
                        Name := string(FontName);
                        Size := FontSize;
                        Style := [];
                        if FontBold then
                           Style := Style + [fsBold];
                        if FontItalic then
                           Style := Style + [fsItalic];
                        if FontUnderline then
                           Style := Style + [fsUnderline];
                        if FontStrikeOut then
                           Style := Style + [fsStrikeOut];
                        Color := FontColor;
                        Charset := FontScript;
                     end
                     else
                     begin
                        Name := string(DefaultFontName);
                        Size := DefaultFontSize;
                        Style := [];
                        if DefaultFontBold then
                           Style := Style + [fsBold];
                        if DefaultFontItalic then
                           Style := Style + [fsItalic];
                        if DefaultFontUnderline then
                           Style := Style + [fsUnderline];
                        if DefaultFontStrikeOut then
                           Style := Style + [fsStrikeOut];
                        Color := DefaultFontColor;
                        Charset := DefaultFontScript;
                     end;
                     vstVMs.Canvas.Font.Assign(vstVMs.Font);
                  end;
                  with vstVMs.Header.Font do
                  begin
                     if not AutomaticFont then
                     begin
                        Name := string(FontName);
                        if vstVMs.Font.Size <= 8 then
                           Size := 8
                        else
                           Size := Round(sqrt(vstVMs.Font.Size - 8) + 8);
                        Style := [];
                        if FontBold then
                           Style := Style + [fsBold];
                        if FontItalic then
                           Style := Style + [fsItalic];
                        if FontUnderline then
                           Style := Style + [fsUnderline];
                        if FontStrikeOut then
                           Style := Style + [fsStrikeOut];
                        Charset := FontScript;
                     end
                     else
                     begin
                        Name := string(DefaultFontName);
                        if DefaultFontSize <= 8 then
                           Size := 8
                        else
                           Size := Round(sqrt(DefaultFontSize - 8) + 8);
                        Style := [];
                        if DefaultFontBold then
                           Style := Style + [fsBold];
                        if DefaultFontItalic then
                           Style := Style + [fsItalic];
                        if DefaultFontUnderline then
                           Style := Style + [fsUnderline];
                        if DefaultFontStrikeOut then
                           Style := Style + [fsStrikeOut];
                        Charset := DefaultFontScript;
                     end;
                  end;
                  FontHeight := vstVMs.Canvas.TextHeight('Hg');
                  case FontHeight of
                     0..23:
                        begin
                           if imlVST_items.Width <> 24 then
                           begin
                              imlVST_items.BeginUpdate;
                              imlVST_items.SetSize(24, 24);
                              imlVST_items.PngImages.Assign(imlVST24.PngImages);
                              for i := 1 to 3 do
                                 imlVST_items.PngImages.Delete(0);
                              imlVST_items.EndUpdate(True);
                           end;
                           if btnStart.PngImage.Height <> 16 then
                           begin
                              btnStart.PngImage := imlBtn16.PngImages[0].PngImage;
                              btnAdd.PngImage := imlBtn16.PngImages[1].PngImage;
                              btnEdit.PngImage := imlBtn16.PngImages[2].PngImage;
                              btnDelete.PngImage := imlBtn16.PngImages[3].PngImage;
                              btnManager.PngImage := imlBtn16.PngImages[4].PngImage;
                              btnOptions.PngImage := imlBtn16.PngImages[5].PngImage;
                              btnShowTrayIcon.PngImage := imlBtn16.PngImages[6].PngImage;
                              btnExit.PngImage := imlBtn16.PngImages[7].PngImage;
                           end;
                           if imlVST_header.Width <> 16 then
                           begin
                              imlVST_header.BeginUpdate;
                              imlVST_header.SetSize(16, 16);
                              for i := 0 to 2 do
                                 imlVST_header.AddPng(imlVST16.PngImages[i].PngImage);
                              imlVST_header.EndUpdate(True);
                           end;
                        end;
                     24..32:
                        begin
                           if imlVST_items.Width <> 28 then
                           begin
                              imlVST_items.BeginUpdate;
                              imlVST_items.SetSize(28, 28);
                              imlVST_items.PngImages.Assign(imlVST28.PngImages);
                              for i := 1 to 3 do
                                 imlVST_items.PngImages.Delete(0);
                              imlVST_items.EndUpdate(True);
                           end;
                           if btnStart.PngImage.Height <> 20 then
                           begin
                              btnStart.PngImage := imlBtn20.PngImages[0].PngImage;
                              btnAdd.PngImage := imlBtn20.PngImages[1].PngImage;
                              btnEdit.PngImage := imlBtn20.PngImages[2].PngImage;
                              btnDelete.PngImage := imlBtn20.PngImages[3].PngImage;
                              btnManager.PngImage := imlBtn20.PngImages[4].PngImage;
                              btnOptions.PngImage := imlBtn20.PngImages[5].PngImage;
                              btnShowTrayIcon.PngImage := imlBtn20.PngImages[6].PngImage;
                              btnExit.PngImage := imlBtn20.PngImages[7].PngImage;
                           end;
                           if imlVST_header.Width <> 20 then
                           begin
                              imlVST_header.BeginUpdate;
                              imlVST_header.SetSize(20, 20);
                              for i := 0 to 2 do
                                 imlVST_header.AddPng(imlVST20.PngImages[i].PngImage);
                              imlVST_header.EndUpdate(True);
                           end;
                        end;
                     else
                        begin
                           if imlVST_items.Width <> 32 then
                           begin
                              imlVST_items.BeginUpdate;
                              imlVST_items.SetSize(32, 32);
                              imlVST_items.PngImages.Assign(imlVST32.PngImages);
                              for i := 1 to 3 do
                                 imlVST_items.PngImages.Delete(0);
                              imlVST_items.EndUpdate(True);
                           end;
                           if btnStart.PngImage.Height <> 24 then
                           begin
                              btnStart.PngImage := imlBtn24.PngImages[0].PngImage;
                              btnAdd.PngImage := imlBtn24.PngImages[1].PngImage;
                              btnEdit.PngImage := imlBtn24.PngImages[2].PngImage;
                              btnDelete.PngImage := imlBtn24.PngImages[3].PngImage;
                              btnManager.PngImage := imlBtn24.PngImages[4].PngImage;
                              btnOptions.PngImage := imlBtn24.PngImages[5].PngImage;
                              btnShowTrayIcon.PngImage := imlBtn24.PngImages[6].PngImage;
                              btnExit.PngImage := imlBtn24.PngImages[7].PngImage;
                           end;
                           if imlVST_header.Width <> 24 then
                           begin
                              imlVST_header.BeginUpdate;
                              imlVST_header.SetSize(24, 24);
                              for i := 0 to 2 do
                                 imlVST_header.AddPng(imlVST24.PngImages[i].PngImage);
                              imlVST_header.EndUpdate(True);
                           end;
                        end;
                  end;
                  vstVMs.DefaultNodeHeight := Round(1.1 * Max(imlVST_items.Height, FontHeight) + 1.6);
                  l := frmMain.Canvas.TextWidth('  ') div 2;
                  if l > 0 then
                  begin
                     PrevHalfSpaceChar := HalfSpaceCharVST;
                     frmMain.Canvas.Font.Assign(vstVMs.Font);
                     i := 8192;
                     l := Canvas.TextWidth('  ') div 2;
                     prevprc := 50;
                     indmin := -1;
                     while i <= 8202 do
                     begin
                        prc := 100.0 * (Canvas.TextWidth(Char(i) + Char(i)) - l) / l;
                        if prc < 0 then
                           prc := -0.75 * prc;
                        if prc < prevprc then
                        begin
                           prevprc := prc;
                           indmin := i;
                        end;
                        Inc(i);
                     end;
                     if indmin > -1 then
                        HalfSpaceCharVST := Char(indmin)
                     else
                        HalfSpaceCharVST := ' ';
                     if PrevHalfSpaceChar <> HalfSpaceCharVST then
                     begin
                        Node := vstVMs.GetFirst;
                        while Node <> nil do
                        begin
                           Data := vstVMs.GetNodeData(Node);
                           with Data^ do
                           begin
                              l := Length(FDDisplayName);
                              if l >= 3 then
                                 if FDDisplayName[l] = 'B' then
                                    if CharInSet(FDDisplayName[l - 1], ['G', 'M', 'T']) then
                                       if FDDisplayName[l - 2] = PrevHalfSpaceChar then
                                          FDDisplayName[l - 2] := HalfSpaceCharVST;
                              l := Length(SDDisplayName);
                              if l >= 3 then
                                 if SDDisplayName[l] = 'B' then
                                    if CharInSet(SDDisplayName[l - 1], ['G', 'M', 'T']) then
                                       if SDDisplayName[l - 2] = PrevHalfSpaceChar then
                                          SDDisplayName[l - 2] := HalfSpaceCharVST;
                              Node := vstVMs.GetNext(Node);
                           end;
                        end;
                     end;
                  end;
                  SetThemeDependantParams;
                  vstVMs.Canvas.Font.Assign(vstVMs.Header.Font);
                  FontHeight := vstVMs.Canvas.TextHeight('Hg');
                  vstVMs.Header.Height := Round(1.5 * Max(imlVST_header.Height, FontHeight));
                  vstVMs.Canvas.Font.Assign(vstVMs.Font);
                  vstVMs.Header.Columns[1].Margin := vstVMs.Margin + (imlVST_items.Width - imlVST_header.Width) div 2 - 1;
                  vstVMs.Header.Columns[1].Spacing := vstVMs.Margin + imlVST_items.Width - vstVMs.Header.Columns[1].Margin - imlVST_header.Width + 5;
                  vstVMs.Header.Columns[2].Margin := vstVMs.Margin + (imlVST_items.Width - imlVST_header.Width) div 2 - 1;
                  vstVMs.Header.Columns[2].Spacing := vstVMs.Margin + imlVST_items.Width - vstVMs.Header.Columns[2].Margin - imlVST_header.Width + 5;
                  vstVMs.Header.Columns[3].Margin := vstVMs.Margin + (imlVST_items.Width - imlVST_header.Width) div 2 - 1;
                  vstVMs.Header.Columns[3].Spacing := vstVMs.Margin + imlVST_items.Width - vstVMs.Header.Columns[3].Margin - imlVST_header.Width + 5;
                  vstVMs.Canvas.Font.Assign(vstVMs.Font);
                  if not (toVariableNodeHeight in vstVMs.TreeOptions.MiscOptions) then
                     vstVMs.TreeOptions.MiscOptions := vstVMs.TreeOptions.MiscOptions + [toVariableNodeHeight];
                  Node := vstVMs.GetFirst;
                  while Node <> nil do
                  begin
                     Exclude(Node.States, vsHeightMeasured);
                     vstVMs.MeasureItemHeight(vstVMs.Canvas, Node);
                     Node := vstVMs.GetNext(Node);
                  end;
                  if toVariableNodeHeight in vstVMs.TreeOptions.MiscOptions then
                     vstVMs.TreeOptions.MiscOptions := vstVMs.TreeOptions.MiscOptions - [toVariableNodeHeight];
                  mmCrt.Tag := Max(vstVMs.Header.Height, Round(2 * vstVMs.Margin + 2 + vstVMs.Canvas.TextWidth('H') * (0.5 + Length(IntToStr(vstVMs.RootNodeCount)))));
                  vstVMs.Header.Columns[0].MaxWidth := mmCrt.Tag;
                  vstVMs.Header.Columns[0].MinWidth := mmCrt.Tag;
                  vstVMs.Header.Columns[0].MaxWidth := mmCrt.Tag;
                  vstVMs.Header.Columns[0].Width := mmCrt.Tag;
                  if (btnStart.Font.Size <> vstVMs.Header.Font.Size) or (btnStart.PngImage.Width <> imlVST_header.Width) then
                  begin
                     MaxBtnWidth := 0;
                     MaxBtnHeight := 0;
                     for i := 0 to frmMain.ComponentCount - 1 do
                        if frmMain.Components[i].ClassNameIs('TPNGSpeedButton') then
                        begin
                           TPNGSpeedButton(frmMain.Components[i]).Font.Size := vstVMs.Header.Font.Size;
                           frmMain.Canvas.Font.Assign(TPNGSpeedButton(frmMain.Components[i]).Font);
                           GetTextExtentPoint32W(frmMain.Canvas.Handle, PWideChar(TPNGSpeedButton(frmMain.Components[i]).Caption), Length(TPNGSpeedButton(frmMain.Components[i]).Caption), Size);
                           MaxBtnWidth := Max(MaxBtnWidth, Size.Width);
                           MaxBtnHeight := Max(MaxBtnHeight, Size.Height);
                        end;
                     frmMain.Canvas.Font.Assign(frmMain.Font);
                     frmMain.btnExit.Tag := 7;
                     for i := 0 to frmMain.ComponentCount - 1 do
                        if frmMain.Components[i].ClassNameIs('TPNGSpeedButton') then
                        begin
                           case imlVST_header.Height of
                              16:
                                 begin
                                    if TPNGSpeedButton(frmMain.Components[i]).PngImage.Height <> 16 then
                                       TPNGSpeedButton(frmMain.Components[i]).PngImage := imlBtn16.PngImages[TPNGSpeedButton(frmMain.Components[i]).Tag].PngImage;
                                 end;
                              20:
                                 begin
                                    if TPNGSpeedButton(frmMain.Components[i]).PngImage.Height <> 20 then
                                       TPNGSpeedButton(frmMain.Components[i]).PngImage := imlBtn20.PngImages[TPNGSpeedButton(frmMain.Components[i]).Tag].PngImage;
                                 end;
                              24:
                                 begin
                                    if TPNGSpeedButton(frmMain.Components[i]).PngImage.Height <> 24 then
                                       TPNGSpeedButton(frmMain.Components[i]).PngImage := imlBtn24.PngImages[TPNGSpeedButton(frmMain.Components[i]).Tag].PngImage;
                                 end;
                           end;
                        end;
                     frmMain.btnExit.Tag := 6 + Integer(btnShowTrayIcon.Visible);
                     btnMargin := Round(sqrt(MaxBtnWidth)) + 5;
                     btnSpacing := Round(0.3 * (sqrt(MaxBtnWidth) + 5)) + 3;
                     MaxBtnWidth := 2 * btnStart.Margin + btnStart.PngImage.Width + btnStart.Spacing + MaxBtnWidth;
                     MaxBtnHeight := Max(btnStart.PngImage.Height, MaxBtnHeight) + 12;
                     abl := Round(frmMain.ClientWidth - 10 / 9 * MaxBtnWidth + frmMain.ClientOrigin.X - frmMain.Left - frmMain.Margins.Right);
                     vstVMs.Width := Round(frmMain.ClientWidth - 11 / 9 * MaxBtnWidth - vstVMs.Left + frmMain.ClientOrigin.X - frmMain.Left);
                     DoAlign := ColWereAligned;
                     diff := 1.0 / (6 + Integer(btnShowTrayIcon.Visible)) * (vstVMs.Height - MaxBtnHeight);
                     for i := 0 to frmMain.ComponentCount - 1 do
                        if frmMain.Components[i].ClassNameIs('TPNGSpeedButton') then
                           TPNGSpeedButton(frmMain.Components[i]).SetBounds(abl, Round(diff * TPNGSpeedButton(frmMain.Components[i]).Tag + btnStart.Top), MaxBtnWidth, MaxBtnHeight);
                     frmMain.vstVMsFocusChanged(nil, nil, 0);
                     frmMain.pnlBackground.Invalidate;
                  end;
               end;
               if not btnShowTrayIcon.Visible then
               begin
                  frmMain.Constraints.MinHeight := 2 * vstVMs.Top + 7 * (btnStart.Height + 1) + frmMain.Height - frmMain.ClientHeight;
                  frmMain.Constraints.MaxHeight := frmMain.Height - frmMain.ClientHeight + 2 * vstVms.Top + vstVMs.Height - vstVMs.ClientHeight + 11 * Integer(vstVMs.DefaultNodeHeight);
               end
               else
               begin
                  frmMain.Constraints.MinHeight := 2 * vstVMs.Top + 8 * (btnStart.Height + 1) + frmMain.Height - frmMain.ClientHeight;
                  frmMain.Constraints.MaxHeight := frmMain.Height - frmMain.ClientHeight + 2 * vstVms.Top + vstVMs.Height - vstVMs.ClientHeight + 12 * Integer(vstVMs.DefaultNodeHeight);
               end;
               if (CurrLanguageFile <> TMyObj(cmbLanguage.Items.Objects[cmbLanguage.ItemIndex]).Text) or ((xmlLanguage.ChildNodes[idxInterface].ChildNodes.FindNode('Language').ChildNodes.FindNode('Name').Text + ', translated by ' + xmlLanguage.ChildNodes[idxInterface].ChildNodes.FindNode('Language').ChildNodes.FindNode('Author').Text) <> cmbLanguage.Items[cmbLanguage.ItemIndex]) then
               begin
                  CurrLanguageFile := TMyObj(cmbLanguage.Items.Objects[cmbLanguage.ItemIndex]).Text;
                  ChangeCompLang;
               end;
               if LowerCase(ExeVBPath) = LowerCase(TRim(edtVBExePath.Text)) then
               begin
                  if isVBPortable and ((cbLoadNetPortable.Checked <> LoadNetPortable) or (cbLoadUSBPortable.Checked <> LoadUSBPortable) or (cbuseLoadedFromInstalled.Checked <> useLoadedFromInstalled)) then
                  begin
                     DoNotRegister := False;
                     while True do
                     begin
                        GetAllWindowsList(VBWinClass);
                        h := High(AllWindowsList);
                        i := 0;
                        cm := 0;
                        cvm := 0;
                        while i <= h do
                        begin
                           if IsWindowVisible(AllWindowsList[i].Handle) then
                           begin
                              p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
                              if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                 Inc(cm)
                              else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                 Inc(cvm);
                           end;
                           Inc(i);
                        end;
                        if (cm + cvm) > 0 then
                        begin
                           r := CustomMessageBox(frmMain.Handle, GetLangTextDef(idxMain, ['Messages', 'ProperRegUnreg'], 'In order to properly (un)register VirtualBox dlls, infs and services'#13#10'for the portable version, all the VirtualBox windows have to be closed!' +
                              #13#10#13#10'You can choose to Abort, close all VirtualBox windows manually and click on Retry,'#13#10'click on Ignore to not unregister or click on Close all to automatically close them'), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbAbort, mbRetry, mbIgnore, mbNoToAll], mbAbort);
                           case r of
                              mrRetry: Continue;
                              mrNoToAll:
                                 begin
                                    isBusyClosing := True;
                                    try
                                       GetAllWindowsList(VBWinClass);
                                       h := High(AllWindowsList);
                                       i := 0;
                                       cm := 0;
                                       cvm := 0;
                                       while i <= h do
                                       begin
                                          if IsWindowVisible(AllWindowsList[i].Handle) then
                                          begin
                                             p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
                                             if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                             begin
                                                PostMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
                                                Inc(cm);
                                             end
                                             else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                             begin
                                                PostMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
                                                Inc(cvm);
                                             end;
                                          end;
                                          Inc(i);
                                       end;
                                       if (cm + cvm) > 0 then
                                       begin
                                          dt := GetTickCount;
                                          wt := 2000 * cm + 5000 * cvm;
                                          while True do
                                          begin
                                             Wait(100);
                                             if (GetTickCount - dt) > wt then
                                                Break;
                                             GetAllWindowsList(VBWinClass);
                                             h := High(AllWindowsList);
                                             i := 0;
                                             cm := 0;
                                             cvm := 0;
                                             while i <= h do
                                             begin
                                                if IsWindowVisible(AllWindowsList[i].Handle) then
                                                begin
                                                   p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
                                                   if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                                      Inc(cm)
                                                   else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                                      Inc(cvm);
                                                end;
                                                Inc(i);
                                             end;
                                             if (cm + cvm) = 0 then
                                                Break;
                                          end;
                                       end;
                                    finally
                                       isBusyClosing := False;
                                    end;
                                 end;
                              mrIgnore: Break;
                              else
                                 DoNotRegister := True;
                                 Break;
                           end;
                        end;
                        if (cm + cvm) = 0 then
                           Break;
                     end;
                     if not DoNotRegister then
                     begin
                        GetSystemDirectory(Buffer, MAX_PATH - 1);
                        ResetLastError;
                        Result := True;
                        strRegErrMsg := '';
                        FillChar(eStartupInfo, SizeOf(eStartupInfo), #0);
                        eStartupInfo.dwFlags := STARTF_USESHOWWINDOW;
                        eStartupInfo.cb := SizeOf(eStartupInfo);
                        eStartupInfo.wShowWindow := SW_HIDE;
                        if TOSVersion.Major < 6 then
                        begin
                           strNetAdp := '';
                           strNetBrdg1 := 'Flt';
                           strNetBrdg2 := 'sun';
                           strNetBrdg3 := 'M';
                        end
                        else
                        begin
                           strNetAdp := '6';
                           strNetBrdg1 := 'Lwf';
                           strNetBrdg2 := 'oracle';
                           strNetBrdg3 := '';
                        end;
                        if PathIsRelative(PChar(ExeVBPath)) then
                        begin
                           FillMemory(@Path[0], Length(Path), 0);
                           PathCanonicalize(@Path[0], PChar(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + ExeVBPath));
                           if string(Path) <> '' then
                              exeVBPathAbs := Path
                           else
                              exeVBPathAbs := exeVBPath;
                        end
                        else
                           exeVBPathAbs := exeVBPath;
                        if cbuseLoadedFromInstalled.Checked <> useLoadedFromInstalled then
                        begin
                           if FRegThread <> nil then
                           begin
                              if not FRegJobDone then
                                 FRegThread.Terminate;
                              if FRegJobDone then
                              begin
                                 try
                                    FRegThread.Free;
                                    FRegThread := nil;
                                 except
                                 end;
                              end
                              else
                              try
                                 TerminateThread(FRegThread.Handle, 0);
                                 FRegThread := nil;
                              except
                              end;
                           end;
                           if FUnregThread <> nil then
                           begin
                              if not FUnregJobDone then
                                 FUnregThread.Terminate;
                              if FUnregJobDone then
                              begin
                                 try
                                    FUnregThread.Free;
                                    FUnregThread := nil;
                                 except
                                 end;
                              end
                              else
                              try
                                 TerminateThread(FRegThread.Handle, 0);
                                 FRegThread := nil;
                              except
                              end;
                           end;
                           ExeVBPathTemp := Trim(edtVBExePath.Text);
                           LoadNetPortableTemp := cbLoadNetPortable.Checked;
                           LoadUSBPortableTemp := cbLoadUSBPortable.Checked;
                           useLoadedFromInstalledTemp := cbuseLoadedFromInstalled.Checked;
                           ChangeFromTempToReal := True;
                           StartRegToo := True;
                           FUnregJobDone := False;
                           FUnregThread := TUnregisterThread.Create;
                        end
                        else
                        begin
                           if cbLoadNetPortable.Checked <> LoadNetPortable then
                           begin
                              if LoadNetPortable then
                              begin
                                 if CheckInstalledInf('sun_VBoxNetAdp') > 0 then
                                 begin
                                    {$IFDEF WIN32}
                                    if TOSversion.Architecture = arIntelX64 then
                                    begin
                                       exeDevConPath := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\devcon_x64.exe';
                                       try
                                          strTemp := '"' + exeDevConPath + '" remove "sun_VBoxNetAdp"';
                                          UniqueString(strTemp);
                                          PexeDevCon := PChar(strTemp);
                                          PexeDevConPath := PChar(ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\');
                                          ResetLastError;
                                          try
                                             Result := CreateProcess(nil, PexeDevCon, nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PexeDevConPath, eStartupInfo, eProcessInfo);
                                             LastError := GetLastError;
                                          except
                                             on E: Exception do
                                             begin
                                                Result := False;
                                                LastExceptionStr := E.Message;
                                             end;
                                          end;
                                          if Result then
                                          begin
                                             dt := GetTickCount;
                                             while (GetTickCount - dt) <= 3000 do
                                             begin
                                                if WaitForInputIdle(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                   Break;
                                             end;
                                             dt := GetTickCount;
                                             while (GetTickCount - dt) <= 5000 do
                                             begin
                                                if WaitForSingleObject(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                   Break;
                                             end;
                                             try
                                                GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                                if ExitCode = Still_Active then
                                                begin
                                                   uExitCode := 0;
                                                   RemoteProcHandle := GetProcessHandleFromID(eProcessInfo.dwProcessId);
                                                   bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
                                                   if GetExitCodeProcess(hProcessDup, dwCode) then
                                                   begin
                                                      hKernel := GetModuleHandle('Kernel32');
                                                      FARPROC := GetProcAddress(hKernel, 'ExitProcess');
                                                      hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
                                                      if hrt = 0 then
                                                         TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0)
                                                      else
                                                         CloseHandle(hRT);
                                                   end
                                                   else
                                                      TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0);
                                                   if (bDup) then
                                                      CloseHandle(hProcessDup);
                                                   GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                                end;
                                                if (ExitCode <> Still_Active) and (ExitCode <> 0) then
                                                begin
                                                   strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemUninstalling'], ['VBoxNetAdp' + strNetAdp + '.inf'], 'problem uninstalling %s'#13#10#13#10'System message:') + ' ' + GetLangTextFormatDef(idxMain, ['Messages', 'ErrorCode'], [IntToStr(ExitCode), 'devcon'], '%s error code from %s');
                                                   Result := False;
                                                end;
                                                CloseHandle(eProcessInfo.hProcess);
                                                CloseHandle(eProcessInfo.hThread);
                                             except
                                             end;
                                          end
                                          else
                                          begin
                                             if not FileExists(exeDevConPath) then
                                                strRegErrMsg := 'path not found'
                                             else if LastError > 0 then
                                                strRegErrMsg := SysErrorMessage(LastError)
                                             else if LastExceptionStr <> '' then
                                                strRegErrMsg := LastExceptionStr;
                                             strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStarting'], ['devcon'], 'problem starting %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                          end;
                                       finally
                                       end;
                                    end
                                    else
                                    begin
                                       Result := UninstallInf('sun_VBoxNetAdp') > 0;
                                       if not Result then
                                       begin
                                          if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemUninstalling'], ['VBoxNetAdp'], 'problem uninstalling %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;
                                    end;
                                    {$ENDIF}
                                    {$IFDEF WIN64}
                                    Result := UninstallInf('sun_VBoxNetAdp') > 0;
                                    if not Result then
                                    begin
                                       if LastError > 0 then
                                          strRegErrMsg := SysErrorMessage(LastError)
                                       else if LastExceptionStr <> '' then
                                          strRegErrMsg := LastExceptionStr;
                                       strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemUninstalling'], ['VBoxNetAdp'], 'problem uninstalling %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                    end;
                                    {$ENDIF}
                                 end;

                                 if Result then
                                 begin
                                    drvSysPath := IncludeTrailingPathDelimiter(string(Buffer)) + '\Drivers\';
                                    if DirectoryExists(drvSysPath) then
                                    begin
                                       DeleteFile(drvSysPath + 'VBoxNetAdp' + strNetAdp + '.sys');
                                       if FileExists(drvSysPath + 'VBoxNetAdp' + strNetAdp + '.sys.pvbbak') then
                                          RenameFile(drvSysPath + 'VBoxNetAdp' + strNetAdp + '.sys.pvbbak', drvSysPath + 'VBoxNetAdp' + strNetAdp + '.sys');
                                    end;
                                 end;
                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxNetAdp');
                                    if ssStatus.dwCurrentState = SERVICE_RUNNING then
                                    begin
                                       Result := ServiceStop('VBoxNetAdp');
                                       if not Result then
                                       begin
                                          if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStopSrv'], ['VBoxNetAdp'], 'problem stopping %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;
                                    end;
                                 end;
                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxNetAdp');
                                    if (ssStatus.dwCurrentState = SERVICE_STOPPED) or (ssStatus.dwCurrentState = SERVICE_STOP_PENDING) then
                                    begin
                                       Result := ServiceDelete('VBoxNetAdp');
                                       if not Result then
                                       begin
                                          if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemRemSrv'], ['VBoxNetAdp'], 'problem removing %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;
                                    end;
                                 end;

                                 {$IFDEF WIN32}
                                 if TOSversion.Architecture = arIntelX64 then
                                    exeSnetCfgPath := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\snetcfg_x64.exe'
                                 else
                                    exeSnetCfgPath := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\snetcfg_x86.exe';
                                 {$ENDIF}
                                 {$IFDEF WIN64}
                                 exeSnetCfgPath := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\snetcfg_x64.exe';
                                 {$ENDIF}
                                 if Result then
                                 begin

                                    //  ssStatus := ServiceStatus('VBoxNet' + strNetBrdg1);
                                      //if (((TOSVersion.Major < 6) and (CheckInstalledInf(strNetBrdg2 + '_VBoxNet' + strNetBrdg1) > 0)) or ((TOSVersion.Major >= 6) and False)) or (ssStatus.dwCurrentState > 0) then
                                    try
                                       strTemp := '"' + exeSnetCfgPath + '" -u ' + strNetBrdg2 + '_VBoxNet' + strNetBrdg1;
                                       l := (Length(strTemp) + 1) * SizeOf(Char);
                                       SetLength(CommLine, l);
                                       Move(strTemp[1], CommLine[0], l);
                                       if ExtractFilePath(exeVBPathAbs) <> '' then
                                          PexeSnetCfgPath := PChar(ExtractFilePath(exeVBPathAbs))
                                       else
                                          PexeSnetCfgPath := nil;
                                       ResetLastError;
                                       try
                                          Result := CreateProcess(nil, @CommLine[0], nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PexeSnetCfgPath, eStartupInfo, eProcessInfo);
                                          LastError := GetLastError;
                                       except
                                          on E: Exception do
                                          begin
                                             Result := False;
                                             LastExceptionStr := E.Message;
                                          end;
                                       end;
                                       if Result then
                                       begin
                                          dt := GetTickCount;
                                          while (GetTickCount - dt) <= 5000 do
                                          begin
                                             if WaitForInputIdle(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                Break;
                                          end;
                                          dt := GetTickCount;
                                          while (GetTickCount - dt) <= 9000 do
                                          begin
                                             if WaitForSingleObject(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                Break;
                                          end;
                                          try
                                             GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                             if ExitCode = Still_Active then
                                             begin
                                                uExitCode := 0;
                                                RemoteProcHandle := GetProcessHandleFromID(eProcessInfo.dwProcessId);
                                                bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
                                                if GetExitCodeProcess(hProcessDup, dwCode) then
                                                begin
                                                   hKernel := GetModuleHandle('Kernel32');
                                                   FARPROC := GetProcAddress(hKernel, 'ExitProcess');
                                                   hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
                                                   if hrt = 0 then
                                                      TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0)
                                                   else
                                                      CloseHandle(hRT);
                                                end
                                                else
                                                   TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0);
                                                if (bDup) then
                                                   CloseHandle(hProcessDup);
                                                GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                             end;
                                             if (ExitCode <> Still_Active) and (ExitCode <> 0) then
                                             begin
                                                strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorCode'], [IntToStr(ExitCode), 'snetcfg'], '%s error code from %s');
                                                strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemUninstalling'], ['VBoxNet' + strNetBrdg1], 'problem uninstalling %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                                Result := False;
                                             end;
                                             CloseHandle(eProcessInfo.hProcess);
                                             CloseHandle(eProcessInfo.hThread);
                                          except
                                          end;
                                       end
                                       else
                                       begin
                                          if not FileExists(exeSnetCfgPath) then
                                             strRegErrMsg := 'file not found'
                                          else if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStarting'], ['snetcfg'], 'problem starting %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;
                                    finally
                                    end;
                                 end;

                                 SetLength(exeRegsvr32Path, StrLen(Buffer));
                                 exeRegsvr32Path := IncludeTrailingPathDelimiter(Buffer);
                                 exeRegsvr32Path := exeRegsvr32Path + 'regsvr32.exe';

                                 if Result and (TOSVersion.Major < 6) then
                                 try
                                    if exeRegsvr32Path <> '' then
                                    begin
                                       strTemp := '"' + exeRegsvr32Path + '" /S /u "' + IncludeTrailingPathDelimiter(ExtractFilePath(exeRegSvr32Path)) + 'VBoxNetFltNobj.dll"';
                                       UniqueString(strTemp);
                                       PexeRegsvr32 := PChar(strTemp);
                                    end
                                    else
                                       PexeRegsvr32 := nil;
                                    if ExtractFilePath(exeRegsvr32Path) <> '' then
                                       PexeRegsvr32Path := PChar(ExtractFilePath(exeRegsvr32Path))
                                    else
                                       PexeRegsvr32Path := nil;
                                    ResetLastError;
                                    try
                                       Result := CreateProcess(nil, PexeRegsvr32, nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PexeRegsvr32Path, eStartupInfo, eProcessInfo);
                                       LastError := GetLastError;
                                    except
                                       on E: Exception do
                                       begin
                                          Result := False;
                                          LastExceptionStr := E.Message;
                                       end;
                                    end;
                                    if Result then
                                    begin
                                       dt := GetTickCount;
                                       while (GetTickCount - dt) <= 3000 do
                                       begin
                                          if WaitForInputIdle(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                             Break;
                                       end;
                                       dt := GetTickCount;
                                       while (GetTickCount - dt) <= 5000 do
                                       begin
                                          if WaitForSingleObject(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                             Break;
                                       end;
                                       try
                                          GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                          if ExitCode = Still_Active then
                                          begin
                                             uExitCode := 0;
                                             RemoteProcHandle := GetProcessHandleFromID(eProcessInfo.dwProcessId);
                                             bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
                                             if GetExitCodeProcess(hProcessDup, dwCode) then
                                             begin
                                                hKernel := GetModuleHandle('Kernel32');
                                                FARPROC := GetProcAddress(hKernel, 'ExitProcess');
                                                hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
                                                if hrt = 0 then
                                                   TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0)
                                                else
                                                   CloseHandle(hRT);
                                             end
                                             else
                                                TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0);
                                             if (bDup) then
                                                CloseHandle(hProcessDup);
                                             GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                          end;
                                          if (ExitCode <> Still_Active) and (ExitCode <> 0) then
                                          begin
                                             if not FileExists(IncludeTrailingPathDelimiter(ExtractFilePath(exeRegSvr32Path)) + 'VBoxNetFltNobj.dll') then
                                                strRegErrMsg := 'file not found'
                                             else
                                                case ExitCode of
                                                   1: strTemp := GetLangTextDef(idxMain, ['Messages', 'InvArg'], 'Invalid argument');
                                                   2: strTemp := GetLangTextDef(idxMain, ['Messages', 'OleinitFld'], 'OleInitialize failed');
                                                   3: strTemp := GetLangTextDef(idxMain, ['Messages', 'LoadLibFld'], 'LoadLibrary failed');
                                                   4: strTemp := GetLangTextDef(idxMain, ['Messages', 'GetPrcAdFld'], 'GetProcAddress failed');
                                                   5: strTemp := GetLangTextDef(idxMain, ['Messages', 'DllRegUnregFld'], 'DllRegisterServer or DllUnregisterServer failed');
                                                   else
                                                      strTemp := '';
                                                end;
                                             strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemReg'], ['VBoxNetFltNobj.dll'], 'problem registering %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                             Result := False;
                                          end;
                                          CloseHandle(eProcessInfo.hProcess);
                                          CloseHandle(eProcessInfo.hThread);
                                       except
                                       end;
                                    end
                                    else
                                    begin
                                       if not FileExists(exeRegSvr32Path) then
                                          strRegErrMsg := 'file not found'
                                       else if LastError > 0 then
                                          strRegErrMsg := SysErrorMessage(LastError)
                                       else if LastExceptionStr <> '' then
                                          strRegErrMsg := LastExceptionStr;
                                       strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStarting'], ['regsvr32.exe'], 'problem starting %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                    end;
                                 finally
                                 end;

                                 if Result then
                                 begin
                                    exeRegSvr32Path := ExtractFilePath(exeRegSvr32Path);
                                    if TOSVersion.Major < 6 then
                                    begin
                                       DeleteFile(exeRegSvr32Path + 'VBoxNetFltNobj.dll');
                                       if FileExists(exeRegSvr32Path + 'VBoxNetFltNobj.dll.pvbbak') then
                                          RenameFile(exeRegSvr32Path + 'VBoxNetFltNobj.dll.pvbbak', exeRegSvr32Path + 'VBoxNetFltNobj.dll');
                                    end;
                                    DeleteFile(exeRegSvr32Path + 'drivers\VBoxNet' + strNetBrdg1 + '.sys');
                                    if FileExists(exeRegSvr32Path + 'drivers\VBoxNet' + strNetBrdg1 + '.sys.pvbbak') then
                                       RenameFile(exeRegSvr32Path + 'drivers\VBoxNet' + strNetBrdg1 + '.sys.pvbbak', exeRegSvr32Path + 'drivers\VBoxNet' + strNetBrdg1 + '.sys');
                                 end;
                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxNet' + strNetBrdg1);
                                    if ssStatus.dwCurrentState = SERVICE_RUNNING then
                                    begin
                                       Result := ServiceStop('VBoxNet' + strNetBrdg1);
                                       if not Result then
                                       begin
                                          if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStopSrv'], ['VBoxNet' + strNetBrdg1], 'problem stopping %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;
                                    end;
                                 end;

                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxNet' + strNetBrdg1);
                                    if (ssStatus.dwCurrentState = SERVICE_STOPPED) or (ssStatus.dwCurrentState = SERVICE_STOP_PENDING) then
                                    begin
                                       Result := ServiceDelete('VBoxNet' + strNetBrdg1);
                                       if not Result then
                                       begin
                                          if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemRemSrv'], ['VBoxNet' + strNetBrdg1], 'problem removing %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;
                                    end;
                                 end;

                                 if not Result then
                                    CustomMessageBox(frmMain.Handle, GetLangTextFormatDef(idxMain, ['Messages', 'CouldNotUnreg'], [' Net'], 'Could not automatically unregister the VirtualBox%s infs and services !'#13#10#13#10'Reason: ') + strRegErrMsg,
                                       GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOK], mbOK);
                              end;
                              LoadNetPortable := not LoadNetPortable;
                              if LoadNetPortable then
                              begin
                                 drvSysPath := IncludeTrailingPathDelimiter(string(Buffer)) + '\Drivers\';
                                 if DirectoryExists(drvSysPath) then
                                 begin
                                    if FileExists(drvSysPath + 'VBoxNetAdp' + strNetAdp + '.sys') then
                                       RenameFile(drvSysPath + 'VBoxNetAdp' + strNetAdp + '.sys', drvSysPath + 'VBoxNetAdp' + strNetAdp + '.sys.pvbbak');
                                    CopyFile(PChar(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\network\netadp' + strNetAdp + '\VBoxNetAdp' + strNetAdp + '.sys'), PChar(drvSysPath + 'VBoxNetAdp' + strNetAdp + '.sys'), False);
                                 end;

                                 if CheckInstalledInf('sun_VBoxNetAdp') < 1 then
                                 begin
                                    {$IFDEF WIN32}
                                    if TOSversion.Architecture = arIntelX64 then
                                    begin
                                       exeDevConPath := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\devcon_x64.exe';
                                       try
                                          strTemp := '"' + exeDevConPath + '" install "' + IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\network\netadp' + strNetAdp + '\VBoxNetAdp' + strNetAdp + '.inf" "sun_VBoxNetAdp"';
                                          UniqueString(strTemp);
                                          PexeDevCon := PChar(strTemp);
                                          PexeDevConPath := PChar(ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\');
                                          ResetLastError;
                                          try
                                             Result := CreateProcess(nil, PexeDevCon, nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PexeDevConPath, eStartupInfo, eProcessInfo);
                                             LastError := GetLastError;
                                          except
                                             on E: Exception do
                                             begin
                                                Result := False;
                                                LastExceptionStr := E.Message;
                                             end;
                                          end;
                                          if Result then
                                          begin
                                             dt := GetTickCount;
                                             while (GetTickCount - dt) <= 5000 do
                                             begin
                                                if WaitForInputIdle(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                   Break;
                                             end;
                                             dt := GetTickCount;
                                             while (GetTickCount - dt) <= 8000 do
                                             begin
                                                if WaitForSingleObject(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                   Break;
                                             end;
                                             try
                                                GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                                if ExitCode = Still_Active then
                                                begin
                                                   uExitCode := 0;
                                                   RemoteProcHandle := GetProcessHandleFromID(eProcessInfo.dwProcessId);
                                                   bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
                                                   if GetExitCodeProcess(hProcessDup, dwCode) then
                                                   begin
                                                      hKernel := GetModuleHandle('Kernel32');
                                                      FARPROC := GetProcAddress(hKernel, 'ExitProcess');
                                                      hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
                                                      if hrt = 0 then
                                                         TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0)
                                                      else
                                                         CloseHandle(hRT);
                                                   end
                                                   else
                                                      TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0);
                                                   if (bDup) then
                                                      CloseHandle(hProcessDup);
                                                   GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                                end;
                                                if (ExitCode <> Still_Active) and (ExitCode <> 0) then
                                                begin
                                                   if not FileExists(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\network\netadp' + strNetAdp + '\VBoxNetAdp' + strNetAdp + '.inf') then
                                                      strRegErrMsg := 'file not found'
                                                   else
                                                      strRegErrMsg := '';
                                                   strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemInstalling'], ['VBoxNetAdp'], 'problem installing %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                                   Result := False;
                                                end;
                                                CloseHandle(eProcessInfo.hProcess);
                                                CloseHandle(eProcessInfo.hThread);
                                             except
                                             end;
                                          end
                                          else
                                          begin
                                             if not FileExists(exeDevConPath) then
                                                strRegErrMsg := 'file not found'
                                             else if LastError > 0 then
                                                strRegErrMsg := SysErrorMessage(LastError)
                                             else if LastExceptionStr <> '' then
                                                strRegErrMsg := LastExceptionStr;
                                             strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStarting'], ['devcon'], 'problem starting %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                          end;
                                       finally
                                       end;
                                    end
                                    else if InstallInf(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\network\netadp' + strNetAdp + '\VBoxNetAdp' + strNetAdp + '.inf', 'sun_VBoxNetAdp') < 1 then
                                    begin
                                       Result := False;
                                       if LastError > 0 then
                                          strRegErrMsg := SysErrorMessage(LastError)
                                       else if LastExceptionStr <> '' then
                                          strRegErrMsg := LastExceptionStr;
                                       strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemInstalling'], ['VoxNetAdp' + strNetAdp], 'problem installing %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                    end;
                                    {$ENDIF}
                                    {$IFDEF WIN64}
                                    if InstallInf(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\network\netadp' + strNetAdp + '\VBoxNetAdp' + strNetAdp + '.inf', 'sun_VBoxNetAdp') < 1 then
                                    begin
                                       Result := False;
                                       if LastError > 0 then
                                          strRegErrMsg := SysErrorMessage(LastError)
                                       else if LastExceptionStr <> '' then
                                          strRegErrMsg := LastExceptionStr;
                                       strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemInstalling'], ['VoxNetAdp' + strNetAdp], 'problem installing %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                    end;
                                    {$ENDIF}
                                 end;

                                 ssStatus := ServiceStatus('VBoxNetAdp');
                                 if (ssStatus.dwCurrentState = SERVICE_STOPPED) or (ssStatus.dwCurrentState = SERVICE_STOP_PENDING) then
                                 begin
                                    i := 0;
                                    while True do
                                    begin
                                       mEvent.WaitFor(500);
                                       Result := ServiceStart('VBoxNetAdp');
                                       if Result then
                                          Break;
                                       if (i >= 6) and (not Result) then
                                       begin
                                          if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStartSrv'], ['VBoxNetAdp'], 'problem starting %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                          Result := False;
                                          Break;
                                       end;
                                       Inc(i);
                                    end;
                                 end;

                                 try
                                    strTemp := '"' + exeSnetCfgPath + '" -u ' + strNetBrdg2 + '_VBoxNet' + strNetBrdg1;
                                    l := (Length(strTemp) + 1) * SizeOf(Char);
                                    SetLength(CommLine, l);
                                    Move(strTemp[1], CommLine[0], l);
                                    if ExtractFilePath(exeVBPathAbs) <> '' then
                                       PexeSnetCfgPath := PChar(ExtractFilePath(exeVBPathAbs))
                                    else
                                       PexeSnetCfgPath := nil;
                                    ResetLastError;
                                    try
                                       resCP := CreateProcess(nil, @CommLine[0], nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PexeSnetCfgPath, eStartupInfo, eProcessInfo);
                                       LastError := GetLastError;
                                    except
                                       on E: Exception do
                                       begin
                                          resCP := False;
                                          LastExceptionStr := E.Message;
                                       end;
                                    end;
                                    if resCP then
                                    begin
                                       dt := GetTickCount;
                                       while (GetTickCount - dt) <= 5000 do
                                       begin
                                          if WaitForInputIdle(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                             Break;
                                       end;
                                       dt := GetTickCount;
                                       while (GetTickCount - dt) <= 9000 do
                                       begin
                                          if WaitForSingleObject(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                             Break;
                                       end;
                                       try
                                          GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                          if ExitCode = Still_Active then
                                          begin
                                             uExitCode := 0;
                                             RemoteProcHandle := GetProcessHandleFromID(eProcessInfo.dwProcessId);
                                             bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
                                             if GetExitCodeProcess(hProcessDup, dwCode) then
                                             begin
                                                hKernel := GetModuleHandle('Kernel32');
                                                FARPROC := GetProcAddress(hKernel, 'ExitProcess');
                                                hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
                                                if hrt = 0 then
                                                   TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0)
                                                else
                                                   CloseHandle(hRT);
                                             end
                                             else
                                                TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0);
                                             if (bDup) then
                                                CloseHandle(hProcessDup);
                                             GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                          end;
                                          CloseHandle(eProcessInfo.hProcess);
                                          CloseHandle(eProcessInfo.hThread);
                                       except
                                       end;
                                    end;
                                 finally
                                 end;

                                 curDir := GetCurrentDir();
                                 SetCurrentDir(ExtractFilePath(exeVBPathAbs));
                                 {$IFDEF WIN32}
                                 if TOSversion.Architecture = arIntelX64 then
                                    exeSnetCfgPath := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\snetcfg_x64.exe'
                                 else
                                    exeSnetCfgPath := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\snetcfg_x86.exe';
                                 {$ENDIF}
                                 {$IFDEF WIN64}
                                 exeSnetCfgPath := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\snetcfg_x64.exe';
                                 {$ENDIF}
                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxNet' + strNetBrdg1);
                                    if (((TOSVersion.Major < 6) and (CheckInstalledInf(strNetBrdg2 + '_VBoxNet' + strNetBrdg1) < 1)) or ((TOSVersion.Major >= 6) and False)) or (ssStatus.dwCurrentState = 0) then
                                    try
                                       strTemp := '"' + exeSnetCfgPath + '" -v -l "drivers\network\net' + strNetBrdg1 + '\VBoxNet' + strNetBrdg1 + '.inf" -m "drivers\network\net' + strNetBrdg1 + '\VBoxNet' + strNetBrdg1 + strNetBrdg3 + '.inf" -c s -i ' + strNetBrdg2 + '_VBoxNet' + strNetBrdg1;
                                       l := (Length(strTemp) + 1) * SizeOf(Char);
                                       SetLength(CommLine, l);
                                       Move(strTemp[1], CommLine[0], l);
                                       if ExtractFilePath(exeVBPathAbs) <> '' then
                                          PexeSnetCfgPath := PChar(ExtractFilePath(exeVBPathAbs))
                                       else
                                          PexeSnetCfgPath := nil;
                                       ResetLastError;
                                       try
                                          Result := CreateProcess(nil, @CommLine[0], nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PexeSnetCfgPath, eStartupInfo, eProcessInfo);
                                          LastError := GetLastError;
                                       except
                                          on E: Exception do
                                          begin
                                             Result := False;
                                             LastExceptionStr := E.Message;
                                          end;
                                       end;
                                       if Result then
                                       begin
                                          dt := GetTickCount;
                                          while (GetTickCount - dt) <= 5000 do
                                          begin
                                             if WaitForInputIdle(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                Break;
                                          end;
                                          dt := GetTickCount;
                                          while (GetTickCount - dt) <= 12000 do
                                          begin
                                             if WaitForSingleObject(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                Break;
                                          end;
                                          try
                                             GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                             if ExitCode = Still_Active then
                                             begin
                                                uExitCode := 0;
                                                RemoteProcHandle := GetProcessHandleFromID(eProcessInfo.dwProcessId);
                                                bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
                                                if GetExitCodeProcess(hProcessDup, dwCode) then
                                                begin
                                                   hKernel := GetModuleHandle('Kernel32');
                                                   FARPROC := GetProcAddress(hKernel, 'ExitProcess');
                                                   hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
                                                   if hrt = 0 then
                                                      TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0)
                                                   else
                                                      CloseHandle(hRT);
                                                end
                                                else
                                                   TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0);
                                                if (bDup) then
                                                   CloseHandle(hProcessDup);
                                                GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                             end;
                                             if (ExitCode <> Still_Active) and (ExitCode <> 0) then
                                             begin
                                                if not FileExists('drivers\network\net' + strNetBrdg1 + '\VBoxNet' + strNetBrdg1 + '.inf') then
                                                   strRegErrMsg := 'VBoxNet' + strNetBrdg1 + '.inf not found'
                                                else if not FileExists('drivers\network\net' + strNetBrdg1 + '\VBoxNet' + strNetBrdg1 + strNetBrdg3 + '.inf') then
                                                   strRegErrMsg := 'VBoxNet' + strNetBrdg1 + strNetBrdg3 + '.inf not found'
                                                else
                                                   strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorCode'], [IntToStr(ExitCode), 'snetcfg'], '%s error code from %s');
                                                strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemInstalling'], ['VBoxNet' + strNetBrdg1], 'problem installing %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                                Result := False;
                                             end;
                                             CloseHandle(eProcessInfo.hProcess);
                                             CloseHandle(eProcessInfo.hThread);
                                          except
                                          end;
                                       end
                                       else
                                       begin
                                          if not FileExists(exeSnetCfgPath) then
                                             strRegErrMsg := 'file not found'
                                          else if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStarting'], ['snetcfg'], 'problem starting %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;

                                    finally
                                    end;
                                 end;

                                 SetCurrentDir(curDir);
                                 if Result then
                                    if (strNetBrdg1 = 'Flt') and (CheckInstalledInf(strNetBrdg2 + '_VBoxNet' + strNetBrdg1) < 1) then
                                    begin
                                       if LastError > 0 then
                                          strRegErrMsg := SysErrorMessage(LastError)
                                       else if LastExceptionStr <> '' then
                                          strRegErrMsg := LastExceptionStr;
                                       strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemInstalling'], ['VBoxNet' + strNetBrdg1], 'problem installing %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       Result := False;
                                    end;
                                 if Result then
                                    if DirectoryExists(drvSysPath) then
                                    begin
                                       if FileExists(drvSysPath + 'VBoxNet' + strNetBrdg1 + '.sys') then
                                          RenameFile(drvSysPath + 'VBoxNet' + strNetBrdg1 + '.sys', drvSysPath + 'VBoxNet' + strNetBrdg1 + '.sys.pvbbak');
                                       CopyFile(PChar(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\network\net' + strNetBrdg1 + '\VBoxNet' + strNetBrdg1 + '.sys'), PChar(drvSysPath + 'VBoxNet' + strNetBrdg1 + '.sys'), False);
                                    end;

                                 if TOSVersion.Major < 6 then
                                 begin
                                    SetLength(exeRegsvr32Path, StrLen(Buffer));
                                    exeRegsvr32Path := Buffer;
                                    exeRegSvr32Path := IncludeTrailingPathDelimiter(exeRegSvr32Path);
                                    if Result then
                                    begin
                                       if FileExists(exeRegSvr32Path + 'VBoxNetFltNobj.dll') then
                                          RenameFile(exeRegSvr32Path + 'VBoxNetFltNobj.dll', exeRegSvr32Path + 'VBoxNetFltNobj.dll.pvbbak');
                                       CopyFile(PChar(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\network\netflt\VBoxNetFltNobj.dll'), PChar(exeRegSvr32Path + 'VBoxNetFltNobj.dll'), False);
                                       exeRegsvr32Path := exeRegsvr32Path + 'regsvr32.exe';
                                    end;

                                    if Result then
                                    try
                                       if exeRegsvr32Path <> '' then
                                       begin
                                          strTemp := '"' + exeRegsvr32Path + '" /S "' + IncludeTrailingPathDelimiter(ExtractFilePath(exeRegSvr32Path)) + 'VBoxNetFltNobj.dll"';
                                          UniqueString(strTemp);
                                          PexeRegsvr32 := PChar(strTemp);
                                       end
                                       else
                                          PexeRegsvr32 := nil;
                                       if ExtractFilePath(exeRegsvr32Path) <> '' then
                                          PexeRegsvr32Path := PChar(ExtractFilePath(exeRegsvr32Path))
                                       else
                                          PexeRegsvr32Path := nil;
                                       ResetLastError;
                                       try
                                          Result := CreateProcess(nil, PexeRegsvr32, nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PexeRegsvr32Path, eStartupInfo, eProcessInfo);
                                          LastError := GetLastError;
                                       except
                                          on E: Exception do
                                          begin
                                             Result := False;
                                             LastExceptionStr := E.Message;
                                          end;
                                       end;
                                       if Result then
                                       begin
                                          dt := GetTickCount;
                                          while (GetTickCount - dt) <= 3000 do
                                          begin
                                             if WaitForInputIdle(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                Break;
                                          end;
                                          dt := GetTickCount;
                                          while (GetTickCount - dt) <= 5000 do
                                          begin
                                             if WaitForSingleObject(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                Break;
                                          end;
                                          try
                                             GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                             if ExitCode = Still_Active then
                                             begin
                                                uExitCode := 0;
                                                RemoteProcHandle := GetProcessHandleFromID(eProcessInfo.dwProcessId);
                                                bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
                                                if GetExitCodeProcess(hProcessDup, dwCode) then
                                                begin
                                                   hKernel := GetModuleHandle('Kernel32');
                                                   FARPROC := GetProcAddress(hKernel, 'ExitProcess');
                                                   hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
                                                   if hrt = 0 then
                                                      TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0)
                                                   else
                                                      CloseHandle(hRT);
                                                end
                                                else
                                                   TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0);
                                                if (bDup) then
                                                   CloseHandle(hProcessDup);
                                                GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                             end;
                                             if (ExitCode <> Still_Active) and (ExitCode <> 0) then
                                             begin
                                                if not FileExists(IncludeTrailingPathDelimiter(ExtractFilePath(exeRegSvr32Path)) + 'VBoxNetFltNobj.dll') then
                                                   strRegErrMsg := 'dll file not found'
                                                else
                                                   case ExitCode of
                                                      1: strTemp := GetLangTextDef(idxMain, ['Messages', 'InvArg'], 'Invalid argument');
                                                      2: strTemp := GetLangTextDef(idxMain, ['Messages', 'OleinitFld'], 'OleInitialize failed');
                                                      3: strTemp := GetLangTextDef(idxMain, ['Messages', 'LoadLibFld'], 'LoadLibrary failed');
                                                      4: strTemp := GetLangTextDef(idxMain, ['Messages', 'GetPrcAdFld'], 'GetProcAddress failed');
                                                      5: strTemp := GetLangTextDef(idxMain, ['Messages', 'DllRegUnregFld'], 'DllRegisterServer or DllUnregisterServer failed');
                                                      else
                                                         strTemp := '';
                                                   end;
                                                strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemReg'], ['VBoxNetFltNobj.dll'], 'problem registering %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                                Result := False;
                                             end;
                                             CloseHandle(eProcessInfo.hProcess);
                                             CloseHandle(eProcessInfo.hThread);
                                          except
                                          end;
                                       end
                                       else
                                       begin
                                          if not FileExists(exeRegSvr32Path) then
                                             strRegErrMsg := 'file not found'
                                          else if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStarting'], ['regsvr32.exe'], 'problem starting %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;
                                    finally
                                    end;
                                 end;

                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxNet' + strNetBrdg1);
                                    if (ssStatus.dwCurrentState = SERVICE_STOPPED) or (ssStatus.dwCurrentState = SERVICE_STOP_PENDING) then
                                    begin
                                       i := 0;
                                       while True do
                                       begin
                                          mEvent.WaitFor(500);
                                          Result := ServiceStart('VBoxNet' + strNetBrdg1);
                                          if Result then
                                             Break;
                                          if (i >= 6) and (not Result) then
                                          begin
                                             if LastError > 0 then
                                                strRegErrMsg := SysErrorMessage(LastError)
                                             else if LastExceptionStr <> '' then
                                                strRegErrMsg := LastExceptionStr;
                                             strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStartSrv'], ['VBoxNet' + strNetBrdg1], 'problem starting %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                             Break;
                                          end;
                                          Inc(i);
                                       end;
                                    end;
                                 end;
                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxNet' + strNetBrdg1);
                                    if ssStatus.dwCurrentState = 0 then
                                    begin
                                       if LastError > 0 then
                                          strRegErrMsg := SysErrorMessage(LastError)
                                       else if LastExceptionStr <> '' then
                                          strRegErrMsg := LastExceptionStr;
                                       strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStartSrv'], ['VBoxNet' + strNetBrdg1], 'problem starting %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       Result := False;
                                    end;
                                 end;

                                 if not Result then
                                    CustomMessageBox(frmMain.Handle, GetLangTextFormatDef(idxMain, ['Messages', 'CouldNotReg'], [' Net'], 'Could not automatically register the VirtualBox%s dlls, infs and services !'#13#10#13#10'Reason:') + ' ' + strRegErrMsg,
                                       GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOK], mbOK);
                              end;
                           end;
                           if cbLoadUSBPortable.Checked <> LoadUSBPortable then
                           begin
                              if LoadUSBPortable then
                              begin
                                 Result := True;
                                 if CheckInstalledInf('USB\VID_80EE&PID_CAFE') > 0 then
                                 begin
                                    {$IFDEF WIN32}
                                    if TOSversion.Architecture = arIntelX64 then
                                    begin
                                       exeDevConPath := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\devcon_x64.exe';
                                       try
                                          strTemp := '"' + exeDevConPath + '" remove "USB\VID_80EE&PID_CAFE"';
                                          UniqueString(strTemp);
                                          PexeDevCon := PChar(strTemp);
                                          PexeDevConPath := PChar(ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\');
                                          ResetLastError;
                                          try
                                             Result := CreateProcess(nil, PexeDevCon, nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PexeDevConPath, eStartupInfo, eProcessInfo);
                                             LastError := GetLastError;
                                          except
                                             on E: Exception do
                                             begin
                                                Result := False;
                                                LastExceptionStr := E.Message;
                                             end;
                                          end;
                                          if Result then
                                          begin
                                             dt := GetTickCount;
                                             while (GetTickCount - dt) <= 3000 do
                                             begin
                                                if WaitForInputIdle(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                   Break;
                                             end;
                                             dt := GetTickCount;
                                             while (GetTickCount - dt) <= 5000 do
                                             begin
                                                if WaitForSingleObject(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                   Break;
                                             end;
                                             try
                                                GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                                if ExitCode = Still_Active then
                                                begin
                                                   uExitCode := 0;
                                                   RemoteProcHandle := GetProcessHandleFromID(eProcessInfo.dwProcessId);
                                                   bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
                                                   if GetExitCodeProcess(hProcessDup, dwCode) then
                                                   begin
                                                      hKernel := GetModuleHandle('Kernel32');
                                                      FARPROC := GetProcAddress(hKernel, 'ExitProcess');
                                                      hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
                                                      if hrt = 0 then
                                                         TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0)
                                                      else
                                                         CloseHandle(hRT);
                                                   end
                                                   else
                                                      TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0);
                                                   if (bDup) then
                                                      CloseHandle(hProcessDup);
                                                   GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                                end;
                                                if (ExitCode <> Still_Active) and (ExitCode <> 0) then
                                                begin
                                                   if not FileExists(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\USB\device\VBoxUSB.inf') then
                                                      strRegErrMsg := 'file not found'
                                                   else
                                                      strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ErrorCode'], [IntToStr(ExitCode), 'devcon'], '%s error code from %s');
                                                   strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemUninstalling'], ['VBoxUSB.inf'], 'problem uninstalling %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                                   Result := False;
                                                end;
                                                CloseHandle(eProcessInfo.hProcess);
                                                CloseHandle(eProcessInfo.hThread);
                                             except
                                             end;
                                          end
                                          else
                                          begin
                                             if not FileExists(exeDevConPath) then
                                                strRegErrMsg := 'file not found'
                                             else if LastError > 0 then
                                                strRegErrMsg := SysErrorMessage(LastError)
                                             else if LastExceptionStr <> '' then
                                                strRegErrMsg := LastExceptionStr;
                                             strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStarting'], ['devcon'], 'problem starting %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                          end;
                                       finally
                                       end;
                                    end
                                    else
                                    begin
                                       Result := UninstallInf('USB\VID_80EE&PID_CAFE') > 0;
                                       if not Result then
                                       begin
                                          if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemUninstalling'], ['VBoxUSB.inf'], 'problem uninstalling %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;
                                    end;
                                    {$ENDIF}
                                    {$IFDEF WIN64}
                                    Result := UninstallInf('USB\VID_80EE&PID_CAFE') > 0;
                                    if not Result then
                                    begin
                                       if LastError > 0 then
                                          strRegErrMsg := SysErrorMessage(LastError)
                                       else if LastExceptionStr <> '' then
                                          strRegErrMsg := LastExceptionStr;
                                       strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemUninstalling'], ['VBoxUSB.inf'], 'problem uninstalling %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                    end;
                                    {$ENDIF}
                                 end;

                                 if Result then
                                 begin
                                    drvSysPath := IncludeTrailingPathDelimiter(string(Buffer)) + '\Drivers\';
                                    if DirectoryExists(drvSysPath) then
                                    begin
                                       DeleteFile(drvSysPath + 'VBoxUSB.sys');
                                       if FileExists(drvSysPath + 'VBoxUSB.sys.pvbbak') then
                                          RenameFile(drvSysPath + 'VBoxUSB.sys.pvbbak', drvSysPath + 'VBoxUSB.sys');
                                    end;
                                 end;

                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxUSB');
                                    if ssStatus.dwCurrentState = SERVICE_RUNNING then
                                    begin
                                       Result := ServiceStop('VBoxUSB');
                                       if not Result then
                                       begin
                                          if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStopSrv'], ['VBoxUSB'], 'problem stopping %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;
                                    end;
                                 end;

                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxUSB');
                                    if (ssStatus.dwCurrentState = SERVICE_STOPPED) or (ssStatus.dwCurrentState = SERVICE_STOP_PENDING) then
                                    begin
                                       Result := ServiceDelete('VBoxUSB');
                                       if not Result then
                                       begin
                                          if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemRemSrv'], ['VBoxNetUSB'], 'problem removing %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;
                                    end;
                                 end;

                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxUSBMon');
                                    if (ssStatus.dwCurrentState = 0) or (ServiceDisplayName('VBoxUSBMon') = 'PortableVBoxUSBMon') then
                                    begin
                                       if ssStatus.dwCurrentState = SERVICE_RUNNING then
                                       begin
                                          Result := ServiceStop('VBoxUSBMon');
                                          if not Result then
                                          begin
                                             if LastError > 0 then
                                                strRegErrMsg := SysErrorMessage(LastError)
                                             else if LastExceptionStr <> '' then
                                                strRegErrMsg := LastExceptionStr;
                                             strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStopSrv'], ['VBoxUSBMon'], 'problem stopping %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                          end;
                                       end;

                                       if Result then
                                       begin
                                          ssStatus := ServiceStatus('VBoxUSBMon');
                                          if (ssStatus.dwCurrentState = SERVICE_STOPPED) or (ssStatus.dwCurrentState = SERVICE_STOP_PENDING) then
                                          begin
                                             Result := ServiceDelete('VBoxUSBMon');
                                             if not Result then
                                             begin
                                                if LastError > 0 then
                                                   strRegErrMsg := SysErrorMessage(LastError)
                                                else if LastExceptionStr <> '' then
                                                   strRegErrMsg := LastExceptionStr;
                                                strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemRemSrv'], ['VBoxUSBMon'], 'problem removing %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                             end;
                                          end;
                                       end;
                                    end;
                                 end;
                                 if not Result then
                                    CustomMessageBox(frmMain.Handle, GetLangTextFormatDef(idxMain, ['Messages', 'CouldNotUnreg'], [' USB'], 'Could not automatically unregister the VirtualBox%s dlls, infs and services !'#13#10#13#10'Reason:') + ' ' + strRegErrMsg,
                                       GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOK], mbOK);
                              end;
                              LoadUSBPortable := not LoadUSBPortable;
                              if LoadUSBPortable then
                              begin
                                 Result := True;
                                 ssStatus := ServiceStatus('VBoxUSBMon');
                                 if ssStatus.dwCurrentState = 0 then
                                 begin
                                    ResetLastError;
                                    if not ServiceCreate(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\USB\filter\VBoxUSBMon.sys', 'VBoxUSBMon') then
                                    begin
                                       Result := False;
                                       if LastError > 0 then
                                          strRegErrMsg := SysErrorMessage(LastError)
                                       else if LastExceptionStr <> '' then
                                          strRegErrMsg := LastExceptionStr;
                                       strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemCreateSrv'], ['VBoxUSBMon'], 'problem creating %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                    end;
                                 end;
                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxUSBMon');
                                    if (ssStatus.dwCurrentState = SERVICE_STOPPED) or (ssStatus.dwCurrentState = SERVICE_STOP_PENDING) then
                                    begin
                                       ResetLastError;
                                       if not ServiceStart('VBoxUSBMon') then
                                       begin
                                          Result := False;
                                          if LastError > 0 then
                                             strRegErrMsg := SysErrorMessage(LastError)
                                          else if LastExceptionStr <> '' then
                                             strRegErrMsg := LastExceptionStr;
                                          strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStartSrv'], ['VBoxUSBMon'], 'problem starting %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                       end;
                                    end;
                                 end;

                                 if CheckInstalledInf('USB\VID_80EE&PID_CAFE') < 1 then
                                 begin
                                    {$IFDEF WIN32}
                                    if TOSversion.Architecture = arIntelX64 then
                                    begin
                                       exeDevConPath := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\devcon_x64.exe';
                                       try
                                          strTemp := '"' + exeDevConPath + '" install "' + IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\USB\device\VBoxUSB.inf" "USB\VID_80EE&PID_CAFE"';
                                          UniqueString(strTemp);
                                          PexeDevCon := PChar(strTemp);
                                          PexeDevConPath := PChar(ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs))) + 'data\tools\');
                                          ResetLastError;
                                          try
                                             Result := CreateProcess(nil, PexeDevCon, nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PexeDevConPath, eStartupInfo, eProcessInfo);
                                             LastError := GetLastError;
                                          except
                                             on E: Exception do
                                             begin
                                                Result := False;
                                                LastExceptionStr := E.Message;
                                             end;
                                          end;
                                          if Result then
                                          begin
                                             dt := GetTickCount;
                                             while (GetTickCount - dt) <= 5000 do
                                             begin
                                                if WaitForInputIdle(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                   Break;
                                             end;
                                             dt := GetTickCount;
                                             while (GetTickCount - dt) <= 8000 do
                                             begin
                                                if WaitForSingleObject(eProcessInfo.hProcess, 50) <> WAIT_TIMEOUT then
                                                   Break;
                                             end;
                                             try
                                                GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                                if ExitCode = Still_Active then
                                                begin
                                                   uExitCode := 0;
                                                   RemoteProcHandle := GetProcessHandleFromID(eProcessInfo.dwProcessId);
                                                   bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
                                                   if GetExitCodeProcess(hProcessDup, dwCode) then
                                                   begin
                                                      hKernel := GetModuleHandle('Kernel32');
                                                      FARPROC := GetProcAddress(hKernel, 'ExitProcess');
                                                      hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
                                                      if hrt = 0 then
                                                         TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0)
                                                      else
                                                         CloseHandle(hRT);
                                                   end
                                                   else
                                                      TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), eProcessInfo.dwProcessId), 0);
                                                   if (bDup) then
                                                      CloseHandle(hProcessDup);
                                                   GetExitCodeProcess(eProcessInfo.hProcess, ExitCode);
                                                end;
                                                if (ExitCode <> Still_Active) and (ExitCode <> 0) then
                                                begin
                                                   if not FileExists(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\USB\device\VBoxUSB.inf') then
                                                      strRegErrMsg := 'file not found'
                                                   else
                                                      strRegErrMsg := IntToStr(ExitCode) + ' error code from devcon';
                                                   strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemInstalling'], ['VBoxUSB.inf'], 'problem installing %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                                   Result := False;
                                                end;
                                                CloseHandle(eProcessInfo.hProcess);
                                                CloseHandle(eProcessInfo.hThread);
                                             except
                                             end;
                                          end
                                          else
                                          begin
                                             if not FileExists(exeDevConPath) then
                                                strRegErrMsg := 'file not found'
                                             else if LastError > 0 then
                                                strRegErrMsg := SysErrorMessage(LastError)
                                             else if LastExceptionStr <> '' then
                                                strRegErrMsg := LastExceptionStr;
                                             strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStarting'], ['devcon'], 'problem starting %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                          end;
                                       finally
                                       end;
                                    end
                                    else if InstallInf(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\USB\device\VBoxUSB.inf', 'USB\VID_80EE&PID_CAFE') < 1 then
                                    begin
                                       Result := False;
                                       if LastError > 0 then
                                          strRegErrMsg := SysErrorMessage(LastError)
                                       else if LastExceptionStr <> '' then
                                          strRegErrMsg := LastExceptionStr;
                                       strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemInstalling'], ['VBoxUSB.inf'], 'problem installing %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                    end;
                                    {$ENDIF}
                                    {$IFDEF WIN64}
                                    if InstallInf(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\USB\device\VBoxUSB.inf', 'USB\VID_80EE&PID_CAFE') < 1 then
                                    begin
                                       Result := False;
                                       if LastError > 0 then
                                          strRegErrMsg := SysErrorMessage(LastError)
                                       else if LastExceptionStr <> '' then
                                          strRegErrMsg := LastExceptionStr;
                                       strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemInstalling'], ['VBoxUSB.inf'], 'problem installing %s'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                    end;
                                    {$ENDIF}
                                 end;

                                 if Result then
                                 begin
                                    drvSysPath := IncludeTrailingPathDelimiter(string(Buffer)) + '\Drivers\';
                                    if DirectoryExists(drvSysPath) then
                                    begin
                                       if FileExists(drvSysPath + 'VBoxUSB.sys') then
                                          RenameFile(drvSysPath + 'VBoxUSB.sys', drvSysPath + 'VBoxUSB.sys.pvbbak');
                                       CopyFile(PChar(IncludeTrailingPathDelimiter(ExtractFilePath(exeVBPathAbs)) + 'drivers\USB\filter\VBoxUSBMon.sys'), PChar(drvSysPath + 'VBoxUSB.sys'), False);
                                    end;
                                 end;

                                 if Result then
                                 begin
                                    ssStatus := ServiceStatus('VBoxUSB');
                                    if (ssStatus.dwCurrentState = SERVICE_STOPPED) or (ssStatus.dwCurrentState = SERVICE_STOP_PENDING) then
                                    begin
                                       i := 0;
                                       while True do
                                       begin
                                          mEvent.WaitFor(500);
                                          Result := ServiceStart('VBoxUSB');
                                          if Result then
                                             Break;
                                          if (i >= 6) and (not Result) then
                                          begin
                                             if LastError > 0 then
                                                strRegErrMsg := SysErrorMessage(LastError)
                                             else if LastExceptionStr <> '' then
                                                strRegErrMsg := LastExceptionStr;
                                             strRegErrMsg := GetLangTextFormatDef(idxMain, ['Messages', 'ProblemStartSrv'], ['VBoxUSB'], 'problem starting %s service'#13#10#13#10'System message:') + ' ' + strRegErrMsg;
                                             Result := False;
                                             Break;
                                          end;
                                          Inc(i);
                                       end;
                                    end;
                                 end;
                                 if not Result then
                                    CustomMessageBox(frmMain.Handle, GetLangTextFormatDef(idxMain, ['Messages', 'CouldNotReg'], [' USB'], 'Could not automatically register the VirtualBox%s dlls, infs and services !'#13#10#13#10'Reason:') + ' ' + strRegErrMsg,
                                       GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOK], mbOK);
                              end;
                           end;
                        end;
                     end;
                  end
                  else
                  begin
                     LoadUSBPortable := cbLoadUSBPortable.Checked;
                     LoadNetPortable := cbLoadNetPortable.Checked;
                     useLoadedFromInstalled := cbuseLoadedFromInstalled.Checked;
                  end;
               end
               else
               begin
                  DoNotRegister := False;
                  if isVBPortable then
                  begin
                     while True do
                     begin
                        GetAllWindowsList(VBWinClass);
                        h := High(AllWindowsList);
                        i := 0;
                        cm := 0;
                        cvm := 0;
                        while i <= h do
                        begin
                           if IsWindowVisible(AllWindowsList[i].Handle) then
                           begin
                              p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
                              if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                 Inc(cm)
                              else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                 Inc(cvm);
                           end;
                           Inc(i);
                        end;
                        if (cm + cvm) > 0 then
                        begin
                           r := CustomMessageBox(frmMain.Handle, GetLangTextDef(idxMain, ['Messages', 'ProperRegUnreg'], 'In order to properly (un)register VirtualBox dlls, infs and services'#13#10'for the portable version, all the VirtualBox windows have to be closed!' +
                              #13#10#13#10'You can choose to Abort, close all VirtualBox windows manually and click on Retry,'#13#10'click on Ignore to not unregister or click on Close all to automatically close them'), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbAbort, mbRetry, mbNoToAll], mbAbort);
                           case r of
                              mrRetry: Continue;
                              mrNoToAll:
                                 begin
                                    isBusyClosing := True;
                                    try
                                       GetAllWindowsList(VBWinClass);
                                       h := High(AllWindowsList);
                                       i := 0;
                                       cm := 0;
                                       cvm := 0;
                                       while i <= h do
                                       begin
                                          if IsWindowVisible(AllWindowsList[i].Handle) then
                                          begin
                                             p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
                                             if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                             begin
                                                PostMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
                                                Inc(cm);
                                             end
                                             else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                             begin
                                                PostMessage(AllWindowsList[i].Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
                                                Inc(cvm);
                                             end;
                                          end;
                                          Inc(i);
                                       end;
                                       if (cm + cvm) > 0 then
                                       begin
                                          dt := GetTickCount;
                                          wt := 2000 * cm + 5000 * cvm;
                                          while True do
                                          begin
                                             Wait(100);
                                             if (GetTickCount - dt) > wt then
                                                Break;
                                             GetAllWindowsList(VBWinClass);
                                             h := High(AllWindowsList);
                                             i := 0;
                                             cm := 0;
                                             cvm := 0;
                                             while i <= h do
                                             begin
                                                if IsWindowVisible(AllWindowsList[i].Handle) then
                                                begin
                                                   p := Pos('Oracle VM VirtualBox', AllWindowsList[i].WCaption);
                                                   if (p = 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                                      Inc(cm)
                                                   else if (p > 1) and (Lowercase(ExtractFileName(GetFileNameFromHandle(AllWindowsList[i].Handle))) = Lowercase(ExtractFileName(ExeVBPath))) then
                                                      Inc(cvm);
                                                end;
                                                Inc(i);
                                             end;
                                             if (cm + cvm) = 0 then
                                                Break;
                                          end;
                                       end;
                                    finally
                                       isBusyClosing := False;
                                    end;
                                 end;
                              mrIgnore: Break;
                              else
                                 DoNotRegister := True;
                                 Break;
                           end;
                        end;
                        if (cm + cvm) = 0 then
                           Break;
                     end;
                  end;
                  if (isVBPortable and (not DoNotRegister)) or (not isVBPortable) then
                  begin
                     if isVBPortable then
                     begin
                        if FRegThread <> nil then
                        begin
                           if not FRegJobDone then
                              FRegThread.Terminate;
                           if FRegJobDone then
                           begin
                              try
                                 FRegThread.Free;
                                 FRegThread := nil;
                              except
                              end;
                           end
                           else
                           try
                              TerminateThread(FRegThread.Handle, 0);
                              FRegThread := nil;
                           except
                           end;
                        end;
                        if FUnregThread <> nil then
                        begin
                           if not FUnregJobDone then
                              FUnregThread.Terminate;
                           if FUnregJobDone then
                           begin
                              try
                                 FUnregThread.Free;
                                 FUnregThread := nil;
                              except
                              end;
                           end
                           else
                           try
                              TerminateThread(FRegThread.Handle, 0);
                              FRegThread := nil;
                           except
                           end;
                        end;
                     end;
                     if PrecacheVBFiles and cbPrecacheVBFiles.Checked then
                     begin
                        if FPCThread <> nil then
                        begin
                           if not FPCJobDone then
                              FPCThread.Terminate;
                           if FPSJobDone then
                           begin
                              try
                                 FPCThread.Free;
                                 FPCThread := nil;
                              except
                              end;
                           end
                           else
                           try
                              TerminateThread(FPCThread.Handle, 0);
                              FPCThread := nil;
                           except
                           end;
                        end;
                     end;
                     if PrestartVBExeFiles and cbPrestartVBExeFiles.Checked then
                     begin
                        if FPSJobDone then
                        begin
                           try
                              FPSThread.Free;
                              FPSThread := nil;
                           except
                           end;
                        end
                        else
                        try
                           TerminateThread(FPSThread.Handle, 0);
                           FPSThread := nil;
                        except
                        end;
                     end;
                     if (PrestartVBExeFiles and FPSJobDone) and (LowerCase(ExeVBPath) <> LowerCase(TRim(edtVBExePath.Text))) then
                     begin
                        try
                           GetExitCodeProcess(svcThrProcessInfo.hProcess, ExitCode);
                           if ExitCode = Still_Active then
                           begin
                              uExitCode := 0;
                              RemoteProcHandle := GetProcessHandleFromID(svcThrProcessInfo.dwProcessId);
                              bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
                              if GetExitCodeProcess(hProcessDup, dwCode) then
                              begin
                                 hKernel := GetModuleHandle('Kernel32');
                                 FARPROC := GetProcAddress(hKernel, 'ExitProcess');
                                 hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
                                 if hrt = 0 then
                                    TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), svcThrProcessInfo.dwProcessId), 0)
                                 else
                                    CloseHandle(hRT);
                              end
                              else
                                 TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), svcThrProcessInfo.dwProcessId), 0);
                              if (bDup) then
                                 CloseHandle(hProcessDup);
                           end;
                           CloseHandle(svcThrProcessInfo.hProcess);
                           CloseHandle(svcThrProcessInfo.hThread);
                        except
                        end;
                     end;

                     ExeVBPathTemp := Trim(edtVBExePath.Text);
                     LoadNetPortableTemp := cbLoadNetPortable.Checked;
                     LoadUSBPortableTemp := cbLoadUSBPortable.Checked;
                     useLoadedFromInstalledTemp := cbuseLoadedFromInstalled.Checked;
                     ChangeFromTempToReal := True;
                     StartRegToo := False;
                     if not isVBPortable then
                     begin
                        ChangeFromTempToReal := False;
                        ExeVBPath := ExeVBPathTemp;
                        LoadNetPortable := LoadNetPortableTemp;
                        LoadUSBPortable := LoadUSBPortableTemp;
                        useLoadedFromInstalled := useLoadedFromInstalledTemp;
                     end;

                     if isVBPortable then
                     begin
                        FUnregJobDone := False;
                        FUnregThread := TUnregisterThread.Create;
                     end;

                     xmlGen.Tag := 0;

                     if (PrecacheVBFiles and cbPrecacheVBFiles.Checked) and (LowerCase(ExeVBPath) <> LowerCase(TRim(edtVBExePath.Text))) then
                     begin
                        FPCJobDone := False;
                        FPCThread := TPrecacheThread.Create;
                     end;

                     isVBPortable := False;
                     if FileExists(exeVBPathTemp) then
                     begin
                        if PathIsRelative(PChar(ExeVBPathTemp)) then
                        begin
                           FillMemory(@Path[0], Length(Path), 0);
                           PathCanonicalize(@Path[0], PChar(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + ExeVBPathTemp));
                           if string(Path) <> '' then
                              ws := Path
                           else
                              ws := exeVBPathTemp;
                        end
                        else
                           ws := exeVBPathTemp;
                        ws := ExcludeTrailingPathDelimiter(ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(ws)))) + '\data\.VirtualBox\VirtualBox.xml';
                        if FileExists(ws) then
                        begin
                           try
                              xmlGen.LoadFromFile(ws);
                           except
                              xmlGen.Active := False;
                           end;
                           xmlGen.Tag := Integer(xmlGen.Active);
                           xmlGen.Active := False;
                           isVBPortable := xmlGen.Tag = 1;
                           if isVBPortable then
                           begin
                              VBOX_USER_HOME := ExcludeTrailingPathDelimiter(ExtractFilePath(ws));
                              isVBInstalledToo := (ServiceStatus.dwCurrentState = SERVICE_RUNNING) and (ServiceDisplayName <> 'PortableVBoxDRV');
                              ExeVBPathToo := GetEnvVarValue('VBOX_MSI_INSTALL_PATH');
                              if ExeVBPathToo = '' then
                                 ExeVBPathToo := GetEnvVarValue('VBOX_INSTALL_PATH');
                              if ExeVBPathToo = '' then
                                 ExeVBPathToo := envProgramFiles + '\Oracle\VirtualBox\';
                              ExeVBPathToo := ExeVBPathToo + 'VirtualBox.exe';
                              if not FileExists(ExeVBPathToo) then
                                 ExeVBPathToo := '';
                              if not FUnregJobDone then
                                 StartRegToo := True
                              else
                              begin
                                 if FRegThread <> nil then
                                 begin
                                    if not FRegJobDone then
                                       FRegThread.Terminate;
                                    if FRegJobDone then
                                    begin
                                       try
                                          FRegThread.Free;
                                          FRegThread := nil;
                                       except
                                       end;
                                    end
                                    else
                                    try
                                       TerminateThread(FRegThread.Handle, 0);
                                       FRegThread := nil;
                                    except
                                    end;
                                 end;
                                 if FUnregThread <> nil then
                                 begin
                                    if not FUnregJobDone then
                                       FUnregThread.Terminate;
                                    if FUnregJobDone then
                                    begin
                                       try
                                          FUnregThread.Free;
                                          FUnregThread := nil;
                                       except
                                       end;
                                    end
                                    else
                                    try
                                       TerminateThread(FRegThread.Handle, 0);
                                       FRegThread := nil;
                                    except
                                    end;
                                 end;
                                 FRegJobDone := False;
                                 FRegThread := TRegisterThread.Create;
                              end;
                           end
                           else
                           begin
                              isVBInstalledToo := False;
                              ExeVBPathToo := '';
                           end;
                        end;
                     end;
                     if xmlGen.Tag = 0 then
                     begin
                        ws := GetEnvVarValue('USERPROFILE');
                        if ws <> '' then
                        begin
                           ws := ws + '\.VirtualBox\VirtualBox.xml';
                           if FileExists(ws) then
                           try
                              xmlGen.LoadFromFile(ws);
                           except
                              xmlGen.Active := False;
                           end;
                           xmlGen.Tag := Integer(xmlGen.Active);
                           xmlGen.Active := False;
                        end;
                     end;

                     if PrestartVBExeFiles and cbPrestartVBExeFiles.Checked then
                     begin
                        if isVBPortable then
                           if not FRegJobDone then
                              StartSvcToo := True
                           else if FRegJobDone and StartRegToo then
                              StartSvcToo := True;

                        if not StartSvcToo then
                           if not FUnregJobDone then
                              StartSvcToo := True;
                        if not StartSvcToo then
                        begin
                           FPSJobDone := False;
                           FPSThread := TPrestartThread.Create;
                        end;
                     end;
                  end;
               end;
               GetVBVersion;
               UpdateVM := 2 * Integer(cbDirectly.Checked) + Integer(cbUseVboxmanage.Checked);
               RemoveDrive := cbRemoveDrive.Checked;
               if PrecacheVBFiles <> cbPrecacheVBFiles.Checked then
               begin
                  if PrecacheVBFiles then
                  begin
                     if FPCThread <> nil then
                     begin
                        if not FPCJobDone then
                           FPCThread.Terminate;
                        try
                           FPCThread.Free;
                           FPCThread := nil;
                        except
                        end;
                     end;
                  end
                  else
                  begin
                     FPCJobDone := False;
                     FPCThread := TPrecacheThread.Create;
                  end;
                  PrecacheVBFiles := cbPrecacheVBFiles.Checked;
               end;
               if PrestartVBExeFiles <> cbPrestartVBExeFiles.Checked then
               begin
                  if PrestartVBExeFiles then
                  begin
                     if FPSThread <> nil then
                     begin
                        if not FPSJobDone then
                           FPSThread.Terminate;
                        try
                           FPSThread.Free;
                           FPSThread := nil;
                        except
                        end;
                     end;
                     if FPSJobDone then
                     begin
                        try
                           GetExitCodeProcess(svcThrProcessInfo.hProcess, ExitCode);
                           if ExitCode = Still_Active then
                           begin
                              uExitCode := 0;
                              RemoteProcHandle := GetProcessHandleFromID(svcThrProcessInfo.dwProcessId);
                              bDup := DuplicateHandle(GetCurrentProcess(), RemoteProcHandle, GetCurrentProcess(), @hProcessDup, PROCESS_ALL_ACCESS, False, 0);
                              if GetExitCodeProcess(hProcessDup, dwCode) then
                              begin
                                 hKernel := GetModuleHandle('Kernel32');
                                 FARPROC := GetProcAddress(hKernel, 'ExitProcess');
                                 hRT := CreateRemoteThread(hProcessDup, nil, 0, Pointer(FARPROC), @uExitCode, 0, dwTID);
                                 if hrt = 0 then
                                    TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), svcThrProcessInfo.dwProcessId), 0)
                                 else
                                    CloseHandle(hRT);
                              end
                              else
                                 TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), svcThrProcessInfo.dwProcessId), 0);
                              if (bDup) then
                                 CloseHandle(hProcessDup);
                           end;
                           CloseHandle(svcThrProcessInfo.hProcess);
                           CloseHandle(svcThrProcessInfo.hThread);
                        except
                        end;
                     end;
                  end
                  else
                  begin
                     if isVBPortable then
                        if not FRegJobDone then
                           StartSvcToo := True
                        else if FRegJobDone and StartRegToo then
                           StartSvcToo := True;

                     if not StartSvcToo then
                        if not FUnregJobDone then
                           StartSvcToo := True;
                     if not StartSvcToo then
                     begin
                        FPSJobDone := False;
                        FPSThread := TPrestartThread.Create;
                     end;
                  end;
                  PrestartVBExeFiles := cbPrestartVBExeFiles.Checked;
               end;
               if Trim(edtQExePath.Text) <> '' then
                  ExeQPath := ExcludeTrailingPathDelimiter((Trim(edtQExePath.Text))) + '\' + Trim(cmbExeVersion.Text)
               else
                  ExeQPath := '';
               HideConsoleWindow := cbHideConsoleWindow.Checked;
               EmulationBusType := 0 * Integer(rbIDE.Checked) + 1 * Integer(rbSCSI.Checked);
               QEMUDefaultParameters := Trim(edtDefaultParameters.Text);
               if DoAlign then
               begin
                  RealignColumns(False);
                  HideAutoSustainScrollbars;
               end;
               vstVMs.Header.Columns.EndUpdate;
               vstVMs.EndUpdate;
               StartKeyComb := hkStart.HotKey;
               SaveCFG(CfgFile);
            end;
         end;
      finally
         try
            frmOptions.Free;
            frmOptions := nil;
         except
         end;
         ShortCutToHotKey(StartKeyComb, Key, Modifiers);
         Hotkey_id := GlobalAddAtom('hkVMUbStart');
         RegisterHotKey(frmMain.Handle, Hotkey_id, Modifiers, Key);
      end;
   except
   end;
   btnOptions.Down := False;
end;

procedure TfrmMain.WMHotKey(var Msg: TWMHotKey);
begin
   if Msg.HotKey = Hotkey_id then
      if not isOnModal then
         btnStart.Click;
end;

procedure TfrmMain.mmHelpClick(Sender: TObject);
begin
   OpenInternetHelp(Self.Handle, DefSiteHelp);
end;

procedure TfrmMain.mmHideTrayIconClick(Sender: TObject);
var
   t: Double;
   dt: Cardinal;
begin
   HideTray;
   ShowTrayIcon := False;
   btnShowTrayIcon.Visible := True;
   btnExit.Tag := 7;
   OnResize := nil;
   if Visible and (not IsIconic(Application.Handle)) then
   begin
      LockWindowUpdate(Handle);
      SendMessage(pnlBackground.Handle, WM_SETREDRAW, wParam(False), 0);
   end;
   Constraints.MinHeight := 2 * vstVMs.Top + 8 * btnStart.Height + Height - ClientHeight;
   Constraints.MaxHeight := Height - ClientHeight + 2 * vstVms.Top + vstVMs.Height - vstVMs.ClientHeight + 12 * Integer(vstVMs.DefaultNodeHeight);
   t := 1.0 / 7 * (btnExit.Top - btnStart.Top);
   btnAdd.Top := Round(t + btnStart.Top);
   btnEdit.Top := Round(2.0 * t + btnStart.Top);
   btnDelete.Top := Round(3.0 * t + btnStart.Top);
   btnManager.Top := Round(4.0 * t + btnStart.Top);
   btnOptions.Top := Round(5.0 * t + btnStart.Top);
   btnShowTrayIcon.Top := Round(6.0 * t + btnStart.Top);
   if Visible and (not IsIconic(Application.Handle)) then
   begin
      SendMessage(pnlBackground.Handle, WM_SETREDRAW, wParam(True), 0);
      LockWindowUpdate(0);
   end;
   OnResize := FormResize;
   if IsIconic(Application.Handle) then
   begin
      SendMessage(Application.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
      dt := GetTickCount;
      while isIconic(Application.Handle) do
      begin
         mEvent.WaitFor(1);
         Application.ProcessMessages;
         if (GetTickCount - dt) > 3000 then
            Break;
      end;
   end
end;

procedure TfrmMain.mmOptionsClick(Sender: TObject);
begin
   btnOptions.Click;
end;

function TfrmMain.FindCDROMLetter(const CDROMName: AnsiString): AnsiChar;
var
   objWMIService: OLEVariant;
   colItems: OLEVariant;
   colItem: OLEVariant;
   oEnum: IEnumvariant;
   iValue: LongWord;
   i, j: Integer;
   isFound: Boolean;
   strTemp: AnsiString;

   function GetWMIObject(const objectName: AnsiString): IDispatch;
   var
      chEaten: Integer;
      BindCtx: IBindCtx;
      Moniker: IMoniker;
   begin
      OleCheck(CreateBindCtx(0, BindCtx));
      OleCheck(MkParseDisplayName(BindCtx, StringToOleStr(objectName), chEaten, Moniker));
      OleCheck(Moniker.BindToObject(BindCtx, nil, IDispatch, Result));
   end;

begin
   Result := '0';
   if Succeeded(CoInitialize(nil)) then
   try
      try
         objWMIService := GetWMIObject(AnsiString(Format('winmgmts:\\%s\%s', ['.', 'root\CIMV2'])));
         colItems := objWMIService.ExecQuery(Format('SELECT %s FROM %s', ['Caption', 'Win32_CDROMDrive']), 'WQL', 0);
         oEnum := IUnknown(colItems._NewEnum) as IEnumvariant;
         i := 0;
         isFound := False;
         while oEnum.Next(1, colItem, iValue) = 0 do
         begin
            if AnsiString(colItem.Properties_.Item('Caption', 0)) = CDROMName then
            begin
               isFound := True;
               Break;
            end;
            Inc(i);
         end;
         if not isFound then
            Exit;
         colItems := objWMIService.ExecQuery(Format('SELECT %s FROM %s', ['Drive', 'Win32_CDROMDrive']), 'WQL', 0);
         oEnum := IUnknown(colItems._NewEnum) as IEnumvariant;
         j := 0;
         while oEnum.Next(1, colItem, iValue) = 0 do
         begin
            if i = j then
            begin
               strTemp := AnsiString(colItem.Properties_.Item('Drive', 0));
               if (Length(strTemp) = 2) and (strTemp[2] = ':') and (strTemp[1] in ['A'..'Z']) then
                  Result := strTemp[1];
               Break;
            end;
            Inc(j);
            if j > i then
               Break;
         end;
      except
      end;
   finally
      CoUninitialize;
   end;
end;

procedure GetVBVersion;
type
   TBytes = array of Byte;
var
   Size, Handle: DWORD;
   Buffer: TBytes;
   FixedPtr: PVSFixedFileInfo;
   UseDll: Boolean;
begin
   WaitForVBSVC := True;
   VBSVC2x := True;
   UseDll := False;
   VBWinClass := 'QWidget';
   try
      if not FileExists(ExeVBPath) then
      begin
         WaitForVBSVC := False;
         VBSVC2x := False;
         Exit;
      end;
      Size := GetFileVersionInfoSize(PChar(ExeVBPath), Handle);
      if Size = 0 then
      begin
         Size := GetFileVersionInfoSize(PChar(ExtractFilePath(ExeVBPath) + 'VirtualBox.dll'), Handle);
         if Size = 0 then
         begin
            WaitForVBSVC := False;
            VBSVC2x := False;
            Exit;
         end;
         UseDll := True;
      end;
      SetLength(Buffer, Size);
      if not UseDll then
      begin
         if not GetFileVersionInfo(PChar(ExeVBPath), Handle, Size, Buffer) then
         begin
            WaitForVBSVC := False;
            VBSVC2x := False;
            Exit;
         end;
      end
      else if not GetFileVersionInfo(PChar(ExtractFilePath(ExeVBPath) + 'VirtualBox.dll'), Handle, Size, Buffer) then
      begin
         WaitForVBSVC := False;
         VBSVC2x := False;
         Exit;
      end;
      if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
      begin
         WaitForVBSVC := False;
         VBSVC2x := False;
         Exit;
      end;
      if LongRec(FixedPtr.dwFileVersionMS).hi <= 3 then
      begin
         WaitForVBSVC := False;
         VBSVC2x := False;
         Exit;
      end
      else if LongRec(FixedPtr.dwFileVersionMS).hi >= 5 then
      begin
         WaitForVBSVC := False;
         VBSVC2x := False;
         if ((LongRec(FixedPtr.dwFileVersionMS).hi = 5) and (((LongRec(FixedPtr.dwFileVersionMS).Lo = 1) and (LongRec(FixedPtr.dwFileVersionLS).hi >= 2))
            or (LongRec(FixedPtr.dwFileVersionMS).Lo >= 2))) or (LongRec(FixedPtr.dwFileVersionMS).hi > 5) then
            VBWinClass := 'Qt5QWindowIcon';
         Exit;
      end;

      case LongRec(FixedPtr.dwFileVersionMS).Lo of
         0..1:
            begin
               WaitForVBSVC := False;
               VBSVC2x := False;
            end;
         2:
            VBSVC2x := False;
         3:
            if LongRec(FixedPtr.dwFileVersionLS).hi >= 11 then
            begin
               WaitForVBSVC := False;
               VBSVC2x := False;
            end;
         else
            WaitForVBSVC := False;
            VBSVC2x := False;
      end;
   except
   end;
end;

procedure TfrmMain.mmRefreshClick(Sender: TObject);
var
   Data: PData;
   Node: PVirtualNode;
begin
   FindDrives;
   vstVMs.BeginUpdate;
   Node := vstVMs.GetFirst;
   while Node <> nil do
   begin
      Data := vstVMs.GetNodeData(Node);
      with Data^ do
      begin
         if FirstDriveName = '' then
            FFDImageIndex := -1
         else if FirstDriveFound then
         begin
            if ListOnlyUSBDrives then
            begin
               if FirstDriveBusType = 7 then
                  FFDImageIndex := 2
               else
                  FFDImageIndex := 3;
            end
            else
               case FirstDriveBusType of
                  1:
                     FFDImageIndex := 10;
                  4:
                     FFDImageIndex := 12;
                  7:
                     FFDImageIndex := 4;
                  8: FFDImageIndex := 14;
                  14, 15:
                     FFDImageIndex := 8;
                  else
                     FFDImageIndex := 6;
               end;
         end
         else if ListOnlyUSBDrives then
            FFDImageIndex := 3
         else
            case FirstDriveBusType of
               1:
                  FFDImageIndex := 11;
               4:
                  FFDImageIndex := 13;
               7:
                  FFDImageIndex := 5;
               8: FFDImageIndex := 15;
               14, 15:
                  FFDImageIndex := 9;
               else
                  FFDImageIndex := 7;
            end;

         if SecondDriveName = '' then
            FSDImageIndex := -1
         else if SecondDriveFound then
         begin
            if ListOnlyUSBDrives then
            begin
               if SecondDriveBusType = 7 then
                  FSDImageIndex := 2
               else
                  FSDImageIndex := 3;
            end
            else
               case SecondDriveBusType of
                  1:
                     FSDImageIndex := 10;
                  4:
                     FSDImageIndex := 12;
                  7:
                     FSDImageIndex := 4;
                  8: FSDImageIndex := 14;
                  14, 15:
                     FSDImageIndex := 8;
                  else
                     FSDImageIndex := 6;
               end;
         end
         else if ListOnlyUSBDrives then
            FSDImageIndex := 3
         else
            case SecondDriveBusType of
               1:
                  FSDImageIndex := 11;
               4:
                  FSDImageIndex := 13;
               7:
                  FSDImageIndex := 5;
               8: FSDImageIndex := 15;
               14, 15:
                  FSDImageIndex := 9;
               else
                  FSDImageIndex := 7;
            end;
      end;
      Node := frmMain.vstVMs.GetNext(Node);
   end;
   vstVMs.EndUpdate;
   vstVMs.Invalidate;
end;

procedure TfrmMain.mmShowHideMainWindowClick(Sender: TObject);
var
   dt: Cardinal;
begin
   if IsIconic(Application.Handle) then
   begin
      SendMessage(Application.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
      dt := GetTickCount;
      while isIconic(Application.Handle) do
      begin
         mEvent.WaitFor(1);
         Application.ProcessMessages;
         if (GetTickCount - dt) > 3000 then
            Break;
      end;
      SetForegroundWindow(Handle);
      if Assigned(frmOptions) and frmOptions.Showing then
         SetForegroundWindow(frmOptions.Handle);
   end
   else if not Showing then
   begin
      Show;
      if Assigned(frmOptions) and frmOptions.Showing then
         SetForegroundWindow(frmOptions.Handle);
   end
   else
      Hide;
end;

procedure TfrmMain.mmStartManagersClick(Sender: TObject);
var
   Data: PData;
begin
   if isBusyStartVM or IsBusyEjecting then
      Exit;
   if vstVMs.GetFirstSelected <> nil then
   begin
      Data := vstVMs.GetNodeData(vstVMs.GetFirstSelected);
      if Data^.Ptype = 0 then
         StartManagersClick(mmVirtualBoxManager)
      else
         StartManagersClick(mmQEMUManager);
   end;
end;

procedure TfrmMain.StartManagersClick(Sender: TObject);
var
   j, l, nWait: Integer;
   eStartupInfo: TStartupInfo;
   eProcessInfo: TProcessInformation;
   ProcessID: THandle;
   PexeVBPath, PVBPath, PexeQManager, PexeQManPath: PChar;
   Result: Boolean;
   strTemp: string;
   exeVBPath: string;
   Path: array[0..MAX_PATH - 1] of Char;
   dt: Cardinal;
   //     ts: TTime;
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;

   IsBusyManager := True;
   FillChar(eStartupInfo, SizeOf(eStartupInfo), #0);
   eStartupInfo.dwFlags := STARTF_USESHOWWINDOW;
   eStartupInfo.cb := SizeOf(eStartupInfo);
   eStartupInfo.wShowWindow := SW_SHOWNORMAL;
   PrestartVBFilesAgain := False;
   try
      tmCheckCTRL.Enabled := False;
      case btnStart.PngImage.Width of
         16:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn16.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn16.PngImages[0].PngImage;
            end;
         20:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn20.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn20.PngImages[0].PngImage;
            end;
         24:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn24.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn24.PngImages[0].PngImage;
            end;
      end;
      StartVMAnimation;
      if vstVMs.GetFirstSelected <> nil then
      begin
         vstVMs.ScrollIntoView(vstVMs.GetFirstSelected, True, True);
         CurSelNode := vstVMs.GetFirstSelected.Index;
      end;
      vstVMs.SelectionLocked := True;
      if Sender = mmVirtualBoxManager then
      begin
         if (isVBPortable and ((not FRegJobDone)) or (not FUnregJobDone)) then
            Exit;
         if PathIsRelative(PChar(Mainform.ExeVBPath)) then
         begin
            FillMemory(@Path[0], Length(Path), 0);
            PathCanonicalize(@Path[0], PChar(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + Mainform.ExeVBPath));
            if string(Path) <> '' then
               exeVBPath := Path
            else
               exeVBPath := Mainform.ExeVBPath;
         end
         else
            exeVBPath := Mainform.ExeVBPath;
         GetAllWindowsList(VBWinClass);
         l := Length(AllWindowsList);
         j := 0;
         while j < l do
         begin
            if IsWindowVisible(AllWindowsList[j].Handle) then
               if Pos('Oracle VM VirtualBox ', AllWindowsList[j].WCaption) = 1 then
                  if GetFileNameAndThreadFromHandle(AllWindowsList[j].Handle, ProcessID) = LowerCase(ExtractFileName(ExeVBPath)) then
                     if not IsAppNotStartedByAdmin(ProcessID) then
                     begin
                        if IsIconic(AllWindowsList[j].Handle) then
                        begin
                           SendMessage(AllWindowsList[j].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                           dt := GetTickCount;
                           while isIconic(AllWindowsList[j].Handle) do
                           begin
                              mEvent.WaitFor(1);
                              Application.ProcessMessages;
                              if (GetTickCount - dt) > 3000 then
                                 Break;
                           end;
                        end
                        else
                           SetForegroundWindow(AllWindowsList[j].Handle);
                        mEvent.WaitFor(1000);
                        Exit;
                     end;
            Inc(j);
         end;
         if ExeVBPath <> '' then
         begin
            UniqueString(ExeVBPath);
            PexeVBPath := PChar(ExeVBPath);
         end
         else
            PexeVBPath := nil;
         if ExtractFilePath(ExeVBPath) <> '' then
            PVBPath := PChar(ExtractFilePath(ExeVBPath))
         else
            PVBPath := nil;
         strTemp := '';
         //   ts := Now;
         ResetLastError;
         try
            Result := CreateProcess(nil, PExeVBPath, nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PVBPath, eStartupInfo, eProcessInfo);
            LastError := GetLastError;
         except
            on E: Exception do
            begin
               Result := False;
               LastExceptionStr := E.Message;
            end;
         end;
         if Result then
         begin
            PrestartVBFilesAgain := True;
            while True do
            begin
               Application.ProcessMessages;
               if Application.Terminated then
                  Exit;
               if WaitForSingleObject(eProcessInfo.hProcess, 25) <> WAIT_TIMEOUT then
                  Break;
               GetAllWindowsList(VBWinClass);
               l := Length(AllWindowsList);
               j := 0;
               while j < l do
               begin
                  if IsWindowVisible(AllWindowsList[j].Handle) then
                     if Pos('Oracle VM VirtualBox ', AllWindowsList[j].WCaption) = 1 then
                        if GetFileNameAndThreadFromHandle(AllWindowsList[j].Handle, ProcessID) = LowerCase(ExtractFileName(ExeVBPath)) then
                           if not IsAppNotStartedByAdmin(ProcessID) then
                              Break;
                  Inc(j);
               end;
               if j < l then
                  Break;
            end;
            try
               CloseHandle(eProcessInfo.hProcess);
               CloseHandle(eProcessInfo.hThread);
            except
            end;
         end
         else
         begin
            StopVMAnimation;
            Application.ProcessMessages;
            if not FileExists(ExeVBPath) then
               strTemp := 'file not found'
            else if LastError > 0 then
               strTemp := SysErrorMessage(LastError)
            else if LastExceptionStr <> '' then
               strTemp := LastExceptionStr
            else
               strTemp := 'Unknown error';
            CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'VBUnableLaunch'], [strTemp], 'Unable to launch VirtualBox.exe !'#13#10#13#10'System message: %s')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
         end;
      end
      else
      begin
         GetAllWindowsList('TApplication');
         l := Length(AllWindowsList);
         j := 0;
         while j < l do
         begin
            if IsWindowVisible(AllWindowsList[j].Handle) or IsIconic(AllWindowsList[j].Handle) then
               if Pos('Qemu Manager', AllWindowsList[j].WCaption) > 0 then
                  if GetFileNameAndThreadFromHandle(AllWindowsList[j].Handle, ProcessID) = LowerCase(ExtractFileName(exeQManager)) then
                     if not IsAppNotStartedByAdmin(ProcessID) then
                     begin
                        if IsIconic(AllWindowsList[j].Handle) then
                        begin
                           SendMessage(AllWindowsList[j].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                           dt := GetTickCount;
                           while isIconic(AllWindowsList[j].Handle) do
                           begin
                              mEvent.WaitFor(1);
                              Application.ProcessMessages;
                              if (GetTickCount - dt) > 3000 then
                                 Break;
                           end;
                        end
                        else
                           SetForegroundWindow(AllWindowsList[j].Handle);
                        mEvent.WaitFor(1000);
                        Exit;
                     end;
            Inc(j);
         end;
         if ExeQManager <> '' then
         begin
            UniqueString(ExeQManager);
            PexeQManager := PChar(exeQManager);
         end
         else
            PexeQManager := nil;
         if ExtractFilePath(exeQManager) <> '' then
            PexeQManPath := PChar(ExtractFilePath(exeQManager))
         else
            PexeQManPath := nil;
         strTemp := '';
         ResetLastError;
         try
            Result := CreateProcess(nil, PexeQManager, nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PexeQManPath, eStartupInfo, eProcessInfo);
            LastError := GetLastError;
         except
            on E: Exception do
            begin
               Result := False;
               LastExceptionStr := E.Message;
            end;
         end;
         if Result then
         begin
            nWait := 0;
            while (WaitForInputIdle(eProcessInfo.hProcess, 20) <> WAIT_TIMEOUT) and (nWait < 250) do
               Application.ProcessMessages;
            if Application.Terminated then
               Exit;
            while True do
            begin
               Application.ProcessMessages;
               if Application.Terminated then
                  Exit;
               if WaitForSingleObject(eProcessInfo.hProcess, 20) <> WAIT_TIMEOUT then
                  Break;
               GetAllWindowsList('TMain');
               l := Length(AllWindowsList);
               j := 0;
               while j < l do
               begin
                  if IsWindowVisible(AllWindowsList[j].Handle) then
                     if Pos('Qemu Manager', AllWindowsList[j].WCaption) > 0 then
                        if GetFileNameAndThreadFromHandle(AllWindowsList[j].Handle, ProcessID) = LowerCase(ExtractFileName(exeQManager)) then
                           if not IsAppNotStartedByAdmin(ProcessID) then
                              Break;
                  Inc(j);
               end;
               if j < l then
                  Break;
            end;
            try
               CloseHandle(eProcessInfo.hProcess);
               CloseHandle(eProcessInfo.hThread);
            except
            end;
         end
         else
         begin
            StopVMAnimation;
            Application.ProcessMessages;
            if not FileExists(ExeQManager) then
               strTemp := 'file not found'
            else if LastError > 0 then
               strTemp := SysErrorMessage(LastError)
            else if LastExceptionStr <> '' then
               strTemp := LastExceptionStr
            else
               strTemp := 'Unknown error';
            CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'QMUnableLaunch'], [strTemp], 'Unable to launch QemuManager.exe !'#13#10#13#10'System message: %s')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
         end;

      end;
   finally
      StopVMAnimation;
      IsBusyManager := False;
      vstVMs.SelectionLocked := False;
      btnManager.Down := False;
      if PrestartVBFilesAgain then
      begin
         PrestartVBFilesAgain := False;
         if PrestartVBExeFiles then
         begin
            if FPSThread <> nil then
            begin
               FPSThread.Terminate;
               FPSThread.Free;
               FPSThread := nil;
            end;
            try
               CloseHandle(svcThrProcessInfo.hProcess);
               CloseHandle(svcThrProcessInfo.hThread);
            except
            end;
            FPSJobDone := False;
            FPSThread := TPrestartThread.Create;
         end;
      end;
      //  ts := Now - ts;
        //ShowMessage('Starting VB Manager = ' + FormatDateTime('ss.zzz', ts));
   end;
end;

constructor TComponentDrive.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FWindowHandle := Classes.AllocateHWnd(WndProc);
   DriveRegister;
end;

destructor TComponentDrive.Destroy;
begin
   UnregisterDeviceNotification(FHandle);
   Classes.DeallocateHWnd(FWindowHandle);
   inherited Destroy;
end;

procedure TComponentDrive.WndProc(var Msg: TMessage);
begin
   if Msg.Msg = WM_DEVICECHANGE then
   begin
      try
         WMDeviceChange(Msg);
      except
         Application.HandleException(Self);
      end;
   end
   else
      Msg.Result := DefWindowProc(FWindowHandle, Msg.Msg, Msg.wParam, Msg.lParam);
end;

procedure TComponentDrive.WMDeviceChange(var Msg: TMessage);
var
   i: Byte;
   k, l: Integer;
   sz: Double;
   Mask: DWORD;
   hVolume, hDrive: THandle;
   dwBytesReturned: DWORD;
   sdn: STORAGE_DEVICE_NUMBER;
   strTemp, csz, mu: AnsiString;
   BusType: Byte;
   Data: PData;
   Node: PVirtualNode;
   Letters: array of string;
   j: Integer;

   procedure Round3;
   var
      k, n: Integer;
   begin
      k := 0;
      if sz < 100 then
      begin
         while sz < 1000 do
         begin
            sz := sz * 10;
            Inc(k);
         end;
         Dec(k);
         csz := AnsiString(IntToStr(Round(sz / 10)));
         if k <= 2 then
            Insert('.', csz, 4 - k)
         else
         begin
            for n := 1 to k - 2 do
               csz := '0' + csz;
            Insert('.', csz, 2);
         end;
      end
      else if sz > 1000 then
      begin
         while sz > 100 do
         begin
            sz := sz / 10;
            Inc(k);
         end;
         Dec(k);
         csz := AnsiString(IntToStr(Round(sz * 10)));
         for n := 1 to k do
            csz := csz + '0';
      end
      else
         csz := AnsiString(IntToStr(Round(sz)));
   end;

begin
   if frmMain.vstVMs.RootNodeCount = 0 then
      Exit;
   if (Msg.wParam = DBT_DEVICEREMOVECOMPLETE) and (PDevBroadcastHdr(Msg.lParam)^.dbch_devicetype = DBT_DEVTYP_DEVICEINTERFACE) then
   begin
      if frmMain.Showing then
      begin
         frmMain.vstVMs.BeginUpdate;
         FindDrives;
         Node := frmMain.vstVMs.GetFirst;
         while Node <> nil do
         begin
            Data := frmMain.vstVMs.GetNodeData(Node);
            with Data^ do
            begin
               if FirstDriveName = '' then
                  FFDImageIndex := -1
               else if FirstDriveFound then
               begin
                  if ListOnlyUSBDrives then
                  begin
                     if FirstDriveBusType = 7 then
                        FFDImageIndex := 2
                     else
                        FFDImageIndex := 3;
                  end
                  else
                     case FirstDriveBusType of
                        1:
                           FFDImageIndex := 10;
                        4:
                           FFDImageIndex := 12;
                        7:
                           FFDImageIndex := 4;
                        8: FFDImageIndex := 14;
                        14, 15:
                           FFDImageIndex := 8;
                        else
                           FFDImageIndex := 6;
                     end;
               end
               else if ListOnlyUSBDrives then
                  FFDImageIndex := 3
               else
                  case FirstDriveBusType of
                     1:
                        FFDImageIndex := 11;
                     4:
                        FFDImageIndex := 13;
                     7:
                        FFDImageIndex := 5;
                     8: FFDImageIndex := 15;
                     14, 15:
                        FFDImageIndex := 9;
                     else
                        FFDImageIndex := 7;
                  end;

               if SecondDriveName = '' then
                  FSDImageIndex := -1
               else if SecondDriveFound then
               begin
                  if ListOnlyUSBDrives then
                  begin
                     if SecondDriveBusType = 7 then
                        FSDImageIndex := 2
                     else
                        FSDImageIndex := 3;
                  end
                  else
                     case SecondDriveBusType of
                        1:
                           FSDImageIndex := 10;
                        4:
                           FSDImageIndex := 12;
                        7:
                           FSDImageIndex := 4;
                        8: FSDImageIndex := 14;
                        14, 15:
                           FSDImageIndex := 8;
                        else
                           FSDImageIndex := 6;
                     end;
               end
               else if ListOnlyUSBDrives then
                  FSDImageIndex := 3
               else
                  case SecondDriveBusType of
                     1:
                        FSDImageIndex := 11;
                     4:
                        FSDImageIndex := 13;
                     7:
                        FSDImageIndex := 5;
                     8: FSDImageIndex := 15;
                     14, 15:
                        FSDImageIndex := 9;
                     else
                        FSDImageIndex := 7;
                  end;
            end;
            Node := frmMain.vstVMs.GetNext(Node);
         end;
         frmMain.vstVMs.EndUpdate;
         if (coVisible in frmMain.vstVMs.Header.Columns[2].Options) or (coVisible in frmMain.vstVMs.Header.Columns[3].Options) then
            frmMain.vstVMs.Invalidate;
      end
      else
         FindDrivesScheduled := True;
   end
   else if (Msg.wParam = DBT_DEVICEARRIVAL) and (PDevBroadcastHdr(Msg.lParam)^.dbch_devicetype = DBT_DEVTYP_VOLUME) then
   begin
      if PDevBroadcastVolume(Msg.lParam)^.dbcv_flags = $0000 then
      begin
         if frmMain.Showing then
         begin
            try
               SetLength(Letters, 0);
               Mask := PDevBroadcastVolume(Msg.lParam)^.dbcv_unitmask;
               i := 0;
               while i <= 25 do
               begin
                  if (Mask and 1) = 1 then
                     case GetDriveType(PChar(Char(i + Ord('A')) + ':')) of
                        DRIVE_REMOVABLE, DRIVE_FIXED:
                           begin
                              SetLength(Letters, Length(Letters) + 1);
                              Letters[High(Letters)] := Char(i + Ord('A')) + ':';
                           end;
                     end;
                  Mask := Mask shr 1;
                  Inc(i);
               end;
               frmMain.vstVMs.BeginUpdate;
               if Length(Letters) = 0 then
                  FindDrives
               else
                  for i := 0 to High(Letters) do
                  begin
                     try
                        hVolume := CreateFile(PChar('\\.\' + Letters[i]), 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                     except
                        hVolume := INVALID_HANDLE_VALUE;
                     end;
                     if hVolume <> INVALID_HANDLE_VALUE then
                     begin
                        BusType := GetBusType(hVolume);
                        if ListOnlyUSBDrives and (BusType <> Integer(BusTypeUSB)) then
                        begin
                           try
                              CloseHandle(hVolume);
                           except
                           end;
                           Continue;
                        end;
                        dwBytesReturned := 0;
                        try
                           if DeviceIoControl(hVolume, IOCTL_STORAGE_GET_DEVICE_NUMBER, nil, 0, @sdn, SizeOf(sdn), dwBytesReturned, nil) then
                           begin
                              if sdn.DeviceNumber = OSDrive then
                                 Exit;
                              try
                                 hDrive := CreateFile(PChar('\\.\PHYSICALDRIVE' + IntToStr(sdn.DeviceNumber)), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                              except
                                 hDrive := INVALID_HANDLE_VALUE;
                              end;
                              if hDrive <> INVALID_HANDLE_VALUE then
                              begin
                                 strTemp := GetDriveVendorAndProductID(hDrive);
                                 sz := 1.0 * GetDriveSize(hDrive) / 1073741824;
                                 try
                                    CloseHandle(hDrive);
                                 except
                                 end;
                                 if sz <= 0 then
                                    Continue
                                 else
                                 begin
                                    if sz < 1 then
                                    begin
                                       sz := sz * 1024;
                                       mu := ' MB';
                                    end
                                    else if sz > 1000 then
                                    begin
                                       sz := sz / 1024;
                                       mu := ' TB';
                                    end
                                    else
                                       mu := ' GB';
                                    Round3;
                                    strTemp := strTemp + ', ' + csz + mu;
                                 end;
                                 l := Length(strTemp);
                                 if l = 0 then
                                 begin
                                    try
                                       CloseHandle(hDrive);
                                    except
                                    end;
                                    Continue;
                                 end;
                                 Node := frmMain.vstVMs.GetFirst;
                                 while Node <> nil do
                                 begin
                                    Data := frmMain.vstVMs.GetNodeData(Node);
                                    if (Data^.FirstDriveNumber = -1) or (Data^.FirstDriveNumber = Integer(sdn.DeviceNumber)) then
                                       if Length(Data^.FirstDriveName) = l then
                                       begin
                                          k := 1;
                                          while k <= l do
                                          begin
                                             if strTemp[k] <> Data^.FirstDriveName[k] then
                                                Break;
                                             Inc(k);
                                          end;
                                          if k > l then
                                          begin
                                             Data^.FirstDriveFound := True;
                                             Data^.FirstDriveBusType := BusType;
                                             Data^.FirstDriveNumber := sdn.DeviceNumber;
                                             j := 0;
                                             while j <= High(Data^.FDMountPointsArr) do
                                             begin
                                                if Data^.FDMountPointsArr[j] = Letters[i] then
                                                begin
                                                   FindDrives;
                                                   Exit;
                                                end
                                                else if Data^.FDMountPointsArr[j] > Letters[i] then
                                                   Break;
                                                Inc(j);
                                             end;
                                             SetLength(Data^.FDMountPointsArr, Length(Data^.FDMountPointsArr) + 1);
                                             for k := High(Data^.FDMountPointsArr) downto j + 1 do
                                                Data^.FDMountPointsArr[j] := Data^.FDMountPointsArr[j - 1];
                                             Data^.FDMountPointsArr[j] := Letters[i];
                                             Data^.FDMountPointsStr := '[';
                                             for k := 0 to High(Data^.FDMountPointsArr) do
                                                Data^.FDMountPointsStr := Data^.FDMountPointsStr + Data^.FDMountPointsArr[k] + ', ';
                                             if Length(Data^.FDMountPointsStr) > 1 then
                                             begin
                                                Delete(Data^.FDMountPointsStr, Length(Data^.FDMountPointsStr) - 1, 2);
                                                Data^.FDMountPointsStr := Data^.FDMountPointsStr + ']';
                                             end
                                             else
                                                Data^.FDMountPointsStr := Data^.FDMountPointsStr + ' ]';
                                          end;
                                       end;
                                    if AddSecondDrive then
                                       if (Data^.SecondDriveNumber = -1) or (Data^.SecondDriveNumber = Integer(sdn.DeviceNumber)) then
                                          if Length(Data^.SecondDriveName) = l then
                                          begin
                                             k := 1;
                                             while k <= l do
                                             begin
                                                if strTemp[k] <> Data^.SecondDriveName[k] then
                                                   Break;
                                                Inc(k);
                                             end;
                                             if k > l then
                                             begin
                                                Data^.SecondDriveFound := True;
                                                Data^.SecondDriveBusType := BusType;
                                                Data^.SecondDriveNumber := sdn.DeviceNumber;
                                                j := 0;
                                                while j <= High(Data^.SDMountPointsArr) do
                                                begin
                                                   if Data^.SDMountPointsArr[j] = Letters[i] then
                                                   begin
                                                      FindDrives;
                                                      Exit;
                                                   end
                                                   else if Data^.SDMountPointsArr[j] > Letters[i] then
                                                      Break;
                                                   Inc(j);
                                                end;
                                                SetLength(Data^.SDMountPointsArr, Length(Data^.SDMountPointsArr) + 1);
                                                for k := High(Data^.SDMountPointsArr) downto j + 1 do
                                                   Data^.SDMountPointsArr[j] := Data^.SDMountPointsArr[j - 1];
                                                Data^.SDMountPointsArr[j] := Letters[i];
                                                Data^.SDMountPointsStr := '[';
                                                for k := 0 to High(Data^.SDMountPointsArr) do
                                                   Data^.SDMountPointsStr := Data^.SDMountPointsStr + Data^.SDMountPointsArr[k] + ', ';
                                                if Length(Data^.SDMountPointsStr) > 1 then
                                                begin
                                                   Delete(Data^.SDMountPointsStr, Length(Data^.SDMountPointsStr) - 1, 2);
                                                   Data^.SDMountPointsStr := Data^.SDMountPointsStr + ']';
                                                end
                                                else
                                                   Data^.SDMountPointsStr := Data^.SDMountPointsStr + ' ]';
                                             end;
                                          end;
                                    Node := frmMain.vstVMs.GetNext(Node);
                                 end;
                              end
                              else
                                 Exit;
                           end
                           else
                           begin
                              FindDrives;
                              Break;
                           end;
                        except
                           begin
                              FindDrives;
                              Break;
                           end;
                        end;
                        try
                           CloseHandle(hVolume);
                        except
                        end;
                     end
                     else
                     begin
                        FindDrives;
                        Break;
                     end;
                  end;
            finally
               Node := frmMain.vstVMs.GetFirst;
               while Node <> nil do
               begin
                  Data := frmMain.vstVMs.GetNodeData(Node);
                  with Data^ do
                  begin
                     if FirstDriveName = '' then
                        FFDImageIndex := -1
                     else if FirstDriveFound then
                     begin
                        if ListOnlyUSBDrives then
                        begin
                           if FirstDriveBusType = 7 then
                              FFDImageIndex := 2
                           else
                              FFDImageIndex := 3;
                        end
                        else
                           case FirstDriveBusType of
                              1:
                                 FFDImageIndex := 10;
                              4:
                                 FFDImageIndex := 12;
                              7:
                                 FFDImageIndex := 4;
                              8: FFDImageIndex := 14;
                              14, 15:
                                 FFDImageIndex := 8;
                              else
                                 FFDImageIndex := 6;
                           end;
                     end
                     else if ListOnlyUSBDrives then
                        FFDImageIndex := 3
                     else
                        case FirstDriveBusType of
                           1:
                              FFDImageIndex := 11;
                           4:
                              FFDImageIndex := 13;
                           7:
                              FFDImageIndex := 5;
                           8: FFDImageIndex := 15;
                           14, 15:
                              FFDImageIndex := 9;
                           else
                              FFDImageIndex := 7;
                        end;

                     if SecondDriveName = '' then
                        FSDImageIndex := -1
                     else if SecondDriveFound then
                     begin
                        if ListOnlyUSBDrives then
                        begin
                           if SecondDriveBusType = 7 then
                              FSDImageIndex := 2
                           else
                              FSDImageIndex := 3;
                        end
                        else
                           case SecondDriveBusType of
                              1:
                                 FSDImageIndex := 10;
                              4:
                                 FSDImageIndex := 12;
                              7:
                                 FSDImageIndex := 4;
                              8: FSDImageIndex := 14;
                              14, 15:
                                 FSDImageIndex := 8;
                              else
                                 FSDImageIndex := 6;
                           end;
                     end
                     else if ListOnlyUSBDrives then
                        FSDImageIndex := 3
                     else
                        case SecondDriveBusType of
                           1:
                              FSDImageIndex := 11;
                           4:
                              FSDImageIndex := 13;
                           7:
                              FSDImageIndex := 5;
                           8: FSDImageIndex := 15;
                           14, 15:
                              FSDImageIndex := 9;
                           else
                              FSDImageIndex := 7;
                        end;
                  end;
                  Node := frmMain.vstVMs.GetNext(Node);
               end;
               frmMain.vstVMs.EndUpdate;
               if (coVisible in frmMain.vstVMs.Header.Columns[2].Options) or (coVisible in frmMain.vstVMs.Header.Columns[3].Options) then
                  frmMain.vstVMs.Invalidate;
            end;
         end
         else
            FindDrivesScheduled := True;
      end;
   end
   else if (Msg.wParam = DBT_DEVICEREMOVECOMPLETE) and (PDevBroadcastHdr(Msg.lParam)^.dbch_devicetype = DBT_DEVTYP_VOLUME) then
   begin
      if PDevBroadcastVolume(Msg.lParam)^.dbcv_flags = $0000 then
      begin
         if frmMain.Showing then
         begin
            SetLength(Letters, 0);
            Mask := PDevBroadcastVolume(Msg.lParam)^.dbcv_unitmask;
            i := 0;
            while i <= 25 do
            begin
               if (Mask and 1) = 1 then
               begin
                  SetLength(Letters, Length(Letters) + 1);
                  Letters[High(Letters)] := Char(i + Ord('A')) + ':';
               end;
               Mask := Mask shr 1;
               Inc(i);
            end;
            frmMain.vstVMs.BeginUpdate;
            if Length(Letters) = 0 then
               FindDrives
            else
               for i := 0 to High(Letters) do
               begin
                  Node := frmMain.vstVMs.GetFirst;
                  while Node <> nil do
                  begin
                     Data := frmMain.vstVMs.GetNodeData(Node);
                     if Data^.FirstDriveFound then
                     begin
                        j := 0;
                        while j <= High(Data^.FDMountPointsArr) do
                        begin
                           if Data^.FDMountPointsArr[j] = Letters[i] then
                           begin
                              for k := j + 1 to High(Data^.FDMountPointsArr) do
                                 Data^.FDMountPointsArr[k - 1] := Data^.FDMountPointsArr[k];
                              SetLength(Data^.FDMountPointsArr, Length(Data^.FDMountPointsArr) - 1);
                              Data^.FDMountPointsStr := '[';
                              for k := 0 to High(Data^.FDMountPointsArr) do
                                 Data^.FDMountPointsStr := Data^.FDMountPointsStr + Data^.FDMountPointsArr[k] + ', ';
                              if Length(Data^.FDMountPointsStr) > 1 then
                              begin
                                 Delete(Data^.FDMountPointsStr, Length(Data^.FDMountPointsStr) - 1, 2);
                                 Data^.FDMountPointsStr := Data^.FDMountPointsStr + ']';
                              end
                              else
                                 Data^.FDMountPointsStr := Data^.FDMountPointsStr + ' ]';
                              Break;
                           end;
                           Inc(j);
                        end;
                     end;
                     if AddSecondDrive then
                        if Data^.SecondDriveFound then
                        begin
                           j := 0;
                           while j <= High(Data^.SDMountPointsArr) do
                           begin
                              if Data^.SDMountPointsArr[j] = Letters[i] then
                              begin
                                 for k := j + 1 to High(Data^.SDMountPointsArr) do
                                    Data^.SDMountPointsArr[k - 1] := Data^.SDMountPointsArr[k];
                                 SetLength(Data^.SDMountPointsArr, Length(Data^.SDMountPointsArr) - 1);
                                 Data^.SDMountPointsStr := '[';
                                 for k := 0 to High(Data^.SDMountPointsArr) do
                                    Data^.SDMountPointsStr := Data^.SDMountPointsStr + Data^.SDMountPointsArr[k] + ', ';
                                 if Length(Data^.SDMountPointsStr) > 1 then
                                 begin
                                    Delete(Data^.SDMountPointsStr, Length(Data^.SDMountPointsStr) - 1, 2);
                                    Data^.SDMountPointsStr := Data^.SDMountPointsStr + ']';
                                 end
                                 else
                                    Data^.SDMountPointsStr := Data^.SDMountPointsStr + ' ]';
                                 Break;
                              end;
                              Inc(j);
                           end;
                        end;
                     Node := frmMain.vstVMs.GetNext(Node);
                  end;
               end;
            frmMain.vstVMs.EndUpdate;
            if (coVisible in frmMain.vstVMs.Header.Columns[2].Options) or (coVisible in frmMain.vstVMs.Header.Columns[3].Options) then
               frmMain.vstVMs.Invalidate;
         end
         else
            FindDrivesScheduled := True;
      end;
   end
   else if (Msg.wParam = DBT_DEVICEARRIVAL) and (PDevBroadcastHdr(Msg.lParam)^.dbch_devicetype = DBT_DEVTYP_DEVICEINTERFACE) then
   begin
      if frmMain.Showing then
      begin
         frmMain.vstVMs.BeginUpdate;
         for i := 0 to MAX_IDE_DRIVES - 1 do
         begin
            if i = OSDrive then
               Continue;
            hDrive := INVALID_HANDLE_VALUE;
            try
               ResetLastError;
               hDrive := CreateFile(PChar('\\.\PHYSICALDRIVE' + IntToStr(i)), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
               LastError := GetLastError;
            except
               on E: Exception do
                  LastExceptionStr := E.Message;
            end;
            if hDrive <> INVALID_HANDLE_VALUE then
            begin
               BusType := GetBusType(hDrive);
               if ListOnlyUSBDrives and (BusType <> Integer(BusTypeUSB)) then
               begin
                  try
                     CloseHandle(hDrive);
                  except
                  end;
                  Continue;
               end;
               strTemp := GetDriveVendorAndProductID(hDrive);
               if strTemp = '' then
               begin
                  try
                     CloseHandle(hDrive);
                  except
                  end;
                  Continue;
               end;
               sz := GetDriveSize(hDrive) / 1073741824;
               try
                  CloseHandle(hDrive);
               except
               end;
               if sz <= 0 then
                  Continue
               else
               begin
                  if sz < 1 then
                  begin
                     sz := sz * 1024;
                     mu := ' MB';
                  end
                  else if sz > 1000 then
                  begin
                     sz := sz / 1024;
                     mu := ' TB';
                  end
                  else
                     mu := ' GB';
                  Round3;
                  strTemp := strTemp + ', ' + csz + mu;
               end;
               l := Length(strTemp);
               Node := frmMain.vstVMs.GetFirst;
               while Node <> nil do
               begin
                  Data := frmMain.vstVMs.GetNodeData(Node);
                  if Length(Data^.FirstDriveName) = l then
                  begin
                     k := 1;
                     while k <= l do
                     begin
                        if strTemp[k] <> Data^.FirstDriveName[k] then
                           Break;
                        Inc(k);
                     end;
                     if (k > l) and (Data^.FirstDriveNumber = -1) then
                     begin
                        Data^.FirstDriveFound := True;
                        Data^.FirstDriveBusType := BusType;
                        Data^.FirstDriveNumber := i;
                     end;
                  end;
                  if AddSecondDrive then
                  begin
                     if Length(Data^.SecondDriveName) = l then
                     begin
                        k := 1;
                        while k <= l do
                        begin
                           if strTemp[k] <> Data^.SecondDriveName[k] then
                              Break;
                           Inc(k);
                        end;
                        if (k > l) and (Data^.SecondDriveNumber = -1) then
                        begin
                           Data^.SecondDriveFound := True;
                           Data^.SecondDriveBusType := BusType;
                           Data^.SecondDriveNumber := i;
                        end;
                     end;
                  end;
                  Node := frmMain.vstVMs.GetNext(Node);
               end;
            end;
         end;
         Node := frmMain.vstVMs.GetFirst;
         while Node <> nil do
         begin
            Data := frmMain.vstVMs.GetNodeData(Node);
            with Data^ do
            begin
               if FirstDriveName = '' then
                  FFDImageIndex := -1
               else if FirstDriveFound then
               begin
                  if ListOnlyUSBDrives then
                  begin
                     if FirstDriveBusType = 7 then
                        FFDImageIndex := 2
                     else
                        FFDImageIndex := 3;
                  end
                  else
                     case FirstDriveBusType of
                        1:
                           FFDImageIndex := 10;
                        4:
                           FFDImageIndex := 12;
                        7:
                           FFDImageIndex := 4;
                        8: FFDImageIndex := 14;
                        14, 15:
                           FFDImageIndex := 8;
                        else
                           FFDImageIndex := 6;
                     end;
               end
               else if ListOnlyUSBDrives then
                  FFDImageIndex := 3
               else
                  case FirstDriveBusType of
                     1:
                        FFDImageIndex := 11;
                     4:
                        FFDImageIndex := 13;
                     7:
                        FFDImageIndex := 5;
                     8: FFDImageIndex := 15;
                     14, 15:
                        FFDImageIndex := 9;
                     else
                        FFDImageIndex := 7;
                  end;

               if SecondDriveName = '' then
                  FSDImageIndex := -1
               else if SecondDriveFound then
               begin
                  if ListOnlyUSBDrives then
                  begin
                     if SecondDriveBusType = 7 then
                        FSDImageIndex := 2
                     else
                        FSDImageIndex := 3;
                  end
                  else
                     case SecondDriveBusType of
                        1:
                           FSDImageIndex := 10;
                        4:
                           FSDImageIndex := 12;
                        7:
                           FSDImageIndex := 4;
                        8: FSDImageIndex := 14;
                        14, 15:
                           FSDImageIndex := 8;
                        else
                           FSDImageIndex := 6;
                     end;
               end
               else if ListOnlyUSBDrives then
                  FSDImageIndex := 3
               else
                  case SecondDriveBusType of
                     1:
                        FSDImageIndex := 11;
                     4:
                        FSDImageIndex := 13;
                     7:
                        FSDImageIndex := 5;
                     8: FSDImageIndex := 15;
                     14, 15:
                        FSDImageIndex := 9;
                     else
                        FSDImageIndex := 7;
                  end;
            end;
            Node := frmMain.vstVMs.GetNext(Node);
         end;
         frmMain.vstVMs.EndUpdate;
         if (coVisible in frmMain.vstVMs.Header.Columns[2].Options) or (coVisible in frmMain.vstVMs.Header.Columns[3].Options) then
            frmMain.vstVMs.Invalidate;
      end
      else
         FindDrivesScheduled := True;
   end;
end;

procedure TComponentDrive.DriveRegister;
var
   dbi: DEV_BROADCAST_DEVICEINTERFACE;
   Size: Integer;
begin
   Size := SizeOf(DEV_BROADCAST_DEVICEINTERFACE);
   ZeroMemory(@dbi, Size);
   dbi.dbcc_size := Size;
   dbi.dbcc_devicetype := DBT_DEVTYP_DEVICEINTERFACE;
   dbi.dbcc_reserved := 0;
   dbi.dbcc_classguid := GUID_DEVINTERFACE_DISK;

   FHandle := RegisterDeviceNotification(FWindowHandle, @dbi, DEVICE_NOTIFY_WINDOW_HANDLE);
end;

procedure TfrmMain.AppException(Sender: TObject; E: Exception);
begin
   //
end;

procedure TfrmMain.AcceptFiles(var Msg: TMessage);
var
   Buffer: array[0..MAX_PATH] of Char;
   strTemp: string;
   hVolume, hDrive: THandle;
   dwBytesReturned: DWORD;
   sdn: STORAGE_DEVICE_NUMBER;
   ErrorMode: Word;
   BusType: Byte;
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;
   Application.BringToFront;
   Repaint;
   case DragQueryFile(Msg.wParam, $FFFFFFFF, nil, 0) of
      1:
         begin
            DragQueryFile(Msg.wParam, 0, @Buffer, SizeOf(Buffer));
            DragFinish(Msg.wParam);
            strTemp := string(Buffer);
            if (Length(strTemp) = 3) and CharInSet(strTemp[1], ['A'..'Z']) and (strTemp[2] = ':') and (strTemp[3] = '\') then
            begin
               ErrorMode := SetErrorMode(SEM_FailCriticalErrors);
               try
                  case GetDriveType(PChar(string(strTemp))) of
                     DRIVE_REMOVABLE, DRIVE_FIXED:
                        begin
                           try
                              hVolume := CreateFile(PChar('\\.\' + strTemp[1] + ':'), 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                           except
                              hVolume := INVALID_HANDLE_VALUE;
                           end;
                           if hVolume <> INVALID_HANDLE_VALUE then
                           begin
                              BusType := GetBusType(hVolume);
                              if ListOnlyUSBDrives and (BusType <> Integer(BusTypeUSB)) then
                              begin
                                 try
                                    CloseHandle(hVolume);
                                 except
                                 end;
                                 CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'NotUSBDrive'], 'This is not a USB drive !')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOk], mbOk);
                                 Exit;
                              end;
                              dwBytesReturned := 0;
                              try
                                 if DeviceIoControl(hVolume, IOCTL_STORAGE_GET_DEVICE_NUMBER, nil, 0, @sdn, SizeOf(sdn), dwBytesReturned, nil) then
                                 begin
                                    if sdn.DeviceNumber <> OSDrive then
                                    begin
                                       try
                                          hDrive := CreateFile(PChar('\\.\PHYSICALDRIVE' + IntToStr(sdn.DeviceNumber)), 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                                       except
                                          hDrive := INVALID_HANDLE_VALUE;
                                       end;
                                       if hDrive <> INVALID_HANDLE_VALUE then
                                       begin
                                          try
                                             try
                                                CloseHandle(hDrive);
                                             except
                                             end;
                                             try
                                                DriveToAdd := sdn.DeviceNumber;
                                                btnAddClick(nil);
                                             finally
                                                DriveToAdd := -1;
                                             end
                                          except
                                          end;
                                       end
                                       else
                                       begin
                                          LastError := GetLastError;
                                          CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'ErrorAccessDrive'], [SysErrorMessage(LastError)], 'Error accessing the drive !'#13#10#13#10'System message: %s')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOk], mbOk);
                                       end;
                                    end
                                    else
                                    begin
                                       CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'CantUseOSDrive'], 'This is the OS drive, can''t use !')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOk], mbOk);
                                    end;
                                 end
                                 else
                                 begin
                                    LastError := GetLastError;
                                    CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'ErrorGetDriveNr'], [SysErrorMessage(LastError)], 'Error getting the drive number !'#13#10#13#10'System message: %s')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOk], mbOk);
                                 end;
                              except
                                 LastError := GetLastError;
                                 CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'ErrorAccessVolDrive'], [SysErrorMessage(LastError)], 'Error accessing the volume on drive !'#13#10#13#10'System message: %s')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOk], mbOk);
                              end;
                              try
                                 CloseHandle(hVolume);
                              except
                              end;
                           end
                           else
                           begin
                              LastError := GetLastError;
                              CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'ErrorAccessVolDrive'], [SysErrorMessage(LastError)], 'Error accessing the volume on drive !'#13#10#13#10'System message: %s')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOk], mbOk);
                           end;
                        end
                     else
                        CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'NotRemFixedLocalDrive'], 'This is not a removable or fixed local drive !')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOk], mbOk);
                        Exit;
                  end;
               finally
                  SetErrorMode(ErrorMode);
               end;
            end
            else
            begin
               CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'NotVolDrive'], 'Not a volume or drive !')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOk], mbOk);
            end;
         end;
      else
         DragFinish(Msg.wParam);
         CustomMessageBox(Handle, (GetLangTextDef(idxMain, ['Messages', 'JustOneItem'], 'Just one item at a time !')), GetLangTextDef(idxMessages, ['Types', 'Warning'], 'Warning'), mtWarning, [mbOk], mbOk);
   end;
end;

function CStyleEscapes(const InputText: string): string;
var
   i, j: Integer;
begin
   SetLength(Result, Length(InputText));
   i := 1;
   j := 1;
   while i <= Length(InputText) do
      if InputText[i] = '\' then
         if i = Length(InputText) then
         begin
            Result[j] := '\';
            Inc(i);
            Inc(j);
         end
         else
         begin
            case InputText[i + 1] of
               'r', 'R':
                  Result[j] := #13;
               'n', 'N':
                  Result[j] := #10;
               't', 'T':
                  Result[j] := #9;
               '\':
                  begin
                     Result[j] := '\';
                     Inc(j);
                     Result[j] := '\';
                  end;
               else
                  begin
                     Result[j] := '\';
                     Inc(j);
                     Result[j] := InputText[i + 1];
                  end;
            end;
            Inc(i, 2);
            Inc(j);
         end
      else
      begin
         Result[j] := InputText[i];
         Inc(i);
         Inc(j);
      end;
   SetLength(Result, j - 1);
end;

function GetLangTextDef(const IntBaseParam: Integer; const StrParams: array of AnsiString; const DefStr: AnsiString): string;
var
   i: Integer;
   XN: IXMLNode;
begin
   try
      XN := frmMain.xmlLanguage.ChildNodes[idxInterface].ChildNodes[IntBaseParam];
      for i := 0 to High(StrParams) do
         XN := XN.ChildNodes.FindNode(string(StrParams[i]));
      Result := CStyleEscapes(XN.Text);
   except
      Result := string(DefStr);
   end;
end;

function GetLangTextFormatDef(const IntBaseParam: Integer; const StrParams: array of AnsiString; const VarRec: array of TVarRec; const DefStr: AnsiString): string;
var
   i: Integer;
   XN: IXMLNode;
begin
   try
      XN := frmMain.xmlLanguage.ChildNodes[idxInterface].ChildNodes[IntBaseParam];
      for i := 0 to High(StrParams) do
         XN := XN.ChildNodes.FindNode(string(StrParams[i]));
      Result := Format(CStyleEscapes(XN.Text), VarRec);
   except
      try
         Result := Format(string(DefStr), VarRec);
      except
         Result := 'Internal error';
      end;
   end;
end;

function IsAppNotStartedByAdmin(const ProcessID: THandle): Boolean;
const
   SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
   SECURITY_BUILTIN_DOMAIN_RID = $00000020;
   DOMAIN_ALIAS_RID_ADMINS = $00000220;
   SE_GROUP_ENABLED = 4;
var
   hAccessToken: THandle;
   ptgGroups: PTokenGroups;
   dwInfoBufferSize: DWORD;
   psidAdministrators: PSID;
   i: Integer;
begin
   Result := False;
   try
      if not AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2,
         // 2 sub-authorities
         SECURITY_BUILTIN_DOMAIN_RID, // sub-authority 0
         DOMAIN_ALIAS_RID_ADMINS, // sub-authority 1
         0, 0, 0, 0, 0, 0, // sub-authorities 2-7 not passed
         psidAdministrators) then
         Exit;
      if not OpenProcessToken(OpenProcess(PROCESS_QUERY_INFORMATION, BOOL(0), ProcessID), TOKEN_QUERY, hAccessToken) then
         Exit;
      GetMem(ptgGroups, 1024);
      if not GetTokenInformation(hAccessToken, TokenGroups, ptgGroups, 1024, dwInfoBufferSize) then
      begin
         FreeSid(psidAdministrators);
         FreeMem(ptgGroups);
         Exit;
      end;
      CloseHandle(hAccessToken);
      Result := True;
      {$R-}
      for i := 0 to ptgGroups^.GroupCount - 1 do
         if ((ptgGroups^.Groups[i].Attributes and SE_GROUP_ENABLED) = SE_GROUP_ENABLED) and EqualSid(psidAdministrators, ptgGroups^.Groups[i].sid) then
         begin
            Result := False;
            Break;
         end;
      {$R+}
      FreeSid(psidAdministrators);
      FreeMem(ptgGroups);
   except
   end;
end;

constructor TMessageForm.CreateNew(AOwner: TComponent);
var
   NonClientMetrics: TNonClientMetrics;
begin
   inherited CreateNew(AOwner);
   NonClientMetrics.cbSize := SizeOf(NonClientMetrics);
   if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
      Font.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont);
end;

procedure TMessageForm.HelpButtonClick(Sender: TObject);
begin
   Application.HelpContext(HelpContext);
end;

procedure TMessageForm.CustomKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (Shift = [ssCtrl]) and (Key = Word('C')) then
   begin
      Shift := [];
      Key := 0;
      if ((TOSVersion.Major = 6) and (TOSVersion.Minor >= 2)) or (TOSVersion.Major > 6) then
         PlaySound('Notification.Default', 0, SND_ASYNC)
      else
         PlaySound('SystemNotification', 0, SND_ASYNC);
      Clipboard.AsText := GetFormText;
   end;
end;

function TMessageForm.GetFormText: string;
var
   DividerLine, ButtonCaptions: string;
   i: Integer;
begin
   DividerLine := StringOfChar('-', 27) + sLineBreak;
   for i := 0 to ComponentCount - 1 do
      if Components[i] is TButton then
         ButtonCaptions := ButtonCaptions + TButton(Components[i]).Caption + StringOfChar(' ', 3);
   ButtonCaptions := StringReplace(ButtonCaptions, '&', '', [rfReplaceAll]);
   Result := DividerLine + Caption + sLineBreak + DividerLine + lbMessage.Caption + sLineBreak + DividerLine + ButtonCaptions + sLineBreak + DividerLine;
end;

function GetAveCharSize(Canvas: TCanvas): TPoint;
var
   i: Integer;
   Buffer: array[0..51] of Char;
   tm: TTextMetric;
begin
   for i := 0 to 25 do
      Buffer[i] := Char(i + Ord('A'));
   for i := 0 to 25 do
      Buffer[i + 26] := Char(i + Ord('a'));
   GetTextMetrics(Canvas.Handle, tm);
   GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
   Result.X := (Result.X div 26 + 1) div 2;
   Result.Y := tm.tmHeight;
end;

function CustomMessageBox(const OwnerHandle: THandle; const Msg: string; const Caption: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; DefaultButton: TMsgDlgBtn; const CbText: string = ''): Integer;
const
   mcHorzMargin = 8;
   mcVertMargin = 8;
   mcHorzSpacing = 10;
   mcVertSpacing = 10;
   mcButtonWidth = 50;
   mcButtonHeight = 14;
   mcButtonSpacing = 4;
   Sounds: array[TMsgDlgType] of Integer = (MB_ICONEXCLAMATION, MB_ICONHAND, MB_ICONASTERISK, MB_ICONQUESTION, MB_OK);
var
   msgForm: TForm;
   DialogUnits: TPoint;
   HorzMargin, VertMargin, HorzSpacing, VertSpacing, ButtonWidth, ButtonHeight, ButtonMargin, ButtonSpacing, ButtonCount, ButtonGroupWidth, IconTextWidth, IconTextHeight, X, ALeft, wImg: Integer;
   b, CancelButton: TMsgDlgBtn;
   IconID: PChar;
   OwnerRect, ATextRect: TRect;
   Owner: TWinControl;
   ThisButtonWidth: Integer;
   LButton: TPngBitBtn;
   AddCb, Snap: Boolean;
   ImgSize: Integer;
   dt: Cardinal;
begin
   Snap := False;
   SystemParametersInfo(SPI_GETSNAPTODEFBUTTON, 1, @Snap, 0);
   if OwnerHandle <> 0 then
      if isIconic(Application.Handle) then
      begin
         SendMessage(Application.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
         dt := GetTickCount;
         while isIconic(Application.Handle) do
         begin
            mEvent.WaitFor(1);
            Application.ProcessMessages;
            if (GetTickCount - dt) > 3000 then
               Break;
         end;
         SetForegroundWindow(OwnerHandle);
      end;
   Owner := FindControl(OwnerHandle);
   if Owner = nil then
      msgForm := TMessageForm.CreateNew(Application)
   else
      msgForm := TMessageForm.CreateNew(Owner);
   AddCb := CbText <> '';
   msgForm.Caption := Caption;
   ImgSize := Round(32.0 * Screen.PixelsPerInch / 96);
   wImg := 16;
   with msgForm do
   begin
      Visible := False;
      BorderStyle := bsDialog;
      BiDiMode := Application.BiDiMode;
      Canvas.Font := Font;
      KeyPreview := True;
      Position := poDesigned;
      OnKeyDown := TMessageForm(msgForm).CustomKeyDown;
      DialogUnits := GetAveCharSize(Canvas);
      HorzMargin := MulDiv(mcHorzMargin, DialogUnits.X, 4);
      VertMargin := MulDiv(mcVertMargin, DialogUnits.Y, 8);
      HorzSpacing := MulDiv(mcHorzSpacing, DialogUnits.X, 4);
      VertSpacing := MulDiv(mcVertSpacing, DialogUnits.Y, 8);
      ButtonWidth := 0;
      for b := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
      begin
         if b in Buttons then
         begin
            ATextRect := Rect(0, 0, 0, 0);
            DrawText(Canvas.Handle, PChar(GetLangTextDef(idxMessages, ['Buttons', AnsiString(ReplaceStr(ReplaceStr(ButtonNames[b], '&', ''), ' ', ''))], AnsiString(ButtonNames[b]))), -1, ATextRect, DT_CALCRECT or DT_LEFT or DT_SINGLELINE or DrawTextBiDiModeFlagsReadingOnly);
            with ATextRect do
               ThisButtonWidth := Right - Left;
            if ThisButtonWidth > ButtonWidth then
               ButtonWidth := ThisButtonWidth;
         end;
      end;
      ButtonMargin := Round(sqrt(ButtonWidth)) + 5;
      case SystemIconSize of
         -2147483647..18:
            begin
               wImg := frmMain.imlBtn16.Width;
            end;
         19..22:
            begin
               wImg := frmMain.imlBtn20.Width;
            end;
         23..2147483647:
            begin
               wImg := frmMain.imlBtn24.Width;
            end;
      end;
      if (3 * ButtonMargin + wImg + ButtonWidth) < MulDiv(mcButtonWidth, DialogUnits.X, 4) then
      begin
         ButtonMargin := Max(0, Round((MulDiv(mcButtonWidth, DialogUnits.X, 4) - wImg - ButtonWidth) / 3));
         ButtonWidth := MulDiv(mcButtonWidth, DialogUnits.X, 4);
      end
      else
         ButtonWidth := 3 * ButtonMargin + wImg + ButtonWidth;
      ButtonHeight := Max(wImg + 8, MulDiv(mcButtonHeight, DialogUnits.Y, 8));
      ButtonSpacing := MulDiv(mcButtonSpacing, DialogUnits.X, 4);
      SetRect(ATextRect, 0, 0, Round(3 * Screen.WorkAreaWidth / 4), 0);
      DrawText(Canvas.Handle, PChar(Msg), Length(Msg) + 1, ATextRect, DT_EXPANDTABS or DT_CALCRECT or DT_WORDBREAK or DrawTextBiDiModeFlagsReadingOnly);
      IconID := IconIDs[DlgType];
      IconTextWidth := ATextRect.Right;
      IconTextHeight := ATextRect.Bottom;
      if IconID <> nil then
      begin
         Inc(IconTextWidth, ImgSize + HorzSpacing);
         if IconTextHeight < ImgSize then
            IconTextHeight := ImgSize;
      end;
      ButtonCount := 0;
      for b := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
         if b in Buttons then
            Inc(ButtonCount);
      ButtonGroupWidth := 0;
      if ButtonCount <> 0 then
         ButtonGroupWidth := ButtonWidth * ButtonCount + ButtonSpacing * (ButtonCount - 1);
      ClientWidth := Max(IconTextWidth, ButtonGroupWidth) + HorzMargin * 2;
      ClientHeight := IconTextHeight + ButtonHeight + VertSpacing + VertMargin * 2;
      if IconID <> nil then
         with TImage.Create(msgForm) do
         begin
            Name := 'Image';
            Parent := msgForm;
            Picture.Icon.Handle := LoadIcon(0, IconID);
            SetBounds(HorzMargin, VertMargin, ImgSize, ImgSize);
         end;
      TMessageForm(msgForm).lbMessage := TLabel.Create(msgForm);
      with TMessageForm(msgForm).lbMessage do
      begin
         Name := 'Message';
         Anchors := [akRight, akTop];
         Parent := msgForm;
         Caption := Msg;
         BoundsRect := ATextRect;
         Wordwrap := True;
         BiDiMode := msgForm.BiDiMode;
         ALeft := IconTextWidth - ATextRect.Right + HorzMargin;
         if UseRightToLeftAlignment then
            ALeft := msgForm.ClientWidth - ALeft - Width;
         SetBounds(ALeft, VertMargin, ATextRect.Right, ATextRect.Bottom);
      end;
      if AddCb then
      begin
         TMessageForm(msgForm).cbConfirmation := TCheckbox.Create(msgForm);
         with TMessageForm(msgForm).cbConfirmation do
         begin
            Name := 'cbConfirmation';
            Parent := msgForm;
            Caption := CbText;
            Left := HorzMargin;
            Width := Height + msgForm.Canvas.TextWidth(CbText) + 5;
            if UseRightToLeftAlignment then
               Left := msgForm.ClientWidth - Left - Width;
            Top := IconTextHeight + VertMargin + VertSpacing + Ceil(0.5 * (ButtonHeight - Height));
            BiDiMode := msgForm.BiDiMode;
            Checked := cbConfirmationSt;
         end;
         ClientWidth := Max(IconTextWidth, ButtonGroupWidth + TMessageForm(msgForm).cbConfirmation.Width + 20) + HorzMargin * 2;
      end;

      if (CustomMessageTop <> -10000) and (CustomMessageHorzCenter <> -10000) then
      begin
         Left := CustomMessageHorzCenter - (Width div 2);
         if (CustomMessageTop + Height + DlgOffsPos) <= Screen.WorkAreaRect.Bottom then
            Top := CustomMessageTop + DlgOffsPos
         else
            Top := CustomMessageBottom - Height - DlgOffsPos;
         CustomMessageHorzCenter := -10000;
         CustomMessageTop := -10000;
         CustomMessageBottom := -10000;
      end
      else if (OwnerHandle = 0) or (not IsWindowVisible(OwnerHandle)) then
      begin
         Left := Screen.WorkAreaLeft + Screen.WorkAreaWidth div 2 - Width div 2;
         Top := Screen.WorkAreaTop + Screen.WorkAreaHeight div 2 - Height div 2;
      end
      else
      begin
         GetWindowRect(OwnerHandle, OwnerRect);
         Left := OwnerRect.Left + (OwnerRect.Right - OwnerRect.Left) div 2 - Width div 2;
         Top := OwnerRect.Top + (OwnerRect.Bottom - OwnerRect.Top) div 2 - Height div 2;
         if Top < Screen.WorkAreaTop then
            Top := Screen.WorkAreaTop + DlgOffsPos
         else if (Top + Height) > Screen.WorkAreaRect.Bottom then
            Top := Screen.WorkAreaRect.Bottom - Height - DlgOffsPos;
      end;
      if Left < Screen.WorkAreaLeft then
         Left := Screen.WorkAreaLeft + DlgOffsPos
      else if (Left + Width) > Screen.WorkAreaRect.Right then
         Left := Screen.WorkAreaRect.Right - Width - DlgOffsPos;
      if mbCancel in Buttons then
         CancelButton := mbCancel
      else if mbNo in Buttons then
         CancelButton := mbNo
      else if mbIgnore in Buttons then
         CancelButton := mbIgnore
      else if mbAbort in Buttons then
         CancelButton := mbAbort
      else
         CancelButton := mbOk;
      if not AddCb then
         X := (ClientWidth - ButtonGroupWidth) div 2
      else
         X := TMessageForm(msgForm).cbConfirmation.Width + 5 + (ClientWidth - ButtonGroupWidth - TMessageForm(msgForm).cbConfirmation.Width) div 2;
      for b := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
         if b in Buttons then
         begin
            LButton := TPngBitBtn.Create(msgForm);
            with LButton do
            begin
               Name := ReplaceStr(ReplaceStr(ButtonNames[b], '&', ''), ' ', '');
               Parent := msgForm;
               DrawText(Canvas.Handle, PChar(GetLangTextDef(idxMessages, ['Buttons', AnsiString(ReplaceStr(ReplaceStr(ButtonNames[b], '&', ''), ' ', ''))], AnsiString(ButtonNames[b]))), -1, ATextRect, DT_CALCRECT or DT_LEFT or DT_SINGLELINE or DrawTextBiDiModeFlagsReadingOnly);
               with ATextRect do
                  Spacing := Max(0, ButtonWidth - ButtonMargin - wImg - Right + Left) div 2;
               Margin := ButtonMargin;
               Caption := GetLangTextDef(idxMessages, ['Buttons', AnsiString(ReplaceStr(ReplaceStr(ButtonNames[b], '&', ''), ' ', ''))], AnsiString(ButtonNames[b]));
               case wImg of
                  16:
                     case b of
                        mbOK: PngImage := frmMain.imlBtn16.PngImages[14].PngImage;
                        mbCancel: PngImage := frmMain.imlBtn16.PngImages[15].PngImage;
                        mbRetry: PngImage := frmMain.imlBtn16.PngImages[16].PngImage;
                        mbAbort: PngImage := frmMain.imlBtn16.PngImages[17].PngImage;
                        mbIgnore: PngImage := frmMain.imlBtn16.PngImages[18].PngImage;
                        mbYes: PngImage := frmMain.imlBtn16.PngImages[19].PngImage;
                        mbNo: PngImage := frmMain.imlBtn16.PngImages[20].PngImage;
                        mbYesToAll: if ListOnlyUSBDrives then
                              PngImage := frmMain.imlVST16.PngImages[1].PngImage
                           else
                              PngImage := frmMain.imlVST16.PngImages[2].PngImage;
                        mbNoToAll: PngImage := frmMain.imlBtn16.PngImages[20].PngImage;
                     end;
                  20:
                     case b of
                        mbOK: PngImage := frmMain.imlBtn20.PngImages[14].PngImage;
                        mbCancel: PngImage := frmMain.imlBtn20.PngImages[15].PngImage;
                        mbRetry: PngImage := frmMain.imlBtn20.PngImages[16].PngImage;
                        mbAbort: PngImage := frmMain.imlBtn20.PngImages[17].PngImage;
                        mbIgnore: PngImage := frmMain.imlBtn20.PngImages[18].PngImage;
                        mbYes: PngImage := frmMain.imlBtn20.PngImages[19].PngImage;
                        mbNo: PngImage := frmMain.imlBtn20.PngImages[20].PngImage;
                        mbYesToAll: if ListOnlyUSBDrives then
                              PngImage := frmMain.imlVST20.PngImages[1].PngImage
                           else
                              PngImage := frmMain.imlVST20.PngImages[2].PngImage;
                        mbNoToAll: PngImage := frmMain.imlBtn20.PngImages[20].PngImage;
                     end;
                  24:
                     case b of
                        mbOK: PngImage := frmMain.imlBtn24.PngImages[14].PngImage;
                        mbCancel: PngImage := frmMain.imlBtn24.PngImages[15].PngImage;
                        mbRetry: PngImage := frmMain.imlBtn24.PngImages[16].PngImage;
                        mbAbort: PngImage := frmMain.imlBtn24.PngImages[17].PngImage;
                        mbIgnore: PngImage := frmMain.imlBtn24.PngImages[18].PngImage;
                        mbYes: PngImage := frmMain.imlBtn24.PngImages[19].PngImage;
                        mbNo: PngImage := frmMain.imlBtn24.PngImages[20].PngImage;
                        mbYesToAll: if ListOnlyUSBDrives then
                              PngImage := frmMain.imlVST24.PngImages[1].PngImage
                           else
                              PngImage := frmMain.imlVST24.PngImages[2].PngImage;
                        mbNoToAll: PngImage := frmMain.imlBtn24.PngImages[20].PngImage;
                     end;
               end;
               ModalResult := ModalResults[b];
               if b = DefaultButton then
               begin
                  Default := True;
                  ActiveControl := LButton;
               end;
               if b = CancelButton then
                  Cancel := True;
               SetBounds(X, IconTextHeight + VertMargin + VertSpacing, ButtonWidth, ButtonHeight);
               Inc(X, ButtonWidth + ButtonSpacing);
               if b = mbHelp then
                  OnClick := TMessageForm(msgForm).HelpButtonClick;
               if b = DefaultButton then
                  if Snap then
                     SetCursorPos(msgForm.ClientOrigin.X + Left + ButtonWidth div 2, msgForm.ClientOrigin.Y + Top + Height div 2);
            end;
         end;
      MessageBeep(Sounds[DlgType]);
      Result := ShowModal;
      if AddCb then
         cbConfirmationSt := TMessageForm(msgForm).cbConfirmation.Checked;
      try
         msgForm.Free;
      except
      end;
   end;
end;

function GetStrBusType(const BusType: Byte): string;
begin
   case BusType of
      1:
         Result := 'SCSI';
      2:
         Result := 'ATAPI';
      3:
         Result := 'ATA';
      4:
         Result := 'FIREWIRE';
      5:
         Result := 'SSA';
      6:
         Result := 'FIBRE';
      7:
         Result := 'USB';
      8:
         Result := 'RAID';
      9:
         Result := 'iSCSI';
      10:
         Result := 'SAS';
      11:
         Result := 'SATA';
      12:
         Result := 'SD';
      13:
         Result := 'MMC';
      14, 15:
         Result := 'VIRTUAL';
      17:
         Result := 'NVMe';
      else
         Result := '';
   end;
end;

function GetIntBusType(const BusType: string): Byte;
begin
   if BusType = 'UNKNOWN' then
      Result := 0
   else if BusType = 'SCSI' then
      Result := 1
   else if BusType = 'ATAPI' then
      Result := 2
   else if BusType = 'ATA' then
      Result := 3
   else if BusType = 'FIREWIRE' then
      Result := 4
   else if BusType = 'SSA' then
      Result := 5
   else if BusType = 'FIBRE' then
      Result := 6
   else if BusType = 'USB' then
      Result := 7
   else if BusType = 'RAID' then
      Result := 8
   else if BusType = 'iSCSI' then
      Result := 9
   else if BusType = 'SAS' then
      Result := 10
   else if BusType = 'SATA' then
      Result := 11
   else if BusType = 'SD' then
      Result := 12
   else if BusType = 'MMC' then
      Result := 13
   else if BusType = 'VIRTUAL' then
      Result := 14
   else if BusType = 'NVMe' then
      Result := 16
   else
      Result := 0;
end;

function TfrmMain.GetItemIndex: Integer;
var
   Node: PVirtualNode;
begin
   Result := -1;
   Node := vstVMs.GetFirstSelected;
   if Node = nil then
      Exit;
   Result := Node.Index;
end;

{procedure ColorBlend(Canvas: TCanvas; const Rect: TRect; BlendColor: TColor; BlendValue: Integer);
var
   Bitmap: TBitmap;
begin
   if VirtualTrees.MMXAvailable then
      VirtualTrees.Utils.AlphaBlend(0, Canvas.Handle, Rect, Rect.TopLeft, bmConstantAlphaAndColor, BlendValue, ColorToRGB(BlendColor))
   else
   begin
      Bitmap := TBitmap.Create;
      try
         Bitmap.Canvas.Brush.Color := BlendColor;
         Bitmap.SetSize(Rect.Width, Rect.Height);
         Bitmap.Canvas.FillRect(Rect);
         Canvas.Draw(Rect.Left, Rect.Top, Bitmap, BlendValue);
      finally
         Bitmap.Free;
      end;
   end;
end;}

procedure TfrmMain.vstVMsAdvancedHeaderDraw(Sender: TVTHeader; var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements);
var
   r: TRect;
   Tree: TVirtualStringTree;
   Details: TThemedElementDetails;
   RightBorderFlag: Cardinal;
   NormalButtonStyle: Cardinal;
   NormalButtonFlags: Cardinal;
   PressedButtonStyle: Cardinal;
   PressedButtonFlags: Cardinal;
   RaisedButtonStyle: Cardinal;
   RaisedButtonFlags: Cardinal;

   procedure PrepareButtonStyles;
   begin
      RaisedButtonStyle := 0;
      RaisedButtonFlags := 0;
      case Sender.Style of
         hsThickButtons:
            begin
               NormalButtonStyle := BDR_RAISEDINNER or BDR_RAISEDOUTER;
               NormalButtonFlags := BF_LEFT or BF_TOP or BF_BOTTOM or BF_MIDDLE or BF_SOFT or BF_ADJUST;
               PressedButtonStyle := BDR_RAISEDINNER or BDR_RAISEDOUTER;
               PressedButtonFlags := NormalButtonFlags or BF_RIGHT or BF_FLAT or BF_ADJUST;
            end;
         hsFlatButtons:
            begin
               NormalButtonStyle := BDR_RAISEDINNER;
               NormalButtonFlags := BF_LEFT or BF_TOP or BF_BOTTOM or BF_MIDDLE or BF_ADJUST;
               PressedButtonStyle := BDR_SUNKENOUTER;
               PressedButtonFlags := BF_RECT or BF_MIDDLE or BF_ADJUST;
            end;
         else
            begin
               NormalButtonStyle := BDR_RAISEDINNER;
               NormalButtonFlags := BF_RECT or BF_MIDDLE or BF_SOFT or BF_ADJUST;
               PressedButtonStyle := BDR_SUNKENOUTER;
               PressedButtonFlags := BF_RECT or BF_MIDDLE or BF_ADJUST;
               RaisedButtonStyle := BDR_RAISEDINNER;
               RaisedButtonFlags := BF_LEFT or BF_TOP or BF_BOTTOM or BF_MIDDLE or BF_ADJUST;
            end;
      end;
   end;

begin
   if hpeBackground in Elements then
   begin
      IntersectRect(r, PaintInfo.PaintRectangle, vstVMs.HeaderRect);
      Tree := TVirtualStringTree(Sender.Treeview);

      // if there is no column assigned, the header background is painted
      if not Assigned(PaintInfo.Column) then
      begin
         // let VCL Styles draw the stuff by themselves
         if (Tree.VclStyleEnabled and (seClient in Tree.StyleElements)) then
         begin
            Details := StyleServices.GetElementDetails(thHeaderItemRightNormal);
            StyleServices.DrawElement(PaintInfo.TargetCanvas.Handle, Details, r, @r);
         end
         else if tsUseThemes in Tree.TreeStates then
         begin
            PaintInfo.TargetCanvas.Brush.Color := Sender.Background;
            PaintInfo.TargetCanvas.FillRect(r);
         end
         else
            // otherwise just fill the rectangle
         begin
            PaintInfo.TargetCanvas.Brush.Color := Sender.Background;
            PaintInfo.TargetCanvas.FillRect(r);
         end;
      end
      else
         // header plate is painted
      begin
         // let VCL Styles draw the stuff by themselves
         if Tree.VclStyleEnabled and (seClient in Tree.StyleElements) then
         begin
            if PaintInfo.IsDownIndex then
               Details := StyleServices.GetElementDetails(thHeaderItemPressed)
            else if PaintInfo.IsHoverIndex then
               Details := StyleServices.GetElementDetails(thHeaderItemHot)
            else
               Details := StyleServices.GetElementDetails(thHeaderItemNormal);
            StyleServices.DrawElement(PaintInfo.TargetCanvas.Handle, Details, r, @r);
         end
         else
         begin
            // themes are enabled for the tree, so...
            if tsUseThemes in Tree.TreeStates then
            begin
               PrepareButtonStyles;

               if PaintInfo.ShowRightBorder or (PaintInfo.Column.Index < Sender.Columns.Count - 1) then
                  RightBorderFlag := BF_RIGHT
               else
                  RightBorderFlag := 0;

               if PaintInfo.IsDownIndex then
                  DrawEdge(PaintInfo.TargetCanvas.Handle, r, PressedButtonStyle, PressedButtonFlags)
               else if (Sender.Style = hsPlates) and PaintInfo.IsHoverIndex and (coAllowClick in PaintInfo.Column.Options) and (coEnabled in PaintInfo.Column.Options) then
                  DrawEdge(PaintInfo.TargetCanvas.Handle, r, RaisedButtonStyle, RaisedButtonFlags or RightBorderFlag)
               else
                  DrawEdge(PaintInfo.TargetCanvas.Handle, r, NormalButtonStyle, NormalButtonFlags or RightBorderFlag);
            end
            else
            begin
               // draw non-themed plate
               PrepareButtonStyles;

               if PaintInfo.ShowRightBorder or (PaintInfo.Column.Index < Sender.Columns.Count - 1) then
                  RightBorderFlag := BF_RIGHT
               else
                  RightBorderFlag := 0;

               if PaintInfo.IsDownIndex then
                  DrawEdge(PaintInfo.TargetCanvas.Handle, r, PressedButtonStyle, PressedButtonFlags)
               else if (Sender.Style = hsPlates) and PaintInfo.IsHoverIndex and (coAllowClick in PaintInfo.Column.Options) and (coEnabled in PaintInfo.Column.Options) then
                  DrawEdge(PaintInfo.TargetCanvas.Handle, r, RaisedButtonStyle, RaisedButtonFlags or RightBorderFlag)
               else
                  DrawEdge(PaintInfo.TargetCanvas.Handle, r, NormalButtonStyle, NormalButtonFlags or RightBorderFlag);
            end;
         end;
      end;
   end;
end;

procedure TfrmMain.vstVMsAfterColumnWidthTracking(Sender: TVTHeader; Column: TColumnIndex);
var
   lvc: Integer;
begin
   if not DoColumnShift then
      Exit;
   DoColumnShift := False;
   if Column = 0 then
      Exit;
   if Sender.Columns.TotalWidth <> vstVMS.ClientWidth then
      Exit;
   if hoAutoResize in vstVMs.Header.Options then
      vstVMs.Header.Options := vstVMs.Header.Options - [hoAutoResize];
   vstVMS.Header.AutoSizeIndex := -1;
   lvc := vstVMs.Header.Columns.GetLastVisibleColumn;
   if lvc < 0 then
   begin
      if vstVMs.ScrollBarOptions.ScrollBars <> ssBoth then
      begin
         DoNothingOnScrollBarShow := True;
         SendMessage(vstVMs.Handle, WM_SETREDRAW, wParam(False), 0);
         vstVMs.ScrollBarOptions.ScrollBars := ssBoth;
         DoNothingOnScrollBarShow := False;
      end;
      Exit;
   end;
   vstVMs.Header.Options := vstVMs.Header.Options + [hoAutoResize];
   vstVMs.Header.AutoSizeIndex := lvc;
   vstVMs.Header.Columns[lvc].Options := vstVMs.Header.Columns[lvc].Options + [coSmartResize];
   if vstVMs.ScrollBarOptions.ScrollBars <> ssBoth then
   begin
      DoNothingOnScrollBarShow := True;
      SendMessage(vstVMs.Handle, WM_SETREDRAW, wParam(False), 0);
      vstVMs.ScrollBarOptions.ScrollBars := ssBoth;
      DoNothingOnScrollBarShow := False;
   end;
   vstVMs.Header.Options := vstVMs.Header.Options - [hoAutoResize];
   vstVMs.Header.AutoSizeIndex := -1;
   vstVMs.Header.Columns[lvc].Options := vstVMs.Header.Columns[lvc].Options - [coSmartResize];
   SaveCFG(CfgFile);
end;

procedure TfrmMain.vstVMsHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
begin
   if HitInfo.Button <> mbLeft then
      Exit;
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;
   if vstVMs.RootNodeCount > 1 then
      if HitInfo.Column > 0 then
         SortAfterColumn(HitInfo.Column);
end;

procedure TfrmMain.vstVMsHeaderDrawQueryElements(Sender: TVTHeader; var PaintInfo: THeaderPaintInfo; var Elements: THeaderPaintElements);
begin
   Elements := [hpeBackground];
end;

procedure TfrmMain.vstVMsHeaderMouseUp(Sender: TVTHeader; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button <> mbLeft then
      Exit;
   if ColumnResized then
   begin
      ColumnResized := False;
      HideAutoSustainScrollbars;
      SaveCFG(CfgFile);
   end;
end;

procedure TfrmMain.vstVMsKeyDown(Sender: TObject; var Key: Word;
   Shift: TShiftState);
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;
   if (Key = 17) and (Shift = [ssCtrl]) then
   begin
      if tmCheckCTRL.Enabled then
      begin
         tmCheckCTRL.Enabled := False;
         tmCheckCTRL.Enabled := True;
         Exit;
      end;
      case btnStart.PngImage.Width of
         16:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn16.PngImages[10].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn16.PngImages[10].PngImage;
            end;
         20:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn20.PngImages[10].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn20.PngImages[10].PngImage;
            end;
         24:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn24.PngImages[10].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn24.PngImages[10].PngImage;
            end;
      end;
      tmCheckCTRL.Enabled := True;
   end
   else
   begin
      tmCheckCTRL.Enabled := False;
      case btnStart.PngImage.Width of
         16:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn16.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn16.PngImages[0].PngImage;
            end;
         20:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn20.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn20.PngImages[0].PngImage;
            end;
         24:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn24.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn24.PngImages[0].PngImage;
            end;
      end;
   end;
end;

procedure TfrmMain.WmNclButtonDown(var Msg: TMessage);
begin
   case TWMNCLButtonDown(Msg).HitTest of
      HTBOTTOMLEFT, HTBOTTOMRIGHT, HTLEFT, HTRIGHT, HTTOPLEFT, HTTOPRIGHT:
         begin
            ColWereAligned := vstVMs.ClientWidth = vstVMs.Header.Columns.TotalWidth;
            DoNothingOnScrollBarShow := True;
            if ColWereAligned and (vstVMs.ScrollBarOptions.ScrollBars <> ssVertical) then
            begin
               SendMessage(vstVMs.Handle, WM_SETREDRAW, wParam(False), 0);
               vstVMs.ScrollBarOptions.ScrollBars := ssVertical;
            end;
         end;
   end;
   inherited;
   Msg.Result := 0;
end;

procedure TfrmMain.WmExitSizeMove(var Msg: TMessage);
begin
   inherited;
   Msg.Result := 0;
   DoNothingOnScrollBarShow := True;
   if vstVMs.ScrollBarOptions.ScrollBars <> ssBoth then
   begin
      if ColWereAligned then
         SendMessage(vstVMs.Handle, WM_SETREDRAW, wParam(False), 0);
      vstVMs.ScrollBarOptions.ScrollBars := ssBoth;
   end;
   if ColWereAligned then
      HideAutoSustainScrollbars;
   DoNothingOnScrollBarShow := False;
   SaveCFG(CfgFile);
end;

procedure TfrmMain.StartFirstDriveAnimation;
begin
   if vstVMs.GetFirstSelected = nil then
      Exit;
   if not ShowFirstDriveAnim then
   begin
      FirstDriveAnimImageIndex := AnimationStartIndex;
      ShowFirstDriveAnim := True;
   end;
   if TrayIcon.Visible and ShowFirstDriveAnim and ((not Visible) or IsIconic(Application.Handle)) then
      TrayIcon.Animate := True;
   if not tmAnimation.Enabled then
      tmAnimation.Enabled := True;
end;

procedure TfrmMain.StartSecDriveAnimation;
var
   Data: PData;
begin
   if vstVMs.GetFirstSelected = nil then
      Exit;
   Data := vstVMs.GetNodeData(vstVMs.GetFirstSelected);
   if Data^.SDDisplayName = '' then
      Exit;
   if not ShowSecDriveAnim then
   begin
      SecDriveAnimImageIndex := AnimationStartIndex;
      ShowSecDriveAnim := True;
   end;
   if TrayIcon.Visible and ShowSecDriveAnim and ((not Visible) or IsIconic(Application.Handle)) then
      TrayIcon.Animate := True;
   if not tmAnimation.Enabled then
      tmAnimation.Enabled := True;
end;

procedure TfrmMain.StartVMAnimation;
begin
   if vstVMs.GetFirstSelected = nil then
      Exit;
   if not ShowVMAnim then
   begin
      VMAnimImageIndex := AnimationStartIndex;
      ShowVMAnim := True;
   end;
   if TrayIcon.Visible and ShowVMAnim and ((not Visible) or IsIconic(Application.Handle)) then
      TrayIcon.Animate := True;
   if not tmAnimation.Enabled then
      tmAnimation.Enabled := True;
end;

procedure TfrmMain.StopFirstDriveAnimation;
var
   R: TRect;
begin
   ShowFirstDriveAnim := False;
   if TrayIcon.Visible and (not ShowSecDriveAnim) and (not ShowVMAnim) then
      if TrayIcon.Animate then
         StopTrayAnimation
      else
         SetTrayIcon;
   if tmAnimation.Enabled and (not ShowSecDriveAnim) and (not ShowVMAnim) then
   begin
      tmAnimation.Enabled := False;
      TrayIcon.Animate := False;
   end;
   if vstVMs.GetFirstSelected = nil then
      Exit;
   if coVisible in vstVMs.Header.Columns[2].Options then
   begin
      R := vstVMs.GetDisplayRect(vstVMs.GetFirstSelected, 2, False, False, False);
      R.Left := R.Left + vstVMs.Margin - 1;
      R.Right := R.Left + imlVST_items.Width;
      InvalidateRect(vstVms.Handle, &R, False);
   end;
end;

procedure TfrmMain.StopSecDriveAnimation;
var
   R: TRect;
begin
   ShowSecDriveAnim := False;
   if TrayIcon.Visible and (not ShowFirstDriveAnim) and (not ShowVMAnim) then
      if TrayIcon.Animate then
         StopTrayAnimation
      else
         SetTrayIcon;
   if tmAnimation.Enabled and (not ShowFirstDriveAnim) and (not ShowVMAnim) then
      tmAnimation.Enabled := False;
   if vstVMs.GetFirstSelected = nil then
      Exit;
   if coVisible in vstVMs.Header.Columns[3].Options then
   begin
      R := vstVMs.GetDisplayRect(vstVMs.GetFirstSelected, 3, False, False, False);
      R.Left := R.Left + vstVMs.Margin - 1;
      R.Right := R.Left + imlVST_items.Width;
      InvalidateRect(vstVms.Handle, &R, False);
   end;
end;

procedure TfrmMain.StopVMAnimation;
var
   R: TRect;
begin
   ShowVMAnim := False;
   if TrayIcon.Visible and (not ShowSecDriveAnim) and (not ShowFirstDriveAnim) then
      if TrayIcon.Animate then
         StopTrayAnimation
      else
         SetTrayIcon;
   if tmAnimation.Enabled and (not ShowFirstDriveAnim) and (not ShowSecDriveAnim) then
      tmAnimation.Enabled := False;
   if vstVMs.GetFirstSelected = nil then
      Exit;
   if coVisible in vstVMs.Header.Columns[1].Options then
   begin
      R := vstVMs.GetDisplayRect(vstVMs.GetFirstSelected, 1, False, False, False);
      R.Left := R.Left + vstVMs.Margin - 1;
      R.Right := R.Left + imlVST_items.Width;
      InvalidateRect(vstVms.Handle, &R, False);
   end;
   if (not ShowFirstDriveAnim) and (not ShowSecDriveAnim) then
      TrayIcon.Animate := False;
end;

procedure Wait(dt: DWORD);
var
   tc: DWORD;
begin
   tc := GetTickCount;
   while (GetTickCount < tc + dt) and (not Application.Terminated) do
   begin
      mEvent.WaitFor(1);
      Application.ProcessMessages;
   end;
end;

procedure SetThemeDependantParams;

   function Blend(Color1, Color2: TColor; A: Byte): TColor;
   var
      c1, c2: LongInt;
      r, g, b: Byte;
      v1, v2: byte;
   begin
      c1 := ColorToRGB(Color1);
      c2 := ColorToRGB(Color2);
      v1 := Byte(c1);
      v2 := Byte(c2);
      r := Byte(A * (v1 - v2) shr 8 + v2);
      v1 := Byte(c1 shr 8);
      v2 := Byte(c2 shr 8);
      g := Byte(A * (v1 - v2) shr 8 + v2);
      v1 := Byte(c1 shr 16);
      v2 := Byte(c2 shr 16);
      b := Byte(A * (v1 - v2) shr 8 + v2);
      Result := (b shl 16) + (g shl 8) + r;
   end;

   procedure MinMax3(const i, j, k: Integer; var Min, Max: Integer);
   begin
      if i > j then
      begin
         if i > k then
            Max := i
         else
            Max := k;

         if j < k then
            Min := j
         else
            Min := k
      end
      else
      begin
         if j > k then
            Max := j
         else
            Max := k;

         if i < k then
            Min := i
         else
            Min := k
      end
   end;

const
   divisor: Integer = 255 * 60;
   BckRange = 5;
var
   Delta: Integer;
   MinValue: Integer;
   r, g, b, c, h, s, v, v1, v2, f, hTemp, p, q, t: Integer;
   SelBckItemColor, BckItemColor, TaskbarColor: TColor;
begin
   if StyleServices.Enabled then
   begin
      SelBckItemColor := StyleServices.GetSystemColor(frmMain.vstVMs.Colors.SelectionRectangleBlendColor);
      BckItemColor := StyleServices.GetStyleColor(scTreeView);
      TaskbarColor := StyleServices.GetStyleColor(scButtonNormal);
   end
   else
   begin
      SelBckItemColor := frmMain.vstVMs.Colors.SelectionRectangleBlendColor;
      BckItemColor := frmMain.vstVMs.Color;
      TaskbarColor := clBtnFace;
   end;

   SelBckItemColor := Blend(SelBckItemColor, BckItemColor, frmMain.vstVMs.SelectionBlendFactor);

   c := ColorToRGB(SelBckItemColor);
   r := GetRValue(c);
   g := GetGValue(c);
   b := GetBValue(c);
   MinMax3(r, g, b, MinValue, v);
   if v <= 127 then
   begin
      AnimationStartIndex := 64; //white "busy"
      AnimationEndIndex := 109;
   end
   else
   begin
      AnimationStartIndex := 16; //dark blue "busy"
      AnimationEndIndex := 61;
   end;

   c := ColorToRGB(TaskbarColor);
   r := GetRValue(c);
   g := GetGValue(c);
   b := GetBValue(c);
   MinMax3(r, g, b, MinValue, v);
   // Showmessage(Inttostr(r) + ' ' + Inttostr(g) + ' ' + Inttostr(b) + '   ' + Inttostr(v));
   if v <= 127 then
   begin
      AnimTrayStartCopyIndex := 51; //white "busy"
   end
   else
   begin
      AnimTrayStartCopyIndex := 3; //dark blue "busy"
   end;

   c := ColorToRGB(BckItemColor);
   r := GetRValue(c);
   g := GetGValue(c);
   b := GetBValue(c);
   MinMax3(r, g, b, MinValue, v);
   Delta := v - MinValue;
   h := 0;
   if v = 0 then
      s := 0
   else
      s := (255 * Delta) div v;
   if s = 0 then
      h := 0
   else
   begin
      if r = v then
         h := (60 * (g - b)) div Delta
      else if g = v then
         h := 120 + (60 * (b - r)) div Delta
      else if b = v then
         h := 240 + (60 * (r - g)) div Delta;

      if h < 0 then
         h := h + 360;
   end;

   if v <= 127 then
   begin
      if (v >= BckRange) and (v <= (255 - BckRange)) then
      begin
         v1 := v - BckRange;
         v2 := v + BckRange;
      end
      else if v > 245 then
      begin
         v1 := 255 - 2 * BckRange;
         v2 := 255;
      end
      else
      begin
         v1 := 0;
         v2 := 2 * 7;
      end;
   end
   else
   begin
      if (v >= BckRange) and (v <= (255 - BckRange)) then
      begin
         v1 := v + BckRange;
         v2 := v - BckRange;
      end
      else if v > (255 - BckRange) then
      begin
         v1 := 255;
         v2 := 255 - 2 * BckRange;
      end
      else
      begin
         v1 := 2 * BckRange;
         v2 := 0;
      end;
   end;

   if s = 0 then
   begin
      r := v1;
      g := v1;
      b := v1;
   end
   else
   begin
      if h = 360 then
         hTemp := 0
      else
         hTemp := h;

      f := hTemp mod 60;
      hTemp := hTemp div 60;

      p := v1 - v1 * s div 255;
      q := v1 - (v1 * s * f) div divisor;
      t := v1 - (v1 * s * (60 - f)) div divisor;

      case hTemp of
         0:
            begin
               r := v1;
               g := t;
               b := p;
            end;
         1:
            begin
               r := q;
               g := v1;
               b := p;
            end;
         2:
            begin
               r := p;
               g := v1;
               b := t;
            end;
         3:
            begin
               r := p;
               g := q;
               b := v1;
            end;
         4:
            begin
               r := t;
               g := p;
               b := v1;
            end;
         5:
            begin
               r := v1;
               g := p;
               b := q;
            end;
         else
            begin
               r := v1;
               g := v1;
               b := v1;
            end
      end
   end;
   DarkenBckColor := RGB(r, g, b);

   if s = 0 then
   begin
      r := v2;
      g := v2;
      b := v2;
   end
   else
   begin
      if h = 360 then
         hTemp := 0
      else
         hTemp := h;

      f := hTemp mod 60;
      hTemp := hTemp div 60;

      p := v2 - v2 * s div 255;
      q := v2 - (v2 * s * f) div divisor;
      t := v2 - (v2 * s * (60 - f)) div divisor;

      case hTemp of
         0:
            begin
               r := v2;
               g := t;
               b := p;
            end;
         1:
            begin
               r := q;
               g := v2;
               b := p;
            end;
         2:
            begin
               r := p;
               g := v2;
               b := t;
            end;
         3:
            begin
               r := p;
               g := q;
               b := v2;
            end;
         4:
            begin
               r := t;
               g := p;
               b := v2;
            end;
         5:
            begin
               r := v2;
               g := p;
               b := q;
            end;
         else
            begin
               r := v2;
               g := v2;
               b := v2;
            end
      end
   end;
   BrightenBckColor := RGB(r, g, b);
end;

procedure TfrmMain.mmOpenInEXplorerClick(Sender: TObject);
var
   eStartupInfo: TStartupInfo;
   eProcessInfo: TProcessInformation;
   exeCmd, dirName: string;
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;
   if vstVMs.GetFirstSelected = nil then
      Exit;
   try
      dirName := PathsToOpen[Min(High(PathsToOpen), Max(Low(PathsToOPen), StrToIntDef(Copy((Sender as TMenuItem).Name, 15, Length((Sender as TMenuItem).Name) - 14), 0)))];
      FillChar(eStartupInfo, SizeOf(eStartupInfo), #0);
      eStartupInfo.dwFlags := STARTF_USESHOWWINDOW;
      eStartupInfo.cb := SizeOf(eStartupInfo);
      eStartupInfo.wShowWindow := SW_SHOW;
      exeCmd := 'explorer.exe /n,/root,' + dirName;
      UniqueString(exeCmd);
      UniqueString(dirName);
      if CreateProcess(nil, PChar(exeCmd), nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PChar(dirName), eStartupInfo, eProcessInfo) then
      begin
         WaitForInputIdle(eProcessInfo.hProcess, 5000);
         try
            CloseHandle(eProcessInfo.hProcess);
            CloseHandle(eProcessInfo.hThread);
         except
         end;
      end
      else
      begin
         LastError := GetLastError;
         CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'ExplorerUnableLaunch'], [SysErrorMessage(LastError)], 'Unable to launch Windows Explorer!'#13#10#13#10'System message: %s')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
      end;
   finally

   end;
end;

function GetDrivesDevInstByDeviceNumber(DeviceNumber: Integer): DEVINST;
var
   StorageGUID: TGUID;
   hDevInfo: MainForm.HDEVINFO;
   dwIndex: DWORD;
   res: BOOL;
   pspdidd: PSPDeviceInterfaceDetailData;
   spdid: SP_DEVICE_INTERFACE_DATA;
   spdd: SP_DEVINFO_DATA;
   dwSize: DWORD;
   hDrive: THandle;
   sdn: STORAGE_DEVICE_NUMBER;
   dwBytesReturned: DWORD;
   prevLastError: Cardinal;
begin
   Result := 0;
   StorageGUID := GUID_DEVINTERFACE_DISK;
   ResetLastError;
   try
      hDevInfo := SetupDiGetClassDevs(@StorageGUID, nil, 0, DIGCF_PRESENT or DIGCF_DEVICEINTERFACE);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         LastExceptionStr := E.Message;
         Exit;
      end;
   end;
   if NativeUInt(hDevInfo) <> INVALID_HANDLE_VALUE then
   try
      dwIndex := 0;
      spdid.cbSize := SizeOf(spdid);

      while true do
      begin
         try
            try
               prevLastError := LastError;
               res := SetupDiEnumDeviceInterfaces(hDevInfo, nil, StorageGUID, dwIndex, spdid);
               LastError := GetLastError;
               if (LastError = ERROR_NO_MORE_ITEMS) and (LastError > 0) and (LastError <> ERROR_NO_MORE_ITEMS) then
                  LastError := prevLastError;
               if not res then
                  Break;
            except
               on E: Exception do
               begin
                  LastExceptionStr := E.Message;
                  Exit;
               end;
            end;
            dwSize := 0;
            try
               prevLastError := LastError;
               SetupDiGetDeviceInterfaceDetail(hDevInfo, @spdid, nil, 0, dwSize, nil);
               LastError := GetLastError;
               if (LastError = ERROR_NO_MORE_ITEMS) and (LastError > 0) and (LastError <> ERROR_NO_MORE_ITEMS) then
                  LastError := prevLastError;
            except
               on E: Exception do
               begin
                  LastExceptionStr := E.Message;
                  Exit;
               end;
            end;
            if dwSize <> 0 then
            begin
               pspdidd := AllocMem(dwSize);
               try
                  {$IFDEF WIN32}
                  pspdidd.cbSize := SizeOf(TSPDeviceInterfaceDetailData);
                  {$ENDIF}
                  {$IFDEF WIN64}
                  pspdidd.cbSize := 8;
                  {$ENDIF}
                  ZeroMemory(@spdd, sizeof(spdd));
                  spdd.cbSize := SizeOf(spdd);
                  try
                     prevLastError := LastError;
                     res := SetupDiGetDeviceInterfaceDetail(hDevInfo, @spdid, pspdidd, dwSize, dwSize, @spdd);
                     LastError := GetLastError;
                     if (LastError = ERROR_NO_MORE_ITEMS) and (LastError > 0) and (LastError <> ERROR_NO_MORE_ITEMS) then
                        LastError := prevLastError;
                     if not res then
                        Continue;
                  except
                     on E: Exception do
                     begin
                        LastExceptionStr := E.Message;
                        Exit;
                     end;
                  end;
                  try
                     prevLastError := LastError;
                     hDrive := CreateFile(pspdidd.DevicePath, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
                     LastError := GetLastError;
                     if (LastError = ERROR_NO_MORE_ITEMS) and (LastError > 0) and (LastError <> ERROR_NO_MORE_ITEMS) then
                        LastError := prevLastError;
                     if hDrive = INVALID_HANDLE_VALUE then
                        Continue;
                     dwBytesReturned := 0;
                     try
                        prevLastError := LastError;
                        res := DeviceIoControl(hDrive, IOCTL_STORAGE_GET_DEVICE_NUMBER, nil, 0, @sdn, sizeof(sdn), dwBytesReturned, nil);
                        LastError := GetLastError;
                        if (LastError = ERROR_NO_MORE_ITEMS) and (LastError > 0) and (LastError <> ERROR_NO_MORE_ITEMS) then
                           LastError := prevLastError;
                     finally
                        try
                           CloseHandle(hDrive);
                        except
                        end;
                     end;
                     if not res then
                        Continue;
                     if DeviceNumber = Integer(sdn.DeviceNumber) then
                     begin
                        Result := spdd.DevInst;
                        Exit;
                     end;
                  except
                     on E: Exception do
                        LastExceptionStr := E.Message;
                  end;
               finally
                  FreeMem(pspdidd);
               end;
            end;
         finally
            Inc(dwIndex);
         end;
      end;
   finally
      SetupDiDestroyDeviceInfoList(hDevInfo);
   end;
end;

function ServiceCreate(const sBinPath: string; sService: string = 'VBoxDRV'; const DisplayName: string = ''): Boolean;
var
   schSCManager, schService: SC_HANDLE;
begin
   Result := False;
   ResetLastError;
   try
      schSCManager := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         schSCManager := 0;
         LastExceptionStr := E.Message;
      end;
   end;
   if schSCManager = 0 then
      Exit;
   try
      if DisplayName = '' then
         schService := CreateService(schSCManager, PChar(sService), PChar('Portable' + sService), SERVICE_ALL_ACCESS, SERVICE_KERNEL_DRIVER,
            SERVICE_AUTO_START, SERVICE_ERROR_NORMAL, PChar(sBinPath), nil, nil, nil, nil, nil)
      else
         schService := CreateService(schSCManager, PChar(sService), PChar(DisplayName), SERVICE_ALL_ACCESS, SERVICE_KERNEL_DRIVER,
            SERVICE_AUTO_START, SERVICE_ERROR_NORMAL, PChar(sBinPath), nil, nil, nil, nil, nil);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         schService := 0;
         LastExceptionStr := E.Message;
      end;
   end;
   Result := schService <> 0;
   if schService <> 0 then
      CloseServiceHandle(schService);
   CloseServiceHandle(schSCManager);
end;

function ServiceStart(sService: string = 'VBoxDRV'): Boolean;
var
   schSCManager, schService: SC_HANDLE;
   ssStatus: TServiceStatus;
   dwWaitTime, dt: Cardinal;
   psTemp: PChar;
   resStart: Boolean;
begin
   Result := False;
   ResetLastError;
   try
      schSCManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         schSCManager := 0;
         LastExceptionStr := E.Message;
      end;
   end;
   if schSCManager = 0 then
      Exit;
   try
      try
         schService := OpenService(schSCManager, PChar(sService), SERVICE_START or SERVICE_QUERY_STATUS);
         LastError := GetLastError;
      except
         on E: Exception do
         begin
            schService := 0;
            LastExceptionStr := E.Message;
         end;
      end;
      if schService = 0 then
         Exit;
      try
         if not QueryServiceStatus(schService, ssStatus) then
         begin
            if ERROR_SERVICE_NOT_ACTIVE <> GetLastError() then
               Exit;
            ssStatus.dwCurrentState := SERVICE_STOPPED;
         end;
         if (ssStatus.dwCurrentState <> SERVICE_STOPPED) and (ssStatus.dwCurrentState <> SERVICE_STOP_PENDING) then
         begin
            Result := True;
            Exit;
         end;
         dt := GetTickCount;
         while ssStatus.dwCurrentState = SERVICE_STOP_PENDING do
         begin
            dwWaitTime := ssStatus.dwWaitHint div 10;
            if (dwWaitTime < 1000) then
               dwWaitTime := 1000
            else if (dwWaitTime > 10000) then
               dwWaitTime := 10000;
            if (GetTickCount - dt) > 20000 then
            begin
               LastError := 1053;
               Exit;
            end;
            mEvent.WaitFor(dwWaitTime);
            if (GetTickCount - dt) > 20000 then
            begin
               LastError := 1053;
               Exit;
            end;
            if not QueryServiceStatus(schService, ssStatus) then
            begin
               if ERROR_SERVICE_NOT_ACTIVE <> GetLastError() then
                  Exit;
               Break;
            end;
         end;

         psTemp := nil;
         try
            resStart := StartService(schService, 0, psTemp);
            LastError := GetLastError;
         except
            on E: Exception do
            begin
               resStart := False;
               LastExceptionStr := E.Message;
            end;
         end;
         if not resStart then
            Exit;

         if not QueryServiceStatus(schService, ssStatus) then
         begin
            if ERROR_SERVICE_NOT_ACTIVE <> GetLastError() then
               Exit;
            ssStatus.dwCurrentState := SERVICE_STOPPED;
         end;

         dt := GetTickCount;
         while (ssStatus.dwCurrentState = SERVICE_START_PENDING) do
         begin
            dwWaitTime := ssStatus.dwWaitHint div 10;

            if (dwWaitTime < 1000) then
               dwWaitTime := 1000
            else if (dwWaitTime > 10000) then
               dwWaitTime := 10000;
            if (GetTickCount - dt) > 20000 then
            begin
               LastError := 1053;
               Exit;
            end;
            mEvent.WaitFor(dwWaitTime);
            if (GetTickCount - dt) > 20000 then
            begin
               LastError := 1053;
               Exit;
            end;
            if not QueryServiceStatus(schService, ssStatus) then
            begin
               if ERROR_SERVICE_NOT_ACTIVE <> GetLastError() then
                  Exit;
               ssStatus.dwCurrentState := SERVICE_STOPPED;
               Break;
            end;
         end;
         Result := ssStatus.dwCurrentState = SERVICE_RUNNING;
      finally
         CloseServiceHandle(schService);
      end;
   finally
      CloseServiceHandle(schSCManager);
   end;
end;

function ServiceDisplayName(sService: string = 'VBoxDRV'): string;
var
   schSCManager, schService: SC_HANDLE;
   lpcchBuffer: DWORD;
   lpServiceName, lpDisplayName: array[0..255] of Char;
   resDN: Boolean;
begin
   Result := '';
   ResetLastError;
   try
      schSCManager := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         schSCManager := 0;
         LastExceptionStr := E.Message;
      end;
   end;
   if schSCManager = 0 then
      Exit;
   try
      try
         schService := OpenService(schSCManager, PChar(sService), SERVICE_QUERY_STATUS);
         LastError := GetLastError;
      except
         on E: Exception do
         begin
            schService := 0;
            LastExceptionStr := E.Message;
         end;
      end;
      if schService = 0 then
         Exit;
      try
         lpcchBuffer := SizeOf(lpServiceName);
         StrLCopy(lpServiceName, PChar(sService), lpcchBuffer);
         try
            resDN := GetServiceDisplayName(schSCManager, lpServiceName, lpDisplayName, lpcchBuffer);
            LastError := GetLastError;
         except
            on E: Exception do
            begin
               resDN := False;
               LastExceptionStr := E.Message;
            end;
         end;
         if not resDN then
            Exit;
         Result := lpDisplayName;
      finally
         CloseServiceHandle(schService);
      end;
   finally
      CloseServiceHandle(schSCManager);
   end;
end;

function ServiceStop(sService: string = 'VBoxDRV'): Boolean;
var
   schSCManager, schService: SC_HANDLE;
   ssStatus: TServiceStatus;
   dwChkP: DWord;
   dwWaitTime, dt: Cardinal;
   resStop: Boolean;
begin
   Result := False;
   ResetLastError;
   try
      schSCManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         schSCManager := 0;
         LastExceptionStr := E.Message;
      end;
   end;
   if schSCManager = 0 then
      Exit;
   try
      schService := OpenService(schSCManager, PChar(sService), SERVICE_STOP or SERVICE_QUERY_STATUS);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         schService := 0;
         LastExceptionStr := E.Message;
      end;
   end;
   if schService = 0 then
      Exit;
   try
      resStop := ControlService(schService, SERVICE_CONTROL_STOP, ssStatus);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         resStop := False;
         LastExceptionStr := E.Message;
      end;
   end;
   if not resStop then
      Exit;
   try
      dt := GetTickCount;
      if QueryServiceStatus(schService, ssStatus) then
         while SERVICE_STOPPED <> ssStatus.dwCurrentState do
         begin
            dwChkP := ssStatus.dwCheckPoint;
            dwWaitTime := ssStatus.dwWaitHint div 10;
            if (dwWaitTime < 1000) then
               dwWaitTime := 1000
            else if (dwWaitTime > 10000) then
               dwWaitTime := 10000;
            if (GetTickCount - dt) > 20000 then
            begin
               LastError := 1053;
               Exit;
            end;
            mEvent.WaitFor(dwWaitTime);
            if (GetTickCount - dt) > 20000 then
            begin
               LastError := 1053;
               Exit;
            end;
            if not QueryServiceStatus(schService, ssStatus) then
               Break;
            if ssStatus.dwCheckPoint < dwChkP then
               Break;
         end;
   finally
      CloseServiceHandle(schService);
      CloseServiceHandle(schSCManager);
   end;
   Result := SERVICE_STOPPED = ssStatus.dwCurrentState;
end;

function ServiceDelete(sService: string = 'VBoxDRV'): Boolean;
var
   schSCManager, schService: SC_HANDLE;
   ssStatus: TServiceStatus;
   dwChkP: DWord;
   dwWaitTime, dt: Cardinal;
begin
   Result := False;
   ResetLastError;
   try
      schSCManager := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         schSCManager := 0;
         LastExceptionStr := E.Message;
      end;
   end;
   if schSCManager = 0 then
      Exit;
   try
      schService := OpenService(schSCManager, PChar(sService), SERVICE_ALL_ACCESS);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         schService := 0;
         LastExceptionStr := E.Message;
      end;
   end;
   if schService = 0 then
      Exit;
   dt := GetTickCount;
   if QueryServiceStatus(schService, ssStatus) then
      while SERVICE_STOP_PENDING = ssStatus.dwCurrentState do
      begin
         dwChkP := ssStatus.dwCheckPoint;
         dwWaitTime := ssStatus.dwWaitHint div 10;
         if (dwWaitTime < 1000) then
            dwWaitTime := 1000
         else if (dwWaitTime > 10000) then
            dwWaitTime := 10000;
         if (GetTickCount - dt) > 20000 then
         begin
            LastError := 1053;
            Exit;
         end;
         mEvent.WaitFor(dwWaitTime);
         if (GetTickCount - dt) > 20000 then
         begin
            LastError := 1053;
            Exit;
         end;
         if not QueryServiceStatus(schService, ssStatus) then
            Break;
         if ssStatus.dwCheckPoint < dwChkP then
            Break;
      end;
   try
      Result := DeleteService(schService);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         Result := False;
         LastExceptionStr := E.Message;
      end;
   end;
   CloseServiceHandle(schService);
   CloseServiceHandle(schSCManager);
end;

function ServiceStatus(sService: string = 'VBoxDRV'): TServiceStatus;
var
   schSCManager, schService: SC_HANDLE;
begin
   Result.dwCurrentState := 0;
   ResetLastError;
   try
      schSCManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         schSCManager := 0;
         LastExceptionStr := E.Message;
      end;
   end;
   if schSCManager = 0 then
      Exit;
   try
      schService := OpenService(schSCManager, PChar(sService), SERVICE_QUERY_STATUS);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         schService := 0;
         LastExceptionStr := E.Message;
      end;
   end;
   if schService = 0 then
      Exit;
   try
      QueryServiceStatus(schService, Result);
   finally
      CloseServiceHandle(schService);
      CloseServiceHandle(schSCManager);
   end;
end;

function SetEnvVariable(Name, Value: string): Boolean;
var
   PrevValue: string;
begin
   Result := False;
   ResetLastError;
   if GetEnvVarValue(Name) <> Value then
   try
      if Value <> '' then
         SetEnvironmentVariable(PChar(Name), PChar(Value))
      else
         SetEnvironmentVariable(PChar(Name), nil);
      MainForm.LastError := GetLastError;
   except
      on E: Exception do
         LastExceptionStr := E.Message;
   end;
   with TRegistry.Create do
   begin
      try
         RootKey := HKEY_LOCAL_MACHINE;
         OpenKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', False);
         MainForm.LastError := GetLastError;
         PrevValue := ReadString(Name);
         MainForm.LastError := GetLastError;
         if PrevValue <> Value then
         begin
            if Value <> '' then
            begin
               WriteString(Name, Value);
               MainForm.LastError := GetLastError;
               Result := True;
            end
            else
            begin
               Result := DeleteValue(Name);
               MainForm.LastError := GetLastError;
            end;
            SendNotifyMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0, LParam(PChar('Environment')));
         end
         else
            Result := True;
      except
         on E: Exception do
            LastExceptionStr := E.Message;
      end;
      Free;
   end;
end;

function InstallInf(const PathToInf, HardwareID: string): Smallint;
const
   LINE_LEN = 256;
   MAX_CLASS_NAME_LEN = 32;
   DICD_GENERATE_ID = $00000001;
   SPDRP_HARDWAREID = $00000001;
   DIF_REGISTERDEVICE = $00000019;
   INSTALLFLAG_FORCE = $00000001;
var
   hwIdList: array[0..LINE_LEN + 4] of Char;
   ClassGuid: TGUID;
   ClassName: array[0..MAX_CLASS_NAME_LEN] of Char;
   DeviceInfoSet: HDEVINFO;
   DeviceInfoData: SP_DEVINFO_DATA;
   resFct: Boolean;
   bRebootRequired: Bool;
begin
   Result := -1;
   ResetLastError;
   try
      resFct := SetupDiGetINFClass(PChar(PathToInf), ClassGUID, @ClassName, MAX_CLASS_NAME_LEN, nil);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         resFct := False;
         LastExceptionStr := E.Message;
      end;
   end;
   if not resFct then
      Exit;
   ZeroMemory(@hwIdList, SizeOf(hwIdList));
   StrCpy(hwIdList, PChar(HardwareID));
   DeviceInfoSet := nil;
   try
      DeviceInfoSet := SetupDiCreateDeviceInfoList(@ClassGUID, 0);
      LastError := GetLastError;
      resFct := DWORD(DeviceInfoSet) <> INVALID_HANDLE_VALUE;
   except
      on E: Exception do
      begin
         resFct := False;
         LastExceptionStr := E.Message;
      end;
   end;
   if not resFct then
      Exit;
   DeviceInfoData.cbSize := SizeOf(SP_DEVINFO_DATA);
   try
      resFct := SetupDiCreateDeviceInfo(DeviceInfoSet, @ClassName, ClassGUID, nil, 0, DICD_GENERATE_ID, @DeviceInfoData);
      LastError := GetLastError;
   except
      on E: Exception do
      begin
         resFct := False;
         LastExceptionStr := E.Message;
      end;
   end;
   if not resFct then
      Exit;
   try
      try
         resFct := SetupDiSetDeviceRegistryProperty(DeviceInfoSet, DeviceInfoData, SPDRP_HARDWAREID, PBYTE(@hwIdList),
            (lstrlen(@hwIdList) + 1 + 1) * SizeOf(CHAR));
         LastError := GetLastError;
      except
         on E: Exception do
         begin
            resFct := False;
            LastExceptionStr := E.Message;
         end;
      end;
      if not resFct then
         Exit;
      try
         resFct := SetupDiCallClassInstaller(DIF_REGISTERDEVICE, DeviceInfoSet, @DeviceInfoData);
         LastError := GetLastError;
      except
         on E: Exception do
         begin
            resFct := False;
            LastExceptionStr := E.Message;
         end;
      end;
      if not resFct then
         Exit;
      ResetLastError;
      try
         resFct := UpdateDriverForPlugAndPlayDevices(0, PChar(HardwareID), PChar(PathToInf), INSTALLFLAG_FORCE, @bRebootRequired);
         LastError := GetLastError;
      except
         on E: Exception do
         begin
            resFct := False;
            LastExceptionStr := E.Message;
         end;
      end;
      if not resFct then
      begin
         if (LastError = 0) and (LastExceptionStr = '') then
            Result := 0
      end
      else
         Result := 1;
   finally
      SetupDiDestroyDeviceInfoList(DeviceInfoSet);
   end;
end;

function UninstallInf(HardwareID: string): Smallint;
const
   LINE_LEN = 256;
   MAX_CLASS_NAME_LEN = 32;
   DICD_GENERATE_ID = $00000001;
   SPDRP_HARDWAREID = $00000001;
   DIF_REGISTERDEVICE = $00000019;
   SPDRP_DEVICEDESC = $00000000;
   MAX_DEVICE_ID_LEN = 200;
var
   ClassName: array[0..MAX_CLASS_NAME_LEN] of Char;
   DeviceInfoSet: HDEVINFO;
   devInfoData: SP_DEVINFO_DATA;
   devInfoListDetail: TSPDevInfoListDetailData;
   Buffer: PChar;
   BufferSize: DWORD;
   DataType, reqSize: System.Cardinal;
   LGUID: TGUID;
   i, pDel, l: Integer;
   strBuf, strToSearch: string;
   devID: array[0..MAX_DEVICE_ID_LEN] of Char;
   rmdParams: SP_REMOVEDEVICE_PARAMS;
   resFct, LGACset: Boolean;
begin
   Result := -1;
   ResetLastError;
   LGACset := False;
   pDel := Pos('\', HardwareID);
   l := Length(HardwareID);
   if (l = 0) or (pDel = 1) or (pDel = l) then
   begin
      LastExceptionStr := 'invalid hardware id';
      Exit;
   end;
   if pDel > 1 then
   begin
      strBuf := Copy(HardwareID, 1, pDel - 1);
      StrCpy(@ClassName, PChar(strBuf));
      try
         resFct := SetupDiClassGuidsFromNameEx(@ClassName, @LGUID, 1, BufferSize, '', nil);
         LastError := GetLastError;
      except
         on E: Exception do
         begin
            resFct := False;
            LastExceptionStr := E.Message;
         end;
      end;
      if not resFct then
         Exit;
      HardwareID := Copy(HardwareID, pDel + 1, l - pDel);
      LGACset := True;
   end;
   DeviceInfoSet := nil;
   try
      if LGACset then
         DeviceInfoSet := SetupDiGetClassDevs(@LGUID, nil, HWND(nil), 0)
      else
         DeviceInfoSet := SetupDiGetClassDevs(nil, nil, HWND(nil), DIGCF_ALLCLASSES);
      LastError := GetLastError;
      resFct := DWORD(DeviceInfoSet) <> INVALID_HANDLE_VALUE;
   except
      on E: Exception do
      begin
         resFct := False;
         LastExceptionStr := E.Message;
      end;
   end;
   if not resFct then
      Exit;
   try
      if LGACset then
         strToSearch := LowerCase(string(ClassName) + '\' + HardwareID)
      else
         strToSearch := LowerCase(HardwareID);
      devInfoData.cbSize := SizeOf(SP_DEVINFO_DATA);
      i := 0;
      Buffersize := 256;
      GetMem(Buffer, BufferSize);
      try
         while True do
         begin
            try
               resFct := SetupDiEnumDeviceInfo(DeviceInfoSet, i, devInfoData);
               LastError := GetLastError;
            except
               on E: Exception do
               begin
                  resFct := False;
                  LastExceptionStr := E.Message;
               end;
            end;
            if not resFct then
               Exit;
            try
               try
                  resFct := SetupDiGetDeviceRegistryProperty(DeviceInfoSet, DevInfoData, SPDRP_HARDWAREID, DataType, PByte(Buffer), BufferSize, reqSize);
                  LastError := GetLastError;
               except
                  on E: Exception do
                  begin
                     resFct := False;
                     LastExceptionStr := E.Message;
                  end;
               end;
               if not resFct then
                  Continue;
               if Result = -1 then
                  Result := 0;
               if LGACset then
                  pDel := 0
               else
                  pDel := Pos('\', Buffer);
               if PosEx(strToSearch, LowerCase(string(Buffer)), pDel + 1) = (pDel + 1) then
               begin
                  try
                     resFct := SetupDiGetDeviceRegistryProperty(DeviceInfoSet, DevInfoData, SPDRP_DEVICEDESC, DataType, PByte(Buffer), BufferSize, reqSize);
                     LastError := GetLastError;
                  except
                     on E: Exception do
                     begin
                        resFct := False;
                        LastExceptionStr := E.Message;
                     end;
                  end;
                  if not resFct then
                     Continue;
                  if Pos('virtualbox ', LowerCase(string(Buffer))) = 1 then
                  begin
                     {$IFDEF WIN32}
                     devInfoListDetail.cbSize := 550;
                     {$ENDIF}
                     {$IFDEF WIN64}
                     devInfoListDetail.cbSize := 560;
                     {$ENDIF}
                     try
                        resFct := SetupDiGetDeviceInfoListDetail(DeviceInfoSet, devInfoListDetail);
                        LastError := GetLastError;
                     except
                        on E: Exception do
                        begin
                           resFct := False;
                           LastExceptionStr := E.Message;
                        end;
                     end;
                     if not resFct then
                        Continue;
                     try
                        resFct := CM_Get_Device_ID(devInfoData.DevInst, @devID, MAX_DEVICE_ID_LEN, 0) = CR_SUCCESS;
                        LastError := GetLastError;
                     except
                        on E: Exception do
                        begin
                           resFct := False;
                           LastExceptionStr := E.Message;
                        end;
                     end;
                     if not resFct then
                        Continue;
                     rmdParams.ClassInstallHeader.cbSize := SizeOf(SP_CLASSINSTALL_HEADER);
                     rmdParams.ClassInstallHeader.InstallFunction := DIF_REMOVE;
                     rmdParams.Scope := DI_REMOVEDEVICE_GLOBAL;
                     rmdParams.HwProfile := 0;
                     try
                        resFct := SetupDiSetClassInstallParams(DeviceInfoSet, @devInfoData, @rmdParams.ClassInstallHeader, SizeOf(rmdParams));
                        LastError := GetLastError;
                        resFct := resFct and SetupDiCallClassInstaller(DIF_REMOVE, DeviceInfoSet, @devInfoData);
                        LastError := GetLastError;
                     except
                        on E: Exception do
                        begin
                           resFct := False;
                           LastExceptionStr := E.Message;
                        end;
                     end;
                     if not resFct then
                        Continue;
                     Inc(Result);
                  end;
               end;
            finally
               Inc(i);
            end;
         end;
      finally
         FreeMem(Buffer);
      end;
   finally
      SetupDiDestroyDeviceInfoList(DeviceInfoSet);
   end;
end;

function CheckInstalledInf(HardwareID: string): Smallint;
const
   LINE_LEN = 256;
   MAX_CLASS_NAME_LEN = 32;
   DICD_GENERATE_ID = $00000001;
   SPDRP_HARDWAREID = $00000001;
   DIF_REGISTERDEVICE = $00000019;
   SPDRP_DEVICEDESC = $00000000;
   MAX_DEVICE_ID_LEN = 200;
var
   ClassName: array[0..MAX_CLASS_NAME_LEN] of Char;
   DeviceInfoSet: HDEVINFO;
   devInfoData: SP_DEVINFO_DATA;
   Buffer: PChar;
   BufferSize: DWORD;
   DataType, reqSize: System.Cardinal;
   LGUID: TGUID;
   i, pDel, l: Integer;
   strBuf, strToSearch: string;
   resFct, LGACset: Boolean;
begin
   Result := -1;
   ResetLastError;
   LGACset := False;
   pDel := Pos('\', HardwareID);
   l := Length(HardwareID);
   if (l = 0) or (pDel = 1) or (pDel = l) then
   begin
      LastExceptionStr := 'invalid hardware id';
      Exit;
   end;
   if pDel > 1 then
   begin
      strBuf := Copy(HardwareID, 1, pDel - 1);
      StrCpy(@ClassName, PChar(strBuf));
      try
         resFct := SetupDiClassGuidsFromNameEx(@ClassName, @LGUID, 1, BufferSize, '', nil);
         LastError := GetLastError;
      except
         on E: Exception do
         begin
            resFct := False;
            LastExceptionStr := E.Message;
         end;
      end;
      if not resFct then
         Exit;
      HardwareID := Copy(HardwareID, pDel + 1, l - pDel);
      LGACset := True;
   end;
   DeviceInfoSet := nil;
   try
      if LGACset then
         DeviceInfoSet := SetupDiGetClassDevs(@LGUID, nil, HWND(nil), 0)
      else
         DeviceInfoSet := SetupDiGetClassDevs(nil, nil, HWND(nil), DIGCF_ALLCLASSES);
      LastError := GetLastError;
      resFct := DWORD(DeviceInfoSet) <> INVALID_HANDLE_VALUE;
   except
      on E: Exception do
      begin
         resFct := False;
         LastExceptionStr := E.Message;
      end;
   end;
   if not resFct then
      Exit;
   try
      if LGACset then
         strToSearch := LowerCase(string(ClassName) + '\' + HardwareID)
      else
         strToSearch := LowerCase(HardwareID);
      devInfoData.cbSize := SizeOf(SP_DEVINFO_DATA);
      i := 0;
      Buffersize := 256;
      GetMem(Buffer, Buffersize);
      try
         while True do
         begin
            try
               resFct := SetupDiEnumDeviceInfo(DeviceInfoSet, i, devInfoData);
               LastError := GetLastError;
            except
               on E: Exception do
               begin
                  resFct := False;
                  LastExceptionStr := E.Message;
               end;
            end;
            if not resFct then
               Exit;
            try
               try
                  resFct := SetupDiGetDeviceRegistryProperty(DeviceInfoSet, DevInfoData, SPDRP_HARDWAREID, DataType, PByte(Buffer), BufferSize, reqSize);
                  LastError := GetLastError;
               except
                  on E: Exception do
                  begin
                     resFct := False;
                     LastExceptionStr := E.Message;
                  end;
               end;
               if not resFct then
                  Continue;
               if Result = -1 then
                  Result := 0;
               if LGACset then
                  pDel := 0
               else
                  pDel := Pos('\', Buffer);
               if PosEx(strToSearch, LowerCase(string(Buffer)), pDel + 1) = (pDel + 1) then
               begin
                  try
                     resFct := SetupDiGetDeviceRegistryProperty(DeviceInfoSet, DevInfoData, SPDRP_DEVICEDESC, DataType, PByte(Buffer), BufferSize, reqSize);
                     LastError := GetLastError;
                  except
                     on E: Exception do
                     begin
                        resFct := False;
                        LastExceptionStr := E.Message;
                     end;
                  end;
                  if not resFct then
                     Continue;
                  if Pos('virtualbox ', LowerCase(string(Buffer))) = 1 then
                     Inc(Result);
               end;
            finally
               Inc(i);
            end;
         end;
      finally
         FreeMem(Buffer);
      end;
   finally
      SetupDiDestroyDeviceInfoList(DeviceInfoSet);
   end;
end;

{function TfrmMain.LoadIconFromResource(const nIndex: Integer): HIcon;
var
   hExe, hResource, hMem: THandle;
   lpResource: PByte;
   nID: Integer;
begin
   Result := 0;
   hExe := LoadLibrary(PChar(Application.ExeName));
   if hExe = 0 then
      Exit;
   hResource := FindResource(hExe, MAKEINTRESOURCE(nIndex), RT_GROUP_ICON);
   if hResource = 0 then
      Exit;
   hMem := LoadResource(hExe, hResource);
   lpResource := LockResource(hMem);
   nID := LookupIconIdFromDirectoryEx(lpResource, TRUE, 24, 24, LR_DEFAULTCOLOR);
   hResource := FindResource(hExe, MAKEINTRESOURCE(nID), MAKEINTRESOURCE(RT_ICON));
   if hResource = 0 then
      Exit;
   hMem := LoadResource(hExe, hResource);
   lpResource := LockResource(hMem);
   Result := CreateIconFromResourceEx(lpResource, SizeofResource(hExe, hResource), TRUE, $00030000, 24, 24, LR_DEFAULTCOLOR);
end;}

procedure TfrmMain.SetTrayIcon;
var
   Icon: TIcon;
begin
   Icon := TIcon.Create;
   case imlTray.Width of
      16:
         imlVST16.GetIcon(imlVST16.Count - 2 + Integer(VMisOff), Icon);
      20:
         imlVST20.GetIcon(imlVST20.Count - 2 + Integer(VMisOff), Icon);
      24:
         imlVST24.GetIcon(imlVST24.Count - 2 + Integer(VMisOff), Icon);
      28:
         imlVST28.GetIcon(imlVST28.Count - 2 + Integer(VMisOff), Icon);
      32:
         imlVST32.GetIcon(imlVST32.Count - 2 + Integer(VMisOff), Icon);
   end;
   TrayIcon.Icon := Icon;
   Icon.Free;
end;

procedure TfrmMain.StopTrayAnimation;
begin
   TrayIcon.Animate := False;
   SetTrayIcon;
end;

procedure TFrmMain.ShowTray;
begin
   ShowWindow(Application.Handle, SW_HIDE);
   TrayIcon.Visible := True;
end;

procedure TFrmMain.HideTray;
begin
   if TrayIcon.Animate then
   begin
      TrayIcon.Animate := False;
      case imlTray.Width of
         16:
            imlVST16.GetIcon(imlVST16.Count - 1, TrayIcon.Icon);
         20:
            imlVST20.GetIcon(imlVST20.Count - 1, TrayIcon.Icon);
         24:
            imlVST24.GetIcon(imlVST24.Count - 1, TrayIcon.Icon);
         28:
            imlVST28.GetIcon(imlVST28.Count - 1, TrayIcon.Icon);
         32:
            imlVST32.GetIcon(imlVST32.Count - 1, TrayIcon.Icon);
      end;
   end;
   TrayIcon.Visible := False;
   if not IsIconic(Application.Handle) then
      if not Visible then
         Show
      else if isOnModal then
         SetForegroundWindow(Application.Handle)
      else
         SetForegroundWindow(Handle);
   ShowWindow(Application.Handle, SW_SHOW);
end;

procedure TFrmMain.AppMinimize(Sender: TObject);
begin
   if TrayIcon.Visible then
   begin
      ShowWindow(Application.Handle, SW_HIDE);
      if TrayIcon.BalloonHint <> '' then
      begin
         TrayIcon.BalloonHint := '';
         Application.ProcessMessages;
      end;
      TrayIcon.BalloonHint := GetLangTextFormatDef(idxMain, ['Messages', 'AppMinToTray'], ['Virtual Machine USB Boot'],
         '%s is now minimized to tray.'#13#10'Click on the icon to restore it...');
      TrayIcon.ShowBalloonHint;
      tmCloseHint.Interval := 5000;
      tmCloseHint.Enabled := False;
      tmCloseHint.Enabled := True;
   end;
end;

procedure TFrmMain.AppRestore(Sender: TObject);
begin
   if TrayIcon.Visible then
      ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TFrmMain.StartVBNewMachineWizzard;
var
   j, k, l: Integer;
   eStartupInfo: TStartupInfo;
   eProcessInfo: TProcessInformation;
   ProcessID: THandle;
   PexeVBPath, PVBPath: PChar;
   Result: Boolean;
   strTemp: string;
   exeVBPath: string;
   Path: array[0..MAX_PATH - 1] of Char;
   dt: Cardinal;
   //     ts: TTime;
begin
   if isBusyStartVM or IsBusyManager or IsBusyEjecting then
      Exit;

   IsBusyManager := True;
   FillChar(eStartupInfo, SizeOf(eStartupInfo), #0);
   eStartupInfo.dwFlags := STARTF_USESHOWWINDOW;
   eStartupInfo.cb := SizeOf(eStartupInfo);
   eStartupInfo.wShowWindow := SW_SHOWNORMAL;
   PrestartVBFilesAgain := False;
   try
      tmCheckCTRL.Enabled := False;
      case btnStart.PngImage.Width of
         16:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn16.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn16.PngImages[0].PngImage;
            end;
         20:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn20.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn20.PngImages[0].PngImage;
            end;
         24:
            begin
               if btnStart.PngImage.Canvas.Pixels[8, 8] <> imlBtn24.PngImages[0].PngImage.Canvas.Pixels[8, 8] then
                  btnStart.PngImage := imlBtn24.PngImages[0].PngImage;
            end;
      end;
      StartVMAnimation;
      if vstVMs.GetFirstSelected <> nil then
      begin
         vstVMs.ScrollIntoView(vstVMs.GetFirstSelected, True, True);
         CurSelNode := vstVMs.GetFirstSelected.Index;
      end;
      vstVMs.SelectionLocked := True;
      if (isVBPortable and ((not FRegJobDone)) or (not FUnregJobDone)) then
         Exit;
      if PathIsRelative(PChar(Mainform.ExeVBPath)) then
      begin
         FillMemory(@Path[0], Length(Path), 0);
         PathCanonicalize(@Path[0], PChar(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + Mainform.ExeVBPath));
         if string(Path) <> '' then
            exeVBPath := Path
         else
            exeVBPath := Mainform.ExeVBPath;
      end
      else
         exeVBPath := Mainform.ExeVBPath;
      GetAllWindowsList(VBWinClass);
      l := Length(AllWindowsList);
      j := 0;
      while j < l do
      begin
         if IsWindowVisible(AllWindowsList[j].Handle) then
            if Pos('Oracle VM VirtualBox ', AllWindowsList[j].WCaption) = 1 then
               if GetFileNameAndThreadFromHandle(AllWindowsList[j].Handle, ProcessID) = LowerCase(ExtractFileName(ExeVBPath)) then
                  if not IsAppNotStartedByAdmin(ProcessID) then
                  begin
                     if IsIconic(AllWindowsList[j].Handle) then
                     begin
                        SendMessage(AllWindowsList[j].Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                        dt := GetTickCount;
                        while isIconic(AllWindowsList[j].Handle) do
                        begin
                           mEvent.WaitFor(1);
                           Application.ProcessMessages;
                           if (GetTickCount - dt) > 3000 then
                              Break;
                        end;
                     end
                     else
                        SetForegroundWindow(AllWindowsList[j].Handle);
                     mEvent.WaitFor(500);
                     if not isWindowEnabled(AllWindowsList[j].Handle) then
                     begin
                        k := 0;
                        while k < l do
                        begin
                           if IsWindowVisible(AllWindowsList[k].Handle) then
                              if j <> k then
                                 if IsWindowEnabled(AllWindowsList[k].Handle) then
                                    if GetFileNameAndThreadFromHandle(AllWindowsList[k].Handle, ProcessID) = LowerCase(ExtractFileName(ExeVBPath)) then
                                       if not IsAppNotStartedByAdmin(ProcessID) then
                                       begin
                                          SetForegroundWindow(AllWindowsList[k].Handle);
                                          Exit;
                                       end;
                           Inc(k);
                        end;
                     end
                     else
                     begin
                        keybd_event(VK_CONTROL, MapVirtualKey(VK_CONTROL, 0), 0, 0);
                        keybd_event(Ord('N'), MapVirtualKey(Ord('N'), 0), 0, 0);
                        keybd_event(Ord('N'), MapVirtualKey(Ord('N'), 0), KEYEVENTF_KEYUP, 0);
                        keybd_event(VK_CONTROL, MapVirtualKey(VK_CONTROL, 0), KEYEVENTF_KEYUP, 0);
                     end;
                     Exit;
                  end;
         Inc(j);
      end;
      if ExeVBPath <> '' then
      begin
         UniqueString(ExeVBPath);
         PexeVBPath := PChar(ExeVBPath);
      end
      else
         PexeVBPath := nil;
      if ExtractFilePath(ExeVBPath) <> '' then
         PVBPath := PChar(ExtractFilePath(ExeVBPath))
      else
         PVBPath := nil;
      strTemp := '';
      //   ts := Now;
      ResetLastError;
      try
         Result := CreateProcess(nil, PExeVBPath, nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PVBPath, eStartupInfo, eProcessInfo);
         LastError := GetLastError;
      except
         on E: Exception do
         begin
            Result := False;
            LastExceptionStr := E.Message;
         end;
      end;
      if Result then
      begin
         PrestartVBFilesAgain := True;
         while True do
         begin
            Application.ProcessMessages;
            if Application.Terminated then
               Exit;
            if WaitForSingleObject(eProcessInfo.hProcess, 20) <> WAIT_TIMEOUT then
               Break;
            GetAllWindowsList(VBWinClass);
            l := Length(AllWindowsList);
            j := 0;
            while j < l do
            begin
               if IsWindowVisible(AllWindowsList[j].Handle) then
                  if Pos('Oracle VM VirtualBox ', AllWindowsList[j].WCaption) = 1 then
                     if GetFileNameAndThreadFromHandle(AllWindowsList[j].Handle, ProcessID) = LowerCase(ExtractFileName(ExeVBPath)) then
                        if not IsAppNotStartedByAdmin(ProcessID) then
                           Break;
               Inc(j);
            end;
            if j < l then
               Break;
         end;
         keybd_event(VK_CONTROL, MapVirtualKey(VK_CONTROL, 0), 0, 0);
         keybd_event(Ord('N'), MapVirtualKey(Ord('N'), 0), 0, 0);
         keybd_event(Ord('N'), MapVirtualKey(Ord('N'), 0), KEYEVENTF_KEYUP, 0);
         keybd_event(VK_CONTROL, MapVirtualKey(VK_CONTROL, 0), KEYEVENTF_KEYUP, 0);
         try
            CloseHandle(eProcessInfo.hProcess);
            CloseHandle(eProcessInfo.hThread);
         except
         end;
      end
      else
      begin
         StopVMAnimation;
         Application.ProcessMessages;
         if not FileExists(ExeVBPath) then
            strTemp := 'file not found'
         else if LastError > 0 then
            strTemp := SysErrorMessage(LastError)
         else if LastExceptionStr <> '' then
            strTemp := LastExceptionStr
         else
            strTemp := 'Unknown error';
         CustomMessageBox(Handle, (GetLangTextFormatDef(idxMain, ['Messages', 'VBUnableLaunch'], [strTemp], 'Unable to launch VirtualBox.exe !'#13#10#13#10'System message: %s')), (GetLangTextDef(idxMessages, ['Types', 'Error'], 'Error')), mtError, [mbOk], mbOk);
      end;
   finally
      StopVMAnimation;
      IsBusyManager := False;
      vstVMs.SelectionLocked := False;
      btnManager.Down := False;
      if PrestartVBFilesAgain then
      begin
         PrestartVBFilesAgain := False;
         if PrestartVBExeFiles then
         begin
            if FPSThread <> nil then
            begin
               FPSThread.Terminate;
               FPSThread.Free;
               FPSThread := nil;
            end;
            try
               CloseHandle(svcThrProcessInfo.hProcess);
               CloseHandle(svcThrProcessInfo.hThread);
            except
            end;
            FPSJobDone := False;
            FPSThread := TPrestartThread.Create;
         end;
      end;
      //  ts := Now - ts;
        //ShowMessage('Starting VB Manager = ' + FormatDateTime('ss.zzz', ts));
   end;
end;

end.

