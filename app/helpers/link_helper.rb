module LinkHelper
  
  def fancy_link(resource)
    clazz = resource.class
    clazz = 'Ontology' if clazz.to_s.include?('Ontology')
    data_type, value = determine_image_type(resource)
    
    unless resource.is_a? Array then
      title = nil

      if block_given?
        name = yield resource
      else
        name = resource
      end
      title = resource.respond_to?(:title) ? resource.title : nil
    else

      if block_given?
        name = yield resource
      else
        name = resource
      end
      title = resource.last.respond_to?(:title) ? resource.last.title : nil
    end

    linked_to = resource
    linked_to = repository_ontology_path(resource.repository, resource) if resource.is_a?(Ontology)

    link_to name, linked_to,
      data_type => value,
      :title    => title
  end

  def determine_image_type(resource)
    return ['data-type', resource.class.to_s] unless resource.is_a?(Ontology)
    data_type = 'data-ontologyclass'
    distributed_type = ->(distributed_ontology) do
      if distributed_ontology.homogeneous?
        "distributed_homogeneous_ontology"
      else
        "distributed_heterogeneous_ontology"
      end
    end
    value = if resource.is_a?(DistributedOntology)
              distributed_type[resource]
            else
              if resource.parent
                "single_in_#{distributed_type[resource.parent]}"
              else
                'single_ontology'
              end
            end
    [data_type, value]
  end

  def ontology_link_to(resource)
    data_type, value = determine_image_type(resource)
    content_tag(:span, class: 'ontology_title') do
      link_to resource, {}, data_type => value
    end
  end

  def counter_link(url, counter, subject)
    text = content_tag(:strong, counter || '?')
    text << content_tag(:span, counter==1 ? subject : subject.pluralize)
    
    link_to text, url
  end
  
  def format_links(*args, &block)
    options = args.extract_options!
    args    = %w(xml json) if args.empty?
    args.flatten!
    
    options[:url]  ||= {}
    
    links = ''
    links << capture(&block) << ' ' if block_given?
    links << args.collect{ |f|
      content_tag :li, link_to(f.to_s.upcase, params.merge(options[:url]).merge(:format => f), :title => "Get this page as #{f.upcase}")
    }.join("")
    
    content_tag('ul', links.html_safe, :class => 'formats')
  end
end
