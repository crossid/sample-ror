class LoginController < ActionController::Base

  def initialize
    super()
    init_client
  end

  def init_client        
    @discovery = OpenIDConnect::Discovery::Provider::Config.discover! ENV['ISSUER_BASE_URL']
    @client = OpenIDConnect::Client.new(
        identifier: ENV['CLIENT_ID'],
        secret: ENV['CLIENT_SECRET'],
        redirect_uri: ENV['REDIRECT_URI'],
        authorization_endpoint: @discovery.authorization_endpoint,
        token_endpoint: @discovery.token_endpoint,
        userinfo_endpoint: @discovery.userinfo_endpoint
    )
  end

  def index
  end

  def login_redirect
    nonce = SecureRandom.urlsafe_base64 
    state = SecureRandom.urlsafe_base64 
    
    session['nonce'] = nonce
    session['state'] = state

    redirect_uri = @client.authorization_uri(
      scope: [:profile, :email],
      state: state,
      nonce: nonce
    )

    redirect_to redirect_uri
  end

  def handle_callback

    if params['code'].blank?
      halt 400,  {'Content-Type' => 'text/plain'}, 'missing code'
    end

    if params['state'].blank? or session['state'].blank? or params['state'] != session['state']
      halt 400,  {'Content-Type' => 'text/plain'}, 'bad or mismatching state'
    end
    session.delete('state')

    if session['nonce'].blank?
      halt 400,  {'Content-Type' => 'text/plain'}, 'missing nonce'
    end

    @client.authorization_code = params['code']
    @access_token = @client.access_token!
    @id_token = OpenIDConnect::ResponseObject::IdToken.decode @access_token.id_token, @discovery.jwks

    @id_token.verify!({:nonce => session["nonce"], :issuer => ENV['ISSUER_BASE_URL'], :client_id => ENV['CLIENT_ID'] })  
    @user_info = @access_token.userinfo!
    
    @logout_redirect_url = ENV['REDIRECT_URI'].gsub("/callback", "")
    @logout_url = @discovery.end_session_endpoint + "?id_token_hint=" +  @access_token.id_token.to_s + "&post_logout_redirect_uri=" + @logout_redirect_url

    render "post_login"
    
  end

end