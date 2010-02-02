require "rubygems"
require "prawn"
require "palm"
require 'iconv'
require 'UniversalDetector' # chardet gem
require 'logger'

require "prawn/measurement_extensions"

module Pdbook
  class Converter
    def initialize(input, output, font = "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf", options = {:page_size => "A4", :margin => 0.6.in, :font_size => 20, :spacing => 10, :compress => true})
      @input = input
      @output = output
      @font = font
      @options = options
      @options[:page_size] = ENV["page_size"] if ENV["page_size"]
      @options[:margin] = ENV["margin"] if ENV["margin"]
      @options[:font_size] = ENV["font_size"].to_i if ENV["font_size"]
      @options[:spacing] = ENV["spacing"].to_i if ENV["spacing"]

      @pdb = Palm::PDB.new(input)
      @log = Logger.new($STDOUT)
    end
  
    def convert!
      data = @pdb.data
      Prawn::Document.generate @output, @options do |doc|
        doc.font @font
        toc = data.shift.data
        content = data

        # render cover & toc
        render_toc(doc, toc)
      
        # render content
        doc.text_options.update(:wrap => :character, :size => @options[:font_size], :spacing => @options[:spacing])            
        content.each do |record|
          render_content(doc, record.data)
        end
      end
    end
    
    protected
    # find current document charset
    def charset
      text_check = @pdb.data.first.data.gsub("\e", "")
      enc = UniversalDetector::chardet(text_check)["encoding"]
    end
  
    private
    # First \e\e\e is marker for first page
    # Subsequent \e is link
    def render_toc(doc, data)
      current_charset = charset
      data = to_utf8(current_charset, data)

      cover, toc = data.split("\e\e\e")    
      if toc.nil?
        toc = cover
        cover = nil
      end
    
      # print cover
      unless cover.nil?
        doc.text_options.update(:wrap => :character, :size => @options[:font_size]*2, :spacing => @options[:spacing] * 2)
        doc.bounding_box [doc.bounds.left, 2*doc.bounds.top/3], :width => doc.bounds.width do
          doc.text cover
        end
        doc.start_new_page
      end
    
      # print toc
      unless toc.nil?
        doc.text_options.update(:wrap => :character, :size => @options[:font_size], :spacing => @options[:spacing])
        toc = toc.split("\e")      
        section_cnt = toc.shift.to_i
        if section_cnt == toc.size      
          @log.debug "Print TOC"
          # details
          toc.each do |line|
            doc.text line
          end
          doc.start_new_page
        else
         @log.error "TOC size not equals to number of section! #{toc.size} != #{section_cnt}"
        end      
      end   
    end

    def render_content(doc, content)
      current_charset = self.charset
      doc.bounding_box([doc.bounds.left, doc.bounds.top], :width => doc.bounds.width) do
        # main text
        content = to_utf8(current_charset, content)
        section = cleanup_content_text(content).split("\r\n")
        section.each do |line|
          doc.text line
        end
        doc.start_new_page
      end
    end
  
    def cleanup_content_text(text)
      text.gsub!('﹁', '「')
      text.gsub!('﹂', '」')
      text.gsub!('︽', '《')
      text.gsub!('︾', '》')
      text.gsub!('｜', 'ー‎')
      text.gsub!('︵', '（')
      text.gsub!('︶', '）')
      text
    end
    
    def to_utf8(charset, text)
      Iconv.conv("UTF-8//IGNORE", charset, text)
    end  
  end
end