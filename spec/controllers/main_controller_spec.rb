# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MainController, type: :controller do
    describe "GET #home" do
        it "renders homepage" do
            get :home

            expect(response).to render_template(:home)
        end
    end

    describe "GET #help" do
        it "renders help page" do
            get :help

            expect(response).to render_template(:help)
        end
    end
end
