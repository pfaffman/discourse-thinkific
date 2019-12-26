# frozen_string_literal: true

# name: discourse-thinkific
# about: Redirects to thinkific url to login to thinkific and redirects back to discourse
# version: 0.1
# authors: fzngagan
# url: https://github.com/fzngagan

enabled_site_setting :discourse_thinkific_enabled

PLUGIN_NAME ||= 'DiscourseThinkific'

after_initialize do

  module SessionControllerExtension
    def generate_thinkific_url(user)
      base_url = SiteSetting.thinkific_base_url
      return "" if(!valid_url?(base_url) || SiteSetting.thinkific_jwt_auth_token.empty?)

      iat = Time.now.to_i
      payload = JWT.encode({
        :iat   => iat,
        :jti   => "#{iat}/#{SecureRandom.hex(18)}",
        :first_name  => user.name.split(' ').first || user.username,
        :last_name => user.name.split(' ').last || user.username,
        :email => user.email,
      },SiteSetting.thinkific_jwt_auth_token)
      params = {
        :jwt => payload,
        :return_to => Discourse.base_url
      }

      "#{base_url}?#{params.to_query}"
    end

    def login(user)
      cookies[:thinkific_redirect] = generate_thinkific_url(user) 
      super
    end

    def valid_url?(url)
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) && !uri.host.nil?
    rescue URI::InvalidURIError
      false
    end
  end

  class ::SessionController
    prepend SessionControllerExtension
  end

end
