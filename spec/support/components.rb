module Support
  module Components

    def self.specs
      {
        div: {
          tag: "div",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true
        },
        header: {
          tag: "header",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true
        },
        main: {
          tag: "main",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true
        },
        nav: {
          tag: "nav",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true
        },
        section: {
          tag: "section",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true
        },
        pg: {
          tag: "p",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true
        },
        icon: {
          tag: "i",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true
        },
        span: {
          tag: "span",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true
        }
      }
    end

  end
end
