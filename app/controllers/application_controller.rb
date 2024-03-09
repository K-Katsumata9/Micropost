class ApplicationController < ActionController::Base
    include SessionsHelper

    def logged_in_user?
        if current_user.nil?
          flash[:danger] = 'Please Login!'
          store_location
          redirect_to login_path, status: :see_other
        end
    end
end
