import std/[strutils, unittest]
import cmark_gfm/abi

proc main =
  test "can convert markdown that doesn't use GFM extensions to HTML":
    const s = """
      # Heading 1

      Text

      _italic_

      **emphasis**

      `monospace`

      Here is a [link][1].

      [1]: https://example.com

      ```nim
      echo "bar"
      ```

      Here is a list:

      - item 1
      - item 2
      - item 3
    """.unindent().cstring

    const expected = """
      <h1>Heading 1</h1>
      <p>Text</p>
      <p><em>italic</em></p>
      <p><strong>emphasis</strong></p>
      <p><code>monospace</code></p>
      <p>Here is a <a href="https://example.com">link</a>.</p>
      <pre><code class="language-nim">echo &quot;bar&quot;
      </code></pre>
      <p>Here is a list:</p>
      <ul>
      <li>item 1</li>
      <li>item 2</li>
      <li>item 3</li>
      </ul>
    """.unindent().cstring

    let actual = cmarkMarkdownToHtml(s, s.len.csize_t, 0.cint)
    check actual == expected
    c_free(actual)

when isMainModule:
  suite "abi":
    main()
