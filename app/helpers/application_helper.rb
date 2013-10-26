module ApplicationHelper

  def admin?
    current_user.try(:admin?)
  end

  def context_pane
    if params[:controller] == 'home'
      return 'shared/user_ontologies'
    end

    if params[:action] != 'index'
      return false
    end

    if %w[entities_search logics].include? params[:controller]
      return 'shared/user_ontologies'
    end

    if params[:controller] == 'ontologies' && !in_repository?
      return 'shared/user_ontologies'
    end

    if params[:controller] == 'repositories'
      return 'shared/user_repositories'
    end

    return false 
  end

  def cover_visible?
    params[:controller] == 'home' && !user_signed_in?
  end

  def in_repository?
    params[:repository_id] || params[:controller] == 'repositories'
  end

  def resource_chain
    return @resource_chain if @resource_chain

    if params[:logic_id]
      @resource_chain = []
      return @resource_chain      
    end

    if !params[:repository_id] && !(params[:controller] == 'repositories' && params[:id])
      @resource_chain = []
      return @resource_chain
    end

    @resource_chain = [ Repository.find_by_path!( controller_name=='repositories' ? params[:id] : params[:repository_id] )]
    
    if id = params[:commit_reference_id]
      @resource_chain << CommitReference.new(id)
    end

    if id = (controller_name=='ontologies' ? params[:id] : params[:ontology_id])
      @resource_chain << Ontology.find(id)
    end

    @resource_chain
  end

end