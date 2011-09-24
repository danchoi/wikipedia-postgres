require 'sequel'

module WikipediaVim
  DB = Sequel.connect 'postgres:///wikipedia'

end
