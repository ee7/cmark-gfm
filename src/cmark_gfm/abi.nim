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

  Node* = distinct object ## `struct cmark_node`
  NodePtr* = ptr Node ## `cmark_node*`

  structiowidedata* = distinct object
  structcmarkparser* = distinct object
  structcmarksyntaxextension* = distinct object
  structcmarkiter* = distinct object
  structiocodecvt* = distinct object
  structiomarker* = distinct object

  structcmarkmem* {.pure, inheritable, bycopy.} = object
    calloc*: proc (a0: culong, a1: culong): pointer {.cdecl.}
    realloc*: proc (a0: pointer, a1: culong): pointer {.cdecl.}
    free*: proc (a0: pointer): void {.cdecl.}

  structcmarkllist* {.pure, inheritable, bycopy.} = object
    next*: ptr structcmarkllist
    data*: pointer

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

const
  CmarkNodeTypePresent* = 32768
  CmarkNodeTypeMask* = 49152
  CmarkNodeValueMask* = 16383
  CmarkOptDefault* = 0

var
  CmarkNodeLastBlock* {.importc: "CMARK_NODE_LAST_BLOCK".}: enumcmarknodetype
  CmarkNodeLastInline* {.importc: "CMARK_NODE_LAST_INLINE".}: enumcmarknodetype

{.push cdecl, raises: [], gcsafe.}

func cmarkNodeGetHeadingLevel*(node: NodePtr): cint {.
    importc: "cmark_node_get_heading_level".}

func cmarkNodeSetHeadingLevel*(node: NodePtr,
                               level: cint): cint {.
    importc: "cmark_node_set_heading_level".}

func cmarkMarkdownToHtml*(text: cstring,
                          len: culong,
                          options: cint): cstring {.
    importc: "cmark_markdown_to_html".}

func cmarkGetDefaultMemAllocator*: ptr structcmarkmem {.
    importc: "cmark_get_default_mem_allocator".}

func cmarkGetArenaMemAllocator*: ptr structcmarkmem {.
    importc: "cmark_get_arena_mem_allocator".}

func cmarkArenaReset*: void {.importc: "cmark_arena_reset".}

func cmarkLlistAppend*(mem: ptr structcmarkmem,
                       head: ptr structcmarkllist,
                       data: pointer): ptr structcmarkllist {.
    importc: "cmark_llist_append".}

func cmarkLlistFreeFull*(mem: ptr structcmarkmem,
                         head: ptr structcmarkllist,
                         freefunc: proc (a0: ptr structcmarkmem,
                                         a1: pointer): void {.cdecl.}): void {.
    importc: "cmark_llist_free_full".}

func cmarkLlistFree*(mem: ptr structcmarkmem,
                     head: ptr structcmarkllist): void {.
    importc: "cmark_llist_free".}

func cmarkNodeNew*(typearg: enumcmarknodetype): NodePtr {.
    importc: "cmark_node_new".}

func cmarkNodeNewWithMem*(typearg: enumcmarknodetype,
                          mem: ptr structcmarkmem): NodePtr {.
    importc: "cmark_node_new_with_mem".}

func cmarkNodeNewWithExt*(typearg: enumcmarknodetype,
                          extension: ptr structcmarksyntaxextension): NodePtr {.
    importc: "cmark_node_new_with_ext".}

func cmarkNodeNewWithMemAndExt*(typearg: enumcmarknodetype,
                                mem: ptr structcmarkmem,
                                extension: ptr structcmarksyntaxextension): NodePtr {.
    importc: "cmark_node_new_with_mem_and_ext".}

func cmarkNodeFree*(node: NodePtr): void {.
    importc: "cmark_node_free".}

func cmarkNodeNext*(node: NodePtr): NodePtr {.
    importc: "cmark_node_next".}

func cmarkNodePrevious*(node: NodePtr): NodePtr {.
    importc: "cmark_node_previous".}

func cmarkNodeParent*(node: NodePtr): NodePtr {.
    importc: "cmark_node_parent".}

func cmarkNodeFirstChild*(node: NodePtr): NodePtr {.
    importc: "cmark_node_first_child".}

func cmarkNodeLastChild*(node: NodePtr): NodePtr {.
    importc: "cmark_node_last_child".}

func cmarkNodeParentFootnoteDef*(node: NodePtr): NodePtr {.
    importc: "cmark_node_parent_footnote_def".}

func cmarkIterNew*(root: NodePtr): ptr structcmarkiter {.
    importc: "cmark_iter_new".}

func cmarkIterFree*(iter: ptr structcmarkiter): void {.
    importc: "cmark_iter_free".}

func cmarkIterNext*(iter: ptr structcmarkiter): enumcmarkeventtype {.
    importc: "cmark_iter_next".}

