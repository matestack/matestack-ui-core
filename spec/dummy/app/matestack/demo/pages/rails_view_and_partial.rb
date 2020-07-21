class Demo::Pages::RailsViewAndPartial < Matestack::Ui::Page

  def response
    paragraph text: 'Rails View Component mit einer View'
    rails_view view: 'demo/header'
    paragraph text: 'Rails View Component mit einem Partial'
    rails_view partial: 'demo/header'
    paragraph text: 'Simple Form in Rails View Component'
    rails_view view: 'demo/simple_form'
  end

end