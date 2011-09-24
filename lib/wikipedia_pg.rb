require 'sequel'

module WikipediaPg
  DB = Sequel.connect 'postgres:///wikipedia'

end
