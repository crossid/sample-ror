module Protected
  extend ActiveSupport::Concern
  @@discovery = OpenIDConnect::Discovery::Provider::Config.discover! ENV['ISSUER_BASE_URL']

  included do
    before_action :is_logged_in?
  end

  def is_logged_in?
    render plain: "invalid token", status: 401 unless valid_token?
  end

  def valid_token?
    unless !request.env['HTTP_AUTHORIZATION'].blank? and "Bearer ".in? request.env['HTTP_AUTHORIZATION']
      return false
    end

    token = request.env['HTTP_AUTHORIZATION']
    token["Bearer "] = ""

    @access_token = JSON::JWT.decode(token, @@discovery.jwks)

    if @access_token["exp"].to_i < Time.now.to_i
      return false
    end

    if @access_token["iss"] != ENV['ISSUER_BASE_URL']
      return false
    end

    if @access_token["client_id"] != ENV['CLIENT_ID']
      return false
    end

    return true
  end
end