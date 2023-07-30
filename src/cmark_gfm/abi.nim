from system/ansi_c import c_free
export c_free

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
type
  enumcmarklisttype* {.size: sizeof(cuint).} = enum
    Cmarknolist = 0, Cmarkbulletlist = 1, Cmarkorderedlist = 2
type
  enumcmarkdelimtype* {.size: sizeof(cuint).} = enum
    Cmarknodelim = 0, Cmarkperioddelim = 1, Cmarkparendelim = 2
type
  enumcmarkeventtype* {.size: sizeof(cuint).} = enum
    Cmarkeventnone = 0, Cmarkeventdone = 1, Cmarkevententer = 2,
    Cmarkeventexit = 3
type
  structiowidedata* = distinct object
type
  structcmarkparser* = distinct object
type
  structcmarksyntaxextension* = distinct object
type
  structcmarkiter* = distinct object
type
  structiocodecvt* = distinct object
type
  structcmarknode* = distinct object
type
  structiomarker* = distinct object
type
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
when 32768 is static:
  const
    Cmarknodetypepresent* = 32768
else:
  let Cmarknodetypepresent* = 32768
when 49152 is static:
  const
    Cmarknodetypemask* = 49152
else:
  let Cmarknodetypemask* = 49152
when 16383 is static:
  const
    Cmarknodevaluemask* = 16383
else:
  let Cmarknodevaluemask* = 16383
