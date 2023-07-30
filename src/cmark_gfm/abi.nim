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
  NodeType* {.size: sizeof(cuint).} = enum
    ntNone = 0 ## Error status.

    # Block nodes.
    ntDocument = 32769
    ntBlockQuote = 32770
    ntList = 32771
    ntItem = 32772
    ntCodeBlock = 32773
    ntHtmlBlock = 32774
    ntCustomBlock = 32775
    ntParagraph = 32776
    ntHeading = 32777
    ntThematicBreak = 32778
    ntFootnoteDefinition = 32779

    # Inline nodes.
    ntText = 49153
    ntSoftBreak = 49154
    ntLineBreak = 49155
    ntCode = 49156
    ntHtmlInline = 49157
    ntCustomInline = 49158
    ntEmph = 49159
    ntStrong = 49160
    ntLink = 49161
    ntImage = 49162
    ntFootnoteReference = 49163

  ListType* {.size: sizeof(cuint).} = enum
    ltNoList
    ltBulletList
    ltOrderedList

  DelimType* {.size: sizeof(cuint).} = enum
    dtNoDeLim
    dtPeriodDelim
    dtParenDelim

  EventType* {.size: sizeof(cuint).} = enum
    etNone
    etDone
    etEnter
    etExit

  Node* = distinct object ## `struct cmark_node`
  NodePtr* = ptr Node ## `cmark_node*`

  Iter* = distinct object ## `struct cmark_iter`
  IterPtr* = ptr Iter ## `cmark_iter*`

  Parser* = distinct object ## `struct cmark_parser`
  ParserPtr* = ptr Parser ## `cmark_parser*`

  SyntaxExtension* = distinct object ## `struct cmark_syntax_extension`
  SyntaxExtensionPtr* = ptr SyntaxExtension ## `cmark_syntax_extension*`

  Mem* {.pure, inheritable, bycopy.} = object
    ## Defines the memory allocation functions to be used by CMark when parsing
    ## and allocating a document tree
    calloc*: proc (a0: culong, a1: culong): pointer {.cdecl.}
    realloc*: proc (a0: pointer, a1: culong): pointer {.cdecl.}
    free*: proc (a0: pointer): void {.cdecl.}
  MemPtr* = ptr Mem

  Llist* {.pure, inheritable, bycopy.} = object ## A singly linked list.
    next*: LlistPtr
    data*: pointer
  LlistPtr* = ptr Llist

const
  CmarkOptDefault* = 0

{.push cdecl, raises: [], gcsafe.}

func cmarkMarkdownToHtml*(text: cstring,
                          len: culong,
                          options: cint): cstring {.
    importc: "cmark_markdown_to_html".}

func cmarkGetDefaultMemAllocator*: MemPtr {.
    importc: "cmark_get_default_mem_allocator".}

func cmarkGetArenaMemAllocator*: MemPtr {.
    importc: "cmark_get_arena_mem_allocator".}

func cmarkArenaReset*: void {.importc: "cmark_arena_reset".}

func cmarkLlistAppend*(mem: MemPtr,
                       head: LlistPtr,
                       data: pointer): LlistPtr {.
    importc: "cmark_llist_append".}

func cmarkLlistFreeFull*(mem: MemPtr,
                         head: LlistPtr,
                         freefunc: proc (a0: MemPtr,
                                         a1: pointer): void {.cdecl.}): void {.
    importc: "cmark_llist_free_full".}

func cmarkLlistFree*(mem: MemPtr,
                     head: LlistPtr): void {.
    importc: "cmark_llist_free".}

func cmarkNodeNew*(typearg: NodeType): NodePtr {.
    importc: "cmark_node_new".}

func cmarkNodeNewWithMem*(typearg: NodeType,
                          mem: MemPtr): NodePtr {.
    importc: "cmark_node_new_with_mem".}

func cmarkNodeNewWithExt*(typearg: NodeType,
                          extension: SyntaxExtensionPtr): NodePtr {.
    importc: "cmark_node_new_with_ext".}

