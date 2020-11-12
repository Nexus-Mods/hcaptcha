# hCaptcha
[![Gem Version](https://badge.fury.io/rb/hcaptcha.svg)](https://badge.fury.io/rb/hcaptcha)

## Credits

* https://github.com/Retrospring/hcaptcha
* https://github.com/firstmoversadvantage/hcaptcha
* https://github.com/ambethia/recaptcha

## Overview

License:   [MIT](http://creativecommons.org/licenses/MIT/)  
Bugs:      https://github.com/firstmoversadvantage/hcaptcha/issues

This gem provides helper methods for the [hCaptcha API](https://hcaptcha.com). In your
views you can use the `hcaptcha_tags` method to embed the needed javascript, and you can validate
in your controllers with `verify_hcaptcha` or `verify_hcaptcha!`.

## Obtaining a key and setup

Go to the [hCaptcha](https://hcaptcha.com/webmaster/signup) signup page to obtain API keys. **You'll also need to set a hostname that your application will run from, even for local development. hCaptcha will not work if your application is being served from `localhost` or `127.0.0.1`. You will need to add a hosts entry for local development.** See the [hCaptcha docs](https://hcaptcha.com/docs) for how to do this.

The hostname you set it to must be a real hostname, since hCaptcha validates it when you create it in the portal. For example, `example.fmadata.com` does not have a DNS record, but `mydomain.com` does. The DNS record doesn't need to point to your application though, it just has to exist - that's why we added the record into the local hosts file.

## Installation

FIrst, add the gem to your bundle:
```shell
bundle add hcaptcha
```

Then, set the following environment variables:
* `HCAPTCHA_SECRET_KEY`
* `HCAPTCHA_SITE_KEY`

> 💡 You should keep keys out of your codebase with external environment variables (using your shell's `export` command), Rails (< 5.2) [secrets](https://guides.rubyonrails.org/v5.1/security.html#custom-secrets), Rails (5.2+) [credentials](https://guides.rubyonrails.org/security.html#custom-credentials), the [dotenv](https://github.com/bkeepers/dotenv) or [figaro](https://github.com/laserlemon/figaro) gems, …

## Usage

First, add `hcaptcha_tags` to the forms you want to protect:

```erb
<%= form_for @foo do |f| %>
  # …
  <%= hcaptcha_tags %>
  # …
<% end %>
```

Then, add `verify_hcaptcha` logic to each form action that you've protected:

```ruby
# app/controllers/users_controller.rb
@user = User.new(params[:user].permit(:name))
if verify_hcaptcha(model: @user) && @user.save
  redirect_to @user
else
  render 'new'
end
```

If you are **not using Rails**, you should:
* `include Hcaptcha::Adapters::ViewMethods` where you need `recaptcha_tags`
* `include Hcaptcha::Adapters::ControllerMethods` where you need `verify_hcaptcha`

### API details

### `hcaptcha_tags(options = {})`

Use in your views to render the JavaScript widget.

Available options:

| Option                  | Description |
|-------------------------|-------------|
| `:badge`                | _legacy, ignored_
| `:callback`             | _see [official documentation](https://docs.hcaptcha.com/configuration)_
| `:chalexpired_callback` | _see [official documentation](https://docs.hcaptcha.com/configuration)_
| `:class`                | Additional CSS classes added to `h-captcha` on the placeholder
| `:close_callback`       | _see [official documentation](https://docs.hcaptcha.com/configuration)_
| `:error_callback`       | _see [official documentation](https://docs.hcaptcha.com/configuration)_
| `:expired_callback`     | _see [official documentation](https://docs.hcaptcha.com/configuration)_
| `:external_script`      | _alias for `:script` option_
| `:hl`                   | _see [official documentation](https://docs.hcaptcha.com/configuration) and [available language codes](https://docs.hcaptcha.com/languages)_
| `:open_callback`        | _see [official documentation](https://docs.hcaptcha.com/configuration)_
| `:nonce`                | Add a `nonce="…"` attribute to the `<script>` tag
| `:onload`               | _see [official documentation](https://docs.hcaptcha.com/configuration)_
| `:recaptchacompat`      | _see [official documentation](https://docs.hcaptcha.com/configuration)_
| `:render`               | _see [official documentation](https://docs.hcaptcha.com/configuration)_
| `:script_async`         | Add `async` attribute to the `<script>` tag (default: `true`)
| `:script_defer`         | Add `defer` attribute to the `<script>` tag (default: `true`)
| `:script`               | Generate the `<script>` tag (default: `true`)
| `:site_key`             | Set hCaptcha Site Key (overrides `HCAPTCHA_SITE_KEY` environment variable)
| `:size`                 | _see [official documentation](https://docs.hcaptcha.com/configuration)_
| `:stoken`               | _legacy, raises an exception_
| `:ssl`                  | _legacy, raises an exception_
| `:theme`                | _see [official documentation](https://docs.hcaptcha.com/configuration)_ (default: `:dark`)
| `:type`                 | _legacy, ignored_
| `:ui`                   | _legacy, ignored_

> ℹ️ Unkown options will be passed directly as attributes to the placeholder element.
>
> For example, `hcaptcha_tags(foo: "bar")` will generate the default script tag and the following placeholder tag:
> ```html
> <div class="h-captcha" data-sitekey="…" foo="bar"></div>
> ```

### `verify_recaptcha`

This method returns `true` or `false` after processing the response token from the hCaptcha widget.
This is usually called from your controller.

Passing in the ActiveRecord object via `model: object` is optional. If you pass a `model`—and the
captcha fails to verify—an error will be added to the object for you to use (available as
`object.errors`).

Why isn't this a model validation? Because that violates MVC. You can use it like this, or how ever
you like.

Some of the options available:

| Option         | Description |
|----------------|-------------|
| `:model`       | Model to set errors.
| `:attribute`   | Model attribute to receive errors. (default: `:base`)
| `:message`     | Custom error message.
| `:secret_key`  | Override the secret API key from the configuration.
| `:timeout`     | The number of seconds to wait for hCaptcha servers before give up. (default: `3`)
| `:response`    | Custom response parameter. (default: `params['g-recaptcha-response']`)
| `:hostname`    | Expected hostname or a callable that validates the hostname, see [domain validation](https://developers.google.com/recaptcha/docs/domain_validation) and [hostname](https://developers.google.com/recaptcha/docs/verify#api-response) docs. (default: `nil`, but can be changed by setting `config.hostname`)
| `:env`         | Current environment. The request to verify will be skipped if the environment is specified in configuration under `skip_verify_env`

## I18n support

hCaptcha supports the I18n gem (it comes with English translations)
To override or add new languages, add to `config/locales/*.yml`

```yaml
# config/locales/en.yml
en:
  recaptcha:
    errors:
      verification_failed: 'hCaptcha was incorrect, please try again.'
      recaptcha_unreachable: 'hCaptcha verification server error, please try again.'
```

## Testing

By default, hCaptcha is skipped in "test" and "cucumber" env. To enable it during test:

```ruby
Hcaptcha.configuration.skip_verify_env.delete("test")
```