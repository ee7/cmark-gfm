import cmark_gfm/abi
export CmarkOptions

type
  CmarkError* = object of CatchableError

  CmarkExtension* = enum
    ceAutolink = "autolink"
    ceTable = "table"
    ceTagfilter = "tagfilter"
    ceTasks = "tasklist"
    ceStrikethrough = "strikethrough"

  RenderKind* = enum
    rkXml
    rkHtml
    rkMan
    rkCommonmark
    rkPlaintext
    rkLatex

const
  defaultExtensions* = {ceAutolink, ceTable, ceTasks, ceStrikethrough,
                        ceTagfilter}

func toCint(options: openArray[CmarkOptions]): cint =
  result = 0.cint
  for o in options:
    result = result or o.ord.cint

func renderImpl(renderKind: RenderKind,
                text: string,
                options: openArray[CmarkOptions],
                extensions: set[CmarkExtension],
                width: cint): string =
  ## Uses cmark-gfm to parse `text`, using the given `options` and GFM-specific
  ## `extensions`.
  cmarkGfmCoreExtensionsEnsureRegistered()
  let opts = toCint(options)

  let parser = cmarkParserNew(opts)
  if parser == nil:
    raise newException(CmarkError, "failed to create cmark parser")

  for name in extensions:
    let ext = cmarkFindSyntaxExtension(name.`$`.cstring)
    if ext == nil:
      raise newException(CmarkError, "failed to find extension: " & $name)
    if parser.cmarkParserAttachSyntaxExtension(ext) == 0:
      raise newException(CmarkError, "failed to attach extension: " & $name)

  parser.cmarkParserFeed(text.cstring, text.cstring.len.csize_t)
  let root = parser.cmarkParserFinish()
  if root == nil:
    raise newException(CmarkError, "failed to parse markdown")

  let exts = parser.cmarkParserGetSyntaxExtensions()
  if extensions.card > 0 and exts == nil:
    raise newException(CmarkError, "failed to get cmark syntax extensions")

  let rendered =
    case renderKind
    of rkXml:
      cmarkRenderXml(root, opts)
    of rkHtml:
      cmarkRenderHtml(root, opts, exts)
    of rkMan:
      cmarkRenderMan(root, opts, width)
    of rkCommonmark:
      cmarkRenderCommonmark(root, opts, width)
    of rkPlaintext:
      cmarkRenderPlaintext(root, opts, width)
    of rkLatex:
      cmarkRenderLatex(root, opts, width)

  result = $rendered
  c_free rendered
  c_free root
  c_free exts # Also frees `parser`. Don't call `cmarkParserFree(parser)` too.

func toXml*(text: string,
            options: openArray[CmarkOptions] = [coDefault],
            extensions: set[CmarkExtension] = defaultExtensions): string =
  ## Uses cmark-gfm to render `text` as XML, using the given `options` and
  ## GFM-specific `extensions`.
  rkXml.renderImpl(text, options, extensions, -1.cint)

func toHtml*(text: string,
             options: openArray[CmarkOptions] = [coDefault],
             extensions: set[CmarkExtension] = defaultExtensions): string =
  ## Uses cmark-gfm to render `text` as an HTML fragment, using the given
  ## `options` and GFM-specific `extensions`.
  ##
  ## It is the caller's responsibility to add an appropriate header and footer.
  rkHtml.renderImpl(text, options, extensions, -1.cint)

func toMan*(text: string,
            options: openArray[CmarkOptions] = [coDefault],
            extensions: set[CmarkExtension] = defaultExtensions,
            width = -1): string =
  ## Uses cmark-gfm to render `text` as a groff man page (without a header),
  ## using the given `options` and GFM-specific `extensions`.
  rkMan.renderImpl(text, options, extensions, width.cint)

func toCommonmark*(text: string,
                   options: openArray[CmarkOptions] = [coDefault],
                   extensions: set[CmarkExtension] = defaultExtensions,
                   width = -1): string =
  ## Uses cmark-gfm to render `text` as a commonmark document, using the given
  ## `options` and GFM-specific `extensions`.
  rkCommonmark.renderImpl(text, options, extensions, width.cint)

func toPlaintext*(text: string,
                  options: openArray[CmarkOptions] = [coDefault],
                  extensions: set[CmarkExtension] = defaultExtensions,
                  width = -1): string =
  ## Uses cmark-gfm to render `text` as a plain text document, using the given
  ## `options` and GFM-specific `extensions`.
  rkPlaintext.renderImpl(text, options, extensions, width.cint)

func toLatex*(text: string,
              options: openArray[CmarkOptions] = [coDefault],
              extensions: set[CmarkExtension] = defaultExtensions,
              width = -1): string =
  ## Uses cmark-gfm to render `text` as a LaTeX document, using the given
  ## `options` and GFM-specific `extensions`.
  rkLatex.renderImpl(text, options, extensions, width.cint)
