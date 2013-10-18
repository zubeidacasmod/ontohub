# This search has been inspired by:
# http://blog.tipter.com/blog/2013/06/16/autocomplete-with-elasticsearch-and-tire/
module Ontology::Search
  extend ActiveSupport::Concern
  include Common::Search
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  included do
    settings :analysis => { 
       filter: {
         trip_ngram: {
           "type"     => "edgeNGram",
           "max_gram" => 15,
           "min_gram" => 2
         }
       },
       analyzer: {
         index_ngram_analyzer: {
           "type" => "custom",
           "tokenizer" => "standard",
           "filter" => [ "standard", "lowercase", "trip_ngram" ]
         },
         search_ngram_analyzer: {
           "type" => "custom",
           "tokenizer" => "standard",
           "filter" => [ "standard", "lowercase"] 
         }
       } 
    }

    mapping do
      indexes :id, index: :not_analyzed
      indexes :name, type: 'multi_field', boost: 10, fields: {
        name: { type: "string" },
        autcomplete: { search_analyzer: "search_ngram_analyzer", index_analyzer: "index_ngram_analyzer", type: "string" }
      }
    end
  end

  module ClassMethods
    def regular_search(params) 
      tire.search(load: true) do
        query {string 'name:' + params }
      end
    end


    def autocomplete(params) 
      tire.search(load: true) do
        query {string 'autocomplete:' + params }
      end
    end
  end
  
  def to_indexed_json
    to_json(:methods => [:name])
  end
  
end