ActionView::Base.field_error_proc =
    proc do |html_tag, instance|
      if [ActionView::Helpers::Tags::CheckBox,
          ActionView::Helpers::Tags::TextArea,
          ActionView::Helpers::Tags::Select,
          ActionView::Helpers::Tags::TextField].any? { |tag| instance.class <= tag }
        errors = instance.object.errors[instance.instance_values['method_name']].join(', ')
        <<-HTML
            <div class='has-error'>#{html_tag}
              <small class='help-block'>#{errors}</small>
            </div>
        HTML
      else
        <<-HTML
        <div class='has-error'>#{html_tag}</div>
        HTML
      end.html_safe
    end