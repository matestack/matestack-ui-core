class Pages::MyApp::Collection < Matestack::Ui::Page

  include Matestack::Ui::Core::Collection::Helper

  def prepare
    current_filter = get_collection_filter("my-first-collection")
    current_order = get_collection_order("my-first-collection")

    my_base_query = DummyModel.all

    my_filtered_query = my_base_query
      .where("title LIKE ?", "%#{current_filter[:title]}%")
      .order(current_order)

    @my_collection = set_collection({
      id: "my-first-collection",
      init_limit: 3,
      init_offset: 0,
      data: my_filtered_query,
      filtered_count: my_filtered_query.count,
      base_count: my_base_query.count
    })
  end

  def response
    components {
      heading size: 2, text: "Collection"

      partial :filter
      partial :ordering
      partial :content
    }
  end

  def filter
    partial {
      collection_filter @my_collection.config do

        collection_filter_input key: :title, type: :text, placeholder: "Filter by Title"
        collection_filter_submit do
          button text: "filter"
        end
        collection_filter_reset do
          button text: "reset"
        end

      end
    }
  end

  def ordering
    partial {
      collection_order @my_collection.config do
        plain "sort by: "
        collection_order_toggel key: :title do
          button do
            collection_order_toggel_indicator key: :title, asc: '&#8593;', desc: '&#8595;'
            plain "title"
          end
        end
      end
    }
  end

  def content
    partial {
      collection_content @my_collection.config do
        partial :list
        partial :paginator
      end
    }
  end

  def list
    partial {
      ul do
        @my_collection.paginated_data.each do |dummy|
          li do
            plain dummy.title
            action my_action_config(dummy.id) do
              button text: "delete"
            end
          end
        end
      end
    }
  end

  def paginator
    partial {
      plain "showing #{@my_collection.from} to #{@my_collection.to} of \
       #{@my_collection.filtered_count} from total #{@my_collection.base_count}"

      collection_content_previous do
        button text: "previous"
      end

      @my_collection.pages.each do |page|
        collection_content_page_link page: page do
          button text: page
        end
      end

      collection_content_next do
        button text: "next"
      end
    }
  end

  def my_action_config id
    {
      method: :delete,
      path: :delete_dummy_model_path,
      params:{
        id: id
      },
      success: {
        emit: "my-first-collection-update"
      }
    }
  end

end
