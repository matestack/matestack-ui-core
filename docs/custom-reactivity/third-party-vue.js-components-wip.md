# Third party Vue.js components \[WIP\]

Using a third party Vue.js component based on an example integrating [https://soal.github.io/vue-mapbox/](https://soal.github.io/vue-mapbox/)

{% hint style="danger" %}
Untested!
{% endhint %}

## Ruby Component

```ruby
class Components::MglMap < Matestack::Ui::VueJsComponent

  vue_name "mgl-map-component"

  optional :custom_map_style_hash

  def response
    plain tag.mglmap(":accessToken": "access_token", "mapStyle": "map_style")
  end

  private

    def access_token
      get_global_access_token_from_env
      #...
    end

    def map_style
      some_global_map_style_hash.merge!(context.custom_map_style_hash)
      #...
    end
end
```

## Vue.js Component

```javascript
import Vue from "vue/dist/vue.esm";
import MatestackUiCore from "matestack-ui-core";

import Mapbox from "mapbox-gl";
import { MglMap } from "vue-mapbox";

Vue.component('mgl-map-component', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {
      mapbox: undefined
    };
  },
  created(){
    this.mapbox = Mapbox;
  }
});
```

## Usage

```ruby
class SomePage < Matestack::Ui::Page

  def response
    div class: "some-layout" do
      Components::MglMap.(custom_map_style_hash: { ... })
    end
  end

end
```

