# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResetPasswordMailer, type: :mailer do
    describe "reset_password" do
        let(:user) { create(:user) }
        let(:mail) { described_class.with(user: user).reset_password('http://localhost:3000') }

        it "creates email" do
            expect(mail.subject).to eq(I18n.t("reset_password.subject"))
            expect(mail.to).to eq([user.email])
            expect(mail.from).to eq(["from@example.com"])
        end

        it "contains at hostname" do
            expect(mail.body.encoded).to include('http://localhost:3000')
        end
    end
end
