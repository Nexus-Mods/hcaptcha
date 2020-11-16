require_relative 'helper'

describe 'View helpers' do
  include Hcaptcha::Adapters::ViewMethods

  it "uses SSL" do
    hcaptcha_tags.must_include "\"#{Hcaptcha.configuration.api_server_url}\""
  end

  it "can include `theme`" do
    html = hcaptcha_tags(theme: "light")
    html.must_include("data-theme=\"light\"")

    html = hcaptcha_tags(theme: "dark")
    html.wont_include("data-theme=\"light\"")
    html.must_include("data-theme=\"dark\"")

    html = hcaptcha_tags
    html.must_include("data-theme=")
  end

  it "can include `size`" do
    html = hcaptcha_tags(size: 10)
    html.must_include("data-size=\"10\"")
  end

  it "raises without site key" do
    Hcaptcha.configuration.site_key = nil
    assert_raises Hcaptcha::HcaptchaError do
      hcaptcha_tags
    end
  end

  it "includes `id` as div attribute" do
    html = hcaptcha_tags(id: 'my_id')
    html.must_include(" id=\"my_id\"")
  end

  it "translates `tabindex` attribute to data- attribute for hcaptcha_tags" do
    html = hcaptcha_tags(tabindex: 123)
    html.must_include(" data-tabindex=\"123\"")
  end

  it "includes `nonce` attribute" do
    html = hcaptcha_tags(nonce: 'P9Y0b6dLSkApYRdOULGW57XHcYNJJKeLwxA2az/Ka9s=')
    html.must_include(" nonce='P9Y0b6dLSkApYRdOULGW57XHcYNJJKeLwxA2az/Ka9s='")
  end

  it "does not include <script> tag when setting `script: false` or `external_script: false`" do
    html = hcaptcha_tags(script: false)
    html.wont_include("<script")

    html = hcaptcha_tags(external_script: false)
    html.wont_include("<script")
  end

  it "adds :hl option to the URL" do
    html = hcaptcha_tags(hl: 'en')
    html.must_include("hl=en")

    html = hcaptcha_tags(hl: 'ru')
    html.wont_include("hl=en")
    html.must_include("hl=ru")

    html = hcaptcha_tags
    html.wont_include("hl=")
  end

  it "adds `onload` option to the URL" do
    html = hcaptcha_tags(onload: 'foobar')
    html.must_include("onload=foobar")

    html = hcaptcha_tags(onload: 'anotherFoobar')
    html.wont_include("onload=foobar")
    html.must_include("onload=anotherFoobar")

    html = hcaptcha_tags
    html.wont_include("onload=")
  end

  it "adds `render` option to the URL" do
    html = hcaptcha_tags(render: 'onload')
    html.must_include("render=onload")

    html = hcaptcha_tags(render: 'explicit')
    html.wont_include("render=onload")
    html.must_include("render=explicit")

    html = hcaptcha_tags
    html.wont_include("render=")
  end

  it "adds `recaptchacompat` option to the URL" do
    html = hcaptcha_tags(recaptchacompat: "on")
    html.must_include("recaptchacompat=on")

    html = hcaptcha_tags(recaptchacompat: "off")
    html.wont_include("recaptchacompat=on")
    html.must_include("recaptchacompat=off")

    html = hcaptcha_tags
    html.wont_include("recaptchacompat=")
  end

  it "adds query params to the URL" do
    html = hcaptcha_tags(hl: 'en', onload: 'foobar')
    html.must_include("?")
    html.must_include("hl=en")
    html.must_include("&")
    html.must_include("onload=foobar")
  end

  it "dasherizes the `expired_callback` attribute name" do
    html = hcaptcha_tags(expired_callback: 'my_expired_callback')
    html.must_include(" data-expired-callback=\"my_expired_callback\"")
  end

  it "dasherizes `error_callback` attribute name" do
    html = hcaptcha_tags(error_callback: 'my_error_callback')
    html.must_include(" data-error-callback=\"my_error_callback\"")
  end

  it "dasherizes the `chalexpired_callback` attribute name" do
    html = hcaptcha_tags(chalexpired_callback: 'my_chalexpired_callback')
    html.must_include(" data-chalexpired-callback=\"my_chalexpired_callback\"")
  end

  it "dasherizes the `open_callback` attribute name" do
    html = hcaptcha_tags(open_callback: 'my_open_callback')
    html.must_include(" data-open-callback=\"my_open_callback\"")
  end

  it "dasherizes the `close_callback` attribute name" do
    html = hcaptcha_tags(close_callback: 'my_close_callback')
    html.must_include(" data-close-callback=\"my_close_callback\"")
  end

  it "adds unexpected options as HTML attributes" do
    html = hcaptcha_tags(unexpected_option: 'my_unexpected_option')
    html.must_include(" unexpected_option=\"my_unexpected_option\"")
  end
end
