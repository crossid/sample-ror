class ProtectedApiController < ProtectedController
  def index
    if !has_any_of_scopes? ["profile"]
      render plain: "missing scopes", status: 403
      return
    end
    render plain: "You are logged in"
  end

end