func cmarkIterGetNode*(iter: ptr structcmarkiter): NodePtr {.
    importc: "cmark_iter_get_node".}

func cmarkIterGetEventType*(iter: ptr structcmarkiter): enumcmarkeventtype {.
    importc: "cmark_iter_get_event_type".}

func cmarkIterGetRoot*(iter: ptr structcmarkiter): NodePtr {.
    importc: "cmark_iter_get_root".}

func cmarkIterReset*(iter: ptr structcmarkiter,
                     current: NodePtr,
                     eventtype: enumcmarkeventtype): void {.
    importc: "cmark_iter_reset".}

func cmarkNodeGetUserData*(node: NodePtr): pointer {.
    importc: "cmark_node_get_user_data".}

func cmarkNodeSetUserData*(node: NodePtr,
                           userdata: pointer): cint {.
    importc: "cmark_node_set_user_data".}

func cmarkNodeSetUserDataFreeFunc*(node: NodePtr,
                                   freefunc: proc (a0: ptr structcmarkmem,
                                                   a1: pointer): void {.cdecl.}): cint {.
    importc: "cmark_node_set_user_data_free_func".}

func cmarkNodeGetType*(node: NodePtr): enumcmarknodetype {.
    importc: "cmark_node_get_type".}

func cmarkNodeGetTypeString*(node: NodePtr): cstring {.
    importc: "cmark_node_get_type_string".}

func cmarkNodeGetLiteral*(node: NodePtr): cstring {.
    importc: "cmark_node_get_literal".}

func cmarkNodeSetLiteral*(node: NodePtr,
                          content: cstring): cint {.
    importc: "cmark_node_set_literal".}

func cmarkNodeGetListType*(node: NodePtr): enumcmarklisttype {.
    importc: "cmark_node_get_list_type".}

func cmarkNodeSetListType*(node: NodePtr,
                           typearg: enumcmarklisttype): cint {.
    importc: "cmark_node_set_list_type".}

func cmarkNodeGetListDelim*(node: NodePtr): enumcmarkdelimtype {.
    importc: "cmark_node_get_list_delim".}

func cmarkNodeSetListDelim*(node: NodePtr,
                            delim: enumcmarkdelimtype): cint {.
    importc: "cmark_node_set_list_delim".}

func cmarkNodeGetListStart*(node: NodePtr): cint {.
    importc: "cmark_node_get_list_start".}

func cmarkNodeSetListStart*(node: NodePtr,
                            start: cint): cint {.
    importc: "cmark_node_set_list_start".}

func cmarkNodeGetListTight*(node: NodePtr): cint {.
    importc: "cmark_node_get_list_tight".}

func cmarkNodeSetListTight*(node: NodePtr,
                            tight: cint): cint {.
    importc: "cmark_node_set_list_tight".}

func cmarkNodeGetItemIndex*(node: NodePtr): cint {.
    importc: "cmark_node_get_item_index".}

func cmarkNodeSetItemIndex*(node: NodePtr,
                            idx: cint): cint {.
    importc: "cmark_node_set_item_index".}

func cmarkNodeGetFenceInfo*(node: NodePtr): cstring {.
    importc: "cmark_node_get_fence_info".}

func cmarkNodeSetFenceInfo*(node: NodePtr,
                            info: cstring): cint {.
    importc: "cmark_node_set_fence_info".}

func cmarkNodeSetFenced*(node: NodePtr,
                         fenced: cint,
                         length: cint,
                         offset: cint,
                         character: cschar): cint {.
    importc: "cmark_node_set_fenced".}

func cmarkNodeGetFenced*(node: NodePtr,
                         length: ptr cint,
                         offset: ptr cint,
                         character: cstring): cint {.
    importc: "cmark_node_get_fenced".}

func cmarkNodeGetUrl*(node: NodePtr): cstring {.
    importc: "cmark_node_get_url".}

func cmarkNodeSetUrl*(node: NodePtr,
                      url: cstring): cint {.
    importc: "cmark_node_set_url".}

func cmarkNodeGetTitle*(node: NodePtr): cstring {.
    importc: "cmark_node_get_title".}

func cmarkNodeSetTitle*(node: NodePtr,
                        title: cstring): cint {.
    importc: "cmark_node_set_title".}

func cmarkNodeGetOnEnter*(node: NodePtr): cstring {.
    importc: "cmark_node_get_on_enter".}

func cmarkNodeSetOnEnter*(node: NodePtr,
                          onenter: cstring): cint {.
    importc: "cmark_node_set_on_enter".}

func cmarkNodeGetOnExit*(node: NodePtr): cstring {.
    importc: "cmark_node_get_on_exit".}

