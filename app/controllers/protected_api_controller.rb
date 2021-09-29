class ProtectedApiController < ProtectedController
  def index
    render plain: 'You are logged in'
  end

end