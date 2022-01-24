import matestackEventHub from '../../event_hub'
import queryParamsHelper from '../../helpers/query_params_helper'
import componentMixin from '../mixin'
import componentHelpers from '../helpers'

const componentDef = {
  mixins: [componentMixin],
  template: componentHelpers.inlineTemplate,
  data: function(){
    return {
      currentLimit: null,
      currentOffset: null,
      currentFilteredCount: null,
      currentBaseCount: null
    }
  },
  methods: {
    next: function(){
      if (this.currentTo() < this.currentCount()){
        this.currentOffset += this.currentLimit
        var url = queryParamsHelper.updateQueryParams(this.props["id"] + "-offset", this.currentOffset)
        window.history.pushState({matestackApp: true, url: url}, null, url);
        matestackEventHub.$emit(this.props["id"] + "-update")
      }
    },
    previous: function(){
      if ((this.currentOffset - this.currentLimit)*-1 != this.currentLimit){
        if((this.currentOffset - this.currentLimit) < 0){
          this.currentOffset = 0
        } else {
          this.currentOffset -= this.currentLimit
        }
        var url = queryParamsHelper.updateQueryParams(this.props["id"] + "-offset", this.currentOffset)
        window.history.pushState({matestackApp: true, url: url}, null, url);
        matestackEventHub.$emit(this.props["id"] + "-update")
      }
    },
    currentTo: function(){
      var to = parseInt(this.currentOffset) + parseInt(this.currentLimit)
      if (to > parseInt(this.currentCount())){
        return this.currentCount();
      } else {
        return to;
      }
    },
    currentCount: function(){
      if (this.currentFilteredCount != null || this.currentFilteredCount != undefined){
        return this.currentFilteredCount;
      } else {
        return this.currentBaseCount;
      }
    },
    goToPage: function(page){
      this.currentOffset = parseInt(this.currentLimit) * (parseInt(page)-1)
      var url = queryParamsHelper.updateQueryParams(this.props["id"] + "-offset", this.currentOffset)
      window.history.pushState({matestackApp: true, url: url}, null, url);
      matestackEventHub.$emit(this.props["id"] + "-update")
    }
  },
  mounted: function(){
    if(queryParamsHelper.getQueryParam(this.props["id"] + "-offset") != null){
        this.currentOffset = parseInt(queryParamsHelper.getQueryParam(this.props["id"] + "-offset"))
    } else {
      if(this.props["init_offset"] != undefined){
        this.currentOffset = this.props["init_offset"]
      } else {
        this.currentOffset = 0
      }
    }

    if(queryParamsHelper.getQueryParam(this.props["id"] + "-limit") != null){
        this.currentOffset = parseInt(queryParamsHelper.getQueryParam(this.props["id"] + "-limit"))
    } else {
      if(this.props["init_limit"] != undefined){
        this.currentLimit = this.props["init_limit"]
      } else {
        this.currentLimit = 10
      }
    }

    if(this.props["filtered_count"] != undefined){
      this.currentFilteredCount = this.props["filtered_count"]
      if(this.currentOffset >= this.currentFilteredCount){
        this.previous()
      }
    }
    if(this.props["base_count"] != undefined){
      this.currentBaseCount = this.props["base_count"]
      if(this.currentOffset >= this.currentBaseCount){
        this.previous()
      }
    }
  }
}

export default componentDef
