{
  upackage Unit
  packages multiple resources, such as files, into a single container.
  file format definition is in docs\packages.txt
  2022 LRT
}
unit
  upackage;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ustream,
    umstream, usstream;

  type
    { three bytes used to represent the file type }
    TPKGSignature = array[0..2] of char;

    { package file header }
    TPKGHeader = packed record
      signature: TPKGSignature;      { must be 'PKG' }
      version: word;                 { must be 1 }
      pageCount: word;               { total number of index pages }
      resourceCount: word;           { total number of resources }
      pageSize: byte;                { number of resources per index page }
      firstPageAddr: longint;        { location of the first index page }
      reserved: array[0..7] of byte; { reserved for future use }
    end;

    { index page }
    PPKGIndexPage = ^TPKGIndexPage;
    TPKGIndexPage = packed record
      count: byte;          { number of valid entries on this page }
      next: longint;        { position of the next index page (0 = none) }
      reserved: longint;    { reserved for future use }
    end;

    { a resource index entry }
    PPKGResource = ^TPKGResource;
    TPKGResource = packed record
      id: string12;         { resource identifier. e.g. 'sprite.bmp' }
      position: longint;    { position of resource }
      size: longint;        { size of resource in bytes }
    end;

    { used to perform search or simply listing the resources of a package }
    PPKGResourceInfo = ^TPKGResourceInfo;
    TPKGResourceInfo = packed record
      id: string12;         { resource identifier. e.g. 'sprite.bmp' }
      position: longint;    { position of resource }
      size: longint;        { size of resource in bytes }
      pageAddr: longint;    { address of the index page for this entry }
      index: byte           { resource index on this page }
    end;

    PPackage = ^TPackage;

    TPackage = object (TObject)
    public
      constructor init(stream: PStream; create: boolean);
      destructor done; virtual;
      procedure add(resourceStream: PStream; id: string12);
      function getResource(id: string12; var stream: PStream): boolean;
      function findFirst(var resourceInfo: TPKGResourceInfo): boolean;
      function findNext(var resourceInfo: TPKGResourceInfo): boolean;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _stream: PStream;
      _header: TPKGHeader;
      procedure initialize;
      procedure load;
      function createPage: longint;
      function isValid: boolean;
    end;

  const
    C_PKG_SIGNATURE : TPKGSignature = 'PKG';
    C_PKG_VERSION   = $0001;
    C_PKG_DEFAULT_PAGE_SIZE = 4;

