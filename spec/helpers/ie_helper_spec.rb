require "spec_helper"

describe IeHelper do
  helper do
    include Haml::Helpers
  end

  before do
    init_haml_helpers
  end

  it "should render body tag with ie classes within IE conditional comments " do
    params = {}
    haml = capture_haml {
      helper.ie_body(params) {}
    }
    haml.should include "<!--[if lt IE 7]> <body class=\"ie6\"> <![endif]-->"
    haml.should include "<!--[if IE 7]>    <body class=\"ie7\"> <![endif]-->"
    haml.should include "<!--[if IE 8]>    <body class=\"ie8\"> <![endif]-->"
    haml.should include "<!--[if IE 9]>    <body class=\"ie9\"> <![endif]-->"
    haml.should include "<!--[if gt IE 9]><!-->\n<body>\n  <!--<![endif]-->\n</body>\n"
  end

end
