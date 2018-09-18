module IeHelper

  # adapted for rendering <body> with specific class if browser is IE
  # from https://github.com/sporkd/compass-html5-boilerplate/blob/master/lib/app/helpers/html5_boilerplate_helper.rb#L17

  def ie_body(attrs={}, &block)
    name=:body

    attrs.symbolize_keys!
    haml_concat("<!--[if lt IE 7]> #{ tag(name, add_class('ie6', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 7]>    #{ tag(name, add_class('ie7', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if lt IE 8]> <div class='ie6_7'>Please upgrade your browser. The site is best viewed on Chrome, Firefox and Internet Explorer (8 or above)</div>  <![endif]-->".html_safe)
    haml_concat("<!--[if IE 8]>    #{ tag(name, add_class('ie8', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 9]>    #{ tag(name, add_class('ie9', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if gt IE 9]><!-->".html_safe)
    haml_tag name, attrs do
      haml_concat("<!--<![endif]-->".html_safe)
      block.call
    end
  end

private

  def add_class(name, attrs)
    classes = attrs[:class] || ''
    classes.strip!
    classes = ' ' + classes if !classes.blank?
    classes = name + classes
    attrs.merge(:class => classes)
  end

end