implementation

  { TPackage public }

  constructor TPackage.init(stream: PStream; create: boolean);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
    if create then initialize else load;
  end;

  destructor TPackage.done;
  begin
    _stream^.release;
    inherited done;
  end;

  procedure TPackage.add(resourceStream: PStream; id: string12);
  var
    page: TPKGIndexPage;
    lastPageAddr: longint;
    result: word;
    resource: TPKGResource;
    resourceAddr: longint;
  begin
    { search for the last page }
    lastPageAddr := _header.firstPageAddr;
    _stream^.seek(lastPageAddr);
    result := _stream^.read(@page, sizeOf(TPKGIndexPage));
    while (not _stream^.isEOF) and (page.next <> 0) do
    begin
      lastPageAddr := page.next;
      _stream^.seek(lastPageAddr);
      result := _stream^.read(@page, sizeOf(TPKGIndexPage));
    end;
    iassert(page.next = 0, @self, 0, S_ERR_PACKAGE_CORRUPT);

    { if last page is full, we need to make a new one and update the
      next field of the last index page }
    if page.count = _header.pageSize then
    begin
      page.next := createPage;
      _stream^.seek(lastPageAddr);
      _stream^.write(@page, sizeOf(TPKGIndexPage));
      { we reload the last page }
      lastPageAddr := page.next;
      _stream^.seek(lastPageAddr);
      result := _stream^.read(@page, sizeOf(TPKGIndexPage));
    end;
    { we increment the page resource counter and save it }
    inc(page.count);
    _stream^.seek(lastPageAddr);
    _stream^.write(@page, sizeOf(TPKGIndexPage));

    { we calculate the position of the resource entry, create it and
      save it }
    resourceAddr := lastPageAddr + sizeOf(TPKGIndexPage) + (page.count - 1) * sizeOf(TPKGResource);
    resource.id := id;
    resource.position := _stream^.getSize;
    resource.size := resourceStream^.getSize;
    _stream^.seek(resourceAddr);
    _stream^.write(@resource, sizeOf(TPKGResource));

    { we save the resource data at the end }
    _stream^.seek(_stream^.getSize);
    resourceStream^.copyAllTo(_stream);

    { update the resource counter in the header }
    inc(_header.resourceCount);
    _stream^.seek(0);
    _stream^.write(@_header, sizeOf(TPKGHeader));
  end;

  function TPackage.getResource(id: string12; var stream: PStream): boolean;
  var
    pageAddr: longint;
    page: TPKGIndexPage;
    resourceIndex: byte;
    resourceAddr: longint;
    resource: TPKGResource;
    result: word;
  begin
    pageAddr := _header.firstPageAddr;
    _stream^.seek(pageAddr);
    result := _stream^.read(@page, sizeOf(TPKGIndexPage));
    resourceIndex := 0;
    while ((resourceIndex<page.count) or (page.next <> 0)) and (resource.id<>id) do
    begin
      if resourceIndex = page.count then
      begin
        pageAddr := page.next;
        _stream^.seek(pageAddr);
        result := _stream^.read(@page, sizeOf(TPKGIndexPage));
        resourceIndex := 0;
      end;
      resourceAddr := pageAddr + sizeOf(TPKGIndexPage) + resourceIndex * sizeOf(TPKGResource);
      _stream^.seek(resourceAddr);
      result := _stream^.read(@resource, sizeOf(TPKGResource));
      inc(resourceIndex);
    end;
    if resource.id = id then
    begin
      getResource := true;
      stream := new(PSubstream, initWithStream(_stream, resource.position, resource.size))
    end else
      getResource := false;
  end;

  function TPackage.findFirst(var resourceInfo: TPKGResourceInfo): boolean;
  var
    pageAddr: longint;
    page: TPKGIndexPage;
    res: word;
  begin
    findFirst := false;
    pageAddr := _header.firstPageAddr;
    _stream^.seek(pageAddr);
    res := _stream^.read(@page, sizeOf(TPKGIndexPage));
    if page.count = 0 then exit;
    _stream^.seek(pageAddr + sizeOf(TPKGIndexPage));
    res := _stream^.read(@resourceInfo, sizeof(TPKGResource));
    resourceInfo.index := 0;
    resourceInfo.pageAddr := pageAddr;
    findFirst := true;
  end;

  function TPackage.findNext(var resourceInfo: TPKGResourceInfo): boolean;
  var
    page: TPKGIndexPage;
    result: word;
    resourceAddr: longint;
  begin
    findNext := false;
    _stream^.seek(resourceInfo.pageAddr);
    result := _stream^.read(@page, sizeOf(TPKGIndexPage));
    inc(resourceInfo.index);
    if (resourceInfo.index = _header.pageSize) then
    begin
      if page.next = 0 then exit;
      resourceInfo.pageAddr := page.next;
      resourceInfo.index := 0;
      _stream^.seek(page.next);
      result := _stream^.read(@page, sizeOf(TPKGIndexPage));
    end;
    if resourceInfo.index = page.count then exit;
    with resourceInfo do
      resourceAddr := pageAddr + sizeOf(TPKGIndexPage) + index * sizeOf(TPKGResource);
    _stream^.seek(resourceAddr);
    result := _stream^.read(@resourceInfo, sizeOf(TPKGResource));
    findNext := true;
  end;

  function TPackage.getClassName: string;
  begin
    getClassName := 'TPackage';
  end;

  function TPackage.getClassId: word;
  begin
    getClassId := C_CLASS_ID_PACKAGE;
  end;

  { TPackage private }

  procedure TPackage.initialize;
  begin
    { create and write package header }
    with _stream^, _header do
    begin
      signature := C_PKG_SIGNATURE;
      version := C_PKG_VERSION;
      pageCount := 1;
      resourceCount := 0;
      pageSize := C_PKG_DEFAULT_PAGE_SIZE;
      firstPageAddr := sizeof(TPKGHeader);
      fillChar(reserved, sizeOf(reserved), 0);
      seek(0);
      write(@_header, sizeof(TPKGHeader));
    end;
    { create and write first index page }
    createPage;
  end;

  procedure TPackage.load;
  begin
    _stream^.seek(0);
    _stream^.read(@_header, sizeOf(TPKGHeader));
    iassert(isValid, @self, 0, S_ERR_PACKAGE_CORRUPT);
  end;

  function TPackage.createPage:longint;
  var
    page: TPKGIndexPage;
    resource: TPKGResource;
    i: word;
    position: longint;
  begin
    fillchar(page, sizeof(TPKGIndexPage), 0);
    fillchar(resource, sizeof(TPKGResource), 0);
    with _stream^ do
    begin
      position := getSize;
      seek(position);
      write(@page, sizeof(TPKGIndexPage));
      for i := 1 to _header.pageSize do write(@resource, sizeOf(TPKGResource));
    end;
    inc(_header.pageCount);
    _stream^.seek(0);
    _stream^.write(@_header, sizeOf(TPKGHeader));
    createPage := position;
  end;

  function TPackage.isValid: boolean;
  begin
    with _header do
      isValid :=
        (signature = C_PKG_SIGNATURE) and
        (version <= C_PKG_VERSION) and
        (pageCount > 0) and
        (pageSize > 0);
  end;

  { Other }

end.