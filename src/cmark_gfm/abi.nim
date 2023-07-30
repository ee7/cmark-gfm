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
    calloc*: proc (a0: csize_t, a1: csize_t): pointer {.cdecl.}
    realloc*: proc (a0: pointer, a1: csize_t): pointer {.cdecl.}
    free*: proc (a0: pointer): void {.cdecl.}
  MemPtr* = ptr Mem

  Llist* {.pure, inheritable, bycopy.} = object ## A singly linked list.
    next*: LlistPtr
    data*: pointer
  LlistPtr* = ptr Llist

  CmarkOptions* {.size: sizeof(cuint).} = enum
    coDefault = 0
      ## Default options.

    # Options affecting rendering (also `coUnsafe`, which must be at the end).
    coSourcepos = 1 shl 1
      ## Include a `data-sourcepos` attribute on all block elements.
    coHardbreaks = 1 shl 2
      ## Render `softbreak` elements as hard line breaks.
    coSafe = 1 shl 3
      ## Defined for API compatibility, but it no longer has any effect.
      ## "Safe" mode is now the default: use `coUnsafe` to disable it.
    coNoBreaks = 1 shl 4
      ## Render `softbreak` elements as spaces.

    # Options affecting parsing.
    coNormalize = 1 shl 8
      ## Legacy option (no effect).
    coValidateUtf8 = 1 shl 9
      ## Validate UTF-8 in the input before parsing, replacing illegal sequences
      ## with the character U+FFFD.
    coSmart = 1 shl 10
      ## Convert straight quotes to curly, --- to em dashes, and -- to en dashes.

    # Options affecting parsing (GFM-only).
    coGitHubPreLang = 1 shl 11
      ## Use GitHub-style <pre lang="x"> tags for code blocks instead of
      ## <pre><code class="language-x">.
    coLiberalHtmlTag = 1 shl 12
      ## Be liberal in interpreting inline HTML tags.
    coFootnotes = 1 shl 13
      ## Parse footnotes.
    coStrikethroughDoubleTilde = 1 shl 14
      ## Only parse strikethroughs if surrounded by exactly 2 tildes.
      ## Gives some compatibility with redcarpet.
    coTablePreferStyleAttributes = 1 shl 15
      ## Use style attributes to align table cells instead of align attributes.
    coFullInfoString = 1 shl 16
      ## Include the remainder of the info string in code blocks in a separate
      ## attribute.

    # Option affecting rendering.
    coUnsafe = 1 shl 17
      ## Render raw HTML and unsafe links (`javascript:`, `vbscript:`, `file:`,
      ## and `data:`, except for `image/png`, `image/gif`, `image/jpeg`, or
      ## `image/webp` mime types).
      ## By default, raw HTML is replaced by a placeholder HTML comment.
      ## Unsafe links are replaced by empty strings.

{.push cdecl, raises: [], gcsafe.}

# Simple interface

func cmarkMarkdownToHtml*(text: cstring,
                          len: csize_t,
                          options: cint): cstring {.
    importc: "cmark_markdown_to_html".}
  ## Converts `text` (assumed to be a UTF-8 encoded string with length `len`)
  ## from CommonMark Markdown to HTML, returning a null-terminated,
  ## UTF-8-encoded string.
  ## It is the caller's responsibility to free the returned buffer.


# Custom memory allocator support

func cmarkGetDefaultMemAllocator*: MemPtr {.
    importc: "cmark_get_default_mem_allocator".}
  ## The default memory allocator; uses the system's calloc, realloc and free.

func cmarkGetArenaMemAllocator*: MemPtr {.
    importc: "cmark_get_arena_mem_allocator".}
  ## An arena allocator; uses system calloc to allocate large slabs of memory.
  ## Memory in these slabs is not reused at all.

func cmarkArenaReset*: void {.importc: "cmark_arena_reset".}
  ## Resets the arena allocator, quickly returning all used memory to the
  ## operating system.


# Manipulating linked lists

