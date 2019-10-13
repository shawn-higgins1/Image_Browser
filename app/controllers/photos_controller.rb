# frozen_string_literal: true

class PhotosController < ApplicationController
    before_action :verify_logged_in, except: [:gallery, :show, :download]
    before_action :verify_ownership, only: [:edit, :update]
    before_action :verify_access, only: [:show, :download]

    def new
        @photo = Photo.new
    end

    def upload
        photo_params = params.require(:photo)
        files = photo_params[:images]

        if files.nil? || files.count.zero?
            flash[:alert] = "You must upload at least one file"
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
        redirect_to gallery_path
    end

    def delete
        return redirect_to gallery_path if params[:ids].nil?

        photos = Photo.where(id: params[:ids], owner: current_user)

        if photos.nil? || photos.count != params[:ids].count
            flash[:alert] = "Some of the files you selected won't be delete because you didn't upload them"
        end

        photos.destroy_all

        redirect_to gallery_path
    end

    def gallery
        @photos = Photo.where(visibility: true)

        @photos = @photos.or(current_user.photos) if current_user
    end

    def edit
    end

    def update
        if @photo.update(photo_params)
            flash[:success] = "Succesfuly edited the photo"
            redirect_to gallery_path
        else
            flash[:alert] = "Failed to edit the photo"
            render :edit
        end
    end

    def download
        redirect_to rails_blob_path(@photo.image, disposition: "attachment")
    end

    def show
        redirect_to url_for(@photo.image)
    end

    def owner?(photo)
        !photo.nil? && photo.owner == current_user
    end
    helper_method :owner?

  private

    def verify_ownership
        @photo = Photo.find_by(id: params[:id] || params[:photo][:id])
        unless owner?(@photo)
            flash[:alert] = "You are unable to edit the selected photo"
            redirect_to gallery_path
        end
    end

    def verify_access
        @photo = Photo.lock.find_by(id: params[:id])

        if @photo.nil? || (!@photo.visibility && @photo.owner != current_user)
            flash[:alert] = "You are unable to access the selected file. The owner may have delete the" \
                            " file or made it private"
            return redirect_to gallery_path
        end
    end

    def photo_params
        params.require(:photo).permit(:title, :visibility)
    end
end
