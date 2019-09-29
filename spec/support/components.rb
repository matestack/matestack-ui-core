module Support
  module Components

    # list of core components is not complete yet
    def self.specs
      {
        div: {
          type: :static, #has no effect yet
          tag: "div",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {} #not tested yet
          },
          block: true,
          optional_dynamics: {
            rerender_on: {
              client_side_event: true,
              websocket_event: true #not tested yet
            }
          }
        },
        header: {
          type: :static,
          tag: "header",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true,
          optional_dynamics: {
            rerender_on: {
              client_side_event: true,
              websocket_event: true
            }
          }
        },
        main: {
          type: :static,
          tag: "main",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true,
          optional_dynamics: {
            rerender_on: {
              client_side_event: true,
              websocket_event: true
            }
          }
        },
        nav: {
          type: :static,
          tag: "nav",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true,
          optional_dynamics: {
            rerender_on: {
              client_side_event: true,
              websocket_event: true
            }
          }
        },
        section: {
          type: :static,
          tag: "section",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true,
          optional_dynamics: {
            rerender_on: {
              client_side_event: true,
              websocket_event: true
            }
          }
        },
        pg: {
          type: :static,
          tag: "p",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true,
          optional_dynamics: {
            rerender_on: {
              client_side_event: true,
              websocket_event: true
            }
          }
        },
        icon: {
          type: :static,
          tag: "i",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true,
          optional_dynamics: {
            rerender_on: {
              client_side_event: true,
              websocket_event: true
            }
          }
        },
        span: {
          type: :static,
          tag: "span",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true,
          optional_dynamics: {
            rerender_on: {
              client_side_event: true,
              websocket_event: true
            }
          }
        },
        q: {
          type: :static,
          tag: "q",
          options: {
            optional: {
              id: :string,
              class: :string,
              attributes: :hash,
            },
            required: {}
          },
          block: true,
          optional_dynamics: {
            rerender_on: {
              client_side_event: true,
              websocket_event: true
            }
          }
        }
      }
    end

  end
end