func cmarkLlistAppend*(mem: MemPtr,
                       head: LlistPtr,
                       data: pointer): LlistPtr {.
    importc: "cmark_llist_append".}
  ## Append an element to the linked list, return the possibly modified head of
  ## the list.

func cmarkLlistFreeFull*(mem: MemPtr,
                         head: LlistPtr,
                         freeFunc: proc (a0: MemPtr,
                                         a1: pointer): void {.cdecl.}): void {.
    importc: "cmark_llist_free_full".}
  ## Frees the list starting with `head`, calling `freeFunc` with the data
  ## pointer of each of its elements.

func cmarkLlistFree*(mem: MemPtr,
                     head: LlistPtr): void {.
    importc: "cmark_llist_free".}
  ## Free the list starting with `head`.


# Creating and destroying nodes

func cmarkNodeNew*(nodeType: NodeType): NodePtr {.
    importc: "cmark_node_new".}
  ## Creates a new node of type `nodeType`. Note that the node may have other
  ## required properties, which it is the caller's responsibility to assign.

func cmarkNodeNewWithMem*(nodeType: NodeType,
                          mem: MemPtr): NodePtr {.
    importc: "cmark_node_new_with_mem".}
  ## Same as `cmarkNodeNew`, but explicitly listing the memory allocator used
  ## to allocate the node. Note: be sure to use the same allocator for every
  ## node in a tree, or bad things can happen.

func cmarkNodeNewWithExt*(nodeType: NodeType,
                          extension: SyntaxExtensionPtr): NodePtr {.
    importc: "cmark_node_new_with_ext".}

func cmarkNodeNewWithMemAndExt*(nodeType: NodeType,
                                mem: MemPtr,
                                extension: SyntaxExtensionPtr): NodePtr {.
    importc: "cmark_node_new_with_mem_and_ext".}

func cmarkNodeFree*(node: NodePtr): void {.
    importc: "cmark_node_free".}
  ## Frees the memory allocated for a node and any children.


# Tree traversal

func cmarkNodeNext*(node: NodePtr): NodePtr {.
    importc: "cmark_node_next".}
  ## Returns the next node after `node`, or NULL if there is none.

func cmarkNodePrevious*(node: NodePtr): NodePtr {.
    importc: "cmark_node_previous".}
  ## Returns the previous node to `node`, or NULL if there is none.

func cmarkNodeParent*(node: NodePtr): NodePtr {.
    importc: "cmark_node_parent".}
  ## Returns the parent of `node`, or NULL if there is none.

func cmarkNodeFirstChild*(node: NodePtr): NodePtr {.
    importc: "cmark_node_first_child".}
  ## Returns the first child of `node`, or NULL if `node` has no children.

func cmarkNodeLastChild*(node: NodePtr): NodePtr {.
    importc: "cmark_node_last_child".}
  ## Returns the last child of `node`, or NULL if `node` has no children.

func cmarkNodeParentFootnoteDef*(node: NodePtr): NodePtr {.
    importc: "cmark_node_parent_footnote_def".}
  ## Returns the footnote reference of `node`, or NULL if `node` doesn't have a
  ## footnote reference.


# Iterator

func cmarkIterNew*(root: NodePtr): IterPtr {.
    importc: "cmark_iter_new".}
  ## Creates a new iterator starting at `root`. The current node and event type
  ## are undefined until `cmarkIterNext` is called for the first time.
  ## The memory allocated for the iterator should be released using
  ## `cmarkIterFree` when it is no longer needed.

func cmarkIterFree*(iter: IterPtr): void {.
    importc: "cmark_iter_free".}
  ## Frees the memory allocated for an iterator.

func cmarkIterNext*(iter: IterPtr): EventType {.
    importc: "cmark_iter_next".}
  ## Advances to the next node and returns the event type.

func cmarkIterGetNode*(iter: IterPtr): NodePtr {.
    importc: "cmark_iter_get_node".}
  ## Returns the current node.

