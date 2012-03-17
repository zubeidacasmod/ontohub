class OntologyVersion < ActiveRecord::Base
  include OntologyVersion::Async
  include OntologyVersion::Download
  include OntologyVersion::Parsing

  belongs_to :user
  belongs_to :ontology, :counter_cache => :versions_count

  mount_uploader :raw_file, OntologyUploader
  mount_uploader :xml_file, OntologyUploader

  attr_accessible :raw_file, :source_uri

  before_validation :set_checksum

  validate :raw_file_xor_source_uri, :on => :create
# validate :raw_file_size_maximum

  validates_format_of :source_uri,
    :with => URI::regexp(ALLOWED_URI_SCHEMAS), :if => :source_uri?

  scope :latest, order('id DESC')
  scope :state, ->(state) { where :state => state }
  scope :done, state('done')
  scope :failed, state('failed')

  # updated_at of the latest version
  def self.last_updated_at
    latest.first.try(:updated_at)
  end
  
  def source_name
    source_uri? ? source_uri : 'File upload'
  end
  
protected

  def raw_file_xor_source_uri
    if !(raw_file.blank? ^ source_uri.blank?)
      errors.add :source_uri, 'Specify either a source file or URI.'
    end
  end

  def raw_file_size_maximum
    if raw_file.size > 10.megabytes.to_i
      errors.add :raw_file, 'The maximum file size is 10M.'
    end
  end

  def set_checksum
    self.checksum = raw_file.sha1 if raw_file.present? and raw_file_changed?
  end
end
