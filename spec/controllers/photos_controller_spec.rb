# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/InstanceVariable
RSpec.describe PhotosController, type: :controller do
    describe "GET #new" do
        it "redirect to the root if the user isn't signed in" do
            get :new

            expect(response).to redirect_to root_path
        end

        it "render photo upload form" do
            signin_fake_user
            get :new

            expect(response).to render_template(:new)
        end
    end

    describe "POST #upload" do
        before do
            @user = signin_fake_user
        end

        it "redirect if the user didn't upload any files" do
            post :upload, params: { photo: { images: [], title: "test" } }

            expect(response).to redirect_to new_photo_path
            expect(flash[:alert]).to eq(I18n.t("photos.upload.at_least_one"))
        end

        it "upload images" do
            file1 = fixture_file_upload(Rails.root.join('spec/support/images/doggo.jpg'), 'image/jpg')
            file2 = fixture_file_upload(Rails.root.join('spec/support/images/doggo.jpg'), 'image/jpg')
            file3 = fixture_file_upload(Rails.root.join('spec/support/images/doggo.jpg'), 'image/jpg')
            file4 = fixture_file_upload(Rails.root.join('spec/support/images/doggo.jpg'), 'image/jpg')
            file5 = fixture_file_upload(Rails.root.join('spec/support/images/doggo.jpg'), 'image/jpg')

            expect do
                post :upload, params: { photo: { images: [file1, file2, file3, file4, file5],
                                                 visibility: true, title: "test" } }
            end.to change(ActiveStorage::Attachment, :count).by(5)

            @user.reload

            expect(@user.photos.count).to eq(5)
            expect(@user.photos.first.visibility).to be true
            expect(@user.photos.first.title).to eq("test")
            expect(flash[:success]).to eq(I18n.t("photos.upload.success"))
            expect(response).to redirect_to gallery_path
        end

        it "upload images with some failures" do
            file1 = fixture_file_upload(Rails.root.join('spec/support/images/doggo.jpg'), 'image/jpg')
            file2 = fixture_file_upload(Rails.root.join('spec/support/images/doggo.jpg'), 'image/jpg')

            tmp = Photo.new(image: file1, owner: create(:user))
            tmp.save!

            upload_file1 = tmp.image.blob.key

            tmp = Photo.new(image: file2, owner: create(:user))
            tmp.save!

            upload_file2 = tmp.image.blob.key

            # rubocop:disable RSpec/AnyInstance
            allow_any_instance_of(Photo).to receive(:save!).and_return(false)
            # rubocop:enable RSpec/AnyInstance

            expect do
                post :upload, params: { photo: { images: [upload_file1, upload_file2],
                                                 visibility: false, title: "test2" } }
            end.to change(ActiveStorage::Attachment, :count).by(0)

            @user.reload

            expect(@user.photos.count).to eq(0)
            expect(flash[:alert]).to eq(I18n.t("photos.upload.failed"))
            expect(response).to redirect_to gallery_path
        end
    end

    describe "DELETE #delete" do
        before do
            @user = signin_fake_user
        end

        it "redirect if no specified ids" do
            delete :delete

            expect(response).to redirect_to gallery_path
        end

        it "delete if no specified ids" do
            file1 = fixture_file_upload(Rails.root.join('spec/support/images/doggo.jpg'), 'image/jpg')
            file2 = fixture_file_upload(Rails.root.join('spec/support/images/doggo.jpg'), 'image/jpg')

            tmp = Photo.new(image: file1, owner: @user)
            tmp.save!

            upload_file1 = tmp.image.id

            tmp = Photo.new(image: file2, owner: create(:user))
            tmp.save!

            upload_file2 = tmp.image.id

            expect do
                delete :delete, params: { ids: [upload_file1, upload_file2] }
            end.to change(ActiveStorage::Attachment, :count).by(-1)

            expect(@user.photos.count).to eq(0)
            expect(flash[:alert]).to eq(I18n.t("photos.delete.error"))
            expect(response).to redirect_to gallery_path
        end
    end

    describe "POST #search" do
        it "redirect to the gallery" do
            post :search, params: { search_query: "test", visibility: true }

            expect(response).to redirect_to gallery_path(search_query: "test", visibility: true)
        end
    end

    describe "GET #gallery" do
        describe "user not signed in" do
            before do
                other_user = create(:user, username: "abs")
                create(:photo, owner: other_user, title: "abc")
                create(:photo, owner: other_user, title: "abc")
                create(:photo, title: "Test", owner: other_user)
                create(:photo, visibility: true, title: "Test", owner: other_user)
                create(:photo, visibility: true, owner: other_user, title: "abc")
            end

            it "get public photos" do
                get :gallery

                expect(assigns(:photos).count).to eq(2)
                expect(response).to render_template(:gallery)
            end

            it "get public search" do
                get :gallery, params: { search_query: "Test" }

                expect(assigns(:photos).count).to eq(1)
                expect(assigns(:photos).first.title).to eq("Test")
                expect(response).to render_template(:gallery)
            end
        end

        describe "user signed in" do
            before do
                user = signin_fake_user
                other_user = create(:user, username: "shawn")
                create(:photo, owner: user, title: "abc", visibility: true)
                create(:photo, owner: user, title: "Test", visibility: true)
                create(:photo, title: "Test", owner: user)
                create(:photo, visibility: true, title: "Test", owner: other_user)
                create(:photo, title: "Test", owner: other_user)
            end

            it "default query" do
                get :gallery

                expect(assigns(:photos).count).to eq(4)
                expect(response).to render_template(:gallery)
            end

            it "search any visibility query" do
                get :gallery, params: { visibility: "Any" }

                expect(assigns(:photos).count).to eq(4)
                expect(response).to render_template(:gallery)
            end

            it "search private visibility query" do
                get :gallery, params: { visibility: "Private" }

                expect(assigns(:photos).count).to eq(1)
                expect(response).to render_template(:gallery)
            end

            it "search public visibility query" do
                get :gallery, params: { visibility: "Public" }

                expect(assigns(:photos).count).to eq(3)
                expect(response).to render_template(:gallery)
            end

            it "search public visibility and search string query" do
                get :gallery, params: { visibility: "Public", search_query: "Test" }

                expect(assigns(:photos).count).to eq(2)
                expect(response).to render_template(:gallery)
            end
        end
    end

    describe "GET #edit" do
        before do
            @user = signin_fake_user
        end

        it "redirect if doesn't own photo" do
            photo = create(:photo)

            get :edit, params: { id: photo.id }

            expect(response).to redirect_to gallery_path
            expect(flash[:alert]).to eq(I18n.t("photos.ownership.error"))
        end

        it "render edit if the current user owns the photo" do
            photo = create(:photo, owner: @user)

            get :edit, params: { id: photo.id }

            expect(response).to render_template(:edit)
        end
    end

    describe "PATCH #update" do
        before do
            @user = signin_fake_user
        end

        it "updates the photo" do
            photo = create(:photo, owner: @user)

            patch :update, params: { id: photo.id, photo: { title: "test1", visibility: true } }

            photo.reload

            expect(response).to redirect_to gallery_path
            expect(flash[:success]).to eq(I18n.t("photos.edit.success"))
            expect(photo.title).to eq("test1")
            expect(photo.visibility).to be true
        end

        it "faileds to update the photo" do
            photo = create(:photo, owner: @user, title: "Test")

            # rubocop:disable RSpec/AnyInstance
            allow_any_instance_of(Photo).to receive(:update).and_return(false)
            # rubocop:enable RSpec/AnyInstance

            patch :update, params: { id: photo.id, photo: { title: "test", visibility: true } }

            photo.reload

            expect(response).to redirect_to edit_photo_path(id: photo.id)
            expect(flash[:alert]).to eq(I18n.t("photos.edit.error"))
            expect(photo.title).to eq("Test")
            expect(photo.visibility).to be false
        end
    end

    describe "GET #download" do
        it "download photo" do
            photo = create(:photo, visibility: true)

            get :download, params: { id: photo.id }

            expect(response).to redirect_to rails_blob_path(photo.image, disposition: "attachment", host: @request.host)
        end

        it "download private photo" do
            user = signin_fake_user
            photo = create(:photo, owner: user)

            get :download, params: { id: photo.id }

            expect(response).to redirect_to rails_blob_path(photo.image, disposition: "attachment", host: @request.host)
        end

        it "display error" do
            photo = create(:photo)

            get :download, params: { id: photo.id }

            expect(response).to redirect_to gallery_path
            expect(flash[:alert]).to eq(I18n.t("photos.access"))
        end
    end

    describe "GET #show" do
        it "show photo" do
            photo = create(:photo, visibility: true)

            get :show, params: { id: photo.id }

            Rails.application.routes.default_url_options[:host] = 'test.host'
            expect(response).to redirect_to(url_for(photo.image))
        end

        it "display error" do
            get :show, params: { id: 108 }

            expect(response).to redirect_to gallery_path
            expect(flash[:alert]).to eq(I18n.t("photos.access"))
        end
    end

    describe "is_owner?" do
        it "return true if owner" do
            user = signin_fake_user
            photo = create(:photo, owner: user)

            expect(controller.owner?(photo)).to be true
        end

        it "return false if nil" do
            signin_fake_user

            expect(controller.owner?(nil)).to be false
        end

        it "return false if not owner" do
            signin_fake_user
            photo = create(:photo)

            expect(controller.owner?(photo)).to be false
        end
    end
end

# rubocop:enable RSpec/InstanceVariable
