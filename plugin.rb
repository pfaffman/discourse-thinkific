# frozen_string_literal: true

# name: discourse-thinkific
# about: Redirects to thinkific url to login to thinkific and redirects back to discourse
# version: 0.1
# authors: pfaffman, fzngagan
# url: https://github.com/pfaffman/discourse-thinkific

enabled_site_setting :discourse_thinkific_enabled

PLUGIN_NAME ||= 'DiscourseThinkific'

after_initialize do

  add_to_serializer(:current_user, :thinkific_redirect_url, false) do
    if object.present?
      puts "Adding to serializer"
      SessionControllerExtension.generate_thinkific_url(object)
    end
  end

  module SessionControllerExtension
    def self.generate_thinkific_url(user)
      base_url = SiteSetting.thinkific_base_url
      puts "generate_thinkific_url(#{user})"
      return "" if(!self.valid_url?(base_url) || SiteSetting.thinkific_jwt_auth_token.empty?)

      iat = Time.now.to_i
      payload = JWT.encode({
        :iat   => iat,
        :jti   => "#{iat}/#{SecureRandom.hex(18)}",
        :first_name  => user.name ? user.name.split(' ').first : user.username,
        :last_name => user.name ? user.name.split(' ').last : user.username,
        :email => user.email,
                           },
                           SiteSetting.thinkific_jwt_auth_token
                          )
      params = {
        :jwt => payload,
        :return_to => "/#{SiteSetting.thinkific_return_to}"
      }
      "#{base_url.chomp('/')}/api/sso/v2/sso/jwt?#{params.to_query}"
    end

    def login(user)
      puts "Calling login"
      cookies[:thinkific_redirect] = SessionControllerExtension.generate_thinkific_url(user)
      super
    end

    def self.valid_url?(url)
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) && !uri.host.nil?
    rescue URI::InvalidURIError
      false
    end
  end

  ::SessionController.prepend SessionControllerExtension if SiteSetting.discourse_thinkific_enabled

end
