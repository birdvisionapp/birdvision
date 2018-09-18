class ProductCodeLabel
  
  def initialize(data, bg_color)
    @data = data
    @bg_color = bg_color.present? ? bg_color : '#ffffff'
  end

  def render(pdf)
    pdf.dash 1, :space => 1
    pdf.fill_color @bg_color.gsub('#', '')
    pdf.fill_and_stroke_rounded_rectangle [0,80], 185, 60, 8
    pdf.fill_color "#000000"
    if @data.present?
      pdf.move_down 14
      @data.each do |cdata|
        #pdf.font_families.update(cdata[:font] =>{:normal => "#{Rails.root}/fonts/#{cdata[:font].downcase}.ttf"})
        #pdf.font(cdata[:font]) do
          pdf.text cdata[:text], :size => 8, :align => :center
        #end
      end
    end
  end
  
end