func cmarkIterGetEventType*(iter: IterPtr): EventType {.
    importc: "cmark_iter_get_event_type".}
  ## Returns the current event type.

func cmarkIterGetRoot*(iter: IterPtr): NodePtr {.
    importc: "cmark_iter_get_root".}
  ## Returns the root node.

func cmarkIterReset*(iter: IterPtr,
                     current: NodePtr,
                     eventType: EventType): void {.
    importc: "cmark_iter_reset".}
  ## Resets the iterator so that the current node is `current` and the event
  ## type is `eventType`. The new current node must be a descendant of the
  ## root node or the root node itself.


# Accessors

func cmarkNodeGetUserData*(node: NodePtr): pointer {.
    importc: "cmark_node_get_user_data".}
  ## Returns the user data of `node`.

func cmarkNodeSetUserData*(node: NodePtr,
                           userData: pointer): cint {.
    importc: "cmark_node_set_user_data".}
  ## Sets arbitrary user data for `node`.
  ## Returns 1 on success, 0 on failure.

func cmarkNodeSetUserDataFreeFunc*(node: NodePtr,
                                   freeFunc: proc (a0: MemPtr,
                                                   a1: pointer): void {.cdecl.}): cint {.
    importc: "cmark_node_set_user_data_free_func".}
  ## Sets free function for user data.

func cmarkNodeGetType*(node: NodePtr): NodeType {.
    importc: "cmark_node_get_type".}
  ## Returns the type of `node`, or `ntNone` on error.

func cmarkNodeGetTypeString*(node: NodePtr): cstring {.
    importc: "cmark_node_get_type_string".}
  ## Like `cmarkNodeGetType`, but returns a string representation of the
  ## type, or `"<unknown>"`.

func cmarkNodeGetLiteral*(node: NodePtr): cstring {.
    importc: "cmark_node_get_literal".}
  ## Returns the string contents of `node`, or an empty string if none is set.
  ## Returns NULL if called on a node that does not have string content.

func cmarkNodeSetLiteral*(node: NodePtr,
                          content: cstring): cint {.
    importc: "cmark_node_set_literal".}
  ## Sets the string contents of `node`.
  ## Returns 1 on success, 0 on failure.

func cmarkNodeGetHeadingLevel*(node: NodePtr): cint {.
    importc: "cmark_node_get_heading_level".}
  ## Returns the heading level of `node`, or 0 if `node` is not a heading.

func cmarkNodeSetHeadingLevel*(node: NodePtr,
                               level: cint): cint {.
    importc: "cmark_node_set_heading_level".}
  ## Sets the heading level of `node`, returning 1 on success and 0 on error.

func cmarkNodeGetListType*(node: NodePtr): ListType {.
    importc: "cmark_node_get_list_type".}
  ## Returns the list type of `node`, or `ltNoList` if `node` is not a list.

func cmarkNodeSetListType*(node: NodePtr,
                           listType: ListType): cint {.
    importc: "cmark_node_set_list_type".}
  ## Sets the list type of `node`, returning 1 on success and 0 on error.

func cmarkNodeGetListDelim*(node: NodePtr): DelimType {.
    importc: "cmark_node_get_list_delim".}
  ## Returns the list delimiter type of `node`, or `dtNoDeLim` if `node` is not
  ## a list.

func cmarkNodeSetListDelim*(node: NodePtr,
                            delim: DelimType): cint {.
    importc: "cmark_node_set_list_delim".}
  ## Sets the list delimiter type of `node`, returning 1 on success and 0 on
  ## error.

func cmarkNodeGetListStart*(node: NodePtr): cint {.
    importc: "cmark_node_get_list_start".}
  ## Returns starting number of `node`, if it is an ordered list, otherwise 0.

func cmarkNodeSetListStart*(node: NodePtr,
                            start: cint): cint {.
    importc: "cmark_node_set_list_start".}
  ## Sets starting number of `node`, if it is an ordered list.
  ## Returns 1 on success, 0 on failure.

