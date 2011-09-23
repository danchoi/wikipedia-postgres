require 'rexml/streamlistener'
require 'rexml/document'

module WikipediaVim

  class WikipediaXmlListener
    include REXML::StreamListener
    def tag_start(name, attributes)
      puts name
    end

    def tag_end(name)
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
