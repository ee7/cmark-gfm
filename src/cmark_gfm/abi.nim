import std/os
from system/ansi_c import c_free
export c_free

const cmarkDir = currentSourcePath().parentDir().parentDir().parentDir() / "cmark-gfm"
const libPath = cmarkDir / "build" / "src" / "libcmark-gfm.a"

static:
  if not fileExists(libPath):
    echo "running make..."
    let (outp, errC) = gorgeEx("make --directory=" & cmarkDir)
    if errC != 0:
      echo outp
      quit 1

{.passL: libPath.}

type
  enumcmarknodetype* {.size: sizeof(cuint).} = enum
    Cmarknodenone = 0, Cmarknodedocument = 32769, Cmarknodeblockquote = 32770,
    Cmarknodelist = 32771, Cmarknodeitem = 32772, Cmarknodecodeblock = 32773,
    Cmarknodehtmlblock = 32774, Cmarknodecustomblock = 32775,
    Cmarknodeparagraph = 32776, Cmarknodeheading = 32777,
    Cmarknodethematicbreak = 32778, Cmarknodefootnotedefinition = 32779,
    Cmarknodetext = 49153, Cmarknodesoftbreak = 49154,
    Cmarknodelinebreak = 49155, Cmarknodecode = 49156,
    Cmarknodehtmlinline = 49157, Cmarknodecustominline = 49158,
    Cmarknodeemph = 49159, Cmarknodestrong = 49160, Cmarknodelink = 49161,
    Cmarknodeimage = 49162, Cmarknodefootnotereference = 49163

  enumcmarklisttype* {.size: sizeof(cuint).} = enum
    Cmarknolist = 0, Cmarkbulletlist = 1, Cmarkorderedlist = 2

  enumcmarkdelimtype* {.size: sizeof(cuint).} = enum
    Cmarknodelim = 0, Cmarkperioddelim = 1, Cmarkparendelim = 2

  enumcmarkeventtype* {.size: sizeof(cuint).} = enum
    Cmarkeventnone = 0, Cmarkeventdone = 1, Cmarkevententer = 2,
    Cmarkeventexit = 3

  structiowidedata* = distinct object
  structcmarkparser* = distinct object
  structcmarksyntaxextension* = distinct object
  structcmarkiter* = distinct object
  structiocodecvt* = distinct object
  structcmarknode* = distinct object
  structiomarker* = distinct object
  cmarknodetype* = enumcmarknodetype
  cmarklisttype* = enumcmarklisttype
  cmarkdelimtype* = enumcmarkdelimtype
  cmarknode* = structcmarknode
  cmarkparser* = structcmarkparser
  cmarkiter* = structcmarkiter
  cmarksyntaxextension* = structcmarksyntaxextension

  structcmarkmem* {.pure, inheritable, bycopy.} = object
    calloc*: proc (a0: culong; a1: culong): pointer {.cdecl.}
    realloc*: proc (a0: pointer; a1: culong): pointer {.cdecl.}
    free*: proc (a0: pointer): void {.cdecl.}

  cmarkmem* = structcmarkmem
  cmarkfreefunc* = proc (a0: ptr structcmarkmem; a1: pointer): void {.cdecl.}
  structcmarkllist* {.pure, inheritable, bycopy.} = object
    next*: ptr structcmarkllist
    data*: pointer

  cmarkllist* = structcmarkllist
  cmarkeventtype* = enumcmarkeventtype
  structiofile* {.pure, inheritable, bycopy.} = object
    internalflags*: cint
    internalioreadptr*: cstring
    internalioreadend*: cstring
    internalioreadbase*: cstring
    internaliowritebase*: cstring
    internaliowriteptr*: cstring
    internaliowriteend*: cstring
    internaliobufbase*: cstring
    internaliobufend*: cstring
    internaliosavebase*: cstring
    internaliobackupbase*: cstring
    internaliosaveend*: cstring
    internalmarkers*: ptr structiomarker
    internalchain*: ptr structiofile
    internalfileno*: cint
    internalflags2*: cint
    internaloldoffset*: clong
    internalcurcolumn*: cushort
    internalvtableoffset*: cschar
    internalshortbuf*: array[1'i64, cschar]
    internallock*: pointer
    internaloffset*: clong
    internalcodecvt*: ptr structiocodecvt
    internalwidedata*: ptr structiowidedata
    internalfreereslist*: ptr structiofile
    internalfreeresbuf*: pointer
    compilerpad5*: culong
    internalmode*: cint
    internalunused2*: array[20'i64, cschar]

  bufsizet* = cint

const
  CmarkNodeTypePresent* = 32768
  CmarkNodeTypeMask* = 49152
  CmarkNodeValueMask* = 16383
  CmarkOptDefault* = 0

var
  CmarkNodeLastBlock* {.importc: "CMARK_NODE_LAST_BLOCK".}: enumcmarknodetype
  CmarkNodeLastInline* {.importc: "CMARK_NODE_LAST_INLINE".}: enumcmarknodetype

{.push cdecl.}

proc cmarkNodeGetHeadingLevel*(node: ptr structcmarknode): cint {.
    importc: "cmark_node_get_heading_level".}

proc cmarkNodeSetHeadingLevel*(node: ptr structcmarknode; level: cint): cint {.
    importc: "cmark_node_set_heading_level".}

proc cmarkMarkdownToHtml*(text: cstring; len: culong; options: cint): cstring {.
    importc: "cmark_markdown_to_html".}

proc cmarkGetDefaultMemAllocator*(): ptr structcmarkmem {.
    importc: "cmark_get_default_mem_allocator".}

proc cmarkGetArenaMemAllocator*(): ptr structcmarkmem {.
    importc: "cmark_get_arena_mem_allocator".}

proc cmarkArenaReset*(): void {.importc: "cmark_arena_reset".}

proc cmarkLlistAppend*(mem: ptr structcmarkmem; head: ptr structcmarkllist;
                       data: pointer): ptr structcmarkllist {.
    importc: "cmark_llist_append".}

proc cmarkLlistFreeFull*(mem: ptr structcmarkmem; head: ptr structcmarkllist;
    freefunc: proc (a0: ptr structcmarkmem; a1: pointer): void {.cdecl.}): void {.
    importc: "cmark_llist_free_full".}

proc cmarkLlistFree*(mem: ptr structcmarkmem; head: ptr structcmarkllist): void {.
    importc: "cmark_llist_free".}

proc cmarkNodeNew*(typearg: enumcmarknodetype): ptr structcmarknode {.
    importc: "cmark_node_new".}

proc cmarkNodeNewWithMem*(typearg: enumcmarknodetype; mem: ptr structcmarkmem): ptr structcmarknode {.
    importc: "cmark_node_new_with_mem".}

proc cmarkNodeNewWithExt*(typearg: enumcmarknodetype;
                          extension: ptr structcmarksyntaxextension): ptr structcmarknode {.
    importc: "cmark_node_new_with_ext".}

proc cmarkNodeNewWithMemAndExt*(typearg: enumcmarknodetype;
                                mem: ptr structcmarkmem;
                                extension: ptr structcmarksyntaxextension): ptr structcmarknode {.
    importc: "cmark_node_new_with_mem_and_ext".}

proc cmarkNodeFree*(node: ptr structcmarknode): void {.
    importc: "cmark_node_free".}

proc cmarkNodeNext*(node: ptr structcmarknode): ptr structcmarknode {.
    importc: "cmark_node_next".}

proc cmarkNodePrevious*(node: ptr structcmarknode): ptr structcmarknode {.
    importc: "cmark_node_previous".}

proc cmarkNodeParent*(node: ptr structcmarknode): ptr structcmarknode {.
    importc: "cmark_node_parent".}

proc cmarkNodeFirstChild*(node: ptr structcmarknode): ptr structcmarknode {.
    importc: "cmark_node_first_child".}

proc cmarkNodeLastChild*(node: ptr structcmarknode): ptr structcmarknode {.
    importc: "cmark_node_last_child".}

proc cmarkNodeParentFootnoteDef*(node: ptr structcmarknode): ptr structcmarknode {.
    importc: "cmark_node_parent_footnote_def".}

proc cmarkIterNew*(root: ptr structcmarknode): ptr structcmarkiter {.
    importc: "cmark_iter_new".}

proc cmarkIterFree*(iter: ptr structcmarkiter): void {.
    importc: "cmark_iter_free".}

proc cmarkIterNext*(iter: ptr structcmarkiter): enumcmarkeventtype {.
    importc: "cmark_iter_next".}

proc cmarkIterGetNode*(iter: ptr structcmarkiter): ptr structcmarknode {.
    importc: "cmark_iter_get_node".}

proc cmarkIterGetEventType*(iter: ptr structcmarkiter): enumcmarkeventtype {.
    importc: "cmark_iter_get_event_type".}

proc cmarkIterGetRoot*(iter: ptr structcmarkiter): ptr structcmarknode {.
    importc: "cmark_iter_get_root".}

proc cmarkIterReset*(iter: ptr structcmarkiter; current: ptr structcmarknode;
                     eventtype: enumcmarkeventtype): void {.
    importc: "cmark_iter_reset".}

proc cmarkNodeGetUserData*(node: ptr structcmarknode): pointer {.
    importc: "cmark_node_get_user_data".}

proc cmarkNodeSetUserData*(node: ptr structcmarknode; userdata: pointer): cint {.
    importc: "cmark_node_set_user_data".}

proc cmarkNodeSetUserDataFreeFunc*(node: ptr structcmarknode; freefunc: proc (
    a0: ptr structcmarkmem; a1: pointer): void {.cdecl.}): cint {.
    importc: "cmark_node_set_user_data_free_func".}

proc cmarkNodeGetType*(node: ptr structcmarknode): enumcmarknodetype {.
    importc: "cmark_node_get_type".}

proc cmarkNodeGetTypeString*(node: ptr structcmarknode): cstring {.
    importc: "cmark_node_get_type_string".}

proc cmarkNodeGetLiteral*(node: ptr structcmarknode): cstring {.
    importc: "cmark_node_get_literal".}

proc cmarkNodeSetLiteral*(node: ptr structcmarknode; content: cstring): cint {.
    importc: "cmark_node_set_literal".}

proc cmarkNodeGetListType*(node: ptr structcmarknode): enumcmarklisttype {.
    importc: "cmark_node_get_list_type".}

proc cmarkNodeSetListType*(node: ptr structcmarknode; typearg: enumcmarklisttype): cint {.
    importc: "cmark_node_set_list_type".}

proc cmarkNodeGetListDelim*(node: ptr structcmarknode): enumcmarkdelimtype {.
    importc: "cmark_node_get_list_delim".}

proc cmarkNodeSetListDelim*(node: ptr structcmarknode; delim: enumcmarkdelimtype): cint {.
    importc: "cmark_node_set_list_delim".}

proc cmarkNodeGetListStart*(node: ptr structcmarknode): cint {.
    importc: "cmark_node_get_list_start".}

proc cmarkNodeSetListStart*(node: ptr structcmarknode; start: cint): cint {.
    importc: "cmark_node_set_list_start".}

proc cmarkNodeGetListTight*(node: ptr structcmarknode): cint {.
    importc: "cmark_node_get_list_tight".}

proc cmarkNodeSetListTight*(node: ptr structcmarknode; tight: cint): cint {.
    importc: "cmark_node_set_list_tight".}

proc cmarkNodeGetItemIndex*(node: ptr structcmarknode): cint {.
    importc: "cmark_node_get_item_index".}

proc cmarkNodeSetItemIndex*(node: ptr structcmarknode; idx: cint): cint {.
    importc: "cmark_node_set_item_index".}

proc cmarkNodeGetFenceInfo*(node: ptr structcmarknode): cstring {.
    importc: "cmark_node_get_fence_info".}

proc cmarkNodeSetFenceInfo*(node: ptr structcmarknode; info: cstring): cint {.
    importc: "cmark_node_set_fence_info".}

proc cmarkNodeSetFenced*(node: ptr structcmarknode; fenced: cint; length: cint;
                         offset: cint; character: cschar): cint {.
    importc: "cmark_node_set_fenced".}

proc cmarkNodeGetFenced*(node: ptr structcmarknode; length: ptr cint;
                         offset: ptr cint; character: cstring): cint {.
    importc: "cmark_node_get_fenced".}

proc cmarkNodeGetUrl*(node: ptr structcmarknode): cstring {.
    importc: "cmark_node_get_url".}

proc cmarkNodeSetUrl*(node: ptr structcmarknode; url: cstring): cint {.
    importc: "cmark_node_set_url".}

proc cmarkNodeGetTitle*(node: ptr structcmarknode): cstring {.
    importc: "cmark_node_get_title".}

proc cmarkNodeSetTitle*(node: ptr structcmarknode; title: cstring): cint {.
    importc: "cmark_node_set_title".}

proc cmarkNodeGetOnEnter*(node: ptr structcmarknode): cstring {.
    importc: "cmark_node_get_on_enter".}

proc cmarkNodeSetOnEnter*(node: ptr structcmarknode; onenter: cstring): cint {.
    importc: "cmark_node_set_on_enter".}

proc cmarkNodeGetOnExit*(node: ptr structcmarknode): cstring {.
    importc: "cmark_node_get_on_exit".}

proc cmarkNodeSetOnExit*(node: ptr structcmarknode; onexit: cstring): cint {.
    importc: "cmark_node_set_on_exit".}

proc cmarkNodeGetStartLine*(node: ptr structcmarknode): cint {.
    importc: "cmark_node_get_start_line".}

proc cmarkNodeGetStartColumn*(node: ptr structcmarknode): cint {.
    importc: "cmark_node_get_start_column".}

proc cmarkNodeGetEndLine*(node: ptr structcmarknode): cint {.
    importc: "cmark_node_get_end_line".}

proc cmarkNodeGetEndColumn*(node: ptr structcmarknode): cint {.
    importc: "cmark_node_get_end_column".}

proc cmarkNodeUnlink*(node: ptr structcmarknode): void {.
    importc: "cmark_node_unlink".}

proc cmarkNodeInsertBefore*(node: ptr structcmarknode;
                            sibling: ptr structcmarknode): cint {.
    importc: "cmark_node_insert_before".}

proc cmarkNodeInsertAfter*(node: ptr structcmarknode;
                           sibling: ptr structcmarknode): cint {.
    importc: "cmark_node_insert_after".}

proc cmarkNodeReplace*(oldnode: ptr structcmarknode;
                       newnode: ptr structcmarknode): cint {.
    importc: "cmark_node_replace".}

proc cmarkNodePrependChild*(node: ptr structcmarknode;
                            child: ptr structcmarknode): cint {.
    importc: "cmark_node_prepend_child".}

proc cmarkNodeAppendChild*(node: ptr structcmarknode; child: ptr structcmarknode): cint {.
    importc: "cmark_node_append_child".}

proc cmarkConsolidateTextNodes*(root: ptr structcmarknode): void {.
    importc: "cmark_consolidate_text_nodes".}

proc cmarkNodeOwn*(root: ptr structcmarknode): void {.
    importc: "cmark_node_own".}

proc cmarkParserNew*(options: cint): ptr structcmarkparser {.
    importc: "cmark_parser_new".}

proc cmarkParserNewWithMem*(options: cint; mem: ptr structcmarkmem): ptr structcmarkparser {.
    importc: "cmark_parser_new_with_mem".}

proc cmarkParserFree*(parser: ptr structcmarkparser): void {.
    importc: "cmark_parser_free".}

proc cmarkParserFeed*(parser: ptr structcmarkparser; buffer: cstring;
                      len: culong): void {.importc: "cmark_parser_feed".}

proc cmarkParserFinish*(parser: ptr structcmarkparser): ptr structcmarknode {.
    importc: "cmark_parser_finish".}

proc cmarkParseDocument*(buffer: cstring; len: culong; options: cint): ptr structcmarknode {.
    importc: "cmark_parse_document".}

proc cmarkParseFile*(f: ptr structiofile; options: cint): ptr structcmarknode {.
    importc: "cmark_parse_file".}

proc cmarkRenderXml*(root: ptr structcmarknode; options: cint): cstring {.
    importc: "cmark_render_xml".}

proc cmarkRenderXmlWithMem*(root: ptr structcmarknode; options: cint;
                            mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_xml_with_mem".}

proc cmarkRenderHtml*(root: ptr structcmarknode; options: cint;
                      extensions: ptr structcmarkllist): cstring {.
    importc: "cmark_render_html".}

proc cmarkRenderHtmlWithMem*(root: ptr structcmarknode; options: cint;
                             extensions: ptr structcmarkllist;
                             mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_html_with_mem".}

proc cmarkRenderMan*(root: ptr structcmarknode; options: cint; width: cint): cstring {.
    importc: "cmark_render_man".}

proc cmarkRenderManWithMem*(root: ptr structcmarknode; options: cint;
                            width: cint; mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_man_with_mem".}

proc cmarkRenderCommonmark*(root: ptr structcmarknode; options: cint;
                            width: cint): cstring {.
    importc: "cmark_render_commonmark".}

proc cmarkRenderCommonmarkWithMem*(root: ptr structcmarknode; options: cint;
                                   width: cint; mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_commonmark_with_mem".}

proc cmarkRenderPlaintext*(root: ptr structcmarknode; options: cint; width: cint): cstring {.
    importc: "cmark_render_plaintext".}

proc cmarkRenderPlaintextWithMem*(root: ptr structcmarknode; options: cint;
                                  width: cint; mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_plaintext_with_mem".}

proc cmarkRenderLatex*(root: ptr structcmarknode; options: cint; width: cint): cstring {.
    importc: "cmark_render_latex".}

proc cmarkRenderLatexWithMem*(root: ptr structcmarknode; options: cint;
                              width: cint; mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_latex_with_mem".}

proc cmarkVersion*(): cint {.importc: "cmark_version".}

proc cmarkVersionString*(): cstring {.importc: "cmark_version_string".}

{.pop.}
