# frozen_string_literal: true

def signin_fake_user
    user = create(:user)

    @request.session[:user_id] = user.id

    user
end
