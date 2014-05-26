module ReadableUnguessableUrlsHelper
  MODELS_WITH_SLUGS = { 'discussion' => :title,
                              'user' => :name,
                            'group'  => :full_name,
                            'motion' => :name }

  MODELS_WITH_SLUGS.keys.each do |model|
    next if model == 'group'
    model = model.to_s.downcase

    define_method("#{model}_url", ->(instance, options={}) {
      options = options.merge( host_and_port )
                       .merge( route_hash(instance, model) )

      url_for(options)
    })

    define_method("#{model}_path", ->(instance, options={}) {
      options = options.merge(only_path: true)

      self.send("#{model}_url", instance, options)
    })

  end

  def group_url(group, options = {})
    options = options.merge( host_and_port ).
                      merge( route_hash(group, 'group') )

    if group.has_subdomain?
      options[:subdomain] = group.subdomain
    elsif ENV['DEFAULT_SUBDOMAIN']
      options[:subdomain] = ENV['DEFAULT_SUBDOMAIN']
    end

    if group.has_subdomain? and not group.is_subgroup?
      uri = URI(url_for(options))
      uri.path = ''
      uri.to_s
    else
      url_for(options)
    end
  end

  def host_needed_to_link_to?(group)
    if request.blank?
      true
    elsif group.has_subdomain?
      group.subdomain != request.subdomain
    elsif ENV['DEFAULT_SUBDOMAIN'].present?
      request.subdomain != ENV['DEFAULT_SUBDOMAIN']
    else
      request.subdomain.present?
    end
  end

  def debug_host_needed_to_link_to?(group)
    if request.blank?
      'request blank'
    elsif group.has_subdomain?
      if group.subdomain != request.subdomain
        'group has subdomain different to request'
      else
        'group has same subdomain as request'
      end
    elsif ENV['DEFAULT_SUBDOMAIN'].present?
      if request.subdomain != ENV['DEFAULT_SUBDOMAIN']
        'request subdomain differs from default subdomain'
      else
        'request subdomain same as default subdomain'
      end
    else
      if request.subdomain.present?
        'request subdomain present'
      else
        'request subdomain blank'
      end
    end
  end

  def group_path(group, options = {})
    url = group_url(group, options)
    if host_needed_to_link_to?(group)
      url
    else
      path = URI(url).path
      if path.blank?
        '/'
      else
        path
      end
    end
  end

  private

  def host_and_port
    if request.present?
      if include_port?(request)
        { host: request.domain, port: request.port }
      else
        { host: request.domain, port: nil }
      end
    else
      ActionMailer::Base.default_url_options
    end
  end

  def include_port?(request)
    if    request.port == 80  && !request.ssl?
      false
    elsif request.port == 443 && request.ssl?
      false
    else
      true
    end
  end

  def route_hash(instance, model)
    controller = "/#{model.pluralize}"
    name = MODELS_WITH_SLUGS[model]
    slug = instance.send(name).parameterize

    { controller: controller, action: 'show', id: instance.key, slug: slug }
  end

end
