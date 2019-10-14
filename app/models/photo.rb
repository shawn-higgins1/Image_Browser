# frozen_string_literal: true

class Photo < ApplicationRecord
    belongs_to :owner, class_name: 'User', foreign_key: :user_id, inverse_of: :photos
    has_one_attached :image

    # Scale the image to the lesser of preferred_with or preferred_height
    # Maintaining the current aspect ratio. This requires you have Imagick
    # installed on your server with the ability to handle the image file type
    def scale_image(preferred_width, preferred_height)
        # Retrieve the current height and width
        image_data = ActiveStorage::Analyzer::ImageAnalyzer.new(image).metadata
        new_width = image_data[:width]
        new_height = image_data[:height]

        # Adjust the width
        if new_width > preferred_width
            new_width = preferred_width
            new_height = (new_height * new_width) / image_data[:width]
        end

        # Adjust the height
        if new_height > preferred_height
            old_height = new_height
            new_height = preferred_height
            new_width = (new_width * new_height) / old_height
        end

        # Resive the image
        image.variant(resize_to_limit: [new_width, new_height])
    end
end
