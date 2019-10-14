# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
    describe "#get_title" do
        it "returns base title if none is specified" do
            expect(helper.get_title).to eql("Image Browser")
        end

        it "returns appended title if one is specified" do
            expect(helper.get_title("Home")).to eql("Home | Image Browser")
        end
    end

    describe "#current_page" do
        before do
            allow(controller).to receive(:controller_name).and_return('photos')
            allow(controller).to receive(:action_name).and_return('gallery')
        end

        it "returns active for active page" do
            expect(helper.current_page('photos', 'gallery')).to eql("active")
        end

        it "returns nothing for inactive page" do
            expect(helper.current_page('photos', 'upload')).to be(nil)
        end
    end
end
