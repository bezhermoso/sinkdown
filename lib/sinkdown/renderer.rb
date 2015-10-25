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


    def render(content)
      partial = @engine.render content
      return @template.render 'content' => partial, 'site' => @site
    end

    def render_index
      content = @index_template.render 'site' => @site
      File.open(File.join(@site.config[:sinkdown_dir], 'index.html'), 'w') do |f|
        f.write content
      end
    end

    def convert(document)
      destination = File.join @site.config[:sinkdown_dir], document.url
      content = document.raw
      full_html = render content
      dir = File.dirname destination
      unless File.directory? dir
        FileUtils.mkdir_p dir
      end

      File.open(destination, 'w') do |f|
        f.write full_html
      end
    end
  end

  class PygmentsHtml < Redcarpet::Render::HTML
    def block_code(code, language)
      Pygments.highlight code, lexer: language
    end
  end
end
