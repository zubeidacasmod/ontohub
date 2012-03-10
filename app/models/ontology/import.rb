module Ontology::Import
	extend ActiveSupport::Concern

  def import_xml(io)
    @logic_name = nil
    @entities   = []
    @axioms     = []

    transaction do
      OntologyParser.parse io,
        ontology: Proc.new { |h| 
          self.logic = Logic.find_or_create_by_name h['logic']
        },
        symbol:   Proc.new { |h|
          entities.update_or_create_from_hash h
        },
        axiom:    Proc.new { |h|
          axioms.update_or_create_from_hash h
        }

#     save!
    end
  end

  def import_xml_from_file(path)
    import_xml File.open path
  end
end
