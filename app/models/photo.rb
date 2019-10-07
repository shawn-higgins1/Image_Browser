# frozen_string_literal: true

class Photo < ApplicationRecord
    belongs_to :owner, class_name: 'User', foreign_key: :user_id
    has_one_attached :image

    def scaleImage(preferredWidth, preferredHeight)
        imageData = ActiveStorage::Analyzer::ImageAnalyzer.new(image).metadata;
        newWidth = imageData[:width]
        newHeight = imageData[:height]

        if(newWidth > preferredWidth)
            newWidth = preferredWidth;
            newHeight = (newHeight * newWidth)/imageData[:width];
        end

        if(newHeight > preferredHeight)
            oldHeight = newHeight;
            newHeight = preferredHeight;
            newWidth = (newWidth * newHeight) / oldHeight;
        end

        image.variant(resize_to_limit: [newWidth, newHeight])
    end        
end
