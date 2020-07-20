class LegacyViews::PagesController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper
  include Components::Registry
  include Matestack::Ui::Core::Collection::Helper
  layout 'legacy_views'

  def action_inline
  end
  
  def action_custom_component
  end
  
  def async_custom_component
  end
  
  def async_inline
  end

  def collection_inline
    my_collection_id = "my-first-collection"
    current_filter = get_collection_filter(my_collection_id)
    my_filtered_query = DummyModel.all.where("title LIKE ?", "%#{current_filter[:title]}%")

    @my_collection = set_collection({
      id: my_collection_id,
      data: my_filtered_query
    })
  end

  def collection_custom_component
    my_collection_id = "my-first-collection"
    current_filter = get_collection_filter(my_collection_id)
    my_filtered_query = DummyModel.all.where("title LIKE ?", "%#{current_filter[:title]}%")

    @my_collection = set_collection({
      id: my_collection_id,
      data: my_filtered_query
    })
  end

  def form_custom_component
  end

  def onclick_custom_component
  end

  def success
    render json: params.to_unsafe_h, status: :ok
  end

  def failure
    render json: params.to_unsafe_h, status: :not_found
  end

  def create
    @dummy_model = DummyModel.create(dummy_model_params)
    if @dummy_model.errors.any?
      render json: {
        errors: @dummy_model.errors,
        message: "Test Model could not be saved!"
      }, status: :unprocessable_entity
    else
      render json: {}, status: :created
    end
  end

  private

  def dummy_model_params
    params.require(:dummy_model).permit(
      :title,
      :description
    )
  end

end