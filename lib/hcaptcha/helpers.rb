# frozen_string_literal: true

module Hcaptcha
  module Helpers
    DEFAULT_ERRORS = {
      hcaptcha_unreachable: 'Oops, we failed to validate your hCaptcha response. Please try again.',
      verification_failed: 'hCaptcha verification failed, please try again.'
    }.freeze
    DEFAULT_OPTIONS = {
      theme: :dark
    }.freeze

    def self.hcaptcha(options)
      if options.key?(:stoken)
        raise(HcaptchaError, "Secure Token is deprecated. Please remove 'stoken' from your calls to hcaptcha_tags.")
      end
      if options.key?(:ssl)
        raise(HcaptchaError, "SSL is now always true. Please remove 'ssl' from your calls to hcaptcha_tags.")
      end

      DEFAULT_OPTIONS.each do |name, value|
        options[name] ||= value
      end

      html, tag_attributes = components(options)
      html << %(<div #{tag_attributes}></div>\n)

      html.respond_to?(:html_safe) ? html.html_safe : html
    end

    def self.to_error_message(key)
      default = DEFAULT_ERRORS.fetch(key) { raise ArgumentError "Unknown hCaptcha error - #{key}" }
      to_message("hcaptcha.errors.#{key}", default)
    end

    if defined?(I18n)
      def self.to_message(key, default)
        I18n.translate(key, default: default)
      end
    else
      def self.to_message(_key, default)
        default
      end
    end

    private_class_method def self.components(options)
      html = +''
      attributes = {}

      options = options.dup
      class_attribute = options.delete(:class)
      site_key = options.delete(:site_key)
      hl = options.delete(:hl)
      onload = options.delete(:onload)
      render = options.delete(:render)
      script_async = options.delete(:script_async)
      script_defer = options.delete(:script_defer)
      nonce = options.delete(:nonce)
      skip_script = (options.delete(:script) == false) || (options.delete(:external_script) == false)
      ui = options.delete(:ui)

      data_attribute_keys = [:badge, :theme, :type, :callback, :expired_callback, :error_callback, :size]
      data_attribute_keys << :tabindex unless ui == :button
      data_attributes = {}
      data_attribute_keys.each do |data_attribute|
        value = options.delete(data_attribute)
        data_attributes["data-#{data_attribute.to_s.tr('_', '-')}"] = value if value
      end

      site_key ||= Hcaptcha.configuration.site_key!
      script_url = Hcaptcha.configuration.api_server_url
      query_params = hash_to_query(
        hl: hl,
        onload: onload,
        render: render
      )
      script_url += "?#{query_params}" unless query_params.empty?
      async_attr = "async" if script_async != false
      defer_attr = "defer" if script_defer != false
      nonce_attr = " nonce='#{nonce}'" if nonce
      html << %(<script src="#{script_url}" #{async_attr} #{defer_attr} #{nonce_attr}></script>\n) unless skip_script
      attributes["data-sitekey"] = site_key
      attributes.merge! data_attributes

      # The remaining options will be added as attributes on the tag.
      attributes["class"] = "h-captcha #{class_attribute}"
      tag_attributes = attributes.merge(options).map { |k, v| %(#{k}="#{v}") }.join(" ")

      [html, tag_attributes]
    end

    private_class_method def self.hash_to_query(hash)
      hash.delete_if { |_, val| val.nil? || val.empty? }.to_a.map { |pair| pair.join('=') }.join('&')
    end
  end
end