func cmarkNodeGetListTight*(node: NodePtr): cint {.
    importc: "cmark_node_get_list_tight".}
  ## Returns 1 if `node` is a tight list, 0 otherwise.

func cmarkNodeSetListTight*(node: NodePtr,
                            tight: cint): cint {.
    importc: "cmark_node_set_list_tight".}
  ## Sets the "tightness" of a list.
  ## Returns 1 on success, 0 on failure.

func cmarkNodeGetItemIndex*(node: NodePtr): cint {.
    importc: "cmark_node_get_item_index".}
  ## Returns item index of `node`. This is only used when rendering output
  ## formats such as commonmark, which need to output the index. It is not
  ## required for formats such as html or latex.

func cmarkNodeSetItemIndex*(node: NodePtr,
                            idx: cint): cint {.
    importc: "cmark_node_set_item_index".}
  ## Sets item index of `node`.
  ## Returns 1 on success, 0 on failure.

func cmarkNodeGetFenceInfo*(node: NodePtr): cstring {.
    importc: "cmark_node_get_fence_info".}
  ## Returns the info string from a fenced code block.

func cmarkNodeSetFenceInfo*(node: NodePtr,
                            info: cstring): cint {.
    importc: "cmark_node_set_fence_info".}
  ## Sets the info string in a fenced code block, returning 1 on success and
  ## 0 on failure.

func cmarkNodeSetFenced*(node: NodePtr,
                         fenced: cint,
                         length: cint,
                         offset: cint,
                         character: cschar): cint {.
    importc: "cmark_node_set_fenced".}
  ## Sets code blocks fencing details.

func cmarkNodeGetFenced*(node: NodePtr,
                         length: ptr cint,
                         offset: ptr cint,
                         character: cstring): cint {.
    importc: "cmark_node_get_fenced".}
  ## Returns code blocks fencing details.

func cmarkNodeGetUrl*(node: NodePtr): cstring {.
    importc: "cmark_node_get_url".}
  ## Returns the URL of a link or image `node`, or an empty string if no URL is
  ## set.
  ## Returns NULL if called on a node that is not a link or image.

func cmarkNodeSetUrl*(node: NodePtr,
                      url: cstring): cint {.
    importc: "cmark_node_set_url".}
  ## Sets the URL of a link or image `node`.
  ## Returns 1 on success, 0 on failure.

func cmarkNodeGetTitle*(node: NodePtr): cstring {.
    importc: "cmark_node_get_title".}
  ## Returns the title of a link or image `node`, or an empty string if no title
  ## is set.
  ## Returns NULL if called on a node that is not a link or image.

func cmarkNodeSetTitle*(node: NodePtr,
                        title: cstring): cint {.
    importc: "cmark_node_set_title".}
  ## Sets the title of a link or image `node`.
  ## Returns 1 on success, 0 on failure.

func cmarkNodeGetOnEnter*(node: NodePtr): cstring {.
    importc: "cmark_node_get_on_enter".}
  ## Returns the literal "on enter" text for a custom `node`, or an empty string
  ## if no onEnter is set.
  ## Returns NULL if called on a non-custom node.

func cmarkNodeSetOnEnter*(node: NodePtr,
                          onEnter: cstring): cint {.
    importc: "cmark_node_set_on_enter".}
  ## Sets the literal text to render "on enter" for a custom `node`.
  ## Any children of the node will be rendered after this text.
  ## Returns 1 on success 0 on failure.

func cmarkNodeGetOnExit*(node: NodePtr): cstring {.
    importc: "cmark_node_get_on_exit".}
  ## Returns the literal "on exit" text for a custom `node`, or an empty string
  ## if no onExit is set.
  ## Returns NULL if called on a non-custom node.

func cmarkNodeSetOnExit*(node: NodePtr,
                         onExit: cstring): cint {.
    importc: "cmark_node_set_on_exit".}
  ## Sets the literal text to render "on exit" for a custom `node`.
  ## Any children of the node will be rendered before this text.
  ## Returns 1 on success 0 on failure.

