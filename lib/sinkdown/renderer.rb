require 'redcarpet'
require 'pygments'
require 'liquid'

module Sinkdown
  class Renderer
    def initialize(site)
      @site = site
      @source_pathname = Pathname.new site.config[:source]
      @engine = Redcarpet::Markdown.new(PygmentsHtml, :fenced_code_blocks => true)
      template_str = File.read site.config[:template]
      index_template_str = File.read File.join(File.dirname(__FILE__), 'templates', 'index.html')
      @template = Liquid::Template.parse(template_str)
      @index_template = Liquid::Template.parse(index_template_str)
    end

    def wrap(html)
      return @template.render 'content' => html, 'site' => @site
    end

    def render_document(document)
      return @template.render 'document' => document, 'site' => @site
    end

    def markdown_to_html(md)
      @engine.render md
    end

    def render_index(index_document)
      @index_template.render 'site' => @site, 'document' => index_document
    end
  end

  class PygmentsHtml < Redcarpet::Render::HTML
    def block_code(code, language)
      Pygments.highlight code, lexer: language
    end
  end
end
