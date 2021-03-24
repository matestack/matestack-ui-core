require 'rails_helper'

describe 'Object Component', type: :feature, js: true do
  include Utils

  it 'Example 1' do
    matestack_render do
      # simple object
      object width: 400, height: 400, data: 'helloworld.swf'
      # enhanced object
      object id: 'my-id', class: 'my-class', width: 400, height: 400, data: 'helloworld.swf'
      # using all attributes
      object id: 'my-id', class: 'my-class', width: 400, height: 400, form: '#my_form', data: 'helloworld.swf', 
        name: 'my_object', type: 'application/vnd.adobe.flash-movie', usemap: '#my_map'
    end

    expect(page).to have_selector("object[width='400'][height='400'][data='helloworld.swf']")
    expect(page).to have_selector("object#my-id.my-class[width='400'][height='400'][data='helloworld.swf']")
    expect(page).to have_selector("object#my-id.my-class[width='400'][height='400'][data='helloworld.swf'][form='#my_form'][name='my_object'][type='application/vnd.adobe.flash-movie'][usemap='#my_map']")
  end

end
