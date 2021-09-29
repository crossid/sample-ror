class ProtectedController < ActionController::Base
  include Protected

  def has_any_of_scopes?(scopes)
    @access_token["scp"].any? { |scope| scopes.include? scope }
  end

end