import hljs from 'highlight.js'
import MarkdownIt from 'markdown-it'
import emoji from 'markdown-it-emoji'
import './../css/bootstrap.css'
import './../css/gist.css'
import './../css/github.css'
import './../css/index.css'

window.showMarkdown = (percentEncodedMarkdown, enableImage = true) => {

  if (!percentEncodedMarkdown) {
    return
  }

  const markdownText = decodeURIComponent(percentEncodedMarkdown)

  let markdown = new MarkdownIt({
    html: true,
    breaks: true,
    linkify: true,
    highlight: function(code){
        return hljs.highlightAuto(code).value;
    }
  })

  if (!enableImage) {
    markdown = markdown.disable('image')
  }

  markdown.use(emoji)

  let html = markdown.render(markdownText)

  document.getElementById('contents').innerHTML = html

  let tables = document.querySelectorAll('table')

  tables.forEach((table) => {
    table.classList.add('table')
  })

  let codes = document.querySelectorAll('pre code')

  codes.forEach((code) => {
    hljs.highlightBlock(code)
  })

}
