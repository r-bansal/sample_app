class UsersController < ApplicationController
  
  def show
	@user = User.find(params[:id])
	@title = @user.name
	#@title = @user.title
  end

  def new
	@title = "Sign up"
  end

end
