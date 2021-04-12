MatestackUiCore.Vue.component('my-form-select', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formSelectMixin],
  data() {
    return {};
  },
  methods: {
    afterInitialize: function(value){
      $('.select2').val(value).trigger("change");
    }
  },
  mounted: function(){
    const self = this;
    //activate
    $('.select2').select2();

    //handle change event
    $('.select2').on('select2:select', function (e) {
      self.setValue(e.params.data.id)
    });
  }
});