func cmarkNodeGetStartLine*(node: NodePtr): cint {.
    importc: "cmark_node_get_start_line".}
  ## Returns the line on which `node` begins.

func cmarkNodeGetStartColumn*(node: NodePtr): cint {.
    importc: "cmark_node_get_start_column".}
  ## Returns the column at which `node` begins.

func cmarkNodeGetEndLine*(node: NodePtr): cint {.
    importc: "cmark_node_get_end_line".}
  ## Returns the line on which `node` ends.

func cmarkNodeGetEndColumn*(node: NodePtr): cint {.
    importc: "cmark_node_get_end_column".}
  ## Returns the column at which `node` ends.


# Tree manipulation

func cmarkNodeUnlink*(node: NodePtr): void {.
    importc: "cmark_node_unlink".}
  ## Unlinks a `node`, removing it from the tree, but not freeing its memory.
  ## Use `cmarkNodeFree` for that.

func cmarkNodeInsertBefore*(node: NodePtr,
                            sibling: NodePtr): cint {.
    importc: "cmark_node_insert_before".}
  ## Inserts `sibling` before `node`.
  ## Returns 1 on success, 0 on failure.

func cmarkNodeInsertAfter*(node: NodePtr,
                           sibling: NodePtr): cint {.
    importc: "cmark_node_insert_after".}
  ## Inserts `sibling` after `node`.
  ## Returns 1 on success, 0 on failure.

func cmarkNodeReplace*(oldNode: NodePtr,
                       newNode: NodePtr): cint {.
    importc: "cmark_node_replace".}
  ## Replaces `oldnode` with `newNode` and unlinks `oldNode` (but does not free
  ## its memory).
  ## Returns 1 on success, 0 on failure.

func cmarkNodePrependChild*(node: NodePtr,
                            child: NodePtr): cint {.
    importc: "cmark_node_prepend_child".}
  ## Adds `child` to the beginning of the children of `node`.
  ## Returns 1 on success, 0 on failure.

func cmarkNodeAppendChild*(node: NodePtr,
                           child: NodePtr): cint {.
    importc: "cmark_node_append_child".}
  ## Adds `child` to the end of the children of `node`.
  ## Returns 1 on success, 0 on failure.

func cmarkConsolidateTextNodes*(root: NodePtr): void {.
    importc: "cmark_consolidate_text_nodes".}
  ## Consolidates adjacent text nodes.

func cmarkNodeOwn*(root: NodePtr): void {.
    importc: "cmark_node_own".}
  ## Ensures a node and all its children own their own chunk memory.


# Parsing

func cmarkParserNew*(options: cint): ParserPtr {.
    importc: "cmark_parser_new".}
  ## Creates a new parser object.

func cmarkParserNewWithMem*(options: cint,
                            mem: MemPtr): ParserPtr {.
    importc: "cmark_parser_new_with_mem".}
  ## Creates a new parser object with the given memory allocator.

func cmarkParserFree*(parser: ParserPtr): void {.
    importc: "cmark_parser_free".}
  ## Frees memory allocated for a parser object.

func cmarkParserFeed*(parser: ParserPtr,
                      buffer: cstring,
                      len: csize_t): void {.
    importc: "cmark_parser_feed".}
  ## Feeds a string of length `len` to `parser`.

func cmarkParserFinish*(parser: ParserPtr): NodePtr {.
    importc: "cmark_parser_finish".}
  ## Finish parsing and return a pointer to a tree of nodes.

func cmarkParseDocument*(buffer: cstring,
                         len: csize_t,
                         options: cint): NodePtr {.
    importc: "cmark_parse_document".}
  ## Parses a CommonMark document in `buffer` of length `len`.
  ## Returns a pointer to a tree of nodes.
  ## The memory allocated for the node tree should be released using
  ## `cmarkNodeFree` when it is no longer needed.


# Rendering

