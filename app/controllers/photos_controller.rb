# frozen_string_literal: true

class PhotosController < ApplicationController
    before_action :verify_logged_in, except: [:gallery, :show, :download, :search]
    before_action :verify_ownership, only: [:edit, :update]
    before_action :verify_access, only: [:show, :download]

    # Render the upload form
    def new
        @photo = Photo.new
    end

    # Upload some new photos
    def upload
        images = params[:photo][:images]

        # Check to make sure that the user uploaded at least one image
        if images.nil? || images.count.zero?
            flash[:alert] = I18n.t("photos.upload.at_least_one")
            return redirect_to new_photo_path
        end

        # Create a new photo model for each uploade image
        images.each do |image|
            new_photo = Photo.new(owner: @current_user, visibility: photo_params[:visibility],
                                  title: photo_params[:title], image: image)

            # Notify the user if the save failed
            next if new_photo.save!

            flash[:alert] = I18n.t("photos.upload.failed") if flash[:alert].nil?
            flash[:alert] += new_photo.errors.full_messages.join(', ')
        end

        # Notify the user of a successful upload
        flash[:success] = I18n.t("photos.upload.success") if flash[:alert].nil?
        redirect_to gallery_path
    end

    # Deletes all the photos specified in ids
    def delete
        # Return if the user didn't specify any photos
        return redirect_to gallery_path if params[:ids].nil?

        # Select all the photos with an id in ids and whose owner is the current user
        photos = Photo.where(id: params[:ids], owner: current_user)

        # Notify the user if they attempted to delete someone elses photos
        flash[:alert] = I18n.t("photos.delete.error") if photos.nil? || photos.count != params[:ids].count

        # Delete all the photos. This synchronously remove all the Photo records from the db
        # so they won't show up in the gallery anymore. However, the actual image files
        # are delete asynchronously as that may take a while
        photos.destroy_all

        redirect_to gallery_path
    end

    # Filter the displayed images this needed to be a sperate route
    # as other the page won't reload
    def search
        redirect_to gallery_path(search_params)
    end

    # Display the photos
    def gallery
        @photos = if (search_params[:visibility].nil? || search_params[:visibility] == "Any") &&
                     !current_user.nil?
            # Retrieve both public and private photos
            Photo.joins(:owner).where(visibility: true).or(current_user.photos.joins(:owner))
        elsif search_params[:visibility] == "Private" && !current_user.nil?
            # Retrieve just private photos
            Photo.joins(:owner).where(visibility: false, owner: current_user)
        else
            # Retrieve just public photos
            Photo.joins(:owner).where(visibility: true)
        end

        # If the user specified a search query filter on that as well
        if params[:search_query].present?
            query_string = "title LIKE :search OR users.username LIKE :search"
            search_param = "%#{params[:search_query]}%"
            @photos = @photos.where(query_string, search: search_param)
        end

        # Paginate the results
        @photos = @photos.paginate(page: params[:page]).order(created_at: :desc)

        # Store the search params so the search bar has the correct search fields
        @search_params = search_params
    end

    # Display the photo and metadata for editing
    def edit
    end

    # Update the photo
    def update
        if @photo.update(photo_params)
            flash[:success] = I18n.t("photos.edit.success")
            redirect_to gallery_path
        else
            flash[:alert] = I18n.t("photos.edit.error") + @photo.errors.full_messages.join(', ')
            redirect_to edit_photo_path(id: @photo.id)
        end
    end

    # Download the image
    def download
        redirect_to rails_blob_path(@photo.image, disposition: "attachment")
    end

    # Display the image in the browser
    def show
        redirect_to url_for(@photo.image)
    end

    # Check if the current user owns the photo
    def owner?(photo)
        !photo.nil? && photo.owner == current_user
    end
    helper_method :owner?

  private

    # Redirect to the gallery if the current user doesn't own the specfied
    # photo
    def verify_ownership
        @photo = Photo.find_by(id: params[:id] || params[:photo][:id])

        unless owner?(@photo)
            flash[:alert] = I18n.t("photos.ownership.error")
            redirect_to gallery_path
        end
    end

    # Verify that the current user has acess to specified photo either
    # because it is a public photo or because they own the photo
    def verify_access
        @photo = Photo.lock.find_by(id: params[:id])

        if @photo.nil? || (!@photo.visibility && @photo.owner != current_user)
            flash[:alert] = I18n.t("photos.access")
            redirect_to gallery_path
        end
    end

    def photo_params
        params.require(:photo).permit(:title, :visibility)
    end

    def search_params
        params.permit(:search_query, :visibility)
    end
end
