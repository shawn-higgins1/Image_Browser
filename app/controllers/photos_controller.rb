# frozen_string_literal: true

class PhotosController < ApplicationController
    before_action :logged_in?, only: [:upload, :delete, :new]

    def new
    end

    def upload
        photo_params = params.require(:photos)
        files = photo_params[:images]

        if files.count.zero?
            flash[:alert] = "You must upload at east one file"
            return redirect_to new_photo_path
        end

        files.each do |file|
            new_photo = Photo.new(owner: @current_user, visibility: photo_params[:visibility],
                                    title: photo_params[:title], image: file)

            unless new_photo.save!
                flash[:alert] = "" if flash[:alert].nil?
                flash[:alert] += "Failed to upload a file: " + new_photo.errors.full_messages.join(', ')
            end
        end

        flash[:success] = "Successfuly uploaded your photos" if flash[:alert].nil?
        redirect_to show_photos_path
    end

    def delete
    end

    def show
        @photos = Photo.where(visibility: true)

        @photos = @photos.or(current_user.photos) if current_user
    end
end
