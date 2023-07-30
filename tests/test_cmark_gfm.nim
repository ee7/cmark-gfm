import std/[strutils, unittest]
import cmark_gfm

proc main =
  suite "basic markdown":
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
    """.unindent()

    test "toXml":
      const expected = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE document SYSTEM "CommonMark.dtd">
        <document xmlns="http://commonmark.org/xml/1.0">
          <heading level="1">
            <text xml:space="preserve">Heading 1</text>
          </heading>
          <paragraph>
            <text xml:space="preserve">Text</text>
          </paragraph>
          <paragraph>
            <emph>
              <text xml:space="preserve">italic</text>
            </emph>
          </paragraph>
          <paragraph>
            <strong>
              <text xml:space="preserve">emphasis</text>
            </strong>
          </paragraph>
          <paragraph>
            <code xml:space="preserve">monospace</code>
          </paragraph>
          <paragraph>
            <text xml:space="preserve">Here is a </text>
            <link destination="https://example.com" title="">
              <text xml:space="preserve">link</text>
            </link>
            <text xml:space="preserve">.</text>
          </paragraph>
          <code_block info="nim" xml:space="preserve">echo &quot;bar&quot;
        </code_block>
          <paragraph>
            <text xml:space="preserve">Here is a list:</text>
          </paragraph>
          <list type="bullet" tight="true">
            <item>
              <paragraph>
                <text xml:space="preserve">item 1</text>
              </paragraph>
            </item>
            <item>
              <paragraph>
                <text xml:space="preserve">item 2</text>
              </paragraph>
            </item>
            <item>
              <paragraph>
                <text xml:space="preserve">item 3</text>
              </paragraph>
            </item>
          </list>
        </document>
      """.dedent(8)

      check expected == toXml(s)

    test "toHtml":
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
      """.unindent()

      check expected == toHtml(s)

    test "toMan":
      const expected = """
        .SH
        Heading 1
        .PP
        Text
        .PP
        \f[I]italic\f[]
        .PP
        \f[B]emphasis\f[]
        .PP
        \f[C]monospace\f[]
        .PP
        Here is a link (https://example.com).
        .IP
        .nf
        \f[C]
        echo "bar"
        \f[]
        .fi
        .PP
        Here is a list:
        .IP \[bu] 2
        item 1
        .IP \[bu] 2
        item 2
        .IP \[bu] 2
        item 3
      """.unindent()

      check expected == toMan(s)

    test "toCommonmark":
      const expected = """
        # Heading 1

        Text

        *italic*

        **emphasis**

        `monospace`

        Here is a [link](https://example.com).

        ``` nim
        echo "bar"
        ```

        Here is a list:

          - item 1
          - item 2
          - item 3
      """.dedent(8)

      check expected == toCommonmark(s)

    test "toPlaintext":
      const expected = """
        Heading 1

        Text

        italic

        emphasis

        monospace

        Here is a link.

        echo "bar"

        Here is a list:

          - item 1
          - item 2
          - item 3
      """.dedent(8)

      check expected == toPlaintext(s)

    test "toLatex":
      const expected = """
        \section{Heading 1}

        Text

        \emph{italic}

        \textbf{emphasis}

        \texttt{monospace}

        Here is a \href{https://example.com}{link}.

        \begin{verbatim}
        echo "bar"
        \end{verbatim}

        Here is a list:

        \begin{itemize}
        \item item 1

        \item item 2

        \item item 3

        \end{itemize}
      """.unindent()

      check expected == toLatex(s)

  suite "raw HTML":
    const s = """
      <strong>text</strong>
    """.unindent()

    block:
      const expected = """
        <p><!-- raw HTML omitted -->text<!-- raw HTML omitted --></p>
      """.unindent()

      test "with default options and extensions":
        check expected == toHtml(s)

      test "with explicit no options":
        check expected == toHtml(s, options = [])

      test "with explicit no extensions":
        check expected == toHtml(s, extensions = {})

      test "with explicit no options and no extensions":
        check expected == toHtml(s, options = [], extensions = {})

    test "with unsafe option and default extensions":
      const expected = """
        <p><strong>text</strong></p>
      """.unindent()

      check expected == toHtml(s, options = [coUnsafe])

  suite "extensions":
    test "tables":
      # See https://github.github.com/gfm/#tables-extension-
      const s = """
        | foo | bar |
        | --- | --- |
        | baz | bim |
      """.unindent()

      const expected = """
        <table>
        <thead>
        <tr>
        <th>foo</th>
        <th>bar</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <td>baz</td>
        <td>bim</td>
        </tr>
        </tbody>
        </table>
      """.unindent()

      check expected == toHtml(s)

    test "tasklists":
      # See https://github.github.com/gfm/#task-list-items-extension-
      const s = """
        - [ ] foo
        - [x] bar
      """.unindent()

      const expected = """
        <ul>
        <li><input type="checkbox" disabled="" /> foo</li>
        <li><input type="checkbox" checked="" disabled="" /> bar</li>
        </ul>
      """.unindent()

      check expected == toHtml(s)

    test "strikethrough":
      # See https://github.github.com/gfm/#strikethrough-extension-
      const s = """
        ~~Hi~~ Hello, ~there~ world!
        This will ~~~not~~~ strike.
      """.unindent()

      const expected = """
        <p><del>Hi</del> Hello, <del>there</del> world!
        This will ~~~not~~~ strike.</p>
      """.unindent()

      check expected == toHtml(s)

    test "autolinks":
      # See https://github.github.com/gfm/#autolinks-extension-
      const s = """
        Visit www.commonmark.org/help for more information.
      """.unindent()

      const expected = """
        <p>Visit <a href="http://www.commonmark.org/help">www.commonmark.org/help</a> for more information.</p>
      """.unindent()

      check expected == toHtml(s)

    block:
      # See https://github.github.com/gfm/#disallowed-raw-html-extension-
      const s = """
        <strong> <title> <style> <em>

        <blockquote>
          <xmp> is disallowed.  <XMP> is also disallowed.
        </blockquote>
      """.unindent()

      test "tagfilter, without unsafe":
        const expected = """
          <p><!-- raw HTML omitted --> <!-- raw HTML omitted --> <!-- raw HTML omitted --> <!-- raw HTML omitted --></p>
          <!-- raw HTML omitted -->
        """.unindent()

        check expected == toHtml(s)

      test "tagfilter, with unsafe":
        const expected = """
          <p><strong> &lt;title> &lt;style> <em></p>
          <blockquote>
          &lt;xmp> is disallowed.  &lt;XMP> is also disallowed.
          </blockquote>
        """.unindent()

        check expected == toHtml(s, options = [coUnsafe], extensions = {ceTagfilter})

when isMainModule:
  main()
