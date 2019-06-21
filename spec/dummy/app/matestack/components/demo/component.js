MatestackUiCore.Vue.component('custom-demo-component', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {
      data: []
    };
  },
  methods: {
    callApi() {
      const self = this;
      MatestackUiCore.axios.get("/api/data.json")
      .then((response) => {
        self.data = response.data;
        MatestackUiCore.matestackEventHub.$emit("my_custom_event")
      });
    }
  }
});