func cmarkNodeNewWithMemAndExt*(typearg: NodeType,
                                mem: MemPtr,
                                extension: SyntaxExtensionPtr): NodePtr {.
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

func cmarkIterNew*(root: NodePtr): IterPtr {.
    importc: "cmark_iter_new".}

func cmarkIterFree*(iter: IterPtr): void {.
    importc: "cmark_iter_free".}

func cmarkIterNext*(iter: IterPtr): EventType {.
    importc: "cmark_iter_next".}

func cmarkIterGetNode*(iter: IterPtr): NodePtr {.
    importc: "cmark_iter_get_node".}

func cmarkIterGetEventType*(iter: IterPtr): EventType {.
    importc: "cmark_iter_get_event_type".}

func cmarkIterGetRoot*(iter: IterPtr): NodePtr {.
    importc: "cmark_iter_get_root".}

func cmarkIterReset*(iter: IterPtr,
                     current: NodePtr,
                     eventtype: EventType): void {.
    importc: "cmark_iter_reset".}

func cmarkNodeGetUserData*(node: NodePtr): pointer {.
    importc: "cmark_node_get_user_data".}

func cmarkNodeSetUserData*(node: NodePtr,
                           userdata: pointer): cint {.
    importc: "cmark_node_set_user_data".}

func cmarkNodeSetUserDataFreeFunc*(node: NodePtr,
                                   freefunc: proc (a0: MemPtr,
                                                   a1: pointer): void {.cdecl.}): cint {.
    importc: "cmark_node_set_user_data_free_func".}

func cmarkNodeGetType*(node: NodePtr): NodeType {.
    importc: "cmark_node_get_type".}

func cmarkNodeGetTypeString*(node: NodePtr): cstring {.
    importc: "cmark_node_get_type_string".}

func cmarkNodeGetLiteral*(node: NodePtr): cstring {.
    importc: "cmark_node_get_literal".}

func cmarkNodeSetLiteral*(node: NodePtr,
                          content: cstring): cint {.
    importc: "cmark_node_set_literal".}

func cmarkNodeGetHeadingLevel*(node: NodePtr): cint {.
    importc: "cmark_node_get_heading_level".}

func cmarkNodeSetHeadingLevel*(node: NodePtr,
                               level: cint): cint {.
    importc: "cmark_node_set_heading_level".}

func cmarkNodeGetListType*(node: NodePtr): ListType {.
    importc: "cmark_node_get_list_type".}

func cmarkNodeSetListType*(node: NodePtr,
                           typearg: ListType): cint {.
    importc: "cmark_node_set_list_type".}

func cmarkNodeGetListDelim*(node: NodePtr): DelimType {.
    importc: "cmark_node_get_list_delim".}

func cmarkNodeSetListDelim*(node: NodePtr,
                            delim: DelimType): cint {.
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

func cmarkParserNew*(options: cint): ParserPtr {.
    importc: "cmark_parser_new".}

func cmarkParserNewWithMem*(options: cint,
                            mem: MemPtr): ParserPtr {.
    importc: "cmark_parser_new_with_mem".}

func cmarkParserFree*(parser: ParserPtr): void {.
    importc: "cmark_parser_free".}

func cmarkParserFeed*(parser: ParserPtr,
                      buffer: cstring,
                      len: culong): void {.
    importc: "cmark_parser_feed".}

func cmarkParserFinish*(parser: ParserPtr): NodePtr {.
    importc: "cmark_parser_finish".}

func cmarkParseDocument*(buffer: cstring,
                         len: culong,
                         options: cint): NodePtr {.
    importc: "cmark_parse_document".}

func cmarkRenderXml*(root: NodePtr,
                     options: cint): cstring {.
    importc: "cmark_render_xml".}

func cmarkRenderXmlWithMem*(root: NodePtr,
                            options: cint,
                            mem: MemPtr): cstring {.
    importc: "cmark_render_xml_with_mem".}

func cmarkRenderHtml*(root: NodePtr,
                      options: cint,
                      extensions: LlistPtr): cstring {.
    importc: "cmark_render_html".}

func cmarkRenderHtmlWithMem*(root: NodePtr,
                             options: cint,
                             extensions: LlistPtr,
                             mem: MemPtr): cstring {.
    importc: "cmark_render_html_with_mem".}

func cmarkRenderMan*(root: NodePtr,
                     options: cint,
                     width: cint): cstring {.
    importc: "cmark_render_man".}

func cmarkRenderManWithMem*(root: NodePtr,
                            options: cint,
                            width: cint,
                            mem: MemPtr): cstring {.
    importc: "cmark_render_man_with_mem".}

func cmarkRenderCommonmark*(root: NodePtr,
                            options: cint,
                            width: cint): cstring {.
    importc: "cmark_render_commonmark".}

func cmarkRenderCommonmarkWithMem*(root: NodePtr,
                                   options: cint,
                                   width: cint,
                                   mem: MemPtr): cstring {.
    importc: "cmark_render_commonmark_with_mem".}

func cmarkRenderPlaintext*(root: NodePtr,
                           options: cint,
                           width: cint): cstring {.
    importc: "cmark_render_plaintext".}

func cmarkRenderPlaintextWithMem*(root: NodePtr,
                                  options: cint,
                                  width: cint,
                                  mem: MemPtr): cstring {.
    importc: "cmark_render_plaintext_with_mem".}

func cmarkRenderLatex*(root: NodePtr,
                       options: cint,
                       width: cint): cstring {.
    importc: "cmark_render_latex".}

func cmarkRenderLatexWithMem*(root: NodePtr,
                              options: cint,
                              width: cint,
                              mem: MemPtr): cstring {.
    importc: "cmark_render_latex_with_mem".}

func cmarkVersion*: cint {.importc: "cmark_version".}

func cmarkVersionString*: cstring {.importc: "cmark_version_string".}

{.pop.}
