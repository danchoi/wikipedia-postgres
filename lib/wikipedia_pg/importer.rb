require 'wikipedia_pg'
require 'rexml/streamlistener'
require 'rexml/document'

module WikipediaPg

  class WikipediaXmlListener
    include REXML::StreamListener

    TAGS = %w( page title id revision timestamp text )

    def initialize
      @page_count = 0
      @page = {}
      @nest = []
    end

    def result; @page; end

    def tag_start(name, attributes)
      @nest.push name
      if name == 'page'
        @page_count += 1
        @page = {}
      end
    end

    def tag_end(name)
      @nest.pop
      if name == 'page'
        import @page
      end
    end

    def text s
      return unless s =~ /\S/
      if @nest.size > 1
        #puts "#{path} #{s.strip[0,50]}"
        @page[path] = s.strip
      end
    end

    def path
      @nest[2..-1].join('.')
    end

    def import(page)
      page_id = page['id'].to_i
      if DB[:pages].filter(:page_id => page_id).first
        puts "Already inserted page: #{page['title']}"
        return
      end
      params = { 
        page_id: page_id,
        page_title: page['title'],
        revision_id: page['revision.id'].to_i,
        revision_timestamp: page['revision.timestamp'],
        page_text: page['revision.text']
      }
      DB[:pages].insert params
      puts "Inserting page: #{params[:page_title]} "
    rescue Sequel::DatabaseError
      if $!.message =~ /violates unique constraint/
        puts "Already inserted page: #{params[:page_title]}"
      else
        raise
      end
    end
  end

  class Importer
    def initialize(xml_file_path)
      @listener = WikipediaXmlListener.new
      @parser = REXML::Parsers::StreamParser.new(File.new(xml_file_path), @listener)
    end

    def run
      @parser.parse
    end
  end
end

if __FILE__ == $0
  file = 'wikipedia.xml'
  importer = WikipediaVim::Importer.new file
  importer.run
end