func cmarkNodeSetOnExit*(node: NodePtr,
                         onexit: cstring): cint {.
    importc: "cmark_node_set_on_exit".}

func cmarkNodeGetStartLine*(node: NodePtr): cint {.
    importc: "cmark_node_get_start_line".}

func cmarkNodeGetStartColumn*(node: NodePtr): cint {.
    importc: "cmark_node_get_start_column".}

func cmarkNodeGetEndLine*(node: NodePtr): cint {.
    importc: "cmark_node_get_end_line".}

func cmarkNodeGetEndColumn*(node: NodePtr): cint {.
    importc: "cmark_node_get_end_column".}

func cmarkNodeUnlink*(node: NodePtr): void {.
    importc: "cmark_node_unlink".}

func cmarkNodeInsertBefore*(node: NodePtr,
                            sibling: NodePtr): cint {.
    importc: "cmark_node_insert_before".}

func cmarkNodeInsertAfter*(node: NodePtr,
                           sibling: NodePtr): cint {.
    importc: "cmark_node_insert_after".}

func cmarkNodeReplace*(oldnode: NodePtr,
                       newnode: NodePtr): cint {.
    importc: "cmark_node_replace".}

func cmarkNodePrependChild*(node: NodePtr,
                            child: NodePtr): cint {.
    importc: "cmark_node_prepend_child".}

func cmarkNodeAppendChild*(node: NodePtr,
                           child: NodePtr): cint {.
    importc: "cmark_node_append_child".}

func cmarkConsolidateTextNodes*(root: NodePtr): void {.
    importc: "cmark_consolidate_text_nodes".}

func cmarkNodeOwn*(root: NodePtr): void {.
    importc: "cmark_node_own".}

func cmarkParserNew*(options: cint): ptr structcmarkparser {.
    importc: "cmark_parser_new".}

func cmarkParserNewWithMem*(options: cint,
                            mem: ptr structcmarkmem): ptr structcmarkparser {.
    importc: "cmark_parser_new_with_mem".}

func cmarkParserFree*(parser: ptr structcmarkparser): void {.
    importc: "cmark_parser_free".}

func cmarkParserFeed*(parser: ptr structcmarkparser,
                      buffer: cstring,
                      len: culong): void {.
    importc: "cmark_parser_feed".}

func cmarkParserFinish*(parser: ptr structcmarkparser): NodePtr {.
    importc: "cmark_parser_finish".}

func cmarkParseDocument*(buffer: cstring,
                         len: culong,
                         options: cint): NodePtr {.
    importc: "cmark_parse_document".}

func cmarkParseFile*(f: ptr structiofile,
                     options: cint): NodePtr {.
    importc: "cmark_parse_file".}

func cmarkRenderXml*(root: NodePtr,
                     options: cint): cstring {.
    importc: "cmark_render_xml".}

func cmarkRenderXmlWithMem*(root: NodePtr,
                            options: cint,
                            mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_xml_with_mem".}

func cmarkRenderHtml*(root: NodePtr,
                      options: cint,
                      extensions: ptr structcmarkllist): cstring {.
    importc: "cmark_render_html".}

func cmarkRenderHtmlWithMem*(root: NodePtr,
                             options: cint,
                             extensions: ptr structcmarkllist,
                             mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_html_with_mem".}

func cmarkRenderMan*(root: NodePtr,
                     options: cint,
                     width: cint): cstring {.
    importc: "cmark_render_man".}

func cmarkRenderManWithMem*(root: NodePtr,
                            options: cint,
                            width: cint,
                            mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_man_with_mem".}

func cmarkRenderCommonmark*(root: NodePtr,
                            options: cint,
                            width: cint): cstring {.
    importc: "cmark_render_commonmark".}

func cmarkRenderCommonmarkWithMem*(root: NodePtr,
                                   options: cint,
                                   width: cint,
                                   mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_commonmark_with_mem".}

func cmarkRenderPlaintext*(root: NodePtr,
                           options: cint,
                           width: cint): cstring {.
    importc: "cmark_render_plaintext".}

func cmarkRenderPlaintextWithMem*(root: NodePtr,
                                  options: cint,
                                  width: cint,
                                  mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_plaintext_with_mem".}

func cmarkRenderLatex*(root: NodePtr,
                       options: cint,
                       width: cint): cstring {.
    importc: "cmark_render_latex".}

func cmarkRenderLatexWithMem*(root: NodePtr,
                              options: cint,
                              width: cint,
                              mem: ptr structcmarkmem): cstring {.
    importc: "cmark_render_latex_with_mem".}

func cmarkVersion*: cint {.importc: "cmark_version".}

func cmarkVersionString*: cstring {.importc: "cmark_version_string".}

{.pop.}
