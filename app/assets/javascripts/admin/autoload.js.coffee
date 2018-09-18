$(document).ready ->
  new AutoloadWidget(".al-selector-init", [".al-content-loader", ".al-category-content-loader", ".al-region-content-loader", ".s-pp-content-loader"], "client_id")
  new AutoloadWidget(".al-content-loader", [".s-pp-content-loader"], "scheme_id")
  new AutoloadWidget(".msp-selector-init", [".al-client-content-loader", ".al-supplier-content-loader", ".al-category-content-loader", ".al-subcategory-content-loader"], "msp_id")

class @AutoloadWidget
  constructor: (selector, load_content, param_name)->
    @param_name = param_name
    @load_content = load_content
    @selector = $('#'+$(selector).attr('id'))
    $.each @load_content, (i, loader) =>
      @buildEvents(loader, @selector, @param_name) if $(loader).attr('id')

  buildEvents: (element, selector, param_name) ->
    loadContent = $('#'+$(element).attr('id'))
    return false unless loadContent.length > 0
    @param_name = param_name
    if @selector.find('option').length <= 2
      #@selector.val(@selector.find('option').eq(1).val())
    else
      if @selector.val()
        @buildOptions(loadContent)
    @selector.change (e) =>
      @buildOptions(loadContent)
    if $(element).val()
      @populateOptions($(element))
    $(element).change (e) =>
      @populateOptions($(element))

  populateOptions: (element) ->
    target = element.find(":selected").attr('data-parent')
    if target
      @selector.val(target)
      $('.al-selector-init').val(@selector.find(":selected").attr('data-parent')) if @param_name == 'scheme_id'
          
  buildOptions: (load_content) ->
    lc = load_content
    lc_value = lc.val()
    opt_label = 'Please Select'
    opt_label = 'All' if @selector.attr('id').match("^q_")
    data = "#{@param_name}=#{@selector.val()}"
    data += "&client_id=#{$('.al-selector-init').val()}" if @param_name == 'scheme_id' && $('.al-selector-init').val()
    $.ajax
      type: "GET"
      url: lc.data('url')
      data: data
      dataType: "json"
      success: (response) ->
        items = "<option value=''>#{opt_label}</option>"
        $.each response, (i, model) ->
          data_url = ''
          data_url = "data-template='#{model.data_template}'" if model.data_template
          data_parent = ''
          data_parent = "data-parent='#{model.data_parent}'" if model.data_parent
          items += "<option value='#{model.id}' #{data_url} #{data_parent}>#{model.name}</option>"
        lc.html(items)
        lc.val(lc_value)
    false