proc cmarknodegetheadinglevel*(node: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_get_heading_level".}
proc cmarknodesetheadinglevel*(node: ptr structcmarknode; level: cint): cint {.
    cdecl, importc: "cmark_node_set_heading_level".}
when 0 is static:
  const
    Cmarkoptdefault* = 0
else:
  let Cmarkoptdefault* = 0
proc cmarkmarkdowntohtml*(text: cstring; len: culong; options: cint): cstring {.
    cdecl, importc: "cmark_markdown_to_html".}
var Cmarknodelastblock* {.importc: "CMARK_NODE_LAST_BLOCK".}: enumcmarknodetype
var Cmarknodelastinline* {.importc: "CMARK_NODE_LAST_INLINE".}: enumcmarknodetype
proc cmarkgetdefaultmemallocator*(): ptr structcmarkmem {.cdecl,
    importc: "cmark_get_default_mem_allocator".}
proc cmarkgetarenamemallocator*(): ptr structcmarkmem {.cdecl,
    importc: "cmark_get_arena_mem_allocator".}
proc cmarkarenareset*(): void {.cdecl, importc: "cmark_arena_reset".}
proc cmarkllistappend*(mem: ptr structcmarkmem; head: ptr structcmarkllist;
                       data: pointer): ptr structcmarkllist {.cdecl,
    importc: "cmark_llist_append".}
proc cmarkllistfreefull*(mem: ptr structcmarkmem; head: ptr structcmarkllist;
    freefunc: proc (a0: ptr structcmarkmem; a1: pointer): void {.cdecl.}): void {.
    cdecl, importc: "cmark_llist_free_full".}
proc cmarkllistfree*(mem: ptr structcmarkmem; head: ptr structcmarkllist): void {.
    cdecl, importc: "cmark_llist_free".}
proc cmarknodenew*(typearg: enumcmarknodetype): ptr structcmarknode {.cdecl,
    importc: "cmark_node_new".}
proc cmarknodenewwithmem*(typearg: enumcmarknodetype; mem: ptr structcmarkmem): ptr structcmarknode {.
    cdecl, importc: "cmark_node_new_with_mem".}
proc cmarknodenewwithext*(typearg: enumcmarknodetype;
                          extension: ptr structcmarksyntaxextension): ptr structcmarknode {.
    cdecl, importc: "cmark_node_new_with_ext".}
proc cmarknodenewwithmemandext*(typearg: enumcmarknodetype;
                                mem: ptr structcmarkmem;
                                extension: ptr structcmarksyntaxextension): ptr structcmarknode {.
    cdecl, importc: "cmark_node_new_with_mem_and_ext".}
proc cmarknodefree*(node: ptr structcmarknode): void {.cdecl,
    importc: "cmark_node_free".}
proc cmarknodenext*(node: ptr structcmarknode): ptr structcmarknode {.cdecl,
    importc: "cmark_node_next".}
proc cmarknodeprevious*(node: ptr structcmarknode): ptr structcmarknode {.cdecl,
    importc: "cmark_node_previous".}
proc cmarknodeparent*(node: ptr structcmarknode): ptr structcmarknode {.cdecl,
    importc: "cmark_node_parent".}
proc cmarknodefirstchild*(node: ptr structcmarknode): ptr structcmarknode {.
    cdecl, importc: "cmark_node_first_child".}
proc cmarknodelastchild*(node: ptr structcmarknode): ptr structcmarknode {.
    cdecl, importc: "cmark_node_last_child".}
proc cmarknodeparentfootnotedef*(node: ptr structcmarknode): ptr structcmarknode {.
    cdecl, importc: "cmark_node_parent_footnote_def".}
proc cmarkiternew*(root: ptr structcmarknode): ptr structcmarkiter {.cdecl,
    importc: "cmark_iter_new".}
proc cmarkiterfree*(iter: ptr structcmarkiter): void {.cdecl,
    importc: "cmark_iter_free".}
proc cmarkiternext*(iter: ptr structcmarkiter): enumcmarkeventtype {.cdecl,
    importc: "cmark_iter_next".}
proc cmarkitergetnode*(iter: ptr structcmarkiter): ptr structcmarknode {.cdecl,
    importc: "cmark_iter_get_node".}
proc cmarkitergeteventtype*(iter: ptr structcmarkiter): enumcmarkeventtype {.
    cdecl, importc: "cmark_iter_get_event_type".}
proc cmarkitergetroot*(iter: ptr structcmarkiter): ptr structcmarknode {.cdecl,
    importc: "cmark_iter_get_root".}
proc cmarkiterreset*(iter: ptr structcmarkiter; current: ptr structcmarknode;
                     eventtype: enumcmarkeventtype): void {.cdecl,
    importc: "cmark_iter_reset".}
proc cmarknodegetuserdata*(node: ptr structcmarknode): pointer {.cdecl,
    importc: "cmark_node_get_user_data".}
proc cmarknodesetuserdata*(node: ptr structcmarknode; userdata: pointer): cint {.
    cdecl, importc: "cmark_node_set_user_data".}
proc cmarknodesetuserdatafreefunc*(node: ptr structcmarknode; freefunc: proc (
    a0: ptr structcmarkmem; a1: pointer): void {.cdecl.}): cint {.cdecl,
    importc: "cmark_node_set_user_data_free_func".}
proc cmarknodegettype*(node: ptr structcmarknode): enumcmarknodetype {.cdecl,
    importc: "cmark_node_get_type".}
proc cmarknodegettypestring*(node: ptr structcmarknode): cstring {.cdecl,
    importc: "cmark_node_get_type_string".}
proc cmarknodegetliteral*(node: ptr structcmarknode): cstring {.cdecl,
    importc: "cmark_node_get_literal".}
proc cmarknodesetliteral*(node: ptr structcmarknode; content: cstring): cint {.
    cdecl, importc: "cmark_node_set_literal".}
proc cmarknodegetlisttype*(node: ptr structcmarknode): enumcmarklisttype {.
    cdecl, importc: "cmark_node_get_list_type".}
proc cmarknodesetlisttype*(node: ptr structcmarknode; typearg: enumcmarklisttype): cint {.
    cdecl, importc: "cmark_node_set_list_type".}
proc cmarknodegetlistdelim*(node: ptr structcmarknode): enumcmarkdelimtype {.
    cdecl, importc: "cmark_node_get_list_delim".}
proc cmarknodesetlistdelim*(node: ptr structcmarknode; delim: enumcmarkdelimtype): cint {.
    cdecl, importc: "cmark_node_set_list_delim".}
proc cmarknodegetliststart*(node: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_get_list_start".}
proc cmarknodesetliststart*(node: ptr structcmarknode; start: cint): cint {.
    cdecl, importc: "cmark_node_set_list_start".}
proc cmarknodegetlisttight*(node: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_get_list_tight".}
proc cmarknodesetlisttight*(node: ptr structcmarknode; tight: cint): cint {.
    cdecl, importc: "cmark_node_set_list_tight".}
proc cmarknodegetitemindex*(node: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_get_item_index".}
proc cmarknodesetitemindex*(node: ptr structcmarknode; idx: cint): cint {.cdecl,
    importc: "cmark_node_set_item_index".}
proc cmarknodegetfenceinfo*(node: ptr structcmarknode): cstring {.cdecl,
    importc: "cmark_node_get_fence_info".}
proc cmarknodesetfenceinfo*(node: ptr structcmarknode; info: cstring): cint {.
    cdecl, importc: "cmark_node_set_fence_info".}
proc cmarknodesetfenced*(node: ptr structcmarknode; fenced: cint; length: cint;
                         offset: cint; character: cschar): cint {.cdecl,
    importc: "cmark_node_set_fenced".}
proc cmarknodegetfenced*(node: ptr structcmarknode; length: ptr cint;
                         offset: ptr cint; character: cstring): cint {.cdecl,
    importc: "cmark_node_get_fenced".}
proc cmarknodegeturl*(node: ptr structcmarknode): cstring {.cdecl,
    importc: "cmark_node_get_url".}
proc cmarknodeseturl*(node: ptr structcmarknode; url: cstring): cint {.cdecl,
    importc: "cmark_node_set_url".}
proc cmarknodegettitle*(node: ptr structcmarknode): cstring {.cdecl,
    importc: "cmark_node_get_title".}
proc cmarknodesettitle*(node: ptr structcmarknode; title: cstring): cint {.
    cdecl, importc: "cmark_node_set_title".}
proc cmarknodegetonenter*(node: ptr structcmarknode): cstring {.cdecl,
    importc: "cmark_node_get_on_enter".}
proc cmarknodesetonenter*(node: ptr structcmarknode; onenter: cstring): cint {.
    cdecl, importc: "cmark_node_set_on_enter".}
proc cmarknodegetonexit*(node: ptr structcmarknode): cstring {.cdecl,
    importc: "cmark_node_get_on_exit".}
proc cmarknodesetonexit*(node: ptr structcmarknode; onexit: cstring): cint {.
    cdecl, importc: "cmark_node_set_on_exit".}
proc cmarknodegetstartline*(node: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_get_start_line".}
proc cmarknodegetstartcolumn*(node: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_get_start_column".}
proc cmarknodegetendline*(node: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_get_end_line".}
proc cmarknodegetendcolumn*(node: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_get_end_column".}
proc cmarknodeunlink*(node: ptr structcmarknode): void {.cdecl,
    importc: "cmark_node_unlink".}
proc cmarknodeinsertbefore*(node: ptr structcmarknode;
                            sibling: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_insert_before".}
proc cmarknodeinsertafter*(node: ptr structcmarknode;
                           sibling: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_insert_after".}
proc cmarknodereplace*(oldnode: ptr structcmarknode;
                       newnode: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_replace".}
proc cmarknodeprependchild*(node: ptr structcmarknode;
                            child: ptr structcmarknode): cint {.cdecl,
    importc: "cmark_node_prepend_child".}
proc cmarknodeappendchild*(node: ptr structcmarknode; child: ptr structcmarknode): cint {.
    cdecl, importc: "cmark_node_append_child".}
proc cmarkconsolidatetextnodes*(root: ptr structcmarknode): void {.cdecl,
    importc: "cmark_consolidate_text_nodes".}
proc cmarknodeown*(root: ptr structcmarknode): void {.cdecl,
    importc: "cmark_node_own".}
proc cmarkparsernew*(options: cint): ptr structcmarkparser {.cdecl,
    importc: "cmark_parser_new".}
proc cmarkparsernewwithmem*(options: cint; mem: ptr structcmarkmem): ptr structcmarkparser {.
    cdecl, importc: "cmark_parser_new_with_mem".}
proc cmarkparserfree*(parser: ptr structcmarkparser): void {.cdecl,
    importc: "cmark_parser_free".}
proc cmarkparserfeed*(parser: ptr structcmarkparser; buffer: cstring;
                      len: culong): void {.cdecl, importc: "cmark_parser_feed".}
proc cmarkparserfinish*(parser: ptr structcmarkparser): ptr structcmarknode {.
    cdecl, importc: "cmark_parser_finish".}
proc cmarkparsedocument*(buffer: cstring; len: culong; options: cint): ptr structcmarknode {.
    cdecl, importc: "cmark_parse_document".}
proc cmarkparsefile*(f: ptr structiofile; options: cint): ptr structcmarknode {.
    cdecl, importc: "cmark_parse_file".}
proc cmarkrenderxml*(root: ptr structcmarknode; options: cint): cstring {.cdecl,
    importc: "cmark_render_xml".}
proc cmarkrenderxmlwithmem*(root: ptr structcmarknode; options: cint;
                            mem: ptr structcmarkmem): cstring {.cdecl,
    importc: "cmark_render_xml_with_mem".}
proc cmarkrenderhtml*(root: ptr structcmarknode; options: cint;
                      extensions: ptr structcmarkllist): cstring {.cdecl,
    importc: "cmark_render_html".}
proc cmarkrenderhtmlwithmem*(root: ptr structcmarknode; options: cint;
                             extensions: ptr structcmarkllist;
                             mem: ptr structcmarkmem): cstring {.cdecl,
    importc: "cmark_render_html_with_mem".}
proc cmarkrenderman*(root: ptr structcmarknode; options: cint; width: cint): cstring {.
    cdecl, importc: "cmark_render_man".}
proc cmarkrendermanwithmem*(root: ptr structcmarknode; options: cint;
                            width: cint; mem: ptr structcmarkmem): cstring {.
    cdecl, importc: "cmark_render_man_with_mem".}
proc cmarkrendercommonmark*(root: ptr structcmarknode; options: cint;
                            width: cint): cstring {.cdecl,
    importc: "cmark_render_commonmark".}
proc cmarkrendercommonmarkwithmem*(root: ptr structcmarknode; options: cint;
                                   width: cint; mem: ptr structcmarkmem): cstring {.
    cdecl, importc: "cmark_render_commonmark_with_mem".}
proc cmarkrenderplaintext*(root: ptr structcmarknode; options: cint; width: cint): cstring {.
    cdecl, importc: "cmark_render_plaintext".}
proc cmarkrenderplaintextwithmem*(root: ptr structcmarknode; options: cint;
                                  width: cint; mem: ptr structcmarkmem): cstring {.
    cdecl, importc: "cmark_render_plaintext_with_mem".}
proc cmarkrenderlatex*(root: ptr structcmarknode; options: cint; width: cint): cstring {.
    cdecl, importc: "cmark_render_latex".}
proc cmarkrenderlatexwithmem*(root: ptr structcmarknode; options: cint;
                              width: cint; mem: ptr structcmarkmem): cstring {.
    cdecl, importc: "cmark_render_latex_with_mem".}
proc cmarkversion*(): cint {.cdecl, importc: "cmark_version".}
proc cmarkversionstring*(): cstring {.cdecl, importc: "cmark_version_string".}
