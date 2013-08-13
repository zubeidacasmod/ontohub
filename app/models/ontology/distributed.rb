module Ontology::Distributed
  extend ActiveSupport::Concern
  
  included do
    acts_as_tree
  end
  
  def distributed?
    is_a? DistributedOntology
  end

  def homogeneous?
    return true unless distributed?
    return true unless self.children.any?
    base_logic = self.children.first.logic
    self.children.count == self.children.where(logic_id: base_logic).count
  end

  def heterogeneous?
    return false unless distributed?
    not homogeneous?
  end

end
