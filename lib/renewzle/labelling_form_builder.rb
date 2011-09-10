module ActionView
  class Base
    # I don't want my input fields wrapped in divs when there are errors.
    @@field_error_proc = Proc.new { |html_tag, instance| "#{html_tag}" }
    cattr_accessor :field_error_proc
  end
end

module Renewzle
  class LabellingFormBuilder < ActionView::Helpers::FormBuilder
    def labelled_text_field(method, options = {})
      index = options.delete(:index)
      
      if raw = options.delete(:raw)
        raw_method = raw_name_for(method)
        options.merge!(:id => field_id_for(raw_method, index), :name => field_name_for(raw_method, index))
      else
        unless index.blank?
          options.merge!(:id => field_id_for(method, index), :name => field_name_for(method, index))
        end
      end
      
      field_contents = ''
      
      label_class = options.delete(:label_class)
      unless no_label = options.delete(:no_label)
        field_contents << label_for(method, { :label => options.delete(:label), :raw => raw, :colon => options.delete(:colon), :index => index, :class => label_class })
      end
      
      field_classes = [ 'field' ]
      field_classes << 'required' if options.delete(:required)
      field_classes << options.delete(:field_class)
      
      with_loading_span_of_size = options.delete(:with_loading_span_of_size)
      error_label = options.delete(:error_label)
      tip = options.delete(:tip)
      
      input_class = [ options.delete(:input_class), 'text' ].join(' ')
      
      field_contents << text_field(method, options.merge(:class => input_class))
    
      if @object.errors.invalid?(method)
        field_classes << 'with_errors'
        field_contents << error_span_for(method, :error_label => error_label)
      elsif tip
        field_contents << tip_span_from(tip)
      end
      
      if with_loading_span_of_size
        field_contents << loading_span_of_size(with_loading_span_of_size, :for => method.to_s)
      end
    
      @template.content_tag('div', field_contents, :class => field_classes.join(' '))
    end
    
    def labelled_percentage_text_field(method, options = {})
      value = @object.send(method)
      value = value.blank? ? nil : @template.number_with_precision(value * 100, 1) + '%'
      labelled_text_field(method, options.merge(:value => value, :raw => true))
    end
    
    def required_kW_text_field(method, options = {})
      labelled_kW_text_field(method, options.merge(:required => true))
    end
    
    def labelled_kW_text_field(method, options = {})
      value = @object.send(method)
      value = value.blank? ? nil : @template.number_with_precision(value, 1) + ' kW'
      labelled_text_field(method, options.merge(:value => value, :raw => true))
    end
    
    def required_dollar_text_field(method, options = {})
      labelled_dollar_text_field(method, options.merge(:required => true))
    end
    
    def labelled_dollar_text_field(method, options = {})
      value = @object.send(method)
      precision = options.delete(:precision)
      value = value.blank? ? nil : @template.number_to_currency(value, :precision => precision)
      labelled_text_field(method, options.merge(:value => value, :raw => true))
    end
    
    def required_text_field(method, options = {})
      labelled_text_field(method, options.merge(:required => true))
    end
    
    def required_country_select(method, priority_countries = [], options = {})
      labelled_country_select(method, priority_countries, options.merge(:required => true))
    end
    
    def labelled_country_select(method, priority_countries = [], options = {})
      field_contents = label_for(method, { :label => options.delete(:label) })
      field_classes = [ 'field' ]
      field_classes << 'required' if options.delete(:required)
      field_contents << country_select(method, priority_countries, options)
      if @object.errors.invalid?(method)
        field_classes << 'with_errors'
        field_contents << error_span_for(method)
      end
      @template.content_tag('div', field_contents, :class => field_classes.join(' '))
    end

    def indexed_hidden_field(method, options = {})
      index = options.delete(:index)
      hidden_field(method, options.merge(:id => field_id_for(method, index), :name => field_name_for(method, index)))
    end
    
    def required_password_field(method, options = {})
      labelled_password_field(method, options.merge(:required => true))
    end
    
    def labelled_password_field(method, options = {})
      field_contents = label_for(method, { :label => options.delete(:label) })
      
      field_classes = [ 'field' ]
      field_classes << 'required' if options.delete(:required)
      
      input_class = [ options.delete(:input_class), 'text' ].join(' ')
      
      field_contents << password_field(method, options.merge(:class => input_class))
      
      if @object.errors.invalid?(method)
        field_classes << 'with_errors'
        field_contents << error_span_for(method)
      end
    
      @template.content_tag('div', field_contents, :class => field_classes.join(' '))
    end
    
    def required_password_fields(method, options = {})
      labelled_password_fields(method, options.merge(:required => true))
    end
    
    def labelled_password_fields(method, options = {})
      input_class = options[:input_class]
      contents = labelled_password_field(method, options)
      contents << labelled_password_field("#{method}_confirmation".to_sym, options.merge(:required => true, :label => 'Confirm password', :input_class => input_class))
    end
    
    def labelled_collection_select(method, choices, value_method, text_method, options = {}, html_options = {})
      if raw = options.delete(:raw)
        raw_method = raw_name_for(method)
        html_options.merge!(:id => field_id_for(raw_method), :name => field_name_for(raw_method))
      end
      
      field_contents = label_for(method, { :label => options.delete(:label), :raw => raw, :colon => options.delete(:colon), :class => options.delete(:label_class) })
      
      field_classes = [ 'field' ]
      field_classes << 'required' if options.delete(:required)
      
      error_label = options.delete(:error_label)
      disabled = options.delete(:disabled)
      html_options[:disabled] = disabled if disabled
      html_options[:class] = options.delete(:input_class)
      html_options[:onchange] = options.delete(:onchange)
      
      field_contents << collection_select(method, choices, value_method, text_method, options, html_options)
      
      if @object.errors.invalid?(method)
        field_classes << 'with_errors'
        field_contents << error_span_for(method, :error_label => error_label)
      end
      
      @template.content_tag('div', field_contents, :class => field_classes.join(' '))
    end
    
    def required_select(method, choices, options = {}, html_options = {})
      labelled_select(method, choices, options.merge(:required => true), html_options)
    end
    
    def labelled_select(method, choices, options = {}, html_options = {})      
      field_contents = label_for(method, { :label => options.delete(:label), :colon => options.delete(:colon), :class => options.delete(:label_class) })
      
      field_classes = [ 'field' ]
      field_classes << 'required' if options.delete(:required)
      
      input_class = options.delete(:input_class)
      field_contents << select(method, choices, options, html_options.merge(:class => input_class))
      
      @template.content_tag('div', field_contents, :class => field_classes.join(' '))
    end
    
    def labelled_inverted_check_box(method, options = {}, checked_value = '1', unchecked_value = '0')    
      labelled_check_box(method, options.merge(:inverted => true), checked_value, unchecked_value)
    end
    
    def labelled_check_box(method, options = {}, checked_value = '1', unchecked_value = '0')
      index = options.delete(:index)
      
      unless index.blank?
        options.merge!(:id => field_id_for(method, index), :name => field_name_for(method, index))
      end
      
      label = options.delete(:label)
      field_classes = [ 'check_box', 'field' ]
      field_classes << 'required' if options.delete(:required)
      
      with_loading_span_of_size = options.delete(:with_loading_span_of_size)
      
      inverted = options.delete(:inverted)
      unless inverted
        field_contents = check_box(method, options, checked_value, unchecked_value)
        field_contents << label_for(method, { :label => label, :index => index })
      else
        field_contents = label_for(method, { :label => label, :index => index })
        field_contents << check_box(method, options, checked_value, unchecked_value)
      end
      
      if with_loading_span_of_size
        field_contents << loading_span_of_size(with_loading_span_of_size, :for => method.to_s)
      end
      
      @template.content_tag('div', field_contents, :class => field_classes.join(' '))
    end
    
  private
  
    def field_id_for(method, index = nil)
      if index.blank?
        "#{@object_name}_#{method}"
      else
        "#{@object_name.to_s.pluralize}_#{index}_#{method}"
      end
    end
  
    def field_name_for(method, index = nil)
      if index.blank?
        "#{@object_name}[#{method}]"
      else
        "#{@object_name.to_s.pluralize}[#{index}][#{method}]"
      end
    end
  
    def raw_name_for(method)
      "raw_#{method}"
    end
  
    def label_for(method, options = {})
      index = options[:index]
      label = options[:label].blank? ? method.to_s.humanize : options[:label]
    
      if options[:raw]
        method = raw_name_for(method)
      end
    
      label_contents = label
      if options[:colon]
        label_contents << ':'
      end
      
      @template.content_tag('label', label_contents, :for => field_id_for(method, index), :class => options.delete(:class))
    end
  
    def error_span_for(method, options = {})
      unless options.delete(:attachment)
        errors = @object.errors.on(method)
      else
        errors = @object.send(method).errors.on(:size_in_bytes)
      end
      
      unless error_label = options.delete(:error_label)
        error_label = method.to_s.humanize
      end
      
      @template.content_tag('span', "#{error_label} #{errors.is_a?(Array) ? errors.first : errors}", :class => 'error')
    end
    
    def tip_span_from(tip)
      @template.content_tag("span", tip, :class => "tip")
    end
    
    def loading_span_of_size(size, options = {})
      if options.has_key?(:for)
        unless options[:for].kind_of?(String)
          span_id = @template.dom_id(options[:for])
        else
          span_id = "#{options[:for]}_loading"
        end
      else
        span_id = nil
      end

      @template.content_tag('span', @template.image_tag('loading.gif', :alt => 'loading indicator', :height => size, :width => size), :id => span_id, :class => 'loading', :style => 'display:none')
    end
  end
end
