class Ontology < ActiveRecord::Base

  # Ontohub Library Includes
  include Commentable
  include Metadatable

  # Ontology Model Includes
  include Ontology::Import
  include Ontology::States
  include Ontology::Versions
  include Ontology::Entities
  include Ontology::Sentences
  include Ontology::Links
  include Ontology::Distributed
  include Ontology::Oops

  # Multiple Class Features
  include Aggregatable

  belongs_to :repository
  belongs_to :language
  belongs_to :logic, counter_cache: true

  attr_accessible :iri, :name, :description, :logic_id

  validates_presence_of :iri
  validates_uniqueness_of :iri, :if => :iri_changed?
  validates_format_of :iri, :with => URI::regexp(Settings.allowed_iri_schemes)

  delegate :permission?, to: :repository

  strip_attributes :only => [:name, :iri]

  scope :search, ->(query) { where "ontologies.iri #{connection.ilike_operator} :term OR name #{connection.ilike_operator} :term", :term => "%" << query << "%" }
  scope :list, includes(:logic).order('ontologies.state asc, ontologies.entities_count desc')

  def to_s
    name? ? name : iri
  end

  # title for links
  def title
    name? ? iri : nil
  end

  def symbols
    entities
  end

  def symbols_count
    entities_count
  end

  def self.filename_without_extension(filename)
    filename.gsub(/(.+)\.[^\.]+/, "\\1")
  end
  
end
