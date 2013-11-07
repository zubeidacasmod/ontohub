module PathHelpers
  extend ActiveSupport::Concern

  included do
    helper_method :fancy_repository_path
  end

  def fancy_repository_path(repository, args)
    args ||= {}
    action = args[:action] || :files
    if params[:ref].nil? && action == :files
      repository_tree_path repository, path: args[:path]
    else
      repository_ref_path repository_id: repository, ref: args[:ref], action: action, path: args[:path]
    end
  end

end