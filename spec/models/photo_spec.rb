# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Photo, type: :model do
    it "scale image to fit within specified size" do
        photo = create(:photo)
        image = photo.scale_image(200, 50)

        expect(image.variation.transformations[:resize_to_limit]).to eq([56, 50])
    end
end