func cmarkRenderXml*(root: NodePtr,
                     options: cint): cstring {.
    importc: "cmark_render_xml".}
  ## Renders a `node` tree as XML.
  ## It is the caller's responsibility to free the returned buffer.

func cmarkRenderXmlWithMem*(root: NodePtr,
                            options: cint,
                            mem: MemPtr): cstring {.
    importc: "cmark_render_xml_with_mem".}
  ## As for `cmarkRenderXml`, but specifying the allocator to use for the
  ## resulting string.

func cmarkRenderHtml*(root: NodePtr,
                      options: cint,
                      extensions: LlistPtr): cstring {.
    importc: "cmark_render_html".}
  ## Renders a `node` tree as an HTML fragment. It is up to the user to add an
  ## appropriate header and footer.
  ## It is the caller's responsibility to free the returned buffer.

func cmarkRenderHtmlWithMem*(root: NodePtr,
                             options: cint,
                             extensions: LlistPtr,
                             mem: MemPtr): cstring {.
    importc: "cmark_render_html_with_mem".}
  ## As for `cmarkRenderHtml`, but specifying the allocator to use for the
  ## resulting string.

func cmarkRenderMan*(root: NodePtr,
                     options: cint,
                     width: cint): cstring {.
    importc: "cmark_render_man".}
  ## Renders a `node` tree as a groff man page, without the header.
  ## It is the caller's responsibility to free the returned buffer.

func cmarkRenderManWithMem*(root: NodePtr,
                            options: cint,
                            width: cint,
                            mem: MemPtr): cstring {.
    importc: "cmark_render_man_with_mem".}
  ## As for `cmarkRenderMan`, but specifying the allocator to use for the
  ## resulting string.

func cmarkRenderCommonmark*(root: NodePtr,
                            options: cint,
                            width: cint): cstring {.
    importc: "cmark_render_commonmark".}
  ## Renders a `node` tree as a commonmark document.
  ## It is the caller's responsibility to free the returned buffer.

func cmarkRenderCommonmarkWithMem*(root: NodePtr,
                                   options: cint,
                                   width: cint,
                                   mem: MemPtr): cstring {.
    importc: "cmark_render_commonmark_with_mem".}
  ## As for `cmarkRenderCommonmark`, but specifying the allocator to use for
  ## the resulting string.

func cmarkRenderPlaintext*(root: NodePtr,
                           options: cint,
                           width: cint): cstring {.
    importc: "cmark_render_plaintext".}
  ## Renders a `node` tree as a plain text document.
  ## It is the caller's responsibility to free the returned buffer.

func cmarkRenderPlaintextWithMem*(root: NodePtr,
                                  options: cint,
                                  width: cint,
                                  mem: MemPtr): cstring {.
    importc: "cmark_render_plaintext_with_mem".}
  ## As for `cmarkRenderPlaintext`, but specifying the allocator to use for
  ## the resulting string.

func cmarkRenderLatex*(root: NodePtr,
                       options: cint,
                       width: cint): cstring {.
    importc: "cmark_render_latex".}
  ## Renders a `node` tree as a LaTeX document.
  ## It is the caller's responsibility to free the returned buffer.

func cmarkRenderLatexWithMem*(root: NodePtr,
                              options: cint,
                              width: cint,
                              mem: MemPtr): cstring {.
    importc: "cmark_render_latex_with_mem".}
  ## As for `cmarkRenderLatex`, but specifying the allocator to use for the
  ## resulting string.


# Version information

func cmarkVersion*: cint {.importc: "cmark_version".}
  ## The library version as integer for runtime checks.
  ##
  ## Bits 16-23 contain the major version.
  ## Bits 8-15 contain the minor version.
  ## Bits 0-7 contain the patchlevel.
  ##
  ## In hexadecimal format, the number 0x010203 represents version 1.2.3.

func cmarkVersionString*: cstring {.importc: "cmark_version_string".}
  ## The library version string for runtime checks.

{.pop.}
