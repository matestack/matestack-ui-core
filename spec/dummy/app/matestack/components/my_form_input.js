MatestackUiCore.Vue.component('my-form-input', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formInputMixin],
  data() {
    return {
    };
  },
  methods: {

  },
  mounted: function(){
    flatpickr(this.$el.querySelector('.flatpickr'), {
      defaultDate: this.componentConfig["init_value"],
      enableTime: true
    });
  }
});
